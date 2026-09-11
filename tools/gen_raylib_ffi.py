#!/usr/bin/env python3
"""Regenerate the raylib FFI glue from raylib's rlparser API JSON.

Reads three inputs:
    api_dir/raylib_api.json   (default: ~/workspace/c/raylib/.../rlparser/output)
    lib/raylib_ffi.rb         (existing hand-written surface, kept, de-duped)
    lib/raylib_adapter.c      (existing hand-written shims, kept, de-duped)

Rewrites lib/raylib_ffi.rb + lib/raylib_adapter.c by appending a generated
section. Existing declarations / wrappers / constants / sp_ symbols are never
duplicated.

Conventions shared with the hand-written layer:
  * flat signatures (scalar / string / opaque-pointer params and returns) are
    declared `ffi_func :Name, [...], ret` straight against libraylib;
  * by-value struct params / returns go through compiled `sp_Name` shims
    (Spinel FFI cannot pass or return C structs by value);
  * opaque resource structs (Texture2D, Image, Font, Sound, Music, Wave, Mesh,
    Model, Shader, Material, AudioStream, RenderTexture2D, GlyphInfo, ...) and
    Vector2 are malloc'd raw pointers: producers heap-return a `:ptr` handle,
    consumer shims deref `*(Kind*)ptr`;
  * geometric value structs (Vector3, Color, Camera3D, Vector4, Rectangle,
    Camera2D, BoundingBox, Ray, RayCollision, Matrix, NPatchInfo, ...) are
    native GC objects embedding the raylib struct past the sp_int header;
    shims access `->v` / `->c`; by-value returns write a trailing out-param the
    Ruby wrapper allocates;
  * bool-returning functions stay `:bool` so the extern is `_Bool`.

Run:  python3 tools/gen_raylib_ffi.py [api_dir]
"""

import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, "lib")
FFI_PATH = os.path.join(LIB, "raylib_ffi.rb")
ADAPTER_PATH = os.path.join(LIB, "raylib_adapter.c")
# Library the bindings are generated against. Only raylib 6.x is supported;
# a pre-6.x lib makes the symbol gate below abort generation. Override with
# RAYLIB_LIB (e.g. a shared lib built from the raylib source tree).
RAYLIB_LIB = os.environ.get("RAYLIB_LIB", "/usr/local/lib/libraylib.so")
if len(sys.argv) > 1:
    API_PATH = os.path.join(sys.argv[1], "raylib_api.json")
else:
    API_PATH = ("/home/nelson/workspace/c/raylib/raylib/tools/"
                "rlparser/output/raylib_api.json")

# ------------------------------------------------------------------ tables --

# Opaque handle structs: heap-allocated raw pointers, shims deref *(Kind*)p.
RAW_STRUCTS = {
    "Vector2", "Texture", "Texture2D", "TextureCubemap", "RenderTexture",
    "RenderTexture2D", "Image", "Font", "Mesh", "Model", "Shader", "Material",
    "Sound", "Music", "Wave", "AudioStream", "GlyphInfo", "ModelAnimation",
    "MaterialMap", "Transform", "BoneInfo", "ModelSkeleton", "rAudioBuffer",
    "rAudioProcessor", "VideoMode",
}

# Geometric value structs embedded in a native GC object.
#   kind -> (Ruby class, embedded C member)
GC_STRUCTS = {
    "Vector3": ("Vector3", "v"),
    "Color": ("Color", "c"),
    "Camera3D": ("Camera", "c"),
    "Camera": ("Camera", "c"),
    "Vector4": ("Vector4", "v"),
    "Quaternion": ("Vector4", "v"),
    "Rectangle": ("Rectangle", "v"),
    "Camera2D": ("Camera2D", "v"),
    "BoundingBox": ("BoundingBox", "v"),
    "Ray": ("Ray", "v"),
    "RayCollision": ("RayCollision", "v"),
    "Matrix": ("Matrix", "v"),
    "NPatchInfo": ("NPatchInfo", "v"),
    "VrDeviceInfo": ("VrDeviceInfo", "v"),
    "VrStereoConfig": ("VrStereoConfig", "v"),
    "FilePathList": ("FilePathList", "v"),
    "AutomationEvent": ("AutomationEvent", "v"),
    "AutomationEventList": ("AutomationEventList", "v"),
}

