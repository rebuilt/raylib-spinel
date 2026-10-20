#!/usr/bin/env python3
"""Audit the adapter shims: every handle-class parameter must be unwrapped.

The Ruby surface passes handle views (rl_<X> * GC objects) to the rl_* shims;
each shim must convert the view to the raylib payload with RL_<C>(o) (or the
equivalent raw cast for the GC-struct classes). A shim that forwards the view
pointer unchanged hands raylib a struct whose first bytes are cls_id/p instead
of the payload -- silent garbage, usually a segfault inside raylib.

The check is positional: a shim's i-th parameter is matched with the API
function's i-th parameter (by name first, then by position).

Usage: python3 tools/check_shim_unwraps.py
Exit status: 0 when clean, 1 when offenders were found.
"""

import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, "lib")
API_DIR = os.path.join(os.path.dirname(ROOT), "raylib-bindings", "generator")

API_FILES = ["raylib_api.json", "raymath_api.json", "physac_api.json",
             "rcamera_api.json", "rlgl_api.json", "raygui_api.json"]
ADAPTERS = ["raylib_adapter.c", "raymath_adapter.c", "rlgl_adapter.c",
            "physac_adapter.c", "rcamera_adapter.c", "raygui_adapter.c"]

# API type -> unwrap macro used by the shims
CLASSES = {
    "Image": "RL_IMG", "Texture2D": "RL_TEX", "Texture": "RL_TEX",
    "TextureCubemap": "RL_TEX", "RenderTexture": "RL_RT",
    "RenderTexture2D": "RL_RT", "Font": "RL_FONT", "GlyphInfo": "RL_GLYPH",
    "Model": "RL_MODEL", "Material": "RL_MAT", "Mesh": "RL_MESH",
    "Shader": "RL_SHDR", "ModelAnimation": "RL_ANIM", "BoneInfo": "RL_BONE",
    "AutomationEvent": "RL_AEVENT", "AutomationEventList": "RL_AEVLIST",
    "Transform": "RL_TRANSFORM", "Rectangle": "RL_RECT",
    "Vector2": "RL_V2", "Vector3": "RL_V3", "Vector4": "RL_V4",
    "Color": "RL_COLOR", "Camera": "RL_CAMERA", "Camera3D": "RL_CAMERA",
    "Camera2D": "RL_CAM2D", "BoundingBox": "RL_BB", "Ray": "RL_RAY",
    "RayCollision": "RL_RAYCOL", "Matrix": "RL_MATRIX",
    "NPatchInfo": "RL_NPATCH", "VrDeviceInfo": "RL_VRDEV",
    "VrStereoConfig": "RL_VRCFG", "FilePathList": "RL_DIRLIST",
    "PhysicsBody": "RL_PBODY", "PhysicsBodyData": "RL_PBODY",
}

# a shim whose parameter is one of these types is intentionally raw
RAW_OK = {"void", "char", "unsigned char", "float", "double", "int",
          "unsigned int", "long", "size_t", "bool", "rlRenderBatch",
          "ModelAnimPose", "MaterialMap", "RL_V2", "RL_V3"}

# handle-typed parameters the Ruby side deliberately passes as raw pointers:
# flat buffers / FFI arrays (points, colors, transforms), pointer typedefs
# (physac PhysicsBody) and the P3 array cases (glyphs, glyphRecs). Anything
# else with a handle type must be unwrapped.
RAW_BY_DESIGN = {
    "UnloadImageColors": {"colors"}, "UnloadImagePalette": {"colors"},
    "SetWindowIcons": {"images"}, "UnloadModelAnimations": {"animations"},
    "UnloadFontData": {"glyphs"},
    "GenImageFontAtlas": {"glyphs", "glyphRecs"},
    "DrawLineStrip": {"points"}, "DrawTriangleFan": {"points"},
    "DrawTriangleStrip": {"points"}, "DrawTriangleStrip3D": {"points"},
    "DrawSplineLinear": {"points"}, "DrawSplineBasis": {"points"},
    "DrawSplineCatmullRom": {"points"},
    "DrawSplineBezierQuadratic": {"points"},
    "DrawSplineBezierCubic": {"points"},
    "CheckCollisionPointPoly": {"points"},
    "ImageDrawLineStrip": {"points"}, "ImageDrawTriangleFan": {"points"},
    "ImageDrawTriangleStrip": {"points"},
    "DrawMeshInstanced": {"transforms"},
    "DestroyPhysicsBody": {"body"}, "PhysicsAddTorque": {"body"},
    "PhysicsShatter": {"body"}, "SetPhysicsBodyRotation": {"body"},
    # raygui color params arrive as the Color payload from Raylib.color_addr
    # (raygui_adapter.c's rl_Color mirror has no p/owner to unwrap).
    "GuiColorPicker": {"color"}, "GuiDrawIcon": {"color"},
}

