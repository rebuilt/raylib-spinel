#!/usr/bin/env python3
"""add_handle_views.py — migrate the adapter consumers of the handle classes.

Rewrites raw-struct casts in lib/*.c onto the RL_<X> unwrap macros:

    *(Image *)expr        ->  *RL_IMG(expr)
    ((Font *)expr)->field ->  RL_FONT(expr)->field
    Font *f = (Font *)e;  ->  Font *f = RL_FONT(e);

Heap allocations (`(Image *)malloc(...)`) are left alone: the shims produce
raw pointers, the Ruby layer wraps them into views. The generated class
sections (gen_handle_class_c.py markers) are masked so their own casts are not
touched.

Run after gen_handle_class_c.py. Idempotent: migrated casts no longer match.
"""

import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, "lib")
FILES = ["raylib_adapter.c", "raygui_adapter.c", "raymath_adapter.c",
         "rlgl_adapter.c", "rcamera_adapter.c", "physac_adapter.c"]

# class, macro, alias spellings (Texture2D and Texture are the same struct)
CLASSES = [
    ("Image", "RL_IMG", []),
    ("Texture2D", "RL_TEX", ["Texture"]),
    ("Font", "RL_FONT", []),
    ("GlyphInfo", "RL_GLYPH", []),
    ("RenderTexture", "RL_RT", ["RenderTexture2D"]),
    ("Model", "RL_MODEL", []),
    ("Material", "RL_MAT", []),
    ("Mesh", "RL_MESH", []),
    ("Shader", "RL_SHDR", []),
    ("ModelAnimation", "RL_ANIM", []),
]

MASK_MARKERS = [
    ("/* ==== handle-class views: preamble", "/* ==== end handle-class views preamble ==== */"),
    ("/* ==== handle-class views: implementation", "/* ==== end handle-class views implementation ==== */"),
]


def expr_after(text, pos):
    """The expression starting at pos: a balanced (...) or a simple identifier."""
    while pos < len(text) and text[pos] in " \t":
        pos += 1
    if pos < len(text) and text[pos] == "(":
        depth, k = 0, pos
        while k < len(text):
            if text[k] == "(":
                depth += 1
            elif text[k] == ")":
                depth -= 1
                if depth == 0:
                    return pos, k + 1
            k += 1
        raise AssertionError("unbalanced")
    m = re.match(r"[A-Za-z_]\w*", text[pos:])
    assert m, text[pos:pos + 30]
    return pos, pos + m.end()


def migrate(text, name, macro):
    casts = []
    for m in re.finditer(r"\(\s*%s\s*\*\)" % re.escape(name), text):
        es, ee = expr_after(text, m.end())
        expr = text[es:ee]
        if re.match(r"(malloc|calloc|realloc)\b", expr):
            continue                      # heap copy produced by a shim
        before = text[max(0, m.start() - 1):m.start()]
        after = text[ee:ee + 2]
        if before == "*":
            casts.append((m.start() - 1, ee, "*%s(%s)" % (macro, expr)))
        elif after == "->":
            casts.append((m.start(), ee, "%s(%s)" % (macro, expr)))
        else:
            casts.append((m.start(), ee, "%s(%s)" % (macro, expr)))
    for s, e, rep in sorted(casts, reverse=True):
        text = text[:s] + rep + text[e:]
    return text, len(casts)


def main():
    for fname in FILES:
        path = os.path.join(LIB, fname)
        if not os.path.exists(path):
            continue
        text = open(path).read()

        # mask the generated class sections
        masked, holds = text, []
        for begin, end in MASK_MARKERS:
            for m in re.finditer(re.escape(begin) + r".*?" + re.escape(end), masked, re.S):
                holds.append(m.group(0))
                masked = masked[:m.start()] + ("\x00%d\x00" % (len(holds) - 1)) + masked[m.end():]

        total = 0
        for name, macro, aliases in CLASSES:
            for spelling in [name] + aliases:
                masked, n = migrate(masked, spelling, macro)
                total += n

        for i, hold in enumerate(holds):
            masked = masked.replace("\x00%d\x00" % i, hold)
        if masked != text:
            open(path, "w").write(masked)
            print("%-22s migrated %d cast(s)" % (fname, total))
    print("done")


if __name__ == "__main__":
    main()
