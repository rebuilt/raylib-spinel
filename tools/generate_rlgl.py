#!/usr/bin/env python3
"""Generate rlgl FFI and adapter code for Spinel AOT.

Reads rlgl_api.json and generates:
  - lib/rlgl_ffi.rb  (Ruby FFI declarations)
  - lib/rlgl_adapter.c (C adapter shims)

Follows the same conventions as tools/gen_raylib_ffi.py.
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, "lib")
FFI_PATH = os.path.join(LIB, "rlgl_ffi.rb")
ADAPTER_PATH = os.path.join(LIB, "rlgl_adapter.c")

API_PATH = os.path.join(os.path.dirname(ROOT), "raylib-bindings",
                        "generator", "rlgl_api.json")

# Global output lists
gen_ffi = []
gen_c = []
gen_shim_c = []
gen_wrap = []


def _gem_version():
    import subprocess
    try:
        return subprocess.check_output(
            ["ruby", "-e", "print Gem::Specification.find_by_name('raylib-bindings').version"],
            text=True, stderr=subprocess.DEVNULL).strip()
    except Exception:
        return None


def _checkout_version():
    import subprocess
    checkout = os.path.join(os.path.dirname(ROOT), "raylib-bindings")
    try:
        out = subprocess.check_output(
            ["git", "-C", checkout, "describe", "--tags", "--abbrev=0"],
            text=True, stderr=subprocess.DEVNULL).strip()
        return out.lstrip("v")
    except Exception:
        return None


_gv, _cv = _gem_version(), _checkout_version()
if _gv and _cv and _gv != _cv:
    raise SystemExit(
        "raylib-spinel: raylib-bindings checkout (%s) does not match the "
        "installed gem (%s). Update the checkout or pass an explicit "
        "api_dir." % (_cv, _gv))


# ------------------------------------------------------------------ tables --

RAW_STRUCTS = {
    "Texture", "RenderTexture", "Shader", "Material",
    "Model", "Mesh", "Image", "Font", "AudioStream",
    "Camera3D", "Camera", "Light",
}

GC_STRUCTS = {
    "Vector2": ("Vector2", "v"),
    "Vector3": ("Vector3", "v"),
    "Vector4": ("Vector4", "v"),
    "Matrix": ("Matrix", "v"),
    "Color": ("Color", "c"),
    "Rectangle": ("Rectangle", "v"),
    "Camera2D": ("Camera2D", "v"),
    "BoundingBox": ("BoundingBox", "v"),
    "Ray": ("Ray", "v"),
    "RayCollision": ("RayCollision", "v"),
    "Matrix": ("Matrix", "v"),
    "NPatchInfo": ("NPatchInfo", "v"),
    "VrDeviceInfo": ("VrDeviceInfo", "v"),
    "VrStereoConfig": ("VrStereoConfig", "v"),
}

CALLBACKS = {}

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

FIELD_TOK = {
    "float": (":float", "double"),
    "int": (":int", "int"),
    "unsigned int": (":int", "int"),
    "bool": (":int", "int"),
    "unsigned char": (":int", "int"),
}


def rname(n):
    keywords = set("""alias and begin break case class def defined? do else elsif end ensure
                    false for if in module next nil not or redo rescue retry return self super
                    then true undef until when while yield""".split())
    if n in keywords:
        return "kw_%s" % n
    return n


def strip_array(t):
    return re.sub(r"\[\d+\]", "", t).strip()


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
struct_fields = {s["name"]: s["fields"] for s in api.get("structs", [])}


def existing_set(pattern, path, lst=False):
    found = set(re.findall(pattern, open(path).read()))
    return found


effi = existing_set(r"ffi_func\s+:(\w+)", FFI_PATH)
enative = existing_set(r'native_struct\s+"(\w+)"', FFI_PATH)
emethod = existing_set(r'native_method\s+:[:A-Za-z0-9_]*,\s*\[[^\]]*\],\s*:[A-Za-z0-9_]*,\s*"(rl_[A-Za-z0-9_]+)"',
                       FFI_PATH)
ewrap = existing_set(r"def self\.(\w+)", FFI_PATH)
esp = existing_set(r"\brl_[A-Za-z0-9_]+", ADAPTER_PATH)
# The primary raylib adapter is linked into every app, so GC structs and
# shims it already provides must not be re-emitted here (duplicate native_struct
# at the Ruby splice level, multiple definition at link time).
PRIMARY_FFI = os.path.join(LIB, "raylib_ffi.rb")
PRIMARY_ADAPTER = os.path.join(LIB, "raylib_adapter.c")
enative |= existing_set(r'native_struct\s+"(\w+)"', PRIMARY_FFI)
emethod |= existing_set(r'native_method\s+:[:A-Za-z0-9_]*,\s*\[[^\]]*\],\s*:[A-Za-z0-9_]*,\s*"(rl_[A-Za-z0-9_]+)"', PRIMARY_FFI)
esp |= existing_set(r"\brl_[A-Za-z0-9_]+", PRIMARY_ADAPTER)


def classify_param(t):
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

report = {"direct": 0, "shim": 0, "decl_only": 0, "out": 0, "heap_in_shim": 0,
          "dup_name": 0, "dup_sp": 0, "varargs": [], "new_gc": [],
          "not_in_installed": []}


def shim_expr(kind, aname, base=None):
    if kind == "gc":
        klass, emb = gc_of(base)
        return "((rl_%s*)%s)->%s" % (klass, aname, emb)
    if kind == "gcp":
        klass, emb = gc_of(base)
        return "&((rl_%s*)%s)->%s" % (klass, aname, emb)
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
    ret = fn.ret.strip()
    ffi_ret = ffi_flat(ret) or ":void"
    gen_ffi.append("  ffi_func :%s, [%s], %s\n" % (fn.name, args, ffi_ret))
    report["direct"] += 1


def emit_shim(fn):
    global esp, effi
    sp = "rl_" + fn.name
    if fn.name in effi or sp in effi:
        report["dup_name"] += 1
        return
    shim_exists = sp in esp
    if shim_exists:
        # C shim already present (hand-written or earlier run); still emit the
        # ffi_func declaration + Ruby wrapper so it is reachable from Ruby.
        report["dup_sp"] += 1
    effi.add(fn.name)
    effi.add(sp)
    esp.add(sp)

    c_params = []
    ffi_args = []
    call_exprs = []
    wrapper_args = []

    for aname, t in fn.args:
        kind = classify_param(t)
        if kind[0] == "flat":
            c_params.append((ffi_c_type(kind[1]), aname))
            ffi_args.append(kind[1])
            call_exprs.append(aname)
        else:
            c_params.append(("void *", aname))
            ffi_args.append(":ptr")
            call_exprs.append(shim_expr(kind[0], aname, kind[1]))
        wrapper_args.append(rname(aname))

    ret = fn.ret.strip()
    out_class = None
    c_ret = "void"
    ffi_ret = ":void"
    ret_base = base_of(ret)
    ptr_return = False

    if is_ptr(ret):
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
        wrapper_args.append(None)
        report["out"] += 1
    elif ret_base in RAW_STRUCTS:
        if ret == "Vector2":
            klass, embv = gc_of(ret_base)
            out_class = klass
            c_params.append(("void *", "_out"))
            ffi_args.append(":ptr")
            wrapper_args.append(None)
            report["out"] += 1
        else:
            c_ret, ffi_ret = "void *", ":ptr"
            report["heap_in_shim"] += 1
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
        body_lines.append("  return %s;" % ret_expr)
    elif out_class is not None:
        klass, emb = gc_of(ret_base)
        body_lines.append("  ((rl_%s*)_out)->%s = %s;" % (klass, emb, ret_expr))
        c_ret = "void"
        ffi_ret = ":void"
    elif c_ret == "void *":
        body_lines.append("  %s *r = (%s *)malloc(sizeof(%s));"
                          % (ret_base, ret_base, ret_base))
        body_lines.append("  *r = %s;" % ret_expr)
        body_lines.append("  return r;")
    else:
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

    if not shim_exists:
        gen_shim_c.append("/** %s(params: %s -> %s) */\n%s rl_%s(%s) {\n%s\n}\n" %
                         (fn.name, sig, c_ret, c_ret, fn.name, sig,
                          "\n".join(body_lines)))
    gen_ffi.append("  ffi_func :%s, [%s], %s\n" % (sp, ", ".join(ffi_args), ffi_ret))

    if out_class is not None:
        gen_wrap.append(wrapper_out(fn, wrapper_args, out_class))
    else:
        gen_wrap.append(wrapper_simple(fn, wrapper_args))
    report["decl_only" if shim_exists else "shim"] += 1


def wrapper_simple(fn, wrapper_args):
    name = fn.name
    if name in ewrap:
        return ""
    ewrap.add(name)
    a = ", ".join(wa for wa in wrapper_args if wa is not None)
    return ("    def self.%s(%s)\n      Raylib.rl_%s(%s)\n    end\n"
            % (name, a, name, a))


def wrapper_out(fn, wrapper_args, out_class):
    name = fn.name
    if name in ewrap:
        return ""
    ewrap.add(name)
    a = ", ".join(wa for wa in wrapper_args if wa is not None)
    fwd = (a + ", _out") if a else "_out"
    if out_class == "Color":
        init = "Color.new(0, 0, 0, 0)"
    elif out_class == "Vector3":
        init = "Vector3.new(0.0, 0.0, 0.0)"
    else:
        init = "%s.new" % out_class
    return ("    def self.%s(%s)\n      _out = %s\n"
            "      Raylib.rl_%s(%s)\n      _out\n    end\n"
            % (name, a, init, name, fwd))


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
    if func_needs_shim(fn):
        emit_shim(fn)
    else:
        emit_flat(fn)

# ------------------------------------------------------------------ structs --

new_gc = []
seen_klass = set()
for base, (klass, emb) in list(GC_STRUCTS.items()) + list(GC_RETURN_ONLY.items()):
    if klass in seen_klass:
        continue
    seen_klass.add(klass)
    # No whole-struct skip: the Ruby native block, the C typedef+ctor, and the
    # per-field accessor shims are each deduped at their own emit site below,
    # so a half-present struct (e.g. hand-written C typedef but no Ruby block
    # or accessors) still gets its missing pieces. The old combined check
    # treated any rl_<Klass> identifier (e.g. the C typedef) as "complete".
    new_gc.append((base, klass, emb))

touched = []
for base, klass, emb in new_gc:
    before = (len(gen_c), len(gen_ffi))
    fields = struct_fields.get(base, [])
    emit_c = ("rl_" + klass + "_new") not in esp
    emit_ruby = klass not in enative and base not in enative
    if emit_c:
        gen_c.append("\n/* rl_%s — GC-embedded %s (see rlgl_ffi.rb) */" % (klass, base))
        gen_c.append("typedef struct rl_%s_s {\n  sp_int cls_id;\n  %s %s;\n} rl_%s;\n"
                     % (klass, base, emb, klass))
        gen_c.append("static void rl_%s_scan(void *p) { (void)p; }\n" % klass)
        init = "  self->%s = (%s){ 0 };\n" % (emb, base)
        gen_c.append("rl_%s *rl_%s_new(sp_int cls_id) {\n"
                     "  rl_%s *self = (rl_%s *)sp_gc_alloc(sizeof(rl_%s), NULL, rl_%s_scan);\n"
                     "  self->cls_id = cls_id;\n%s  return self;\n}\n"
                     % (klass, klass, klass, klass, klass, klass, init))
    if emit_ruby:
        gen_ffi.append(f'  native_struct "{klass}", "rl_{klass}"\n')
        gen_ffi.append(f'  native_new [], "rl_{klass}_new"\n')

    for f in fields:
        if is_ptr(f["type"]):
            continue
        if "[" in f["type"]:
            continue
        ft = strip_array(f["type"])
        if ft not in FIELD_TOK:
            continue
        ftok, ctype = FIELD_TOK[ft]
        fname = f["name"]
        if ft == "bool":
            c_lines = (f"int rl_{klass}_{fname}(rl_{klass} *self) {{\n"
                       f"  return self->{emb}.{fname} ? 1 : 0;\n}}\n"
                       f"int rl_{klass}_set_{fname}(rl_{klass} *self, int {fname}) {{\n"
                       f"  self->{emb}.{fname} = {fname} != 0;\n  return {fname};\n}}\n")
        elif ctype == "double":
            c_lines = (f"double rl_{klass}_{fname}(rl_{klass} *self) {{\n"
                       f"  return (double)self->{emb}.{fname};\n}}\n"
                       f"double rl_{klass}_set_{fname}(rl_{klass} *self, double {fname}) {{\n"
                       f"  self->{emb}.{fname} = (float){fname};\n  return {fname};\n}}\n")
        else:
            c_lines = (f"{ctype} rl_{klass}_{fname}(rl_{klass} *self) {{\n"
                       f"  return self->{emb}.{fname};\n}}\n"
                       f"{ctype} rl_{klass}_set_{fname}(rl_{klass} *self, {ctype} {fname}) {{\n"
                       f"  self->{emb}.{fname} = {fname};\n  return {fname};\n}}\n")
        nmx = f"rl_{klass}_{fname}"
        nms = f"rl_{klass}_set_{fname}"
        if nmx not in esp and nms not in esp:
            gen_c.append(c_lines)
        if nmx not in emethod and nms not in emethod:
            gen_ffi.append(f'  native_method :{fname}, [], {ftok}, "{nmx}"\n')
            gen_ffi.append(f'  native_method :{fname}=, [:{ftok[1:]}], {ftok}, "{nms}"\n')
            emethod.add(nmx)
            emethod.add(nms)
    if (len(gen_c), len(gen_ffi)) != before:
        touched.append(klass)
report["new_gc"] = touched

# ------------------------------------------------------------------ output --

ffi_text = open(FFI_PATH).read()
if not ffi_text.endswith("\n"):
    ffi_text += "\n"   # the wrappers-insert guard needs a final newline
_m = re.search(r'^  ffi_cflags "[^"]*"\n', ffi_text, re.M)
assert _m, "no ffi_cflags anchor line in the ffi file"
anchor = _m.group(0)
top = "".join(gen_ffi)
if top:
    ffi_text = ffi_text.replace(
        anchor, anchor + "\n# ====== generated: complete rlgl API surface ======\n" + top, 1)

consts = []
econst = existing_set(r"(?m)^\s+([A-Z][A-Za-z0-9_]*) =", FFI_PATH)
for e in api.get("enums", []):
    for v in e.get("values", []):
        if v["name"] in econst:
            continue
        econst.add(v["name"])
        consts.append("    %s = %d\n" % (v["name"], v["value"]))
for df in api.get("defines", []):
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

# ------------------------------------------------------- snake_case aliases --
# MRI gem :snake_case naming — same conversion as raylib_main.rb's entries loop.
def snake_case(name):
    s = re.sub(r"([A-Z]+)([A-Z0-9][a-z])", r"\1_\2", name)
    s = re.sub(r"([a-z\d])([A-Z0-9])", r"\1_\2", s)
    s = s.lower()
    if "vector_3" in s:
        s = s.replace("vector_3", "vector3_")
    if "vector_2" in s:
        s = s.replace("vector_2", "vector2_")
    if s.endswith("_"):
        s = s[:-1]
    return s

ealias = existing_set(r"alias_method :(\w+),", FFI_PATH)
ealias |= existing_set(r"alias_method :(\w+),", PRIMARY_FFI)
taken = effi | ewrap | ealias
aliases = []
fwd = []
for fn in api.get("functions", []):
    name = fn["name"]
    if name in ewrap:
        target = name
    elif "rl_" + name in effi:
        target = "rl_" + name
    elif name in effi:
        target = name
    elif "rl_" + name in ewrap:
        target = "rl_" + name
    else:
        continue
    sn = snake_case(name)
    if sn == target or sn in taken:
        continue
    taken.add(sn)
    ealias.add(sn)
    if target in effi and target not in ewrap:
        # Spinel codegen cannot call an aliased ffi_func declaration (the
        # alias table only rewrites def-ed methods), so emit a forwarding
        # wrapper instead of an alias for ffi_func targets.
        a = ", ".join("p%d" % i for i in range(len(fn.get("params", []))))
        fwd.append("  def self.%s(%s)\n    Rlgl.%s(%s)\n  end\n" % (sn, a, target, a))
    else:
        aliases.append("    alias_method :%s, :%s\n" % (sn, target))
report["aliases"] = len(aliases) + len(fwd)
alias_block = ""
if aliases or fwd:
    alias_block = ("\n  # ====== generated: snake_case aliases (MRI gem naming) ======\n"
                   + "".join(fwd)
                   + ("  class << self\n" + "".join(aliases) + "  end\n" if aliases else ""))

# Insert before the file's LAST end (the outer module close); the old
# fixed-suffix assumption broke once files stopped ending "  end\nend\n".
_ends = list(re.finditer(r"(?m)^[ \t]*end[ \t]*$", ffi_text))
assert _ends, "no closing end in ffi file"
if wrappers_out or constants_out or alias_block:
    guard_insert = ("\n    # ====== generated: wrappers + constants ======\n"
                    + wrappers_out + constants_out + alias_block)
    _pos = _ends[-1].start()
    ffi_text = ffi_text[:_pos] + guard_insert + ffi_text[_pos:]
open(FFI_PATH, "w").write(ffi_text)

adapter_text = open(ADAPTER_PATH).read()
gen_c_out = "".join(gen_c)
gen_shim_c_out = "".join(gen_shim_c)
if gen_c_out or gen_shim_c_out:
    adapter_text = adapter_text.rstrip()
    adapter_text += ("\n\n/* ================================================================\n"
                     " * Generated shims (tools/gen_rlgl.py). Same conventions as the\n"
                     " * hand-written shims above; keep in sync by re-running the generator.\n"
                     " * ================================================================ */\n\n")
    adapter_text += gen_c_out
    adapter_text += "\n/* ---- generated shims ---- */\n"
    adapter_text += gen_shim_c_out
open(ADAPTER_PATH, "w").write(adapter_text)

print("=== gen_rlgl summary ===")
for k in ("direct", "shim", "decl_only", "out", "heap_in_shim", "dup_name", "dup_sp", "aliases"):
    print("  %-14s %d" % (k, report[k]))
print("  varargs skipped:", sorted(report["varargs"]))
print("  new GC structs:", touched)