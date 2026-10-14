#!/usr/bin/env python3
"""gem_compat_audit.py — MRI raylib-bindings surface vs raylib-spinel's.

The compatibility contract is the *installed MRI gem* (entry tables + struct
layouts + helper methods) at the raylib version the gem bundles. This audit
diffs that contract against what raylib-spinel exposes, beyond bare name
coverage (tools/coverage_audit.py):

  1. functions: name coverage + a signature-shape verdict
     (ok / shim-only / arity-gap / missing), where "shim-only" means callers
     must reach for `Raylib.rl_*` and marshal pointers themselves;
  2. structs: gem classes and their fields vs our `native_struct` classes and
     `native_method` accessors (aliases resolved);
  3. helpers: the gem's Ruby helper layer (create/copy_from/to_a, Model#*,
     ModelAnimations, Transform#t/r/s, module helpers) vs ours;
  4. constants: gem enum/define names vs our constants.

Reports: reference/reports/gem_compat.md (+ .json worklist).
Usage: python3 tools/gem_compat_audit.py [--gem DIR] [--json OUT] [--md OUT]
"""

import glob
import json
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, "lib")
GEM_GEN = os.path.join(os.path.dirname(ROOT), "raylib-bindings", "generator")
REPORTS = os.path.join(ROOT, "reference", "reports")

LIBS = {
    "raylib": "raylib_main.rb",
    "raymath": "raymath.rb",
    "rlgl": "rlgl.rb",
    "physac": "physac.rb",
    "rcamera": "rcamera.rb",
    "raygui": "raygui_main.rb",
}
FFI_FILES = ["raylib_ffi.rb", "raymath_ffi.rb", "rlgl_ffi.rb", "physac_ffi.rb",
             "rcamera_ffi.rb", "raygui_ffi.rb", "raylib_ruby.rb"]

ENTRY_RE = re.compile(r"^\s*\[:(\w+), :(\w+), \[([^\]]*)\], ([\w.:]+)\]", re.M)


def gem_lib_dir(explicit=None):
    if explicit:
        return explicit
    try:
        gemdir = subprocess.run(["gem", "env", "gemdir"], capture_output=True,
                                text=True, check=True).stdout.strip()
    except Exception:
        return None
    cands = sorted(glob.glob(os.path.join(gemdir, "raylib-bindings-*", "lib")) +
                   glob.glob(os.path.join(gemdir, "gems", "raylib-bindings-*", "lib")))
    return cands[-1] if cands else None


def gem_entries(gem):
    """{lib: {name: (param_types, ret)}} from the installed gem's entry tables."""
    out = {}
    for lib, fname in LIBS.items():
        path = os.path.join(gem, fname)
        out[lib] = {}
        if not os.path.exists(path):
            continue
        for name, _entry, params, ret in ENTRY_RE.findall(open(path).read()):
            out[lib][name] = ([p.strip() for p in params.split(",") if p.strip()], ret)
    return out


def json_api(lib):
    path = os.path.join(GEM_GEN, "%s_api.json" % lib)
    if not os.path.exists(path):
        return {}
    return json.load(open(path))


def our_sources():
    out = {}
    for f in FFI_FILES:
        path = os.path.join(LIB, f)
        if os.path.exists(path):
            # strip comments so commented-out declarations are not counted
            out[f] = "\n".join(l for l in open(path).read().splitlines()
                              if not re.match(r"\s*#", l))
    return out


def our_surface(src):
    text = "\n".join(src.values())
    wrappers, wrapper_args = {}, {}
    for m in re.finditer(r"def self\.([A-Za-z_]\w*)\(([^)]*)\)", text):
        wrappers[m.group(1)] = True
        wrapper_args.setdefault(m.group(1), m.group(2).strip())
    arityless = set(re.findall(r"def self\.([A-Za-z_]\w*)\b(?!\()", text))
    aliases = set(re.findall(r"alias_method\s+:(\w+),\s*:(\w+)", text))
    alias_targets = {b for _a, b in aliases}
    ffi_counts = {}
    for m in re.finditer(r"ffi_func\s+:(\w+),\s*(?:%i\[([^\]]*)\]|\[([^\]]*)\])", text):
        args = m.group(2) if m.group(2) is not None else m.group(3)
        ffi_counts[m.group(1)] = len([p for p in args.split(",") if p.strip()])
    shim = {n for n in ffi_counts if n.startswith("rl_")}
    direct = set(ffi_counts) - shim
    # native struct classes and their field accessors
    structs = {}
    cur = None
    for line in text.splitlines():
        m = re.match(r'\s*native_struct\s+"(\w+)"', line)
        if m:
            cur = m.group(1)
            structs.setdefault(cur, set())
            continue
        m = re.match(r"\s*native_method\s+:(\w+?)=?\s*,", line)
        if m and cur:
            structs[cur].add(m.group(1))
    return {"wrappers": set(wrappers) | arityless, "wrapper_args": wrapper_args,
            "aliases": aliases, "alias_targets": alias_targets,
            "ffi": direct, "ffi_counts": ffi_counts, "shim": shim,
            "structs": structs, "text": text}


