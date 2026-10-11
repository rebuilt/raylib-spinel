#!/usr/bin/env python3
"""coverage_audit.py — raylib API surface vs. raylib-spinel's exposed surface.

Baseline: the MRI raylib-bindings generator API jsons (all six libraries).
Those jsons are version-synced with the local raylib checkout (see the
version guard in gen_raylib_ffi.py), so they are the compatibility contract
this library targets.

Our surface, per lib/<name>_ffi.rb:
  * ffi_func :Name        -> direct extern (linker resolves to libraylib.so)
  * ffi_func :rl_Name     -> struct-shim extern (see *_adapter.c)
  * def self.Name         -> Ruby wrapper (hides pointer marshalling)
  * native_method/native_new -> methods on native struct classes (not top-level)

An API function counts as covered when any of the three top-level forms
exposes it under its exact API name (def self.Name or ffi_func :Name) or
under the shim name (ffi_func :rl_Name). Shim-only coverage is flagged: the
function is callable but callers must pass raw pointers (Raylib.rl_X), which
is not the intended public surface.

Usage: python3 tools/coverage_audit.py [--json OUT]
"""

import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, "lib")
GEM_GEN = os.path.join(os.path.dirname(ROOT), "raylib-bindings", "generator")

LIBS = ["raylib", "raymath", "rlgl", "physac", "rcamera", "raygui"]


def api_functions(lib):
    path = os.path.join(GEM_GEN, "%s_api.json" % lib)
    api = json.load(open(path))
    return {f["name"]: f for f in api.get("functions", [])}


def our_surface(lib):
    path = os.path.join(LIB, "%s_ffi.rb" % lib)
    if not os.path.exists(path):
        return {"ffi": set(), "shim": set(), "wrapper": set(), "missing_file": True}
    text = open(path).read()
    ffi = set(re.findall(r"ffi_func\s+:(\w+)", text))
    wrappers = set(re.findall(r"def self\.([A-Za-z_]\w*)", text))
    shim = {n for n in ffi if n.startswith("rl_")}
    ffi -= shim
    return {"ffi": ffi, "shim": shim, "wrapper": wrappers, "missing_file": False}


def classify(name, surf):
    if name in surf["wrapper"]:
        return "wrapper"
    if name in surf["ffi"]:
        return "direct"
    if "rl_" + name in surf["shim"]:
        return "shim-only"
    return None


def main():
    json_out = None
    if "--json" in sys.argv:
        json_out = sys.argv[sys.argv.index("--json") + 1]

    report = {}
    grand = {"total": 0, "covered": 0}
    for lib in LIBS:
        api = api_functions(lib)
        surf = our_surface(lib)
        rows = {"wrapper": [], "direct": [], "shim-only": [], "missing": []}
        for name in sorted(api):
            kind = classify(name, surf)
            rows[kind or "missing"].append(name)
        covered = len(api) - len(rows["missing"])
        grand["total"] += len(api)
        grand["covered"] += covered
        # exposed-but-not-in-api (custom shims/helpers), informational only
        api_names = set(api)
        extras = sorted(
            (surf["ffi"] | surf["shim"]) - api_names - {"rl_" + n for n in api_names}
        )
        report[lib] = {
            "api": len(api),
            "covered": covered,
            "wrapper": rows["wrapper"],
            "direct": rows["direct"],
            "shim_only": rows["shim-only"],
            "missing": rows["missing"],
            "extras": extras,
        }
        print("== %s: %d/%d covered (%d wrapper, %d direct, %d shim-only, %d missing)"
              % (lib, covered, len(api), len(rows["wrapper"]), len(rows["direct"]),
                 len(rows["shim-only"]), len(rows["missing"])))
        if rows["shim-only"]:
            print("   shim-only (callable only as Raylib.rl_*): %s"
                  % ", ".join(rows["shim-only"]))
        if rows["missing"]:
            print("   missing: %s" % ", ".join(rows["missing"]))
        if extras:
            print("   extras (exposed, not in API json): %s" % ", ".join(extras))

    print("\nTOTAL: %d/%d (%.1f%%)" % (grand["covered"], grand["total"],
                                       100.0 * grand["covered"] / grand["total"]))
    if json_out:
        json.dump(report, open(json_out, "w"), indent=1)
        print("wrote", json_out)


if __name__ == "__main__":
    main()
