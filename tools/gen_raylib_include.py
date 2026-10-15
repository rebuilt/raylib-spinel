#!/usr/bin/env python3
"""gen_raylib_include.py — generate lib/raylib_include.rb (gem instance surface).

The MRI raylib-bindings gem attaches every function both to the Raylib module
and, after `include Raylib`, as an instance method. raylib-spinel declares the
module methods; this generator emits the include-able instance delegators so
unmodified gem code (`include Raylib` + bare calls) compiles under Spinel.

Wrappers keep their written argument lists; ffi_func-only names get positional
arguments sized by the declared FFI arity (a splat would widen every argument
to untyped and defeat the typed FFI slots). No parameter defaults are added:
spinel 2026.09.12+10027 marks the parameters of the method a bare call binds
(matz/spinel#9193), so possibly-nil arguments (an empty-array element is typed
nil-able) flow through and convert at the FFI boundary.

rlgl lives in `module Rlgl` on our side but on `Raylib` in the gem, so rlgl
names get both a Raylib singleton alias and an instance delegator.

Usage: python3 tools/gen_raylib_include.py
"""

import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, "lib")
FILES = ["raylib_ffi.rb", "raymath_ffi.rb", "rlgl_ffi.rb", "physac_ffi.rb",
         "rcamera_ffi.rb", "raygui_ffi.rb"]
OUT = os.path.join(LIB, "raylib_include.rb")

DEF_RE = re.compile(r"^\s*def self\.([A-Za-z_]\w*)(\(([^)]*)\))?\s*$")
FFI_RE = re.compile(r"ffi_func\s+:([A-Za-z_]\w*),\s*(?:%i\[([^\]]*)\]|\[([^\]]*)\])")
ALIAS_RE = re.compile(r"^\s*alias_method\s+:([A-Za-z_]\w*),\s*:([A-Za-z_]\w*)")


def join_signatures(text):
    """Join a `def self.X(...)` signature that spans lines into one line.

    A signature split across lines (e.g. `def self.RGuiSliderBar(bounds, ...,
    max_value)`) is invisible to the line-based DEF_RE, so those names got no
    delegate; a bare call then emitted a call to a symbol the compiler never
    defined (implicit declaration -> `sp_PolyArray *` from `int`).
    """
    out, buf = [], None
    for line in text.split("\n"):
        if buf is not None:
            buf += " " + line.strip()
            if re.search(r"\)\s*$", line):
                out.append(buf)
                buf = None
            continue
        m = re.match(r"^(\s*)def self\.(\w+)\s*\((.*)$", line)
        if m and not re.search(r"\)", m.group(3)):
            buf = line.rstrip()
            continue
        out.append(line)
    if buf is not None:
        out.append(buf)
    return "\n".join(out)


def methods(path, skip_shims=True):
    """[(name, args|arity|None)] in source order.

    args is the wrapper's written argument list when the name has a `def`,
    an int arity when only an ffi_func declaration exists, or None for an
    arity-less wrapper (`def self.GuiLock = ...`).

    skip_shims drops the `rl_*` adapter shims (raylib_ffi.rb); rlgl_ffi.rb is
    itself the rlgl API, snake aliases included, so it passes False.
    """
    out, seen = [], set()
    for line in join_signatures(open(path).read()).split("\n"):
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


def call(name, args):
    """(parameter list, argument list) for a delegator.

    Defaults appear in the parameter list (dual-shape wrappers accept two
    arities) but never in the call: forwarding `p2 = nil` would evaluate an
    assignment and pass nil.
    """
    if isinstance(args, int):
        names = ["p%d" % i for i in range(args)]
        return ", ".join(names), ", ".join(names)
    if args is None:
        return "", ""
    params = [p.strip() for p in args.split(",") if p.strip()]
    call_args = [p.split("=")[0].strip() for p in params]
    return ", ".join(params), ", ".join(call_args)


def main():
    body = [
        "# raylib_include.rb — generated by tools/gen_raylib_include.py.",
        "#",
        "# The MRI gem attaches every function to Raylib and, after `include Raylib`,",
        "# also as an instance method. The instance surface lives in its own module",
        "# (included into Raylib) because Spinel resolves a `Raylib.name` singleton",
        "# call to a same-name instance method defined in Raylib itself, which would",
        "# hide the module methods (alias_method targets included). No parameter",
        "# defaults: a bare call binds the callee's parameters, so possibly-nil",
        "# arguments (matz/spinel#9193) convert at the FFI boundary. Rlgl is exposed",
        "# on Raylib because the gem binds rlgl there. Loaded by raylib.rb (Spinel).",
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
