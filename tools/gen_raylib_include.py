#!/usr/bin/env python3
"""gen_raylib_include.py — generate lib/raylib_include.rb (gem instance surface).

The MRI raylib-bindings gem attaches every function both to the Raylib module
and, after `include Raylib`, as an instance method. raylib-spinel declares the
module methods; this generator emits the include-able instance delegators so
unmodified gem code (`include Raylib` + bare calls) compiles under Spinel.

Wrappers keep their written argument lists; ffi_func-only names get positional
arguments sized by the declared FFI arity (a splat would widen every argument
to untyped and defeat the typed FFI slots).

rlgl lives in `module Rlgl` on our side but on `Raylib` in the gem, so rlgl
names get both a Raylib singleton alias and an instance delegator.

Usage: python3 tools/gen_raylib_include.py
"""

import json
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, "lib")
API_DIR = os.path.join(os.path.dirname(ROOT), "raylib-bindings", "generator")

SCALAR_TYPES = {
    "int", "unsigned int", "float", "double", "bool", "char", "unsigned char",
    "const char *", "char *", "void", "long", "unsigned long", "size_t",
    "unsigned short", "short", "int *", "const int *", "void *",
    "const float *", "float *", "unsigned char *", "const unsigned char *",
    "int64_t", "uint64_t", "unsigned long long", "long long", "void (*)()",
}


def load_param_types():
    """{function name: [type, ...]} from the gem's API JSONs (may be absent)."""
    out = {}
    for fname in ("raylib_api.json", "raymath_api.json", "physac_api.json",
                  "rcamera_api.json", "rlgl_api.json", "raygui_api.json"):
        path = os.path.join(API_DIR, fname)
        if not os.path.exists(path):
            continue
        try:
            data = json.load(open(path))
        except Exception:
            continue
        fns = data["functions"] if isinstance(data, dict) else data
        for fn in fns:
            out[fn["name"]] = [p.get("type", "") for p in fn.get("params", [])]
    return out


PARAM_TYPES = load_param_types()
FILES = ["raylib_ffi.rb", "raymath_ffi.rb", "rlgl_ffi.rb", "physac_ffi.rb",
         "rcamera_ffi.rb", "raygui_ffi.rb"]
OUT = os.path.join(LIB, "raylib_include.rb")

DEF_RE = re.compile(r"^\s*def self\.([A-Za-z_]\w*)(\(([^)]*)\))?\s*$")
FFI_RE = re.compile(r"ffi_func\s+:([A-Za-z_]\w*),\s*(?:%i\[([^\]]*)\]|\[([^\]]*)\])")
ALIAS_RE = re.compile(r"^\s*alias_method\s+:([A-Za-z_]\w*),\s*:([A-Za-z_]\w*)")


def methods(path, skip_shims=True):
    """[(name, args|arity|None)] in source order.

    args is the wrapper's written argument list when the name has a `def`,
    an int arity when only an ffi_func declaration exists, or None for an
    arity-less wrapper (`def self.GuiLock = ...`).

    skip_shims drops the `rl_*` adapter shims (raylib_ffi.rb); rlgl_ffi.rb is
    itself the rlgl API, snake aliases included, so it passes False.
    """
    out, seen = [], set()
    for line in open(path):
        if re.match(r"\s*#", line):
            continue
        m = DEF_RE.match(line)
        if m:
            name, has_args = m.group(1), m.group(2)
            if (skip_shims and name.startswith("rl_")) or name in seen:
                continue
            seen.add(name)
            out.append((name, (m.group(3) or "").strip() if has_args else None))
            continue
        m = ALIAS_RE.match(line)
        if m:
            snake, camel = m.group(1), m.group(2)
            if snake in seen:
                continue
            seen.add(snake)
            known = dict(out).get(camel)
            if isinstance(known, int):
                out.append((snake, known))
            elif isinstance(known, str):
                out.append((snake, known))
            else:
                out.append((snake, None))
            continue
        m = FFI_RE.search(line)
        if m:
            name = m.group(1)
            if (skip_shims and name.startswith("rl_")) or name in seen:
                continue
            if m.group(2) is not None:  # %i[int int str]: whitespace-separated
                arity = len(m.group(2).split())
            else:                        # [:int, :int]: comma-separated
                arity = len([p for p in m.group(3).split(",") if p.strip()])
            seen.add(name)
            out.append((name, arity))
    return out


def with_nil_defaults(param, fn_name=None, index=None):
    """`p0` -> `p0 = nil` for a plain parameter (splats/blocks/defaults as is).

    Spinel's `include`-exposed singleton methods reject possibly-nil arguments
    (an empty-array element is typed nil-able); a default makes the parameter
    optional, and the coercion in the delegate body turns the possibly-nil
    value into a properly typed one for the wrapper call.
    """
    p = param.strip()
    if not p or "=" in p or p.startswith("*") or p.startswith("&"):
        return p
    return p + " = nil"