def gem_structs(gem):
    """{class: {fields:set, alias_of:str|None}} from the installed gem."""
    text = open(os.path.join(gem, "raylib_main.rb")).read()
    structs, cur, depth = {}, None, 0
    for line in text.splitlines():
        m = re.match(r"\s*class (\w+) < FFI::Struct", line)
        if m:
            cur = m.group(1)
            structs[cur] = set()
            depth = 1
            continue
        if cur:
            if re.match(r"\s*end\s*$", line) and depth == 1:
                cur = None
                continue
            m = re.match(r'\s*:(\w+),', line)
            if m:
                structs[cur].add(m.group(1))
    for m in re.finditer(r"^\s*(\w+) = (\w+)\s*$", text, re.M):
        if m.group(2) in structs:
            structs[m.group(1)] = structs[m.group(2)]
            structs.setdefault("__aliases__", {})[m.group(1)] = m.group(2)
    return structs


def gem_helpers(gem):
    """[receiver, name, kind] from the gem's Ruby helper layer."""
    text = open(os.path.join(gem, "raylib_helper.rb")).read()
    out = set()
    cur = None
    for line in text.splitlines():
        m = re.match(r"^  class (\w+)", line)
        if m:
            cur = m.group(1)
            continue
        if re.match(r"^  end\s*$", line):
            cur = None
            continue
        m = re.match(r"^    def self\.(\w+)", line)
        if m:
            out.add((cur or "Raylib", m.group(1), "class"))
            continue
        m = re.match(r"^    def (\w+)", line)
        if m:
            out.add((cur or "Raylib", m.group(1), "instance"))
            continue
        m = re.match(r"^  def (\w+)", line)
        if m:
            out.add(("Raylib", m.group(1), "module"))
    return out


def gem_constants(gem):
    """Constant names the installed gem actually defines (module level)."""
    names = set()
    for fname in LIBS.values():
        path = os.path.join(gem, fname)
        if not os.path.exists(path):
            continue
        for line in open(path):
            m = re.match(r"\s*([A-Z][A-Z0-9_]{2,})\s*=", line)
            if m:
                names.add(m.group(1))
    return names


def our_constants(text):
    return (set(re.findall(r"ffi_const\s+:(\w+)", text)) |
            set(re.findall(r"^\s{2,}([A-Z][A-Z0-9_]{2,})\s*=", text, re.M)))


def required_arity(argtext):
    if not argtext:
        return 0, 0
    parts = [p.strip() for p in argtext.split(",") if p.strip()]
    required = len([p for p in parts if "=" not in p and not p.startswith("*")])
    has_rest = any(p.startswith("*") for p in parts)
    return required, (len(parts) if not has_rest else -1)