DEF_RE = re.compile(r"^(?:void|int|float|double|bool|char|size_t|unsigned [a-z]+|"
                    r"[A-Za-z_]\w*(?: \w+)? \*?)\s*rl_(\w+)\(([^)]*)\)\s*\{$")


def base_type(t):
    return t.replace("const ", "").replace("*", "").strip()


def load_functions():
    out = {}
    for fname in API_FILES:
        path = os.path.join(API_DIR, fname)
        if not os.path.exists(path):
            continue
        data = json.load(open(path))
        fns = data["functions"] if isinstance(data, dict) else data
        for fn in fns:
            out.setdefault(fn["name"], []).append(fn)
    return out


def shims():
    """[(adapter, lineno, name, [param names], body lines)]"""
    out = []
    for fname in ADAPTERS:
        path = os.path.join(LIB, fname)
        if not os.path.exists(path):
            continue
        lines = open(path).read().split("\n")
        i = 0
        while i < len(lines):
            m = DEF_RE.match(lines[i])
            if not m:
                i += 1
                continue
            name, raw = m.group(1), m.group(2)
            params = [p.strip().split()[-1].lstrip("*") for p in raw.split(",") if p.strip()]
            body, j = [], i + 1
            while j < len(lines) and lines[j] != "}":
                body.append(lines[j])
                j += 1
            out.append((fname, i + 1, name, params, body))
            i = j + 1
    return out


DECL_RE = re.compile(r"^\s*ffi_func :(\w+), \[([^\]]*)\]|"
                     r"^\s*ffi_func :(\w+), %i\[([^\]]*)\]")
FFI = os.path.join(LIB, "raylib_ffi.rb")


def check_direct_decls(funcs):
    """Direct (non-shim) ffi decls must not take handle parameters.

    A `ffi_func :ImageFormat, [:ptr, :int]` binds raylib directly, so the
    Ruby-side view pointer reaches raylib without unwrapping.
    """
    bad = []
    for lineno, line in enumerate(open(FFI).read().split("\n"), 1):
        m = DECL_RE.match(line)
        if not m:
            continue
        name = m.group(1) or m.group(3)
        raw = m.group(2) if m.group(1) else m.group(4)
        if name.startswith("rl_"):
            continue
        fn = funcs.get(name)
        if not fn:
            continue
        slots = ([s for s in raw.split(",") if s.strip()] if m.group(1)
                 else raw.split())
        for fn in funcs.get(name, []):
            params = fn.get("params", [])
            if len(slots) != len(params):
                continue
            for p in params:
                base = base_type(p.get("type", ""))
                if base not in CLASSES or base in RAW_OK:
                    continue
                if p["name"] in RAW_BY_DESIGN.get(name, ()):
                    continue
                bad.append((lineno, name, p["name"], p["type"]))
            break
    return bad


def check_defined(funcs):
    """Every ffi_func the Ruby surface declares must have a C definition."""
    declared = set()
    for fname in ("raylib_ffi.rb", "raymath_ffi.rb", "rlgl_ffi.rb",
                  "physac_ffi.rb", "rcamera_ffi.rb", "raygui_ffi.rb",
                  "raylib_handles_ffi.rb"):
        path = os.path.join(LIB, fname)
        if not os.path.exists(path):
            continue
        text = open(path).read()
        declared.update(re.findall(r"ffi_func :(rl_\w+)", text))
        # native_method declarations name a C accessor too
        declared.update(re.findall(r'native_method :[\w=]+, \[[^\]]*\], :\w+, "(rl_\w+)"', text))
    defined = set()
    for fname in ADAPTERS + ["raygui_impl.c", "physac_impl.c"]:
        path = os.path.join(LIB, fname)
        if not os.path.exists(path):
            continue
        # definition shape: a line starting with the return type, then rl_<name>(
        # possibly with the signature continued on following lines (re.S), up to
        # the opening brace. Calls cannot match (they end in `;`, not `{`).
        text = open(path).read()
        defined.update(re.findall(
            r"^[A-Za-z_][\w \t\*]*?\b(rl_\w+)\s*\([^;{}]*\)\s*\{",
            text, re.M))
    return sorted(declared - defined)