def coerce_for_call(name, names):
    """Delegate call arguments: possibly-nil scalars are coerced to their C type.

    The delegate parameters stay nil-able (that is what accepts possibly-nil
    array elements); coercing here keeps the values typed for the wrapper call
    instead of forwarding a possibly-nil value (or a boxed one).
    """
    types = PARAM_TYPES.get(name)
    out = []
    for i, p in enumerate(names):
        ty = types[i] if types and i < len(types) else None
        if ty in ("int", "unsigned int", "char", "unsigned char", "short",
                  "unsigned short", "long", "unsigned long", "size_t",
                  "int64_t", "uint64_t", "unsigned long long", "long long"):
            out.append("(%s || 0).to_i" % p)
        elif ty in ("float", "double"):
            out.append("(%s || 0.0).to_f" % p)
        else:
            out.append(p)
    return ", ".join(out)


def call(name, args):
    if isinstance(args, int):
        names = ["p%d" % i for i in range(args)]
    elif args is None:
        names = []
    else:
        names = [p.strip() for p in args.split(",") if p.strip()]
    defaults = [with_nil_defaults(p, name, i) != p.strip()
                for i, p in enumerate(names)]
    # Ruby requires optional parameters after the required ones: a required
    # parameter keeps every earlier parameter required as well.
    last_required = max((i for i, d in enumerate(defaults) if not d),
                        default=-1)
    parts = []
    for i, p in enumerate(names):
        if defaults[i] and i > last_required and not p.startswith(("*", "&")) \
                and "=" not in p:
            parts.append(p + " = nil")
        else:
            parts.append(p)
    return ", ".join(parts), coerce_for_call(name, names)


def main():
    body = [
        "# raylib_include.rb — generated by tools/gen_raylib_include.py.",
        "#",
        "# The MRI gem attaches every function to Raylib and, after `include Raylib`,",
        "# also as an instance method. The instance surface lives in its own module",
        "# (included into Raylib) because Spinel resolves a `Raylib.name` singleton",
        "# call to a same-name instance method defined in Raylib itself, which would",
        "# hide the module methods (alias_method targets included). Parameters get",
        "# `= nil` defaults: bare calls of Spinel's include-exposed singleton methods",
        "# reject possibly-nil arguments, and the nil-safe FFI conversion path is the",
        "# same one the rest of the surface uses. Rlgl is exposed on Raylib because",
        "# the gem binds rlgl there. Loaded by raylib.rb (Spinel path).",
        "",
        "module RaylibInstanceMethods",
    ]
    total = 0

    raylib_names = set()
    for fname in FILES:
        if fname == "rlgl_ffi.rb":
            continue
        path = os.path.join(LIB, fname)
        if os.path.exists(path):
            raylib_names.update(n for n, _a in methods(path))

    # raygui_compat.rb redefines the RGui* helpers with the gem's Rectangle +
    # (value, result...) shape; it is loaded after raygui_ffi.rb, so those are
    # the definitions a delegate reaches. Prefer them for names they define.
    compat_path = os.path.join(LIB, "raygui_compat.rb")
    compat_names = {n for n, _a in methods(compat_path)} if os.path.exists(compat_path) else set()

    def dedup(entries):
        seen, out = set(), []
        for n, a in entries:
            if n in seen:
                continue
            seen.add(n)
            out.append((n, a))
        return out

    # rlgl_ffi re-declares some raylib names (LoadTexture, SetTextureFilter,
    # ...); only alias the rlgl-specific ones so the Raylib surface is not
    # shadowed by a second declaration.
    rlgl = dedup([(n, a) for n, a in methods(os.path.join(LIB, "rlgl_ffi.rb"),
                                              skip_shims=False)
                  if n not in raylib_names])
    if rlgl:
        body.append("  # --- rlgl surface (gem: Raylib, here Rlgl) ---")
        for name, args in rlgl:
            params, call_args = call(name, args)
            body.append("  def %s(%s) = Rlgl.%s(%s)" % (name, params, name, call_args))
            total += 1
        body.append("")

    for fname in FILES + ["raygui_compat.rb"]:
        path = os.path.join(LIB, fname)
        if not os.path.exists(path) or fname == "rlgl_ffi.rb":
            continue
        entries = [(n, a) for n, a in methods(path)
                   if not (fname == "raygui_ffi.rb" and n in compat_names)]
        if not entries:
            continue
        body.append("  # --- %s ---" % fname)
        for name, args in dedup(entries):
            params, call_args = call(name, args)
            body.append("  def %s(%s) = Raylib.%s(%s)" % (name, params, name, call_args))
            total += 1
        body.append("")

    body.append("end")
    body.append("")
    body.append("module Raylib")
    if rlgl:
        body.append("  # rlgl names on the Raylib module (gem parity).")
        for name, args in rlgl:
            params, call_args = call(name, args)
            body.append("  def self.%s(%s) = Rlgl.%s(%s)" % (name, params, name, call_args))
            total += 1
        body.append("")
    body.append("  include RaylibInstanceMethods")
    body.append("end")
    open(OUT, "w").write("\n".join(body) + "\n")
    print("wrote %s (%d delegators)" % (OUT, total))


if __name__ == "__main__":
    main()
