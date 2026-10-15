#!/usr/bin/env python3
"""fix_pointer_handle_shims.py -- unwrap single-struct handle pointers in shims.

`Image *image` / `Material *material` style parameters name the *payload* in
the raylib API, but the Ruby surface passes an rl_<X> view (a GC object whose
first bytes are cls_id/p/owner). A shim that forwards the view pointer straight
to raylib hands it a struct full of view bookkeeping: raylib then mutates or
dereferences garbage. The fix is the same unwrap the by-value parameters
already use, wrapped around the parameter name.

This rewrites the shim bodies in lib/raylib_adapter.c:
  ImageX(image, ...)      -> ImageX(RL_IMG(image), ...)
  CheckCollisionLines(..., collisionPoint) -> CheckCollisionLines(..., RL_V2(collisionPoint))

Idempotent: a parameter already mentioned as RL_<C>(param) is left alone.
Array parameters (`const Vector2 *points`, `Matrix *transforms`, ...) are
deliberately raw -- the Ruby side passes a flat buffer, not a view.

Usage: python3 tools/fix_pointer_handle_shims.py [--check]
"""

import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, "lib")
API_DIR = os.path.join(os.path.dirname(ROOT), "raylib-bindings", "generator")

ADAPTER = os.path.join(LIB, "raylib_adapter.c")

# single-struct pointer parameters of the promoted classes
CLASS_MACRO = {"Image": "RL_IMG", "Material": "RL_MAT", "Mesh": "RL_MESH",
               "Shader": "RL_SHDR", "Texture2D": "RL_TEX", "Font": "RL_FONT",
               "Model": "RL_MODEL"}
# explicit exceptions (out-params / classes whose pointer form is a view)
EXTRA = {"CheckCollisionLines": {"collisionPoint": "RL_V2"}}

DEF_RE = re.compile(r"^(?:void|int|float|double|bool|char|size_t|unsigned [a-z]+|"
                    r"[A-Za-z_]\w*(?: \w+)? \*?)\s*rl_(\w+)\(([^)]*)\)\s*\{$")


def base_type(t):
    return t.replace("const ", "").replace("*", "").strip()


def targets():
    """{function: {param: macro}} for single-struct handle pointers."""
    out = {}
    for fname in ("raylib_api.json", "physac_api.json", "rcamera_api.json"):
        path = os.path.join(API_DIR, fname)
        if not os.path.exists(path):
            continue
        data = json.load(open(path))
        fns = data["functions"] if isinstance(data, dict) else data
        for fn in fns:
            for p in fn.get("params", []):
                t = p.get("type", "")
                macro = CLASS_MACRO.get(base_type(t))
                if macro and t.rstrip().endswith("*") and "**" not in t:
                    out.setdefault(fn["name"], {})[p["name"]] = macro
    for fn, params in EXTRA.items():
        out.setdefault(fn, {}).update(params)
    return out


def main():
    check_only = "--check" in sys.argv
    want = targets()
    lines = open(ADAPTER).read().split("\n")
    changed, i = [], 0
    while i < len(lines):
        m = DEF_RE.match(lines[i])
        if not m:
            i += 1
            continue
        name, raw = m.group(1), m.group(2)
        params = {p.strip().split()[-1].lstrip("*")
                  for p in raw.split(",") if p.strip()}
        start, body = i, []
        j = i + 1
        while j < len(lines) and lines[j] != "}":
            body.append(lines[j])
            j += 1
        fixes = {p: mac for p, mac in want.get(name, {}).items()
                 if p in params}
        if fixes:
            for k, line in enumerate(body):
                for p, mac in fixes.items():
                    if re.search(r"\b%s\s*\(\s*%s\s*\)" % (mac, re.escape(p)), line):
                        continue  # already unwrapped
                    new = re.sub(r"(?<![\w>:])%s(?![\w])" % re.escape(p),
                                 "%s(%s)" % (mac, p), line)
                    if new != line:
                        changed.append((name, p, mac, line.strip(), new.strip()))
                        line = new
                body[k] = line
        lines[start + 1:j] = body
        i = j + 1

    for name, p, mac, old, new in changed:
        print("rl_%s: %s -> %s\n  - %s\n  + %s" % (name, p, mac, old, new))
    print("%d shim parameter(s) %s" % (len(changed),
                                       "need fixing" if check_only else "fixed"))
    if changed and not check_only:
        open(ADAPTER, "w").write("\n".join(lines))
    return 1 if (check_only and changed) else 0


if __name__ == "__main__":
    sys.exit(main())