# A `native_method` returning :ptr hands the *box* when its value is passed
# into a :ptr slot (matz/spinel box semantics); only a native-class instance is
# handed over as its struct address. That trap cost four segfaults once
# (Camera#pointer). These are known and unused; a new one is worth a look.
PTR_NATIVE_METHOD_ALLOW = {"texture_ptr", "depth_ptr", "recv_ptr", "position_ptr",
                           "target_ptr", "up_ptr", "min_ptr", "max_ptr", "t_ptr",
                           "r_ptr", "s_ptr", "image_ptr", "shader_ptr",
                           "bone_ptr", "material_ptr", "mesh_ptr", "frame_ptr", "offset_ptr",
                           "pose_bone_ptr", "frame_pose_ptr"}


def check_ptr_native_methods():
    """native_method declarations returning :ptr, minus the known allowlist."""
    out = []
    for fname in sorted(os.listdir(LIB)):
        if not fname.endswith("_ffi.rb") and fname != "raylib_handles_ffi.rb":
            continue
        path = os.path.join(LIB, fname)
        for i, line in enumerate(open(path).read().split("\n"), 1):
            m = re.match(r"\s*native_method :(\w+), \[[^\]]*\], :ptr,", line)
            if m and m.group(1) not in PTR_NATIVE_METHOD_ALLOW:
                out.append((fname, i, m.group(1)))
    return out


def main():
    funcs = load_functions()
    offenders, checked = [], 0
    whitelisted = 0
    for adapter, lineno, name, params, body in shims():
        cands = funcs.get(name)
        if not cands:
            continue
        text = "\n".join(body)
        fn = None
        for c in cands:
            if len(c.get("params", [])) == len(params):
                fn = c
                break
        if fn is None:
            continue
        checked += 1
        for i, p in enumerate(params):
            api = fn["params"][i]
            t, a_name = api.get("type", ""), api.get("name", "")
            macro = CLASSES.get(base_type(t))
            if not macro or base_type(t) in RAW_OK:
                continue
            if p in RAW_BY_DESIGN.get(name, ()):
                whitelisted += 1
                continue
            # unwrap present if the body mentions the macro (or a raw cast) with the parameter
            if re.search(r"%s\s*\(\s*%s\s*\)" % (macro, re.escape(p)), text):
                continue
            if re.search(r"\(\(\s*rl_\w+\s*\*\)\s*%s\s*\)->" % re.escape(p), text):
                continue  # raw cast to the view struct (GC-struct style)
            if re.search(r"\b%s\s*->[vp]\b" % re.escape(p), text):
                continue  # already a typed view pointer
            if re.search(r"%s\s*=\s*%s" % (re.escape(p), re.escape(a_name)), text):
                continue
            offenders.append((adapter, lineno, name, p, t, text.strip().split("\n")[-1].strip()))

    print("checked %d shims against the API" % checked)
    for adapter, lineno, name, p, t, call in offenders:
        print("%s:%d  rl_%s: param `%s` (%s) not unwrapped\n    %s"
              % (adapter, lineno, name, p, t, call))
    direct = check_direct_decls(funcs)
    for lineno, name, p, t in direct:
        print("raylib_ffi.rb:%d  ffi_func :%s: param `%s` (%s) bypasses the shim\n"
              "    bind rl_%s and unwrap with the macro for this class"
              % (lineno, name, p, t, name))
    missing = check_defined(funcs)
    for name in missing:
        print("ffi_func :%s is declared but has no C definition (link error)" % name)
    traps = check_ptr_native_methods()
    for fname, lineno, name in traps:
        print("%s:%d  native_method :%s returns :ptr -- passing its value into a "
              ":ptr slot hands the box, not the view (use a plain Ruby method "
              "returning the view, or add it to the allowlist with a comment)"
              % (fname, lineno, name))
    print("%d shim offender(s), %d direct declaration(s), %d undefined symbol(s), "
          "%d whitelisted raw param(s), %d new :ptr native_method(s)"
          % (len(offenders), len(direct), len(missing), whitelisted, len(traps)))
    return 1 if (offenders or direct or missing or traps) else 0


if __name__ == "__main__":
    sys.exit(main())
