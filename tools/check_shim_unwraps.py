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
    print("%d shim offender(s), %d direct declaration(s), %d whitelisted raw param(s)"
          % (len(offenders), len(direct), whitelisted))
    return 1 if (offenders or direct) else 0


if __name__ == "__main__":
    sys.exit(main())