CALLBACKS = {
    "TraceLogCallback", "AudioCallback", "LoadFileDataCallback",
    "SaveFileDataCallback", "LoadFileTextCallback", "SaveFileTextCallback",
}

# By-value structs returned by shims that must NOT go through the raw heap
# path. Vector2 is ABI-packed and its result is useless when returned as an
# opaque pointer; materialize a GC Vector2 via out-param instead. Params of
# type Vector2 stay raw (Vector2Create hands out a plain Vector2*).
GC_RETURN_ONLY = {
    "Vector2": ("Vector2", "v"),
}

SCALAR_TOK = {
    "int": ":int", "unsigned int": ":uint", "float": ":float",
    "double": ":double", "long": ":long", "bool": ":bool",
    "char": ":char", "unsigned char": ":uchar",
}

PTR_TOK = {
    "const char *": ":str", "char *": ":str",
    "unsigned char *": ":ptr", "const unsigned char *": ":ptr",
    "void *": ":ptr", "const void *": ":ptr",
    "int *": ":ptr", "const int *": ":ptr", "float *": ":ptr",
    "const float *": ":ptr", "double *": ":ptr", "long *": ":ptr",
    "unsigned int *": ":ptr", "const unsigned int *": ":ptr",
    "char **": ":ptr", "const char **": ":ptr",
}

# native_method field accessor mapping: ffi token, C type.
FIELD_TOK = {
    "float": (":float", "double"),
    "int": (":int", "int"),
    "unsigned int": (":int", "int"),
    "bool": (":int", "int"),
    "unsigned char": (":int", "int"),
}


RKEYWORDS = set("""alias and begin break case class def defined? do else elsif end ensure
                false for if in module next nil not or redo rescue retry return self super
                then true undef unless until when while yield""".split())


def rname(n):
    if n in RKEYWORDS:
        return "kw_%s" % n
    return n


def strip_array(t):
    return re.sub(r"\[\d+\]", "", t).strip()


# 6.x-only entry points. If the library we scan predates raylib 6 it won't
# export these, and generation must refuse instead of silently truncating the
# binding to whatever subset a 4.x lib happened to ship.
V6_SENTINELS = ("IsMusicValid", "ColorIsEqual", "FileRename")


def installed_raylib_symbols():
    """Symbols exported by the library at RAYLIB_LIB (shared or static).

    Shared libs are scanned with `nm -D`; static archives (whose object
    members are only pulled in at link time) are scanned with `nm -g`. Returns
    None when the library cannot be inspected (filtering disabled)."""
    import subprocess
    path = RAYLIB_LIB
    for args, is_shared in ((["nm", "-D", "--defined-only", path], True),
                            (["nm", "-g", "--defined-only", path], False)):
        try:
            out = subprocess.check_output(args, text=True, stderr=subprocess.DEVNULL)
        except Exception:
            continue
        syms = set()
        for line in out.splitlines():
            p = line.split()
            if len(p) == 3 and p[2].isascii():
                syms.add(p[2])
        return syms
    return None


def base_of(t):
    t = strip_array(t)
    if t.endswith("*"):
        t = t[:-1].strip()
    return t


def is_ptr(t):
    return strip_array(t).endswith("*")


def ffi_flat(t):
    t = strip_array(t).strip()
    if t in SCALAR_TOK:
        return SCALAR_TOK[t]
    if t in PTR_TOK:
        return PTR_TOK[t]
    if t.endswith("*"):
        return ":ptr"
    if t == "void":
        return ":void"
    return None


def ffi_c_type(tok):
    return {
        ":int": "int", ":uint": "uint32_t", ":float": "float",
        ":double": "double", ":long": "long", ":bool": "_Bool",
        ":char": "int8_t", ":uchar": "uint8_t", ":str": "const char *",
        ":ptr": "void *", ":void": "void",
    }.get(tok, "void *")


def san(name):
    n = re.sub(r"[^A-Za-z0-9_]", "_", name or "")
    if n and n[0].isdigit():
        n = "p" + n
    return n or "p"


def gc_of(base):
    return GC_STRUCTS.get(base) or GC_RETURN_ONLY.get(base)


def is_opaque(base):
    return base in RAW_STRUCTS


