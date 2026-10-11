#!/usr/bin/env python3
"""Emit snake_case aliases (MRI gem naming) into lib/raygui_ffi.rb.

raygui has no full generator yet (the ffi file is hand-written), so aliases
are emitted by this standalone tool. Same conversion rules as the MRI gem's
raylib_main.rb entries loop and the generate_*.py tools. Idempotent: existing
alias_method lines are skipped.
"""
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, "lib")
FFI_PATH = os.path.join(LIB, "raygui_ffi.rb")
API_PATH = os.path.join(os.path.dirname(ROOT), "raylib-bindings",
                        "generator", "raygui_api.json")


def existing_set(pattern, path):
    return set(re.findall(pattern, open(path).read()))


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


api = __import__("json").load(open(API_PATH))
ffi_text = open(FFI_PATH).read()
effi = existing_set(r"ffi_func\s+:(\w+)", FFI_PATH)
ewrap = existing_set(r"def self\.(\w+)", FFI_PATH)
ealias = existing_set(r"alias_method :(\w+),", FFI_PATH)

taken = effi | ewrap | ealias
aliases = []
fwd = []
skipped = []
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
        skipped.append(name)
        continue
    sn = snake_case(name)
    if sn == target or sn in taken:
        continue
    taken.add(sn)
    ealias.add(sn)
    if target in effi and target not in ewrap:
        # Spinel codegen cannot call an aliased ffi_func declaration; emit a
        # forwarding wrapper instead (see the generate_*.py tools).
        a = ", ".join("p%d" % i for i in range(len(fn.get("params", []))))
        fwd.append("  def self.%s(%s)\n    Raylib.%s(%s)\n  end\n" % (sn, a, target, a))
    else:
        aliases.append("    alias_method :%s, :%s\n" % (sn, target))

if aliases or fwd:
    alias_block = ("\n  # ====== generated: snake_case aliases (MRI gem naming, "
                   "tools/gen_raygui_aliases.py) ======\n"
                   + "".join(fwd)
                   + ("  class << self\n" + "".join(aliases) + "  end\n" if aliases else ""))
    _ends = list(re.finditer(r"(?m)^[ \t]*end[ \t]*$", ffi_text))
    assert _ends, "no closing end in ffi file"
    _pos = _ends[-1].start()
    ffi_text = ffi_text[:_pos] + alias_block + ffi_text[_pos:]
    open(FFI_PATH, "w").write(ffi_text)

print("aliases emitted:", len(aliases) + len(fwd))
print("no target (unbound):", skipped)
