#!/usr/bin/env python3
"""mri_drift.py — MRI raylib-bindings API drift.

Two comparisons:

1. Across installed gem versions (raylib-bindings-<ver>-<platform> under
   `gem env gemdir`): functions added / removed / signature-changed between
   adjacent versions, per library. This is the "what did the MRI gem add or
   drop" signal; the local raylib-bindings checkout is already synced to the
   current raylib, so installed-gem history is where the drift lives.

2. Latest MRI gem vs. raylib-spinel's exposed surface (same extraction as
   coverage_audit.py): MRI-only names are functions the MRI gem gives users
   that we do not expose (coverage gaps + snake_case alias targets). Our
   extra surface -- snake_case aliases of MRI names plus custom adapter
   shims/helpers -- is not drift, so it is not reported.

MRI surfaces are extracted from the generated entry tables:
    [:Name, :entry_point, [:param, ...], :return]

Usage: python3 tools/mri_drift.py [--json OUT]
"""

import glob
import json
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import coverage_audit as ca  # noqa: E402

ENTRY_RE = re.compile(r"^\s*\[:(\w+), :(\w+), \[([^\]]*)\], ([\w.:]+)\]", re.M)

MRI_FILES = {
    "raylib": "raylib_main.rb",
    "raymath": "raymath.rb",
    "rlgl": "rlgl.rb",
    "physac": "physac.rb",
    "rcamera": "rcamera.rb",
    "raygui": "raygui_main.rb",
}


def gem_dir():
    try:
        return subprocess.run(["gem", "env", "gemdir"], capture_output=True,
                              text=True, check=True).stdout.strip()
    except Exception:
        return None


def gem_versions(root):
    out = []
    # `gem env gemdir` is the versioned gems root; installed gem dirs live
    # directly under it or under its gems/ subdir depending on setup.
    candidates = glob.glob(os.path.join(root, "raylib-bindings-*")) + \
                 glob.glob(os.path.join(root, "gems", "raylib-bindings-*"))
    for d in candidates:
        m = re.search(r"raylib-bindings-(\d+(?:\.\d+)*)-", os.path.basename(d))
        if m:
            out.append((tuple(int(x) for x in m.group(1).split(".")), m.group(1), d))
    return sorted(out)


def mri_surface(gem_path, lib):
    path = os.path.join(gem_path, "lib", MRI_FILES[lib])
    if not os.path.exists(path):
        return {}
    surf = {}
    for name, entry, params, ret in ENTRY_RE.findall(open(path).read()):
        surf[name] = {"entry": entry,
                      "params": [p.strip().lstrip(":") for p in params.split(",") if p.strip()],
                      "ret": ret.lstrip(":")}
    return surf


def diff(a, b):
    added = sorted(set(b) - set(a))
    removed = sorted(set(a) - set(b))
    changed = []
    for n in sorted(set(a) & set(b)):
        if a[n] != b[n]:
            changed.append((n, a[n], b[n]))
    return added, removed, changed


def main():
    json_out = None
    if "--json" in sys.argv:
        json_out = sys.argv[sys.argv.index("--json") + 1]

    root = gem_dir()
    if not root:
        sys.exit("could not locate gem dir (gem env gemdir)")
    versions = gem_versions(root)
    if len(versions) < 2:
        print("installed raylib-bindings gems found: %s" % [v[1] for v in versions])
        sys.exit("need >= 2 installed versions for drift detection")

    report = {"versions": [v[1] for v in versions], "between": {}, "vs_ours": {}}

    print("== MRI gem versions installed: %s" % ", ".join(v[1] for v in versions))
    for (ka, va, da), (kb, vb, db) in zip(versions, versions[1:]):
        print("\n== %s -> %s" % (va, vb))
        key = "%s->%s" % (va, vb)
        report["between"][key] = {}
        for lib in MRI_FILES:
            a, b = mri_surface(da, lib), mri_surface(db, lib)
            if not a or not b:
                continue
            added, removed, changed = diff(a, b)
            report["between"][key][lib] = {
                "added": added, "removed": removed,
                "changed": [{"name": n, "from": f, "to": t} for n, f, t in changed],
            }
            if added or removed or changed:
                print("  %s: +%s -%s ~%d" % (lib, added or "-", removed or "-", len(changed)))
                for n, f, t in changed:
                    print("      %s: %s(%s)->%s  =>  %s(%s)->%s"
                          % (n, f["entry"], ",".join(f["params"]), f["ret"],
                             t["entry"], ",".join(t["params"]), t["ret"]))
            else:
                print("  %s: unchanged (%d fns)" % (lib, len(b)))

    # latest MRI vs ours: report only the MRI-only gaps (what the MRI gem
    # exposes and we do not). Our extra surface is not drift -- it is
    # snake_case aliases of MRI names plus custom adapter shims/helpers -- so
    # it is deliberately not reported.
    latest = versions[-1][2]
    print("\n== MRI %s vs raylib-spinel surface" % versions[-1][1])
    for lib in MRI_FILES:
        mri = mri_surface(latest, lib)
        surf = ca.our_surface(lib)
        mri_only = sorted(n for n in mri if ca.classify(n, surf) is None)
        report["vs_ours"][lib] = {"mri_only": mri_only}
        print("  %s: mri-only=%d" % (lib, len(mri_only)))
        if mri_only:
            print("     mri-only: %s" % ", ".join(mri_only))

    if json_out:
        json.dump(report, open(json_out, "w"), indent=1)
        print("\nwrote", json_out)


if __name__ == "__main__":
    main()