# ------------------------------------------------------------------ inputs --

api = json.load(open(API_PATH))
struct_fields = {s["name"]: s["fields"] for s in api["structs"]}


def existing_set(pattern, path, lst=False):
    found = set(re.findall(pattern, open(path).read()))
    return found


effi = existing_set(r"ffi_func\s+:(\w+)", FFI_PATH)
enative = existing_set(r'native_struct\s+"(\w+)"', FFI_PATH)
enmethod = existing_set(r'native_method\s+:[:A-Za-z0-9_]*,\s*\[[^\]]*\],\s*:[A-Za-z0-9_]*,\s*"(sp_[A-Za-z0-9_]+)"',
                        FFI_PATH)
ewrap = existing_set(r"def self\.(\w+)", FFI_PATH)
econst = existing_set(r"(?m)^[ \t]*([A-Z][A-Z0-9_]*)\s*=[ \t]", FFI_PATH, True)
esp = existing_set(r"\bsp_[A-Za-z0-9_]+", ADAPTER_PATH)


def classify_param(t):
    """Return a (kind, ...) tuple. Inside shims, kinds carry unwrap data."""
    base = base_of(t)
    if not is_ptr(t):
        if base in GC_STRUCTS:
            return ("gc", base, gc_of(base)[0], gc_of(base)[1])
        if base in CALLBACKS:
            return ("cb", base)
        if base in RAW_STRUCTS:
            return ("raw", base)
    if base in GC_STRUCTS and is_ptr(t):
        return ("gcp", base, gc_of(base)[0], gc_of(base)[1])
    tok = ffi_flat(t)
    if tok:
        return ("flat", tok)
    return ("raw", base)


def func_needs_shim(fn):
    for _, t in fn.args:
        if classify_param(t)[0] != "flat":
            return True
    if is_ptr(fn.ret):
        return False
    base = base_of(fn.ret)
    return base in GC_STRUCTS or base in RAW_STRUCTS


# ------------------------------------------------------------------ emit --

# FFI arg retype overrides keyed by fn name -> arg name -> spec. UpdateAudioStream's
# sample buffer is `void *` in raylib, but under Spinel AOT a Ruby String must go
# into a `:str` slot (`:ptr` args reject Strings); raylib only reads `frameCount`
# short values past the pointer, so embedded NULs in the packed buffer are fine.
ARG_OVERRIDES = {
    "UpdateAudioStream": {"data": ":str"},
}


report = {"direct": 0, "shim": 0, "out": 0, "heap_in_shim": 0,
          "dup_name": 0, "dup_sp": 0, "varargs": [], "new_gc": [],
          "not_in_installed": []}
raylib_syms = installed_raylib_symbols()

if raylib_syms is not None:
    missing = [s for s in V6_SENTINELS if s not in raylib_syms]
    if missing:
        raise SystemExit(
            "raylib < 6.x detected at %s (missing %s). Only raylib 6.x is "
            "supported; install a 6.x dev build (see the raylib source tree "
            "README) or point RAYLIB_LIB at one." % (RAYLIB_LIB, ", ".join(missing)))

gen_ffi = []          # module-top ffi_func / native_* lines
gen_c = []            # GC struct typedefs (must precede the shims that use them)
gen_shim_c = []       # adapter shim functions
gen_wrap = []         # wrappers (inside Spinel guard)


def shim_expr(kind, aname, base=None):
    if kind == "gc":
        klass, emb = gc_of(base)
        return "((sp_%s*)%s)->%s" % (klass, aname, emb)
    if kind == "gcp":
        klass, emb = gc_of(base)
        return "&((sp_%s*)%s)->%s" % (klass, aname, emb)
    if kind == "raw":
        return "*(%s *)%s" % (base, aname)
    if kind == "cb":
        return "(%s)%s" % (base, aname)
    raise ValueError(kind)


def emit_flat(fn):
    global effi
    if fn.name in effi:
        report["dup_name"] += 1
        return
    effi.add(fn.name)
    args = ", ".join(classify_param(t)[1] for _, t in fn.args)
    gen_ffi.append("  ffi_func :%s, [%s], %s\n" % (fn.name, args, ffi_flat(fn.ret)))
    report["direct"] += 1