def main():
    gem = gem_lib_dir()
    if not gem:
        sys.exit("gem_compat_audit: raylib-bindings gem not found")
    entries = gem_entries(gem)
    surf = our_surface(our_sources())
    gstructs = gem_structs(gem)
    aliases = gstructs.pop("__aliases__", {})
    ghelpers = gem_helpers(gem)
    gconsts = gem_constants(gem)
    oconsts = our_constants(surf["text"])

    report = {"gem": gem, "libs": {}, "structs": {}, "helpers": {}, "constants": {}}
    worklist = {"missing": [], "shim_only": [], "arity_gap": [],
                "struct_missing": [], "struct_fields": [], "helper_missing": [],
                "const_missing": []}

    for lib, entries_lib in entries.items():
        rows = {"ok": [], "shim_only": [], "arity_gap": [], "missing": []}
        for name in sorted(entries_lib):
            params, ret = entries_lib[name]
            if name in surf["wrappers"] or name in surf["ffi"]:
                required, total = required_arity(surf["wrapper_args"].get(name, ""))
                if name in surf["ffi"]:
                    n = surf["ffi_counts"].get(name, len(params))
                else:
                    n = total if total >= 0 else len(params)
                if name in surf["wrappers"] and not (required <= len(params) <= n):
                    rows["arity_gap"].append(name)
                else:
                    rows["ok"].append(name)
            elif "rl_" + name in surf["shim"]:
                rows["shim_only"].append(name)
            else:
                rows["missing"].append(name)
        report["libs"][lib] = {"total": len(entries_lib), **{k: len(v) for k, v in rows.items()}}
        for k in ("missing", "shim_only", "arity_gap"):
            worklist[k].extend("%s:%s" % (lib, n) for n in rows[k])

    for cls in sorted(gstructs):
        fields = gstructs[cls]
        if cls not in surf["structs"]:
            worklist["struct_missing"].append(cls)
            continue
        miss = sorted(fields - surf["structs"][cls])
        if miss:
            worklist["struct_fields"].append("%s: %s" % (cls, ", ".join(miss)))
    report["structs"] = {"gem_classes": len(gstructs), "aliases": aliases,
                         "ours": sorted(surf["structs"])}

    for recv, name, kind in sorted(ghelpers):
        if name in surf["wrappers"] or name in surf["aliases"] or \
           re.search(r"def %s\b" % re.escape(name), surf["text"]):
            continue
        worklist["helper_missing"].append("%s:%s.%s" % (kind, recv, name))

    missing_c = sorted(gconsts - oconsts)
    worklist["const_missing"] = missing_c

    os.makedirs(REPORTS, exist_ok=True)
    json.dump({"report": report, "worklist": worklist},
              open(os.path.join(REPORTS, "gem_compat.json"), "w"), indent=1)

    md = []
    md.append("# gem compatibility audit\n")
    md.append("Baseline: installed raylib-bindings gem + generator JSONs (raylib 6.1). "
              "Tool: `tools/gem_compat_audit.py`.\n")
    md.append("## Functions\n")
    md.append("| lib | total | ok | shim-only | arity-gap | missing |")
    md.append("| --- | --- | --- | --- | --- | --- |")
    for lib, r in report["libs"].items():
        md.append("| %s | %d | %d | %d | %d | %d |"
                  % (lib, r["total"], r["ok"], r["shim_only"], r["arity_gap"], r["missing"]))
    md.append("\n### Arity/signature gaps\n")
    md.append("`%s`\n" % "`, `".join(worklist["arity_gap"]))
    md.append("\n### Missing functions\n")
    md.append("`%s`\n" % "`, `".join(worklist["missing"]))
    md.append("\n## Structs\n")
    md.append("Missing classes (%d): `%s`\n" % (len(worklist["struct_missing"]),
                                                 "`, `".join(worklist["struct_missing"])))
    md.append("Field gaps (%d):\n" % len(worklist["struct_fields"]))
    for row in worklist["struct_fields"]:
        md.append("- %s" % row)
    md.append("\n## Helpers\n")
    md.append("Missing helper methods (%d):\n" % len(worklist["helper_missing"]))
    for row in worklist["helper_missing"]:
        md.append("- %s" % row)
    md.append("\n## Constants\n")
    md.append("Missing constants (%d): `%s`%s\n"
              % (len(worklist["const_missing"]),
                 "`, `".join(worklist["const_missing"][:80]),
                 " …" if len(worklist["const_missing"]) > 80 else ""))
    open(os.path.join(REPORTS, "gem_compat.md"), "w").write("\n".join(md))
    print("wrote", os.path.join(REPORTS, "gem_compat.md"))

    print("== gem:", gem)
    for lib, r in report["libs"].items():
        print("%-8s total=%-4d ok=%-4d shim-only=%-3d arity-gap=%-3d missing=%-3d"
              % (lib, r["total"], r["ok"], r["shim_only"], r["arity_gap"], r["missing"]))
    print("structs: gem=%d ours=%d missing=%d field-gaps=%d"
          % (report["structs"]["gem_classes"], len(report["structs"]["ours"]),
             len(worklist["struct_missing"]), len(worklist["struct_fields"])))
    print("helpers missing:", len(worklist["helper_missing"]))
    print("constants missing:", len(missing_c))
    print("\nworklist summary:",
          {k: len(v) for k, v in worklist.items()})
    print("wrote", os.path.join(REPORTS, "gem_compat.json"))


if __name__ == "__main__":
    main()
