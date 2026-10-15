#!/usr/bin/env python3
"""guard_unload_frees.py -- Unload<Kind> must not free a borrowed payload.

A view's `p` is either a heap copy this library made (a producer: Load*/Gen*
wrapped by wrap_handle_producers.py, owner = nil) or an *interior* pointer into
someone else's struct (an accessor: `font.texture` -> &font->texture, owner =
the parent view). Unloading the second kind used to call free() on an interior
pointer: `munmap_chunk(): invalid pointer`.

The fix keys on the owner slot the views already carry: producer wrappers pass
nil, accessors pass the parent view. Free only when the payload is not the
embedded `v` and the owner is nil.

Rewrites lib/raylib_adapter.c (`free(self);` inside the view-based Unload
shims). Idempotent; `--check` reports without writing.

Usage: python3 tools/guard_unload_frees.py [--check]
"""

import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ADAPTER = os.path.join(ROOT, "lib", "raylib_adapter.c")

MACRO_CLASS = {
    "RL_TEX": "Texture2D", "RL_SHDR": "Shader", "RL_IMG": "Image",
    "RL_FONT": "Font", "RL_MODEL": "Model", "RL_MESH": "Mesh",
    "RL_MAT": "Material", "RL_RT": "RenderTexture", "RL_GLYPH": "GlyphInfo",
    "RL_ANIM": "ModelAnimation", "RL_BONE": "BoneInfo",
    "RL_AEVLIST": "AutomationEventList", "RL_AEVENT": "AutomationEvent",
    "RL_TRANSFORM": "Transform",
}


def main():
    check_only = "--check" in sys.argv
    lines = open(ADAPTER).read().split("\n")
    changed = []
    for i, line in enumerate(lines):
        if "free(self);" not in line:
            continue
        if "owner.tag" in line:
            continue  # already guarded
        # find the RL_<MACRO>(<param>) that produced `self` (a few lines up)
        macro = param = cls = None
        for j in range(max(0, i - 4), i):
            m = re.search(r"RL_(\w+)\((\w+)\)", lines[j])
            if m and ("RL_" + m.group(1)) in MACRO_CLASS:
                macro, param = m.group(1), m.group(2)
                cls = MACRO_CLASS["RL_" + macro]
                break
        if not cls:
            continue  # a raw handle (Wave/Sound/AudioStream): heap copy, free is right
        indent = line[:len(line) - len(line.lstrip())]
        guard = ("%sif (self != &((rl_%s *)%s)->v && ((rl_%s *)%s)->owner.tag == SP_TAG_NIL)"
                 " free(self);" % (indent, cls, param, cls, param))
        changed.append((i + 1, cls, param, line.strip(), guard.strip()))
        lines[i] = guard
    for lineno, cls, param, old, new in changed:
        print("raylib_adapter.c:%d  %s\n  - %s\n  + %s" % (lineno, cls, old, new))
    print("%d free site(s) %s" % (len(changed), "need fixing" if check_only else "fixed"))
    if changed and not check_only:
        open(ADAPTER, "w").write("\n".join(lines))
    return 1 if (check_only and changed) else 0


if __name__ == "__main__":
    sys.exit(main())