def emit_shim(fn):
    global esp, effi
    if fn.name in effi:
        report["dup_name"] += 1
        return
    sp = "sp_" + fn.name
    if sp in esp:
        report["dup_sp"] += 1
        return
    effi.add(fn.name)
    esp.add(sp)

    c_params = []      # (c_type, c_name)
    ffi_args = []
    call_exprs = []
    wrapper_args = []

    for aname, t in fn.args:
        kind = classify_param(t)
        if kind[0] == "flat":
            c_params.append((ffi_c_type(kind[1]), aname))
            ffi_args.append(ARG_OVERRIDES.get(fn.name, {}).get(aname, kind[1]))
            call_exprs.append(aname)
        else:
            c_params.append(("void *", aname))
            ffi_args.append(":ptr")
            call_exprs.append(shim_expr(kind[0], aname, kind[1]))
        wrapper_args.append(rname(aname))

    ret = fn.ret
    out_class = None
    c_ret = "void"
    ffi_ret = ":void"
    ret_base = base_of(ret)
    ptr_return = False

    if is_ptr(ret):
        # raylib function already returns a pointer: pass it through directly.
        c_ret, ffi_ret = "void *", ":ptr"
        ptr_return = True
    elif ret == "void":
        pass
    elif ret_base in GC_STRUCTS:
        klass, emb = gc_of(ret_base)
        if out_class is None:
            out_class = klass
        c_params.append(("void *", "_out"))
        ffi_args.append(":ptr")
        wrapper_args.append(None)       # synthesized in wrappers
        report["out"] += 1
    elif ret_base in RAW_STRUCTS:
        # By-value struct returned: shim malloc's a heap copy, Ruby owns it.
        if ret == "Vector2":
            # Vector2 is ABI-packed; a raw heap copy is unreadable. Materialize
            # a GC Vector2 (out-param) like the other value structs.
            klass, embv = gc_of(ret_base)
            out_class = klass
            c_params.append(("void *", "_out"))
            ffi_args.append(":ptr")
            wrapper_args.append(None)       # synthesized in wrappers
            report["out"] += 1
        else:
            c_ret, ffi_ret = "void *", ":ptr"
            report["heap_in_shim"] += 1
            heap_ret = True
    elif ret_base in SCALAR_TOK:
        ffl = ffi_flat(ret)
        c_ret, ffi_ret = ffi_c_type(ffl), ffl
    else:
        raise SystemExit("unhandled return %r in %s" % (ret, fn.name))

    sig = ", ".join("%s %s" % (ct, cn) for ct, cn in c_params) or "void"
    call_args = ", ".join(call_exprs)
    ret_expr = "%s(%s)" % (fn.name, call_args)

    body_lines = []
    if ptr_return:
        # Function returns a pointer already (char*, unsigned char*, Color*,
        # float*, ...): hand it straight across the FFI boundary.
        body_lines.append("  return %s;" % ret_expr)
    elif out_class is not None:
        klass, emb = gc_of(ret_base)
        body_lines.append("  ((sp_%s*)_out)->%s = %s;" % (klass, emb, ret_expr))
        c_ret = "void"
        ffi_ret = ":void"
    elif c_ret == "void *":
        # By-value raw struct returned: heap-copy it for Ruby (matching
        # Unload<Kind> frees the copy, see below).
        body_lines.append("  %s *r = (%s *)malloc(sizeof(%s));"
                          % (ret_base, ret_base, ret_base))
        body_lines.append("  *r = %s;" % ret_expr)
        body_lines.append("  return r;")
    else:
        # Unload<Kind>(Kind): release both the raylib resource and the heap
        # copy produced by the matching Load<Kind> shim, like sp_UnloadTexture.
        m = re.fullmatch(r"Unload(\w+)", fn.name)
        if m and len(fn.args) == 1 and ret_base == "void" \
                and base_of(fn.args[0][1]) == m.group(1) \
                and m.group(1) in RAW_STRUCTS:
            arg = fn.args[0][0]
            body_lines.append("  %s *self = (%s *)%s;" % (m.group(1), m.group(1), arg))
            body_lines.append("  Unload%s(*self);" % m.group(1))
            body_lines.append("  free(self);")
        elif c_ret == "void":
            body_lines.append("  %s;" % ret_expr)
        else:
            body_lines.append("  return %s;" % ret_expr)

    gen_shim_c.append("/** %s(params: %s -> %s) */\n%s sp_%s(%s) {\n%s\n}\n" %
                 (fn.name, sig, c_ret, c_ret, fn.name, sig,
                  "\n".join(body_lines)))
    gen_ffi.append("  ffi_func :%s, [%s], %s\n" % (sp, ", ".join(ffi_args), ffi_ret))

    if out_class is not None:
        gen_wrap.append(wrapper_out(fn, wrapper_args, out_class))
    else:
        gen_wrap.append(wrapper_simple(fn, wrapper_args))
    report["shim"] += 1


def wrapper_simple(fn, wrapper_args):
    name = fn.name
    if name in ewrap:
        return ""
    ewrap.add(name)
    a = ", ".join(wa for wa in wrapper_args if wa is not None)
    return ("    def self.%s(%s)\n      Raylib.sp_%s(%s)\n    end\n"
            % (name, a, name, a))


def wrapper_out(fn, wrapper_args, out_class):
    name = fn.name
    if name in ewrap:
        return ""
    ewrap.add(name)
    a = ", ".join(wa for wa in wrapper_args if wa is not None)
    fwd = (a + ", _out") if a else "_out"
    return ("    def self.%s(%s)\n      _out = %s.new\n"
            "      Raylib.sp_%s(%s)\n      _out\n    end\n"
            % (name, a, out_class, name, fwd))


# ------------------------------------------------------------------ scan --

for j in api["functions"]:
    name = j["name"]
    args = [(p["name"], p["type"].strip()) for p in j.get("params", [])]
    fn = type("Fn", (), {
        "name": name,
        "args": [(san(a), t) for a, t in args],
        "ret": j.get("returnType", "void").strip(),
    })()
    if any(t == "..." for _, t in args):
        report["varargs"].append(name)
        continue
    if raylib_syms is not None and name not in raylib_syms:
        report["not_in_installed"].append(name)
        continue
    if func_needs_shim(fn):
        emit_shim(fn)
    else:
        emit_flat(fn)

# ------------------------------------------------------------------ structs --

new_gc = []
seen_klass = set()
for base, (klass, emb) in list(GC_STRUCTS.items()) + list(GC_RETURN_ONLY.items()):
    if klass in enative or base in enative:
        continue                  # Vector3 / Color / Camera exist (hand-written)
    if klass in seen_klass:
        continue                  # Quaternion is Vector4 (alias)
    seen_klass.add(klass)
    new_gc.append((base, klass, emb))
report["new_gc"] = new_gc

for base, klass, emb in new_gc:
    fields = struct_fields.get(base, [])
    gen_c.append("\n/* sp_%s — GC-embedded %s (see raylib_ffi.rb) */" % (klass, base))
    gen_c.append("typedef struct sp_%s_s {\n  sp_int cls_id;\n  %s %s;\n} sp_%s;\n"
                 % (klass, base, emb, klass))
    gen_c.append("static void sp_%s_scan(void *p) { (void)p; }\n" % klass)
    init = "  self->%s = (%s){ 0 };\n" % (emb, base)
    gen_c.append("sp_%s *sp_%s_new(sp_int cls_id) {\n"
                 "  sp_%s *self = (sp_%s *)sp_gc_alloc(sizeof(sp_%s), NULL, sp_%s_scan);\n"
                 "  self->cls_id = cls_id;\n%s  return self;\n}\n"
                 % (klass, klass, klass, klass, klass, klass, init))
    gen_ffi.append(f'  native_struct "{klass}", "sp_{klass}"\n')
    gen_ffi.append(f'  native_new [], "sp_{klass}_new"\n')

    for f in fields:
        if is_ptr(f["type"]):
            continue
        if "[" in f["type"]:
            continue                  # array field (float[4], char[32], ...)
        ft = strip_array(f["type"])
        if ft not in FIELD_TOK:
            continue
        ftok, ctype = FIELD_TOK[ft]
        fname = f["name"]
        if ft == "bool":
            gen_c.append(f"int sp_{klass}_{fname}(sp_{klass} *self) {{\n"
                         f"  return self->{emb}.{fname} ? 1 : 0;\n}}\n")
            gen_c.append(f"int sp_{klass}_set_{fname}(sp_{klass} *self, int {fname}) {{\n"
                         f"  self->{emb}.{fname} = {fname} != 0;\n  return {fname};\n}}\n")
        elif ctype == "double":
            gen_c.append(f"double sp_{klass}_{fname}(sp_{klass} *self) {{\n"
                         f"  return (double)self->{emb}.{fname};\n}}\n")
            gen_c.append(f"double sp_{klass}_set_{fname}(sp_{klass} *self, double {fname}) {{\n"
                         f"  self->{emb}.{fname} = (float){fname};\n  return {fname};\n}}\n")
        else:
            gen_c.append(f"{ctype} sp_{klass}_{fname}(sp_{klass} *self) {{\n"
                         f"  return self->{emb}.{fname};\n}}\n")
            gen_c.append(f"{ctype} sp_{klass}_set_{fname}(sp_{klass} *self, {ctype} {fname}) {{\n"
                         f"  self->{emb}.{fname} = {fname};\n  return {fname};\n}}\n")
        nmx = f"sp_{klass}_{fname}"
        nms = f"sp_{klass}_set_{fname}"
        if nmx not in enmethod and nms not in enmethod:
            gen_ffi.append(f'  native_method :{fname}, [], {ftok}, "{nmx}"\n')
            gen_ffi.append(f'  native_method :{fname}=, [:{ftok[1:]}], {ftok}, "{nms}"\n')
            enmethod.add(nmx)
            enmethod.add(nms)

# ------------------------------------------------------------------ output --

ffi_text = open(FFI_PATH).read()
anchor = '  ffi_cflags "-Wl,-rpath,/usr/local/lib"\n'
assert anchor in ffi_text
top = "".join(gen_ffi)
ffi_text = ffi_text.replace(
    anchor, anchor + "\n# ====== generated: complete raylib API surface ======\n" + top, 1)

consts = []
for e in api["enums"]:
    for v in e["values"]:
        if v["name"] in econst:
            continue
        econst.add(v["name"])
        consts.append("    %s = %d\n" % (v["name"], v["value"]))
for df in api["defines"]:
    val = df["value"]
    val = val if isinstance(val, str) else str(val)
    try:
        float(val.strip())
    except ValueError:
        continue
    if df["name"] in econst:
        continue
    econst.add(df["name"])
    consts.append("    %s = %s\n" % (df["name"], val.strip()))

wrappers_out = "".join(g for g in gen_wrap if g)
constants_out = "".join(consts)
guard_insert = ("\n    # ====== generated: wrappers + constants ======\n"
                + wrappers_out + constants_out)

assert ffi_text.endswith("  end\nend\n"), ffi_text[-40:]
ffi_text = ffi_text[: -len("  end\nend\n")] + guard_insert + "  end\nend\n"
open(FFI_PATH, "w").write(ffi_text)

adapter_text = open(ADAPTER_PATH).read().rstrip()
adapter_text += ("\n\n/* ================================================================\n"
                 " * Generated shims (tools/gen_raylib_ffi.py). Same conventions as the\n"
                 " * hand-written shims above; keep in sync by re-running the generator.\n"
                 " * ================================================================ */\n\n")
adapter_text += "".join(gen_c)
adapter_text += "\n/* ---- generated shims ---- */\n"
adapter_text += "".join(gen_shim_c)
open(ADAPTER_PATH, "w").write(adapter_text)

print("=== gen_raylib_ffi summary ===")
for k in ("direct", "shim", "out", "heap_in_shim", "dup_name", "dup_sp"):
    print("  %-14s %d" % (k, report[k]))
print("  varargs skipped:", sorted(report["varargs"]))
print("  not in installed libraylib (skipped):", len(report["not_in_installed"]))
print("  new GC structs:", [c for _, c, _ in new_gc])
if report["not_in_installed"]:
    raise SystemExit(
        "FATAL: %d JSON functions are missing from %s. Skipping them would "
        "silently drop bindings (the stale-6.1-.so bug). Point RAYLIB_LIB at "
        "a complete raylib 6.x build, e.g.:\n"
        "  RAYLIB_LIB=/home/nelson/workspace/c/raylib/raylib/src/libraylib.so.6.1.0 python3 tools/gen_raylib_ffi.py"
        % (len(report["not_in_installed"]), RAYLIB_LIB))