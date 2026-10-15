#!/usr/bin/env python3
"""add_vector_views.py — P2 migration: view-aware Vector2/Vector3 (one-shot).

Unified owned/view layout for the native Vector2/Vector3 objects:

    typedef struct rl_Vector2_s {
      sp_int cls_id;
      Vector2 *p;     /* NULL: owned (payload in v); non-NULL: view into an owner */
      sp_RbVal owner; /* view: GC-marked reference to the owner */
      Vector2 v;
    } rl_Vector2;

Every consumer reads the payload through RL_V2/RL_V3; constructors initialize
`p = NULL`; `rl_VectorN_view` builds a view over an interior pointer. The
generated shims (tools/gen_raylib_ffi.py) emit the same RL_Vx form.

Single pass over the original text with collected spans, so offsets stay valid.
Run once; the sources are hand-maintained afterwards.
"""

import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, "lib")
FILES = ["raylib_adapter.c", "raymath_adapter.c", "rlgl_adapter.c",
         "rcamera_adapter.c", "physac_adapter.c"]
CLASSES = (("Vector2", "RL_V2"), ("Vector3", "RL_V3"),
           ("Vector4", "RL_V4"), ("Rectangle", "RL_RECT"))

MACROS = """/* --- P2 views: read the Vector2/Vector3 payload through the view pointer.
 * `p == NULL` for owned objects (payload in `v`); `p != NULL` for views built
 * by rl_VectorN_view, where the payload lives in the owner's C struct. */
#define RL_V2(o) (((rl_Vector2 *)(o))->p ? ((rl_Vector2 *)(o))->p : &((rl_Vector2 *)(o))->v)
#define RL_V3(o) (((rl_Vector3 *)(o))->p ? ((rl_Vector3 *)(o))->p : &((rl_Vector3 *)(o))->v)
#define RL_V4(o) (((rl_Vector4 *)(o))->p ? ((rl_Vector4 *)(o))->p : &((rl_Vector4 *)(o))->v)
#define RL_RECT(o) (((rl_Rectangle *)(o))->p ? ((rl_Rectangle *)(o))->p : &((rl_Rectangle *)(o))->v)

"""

VIEW_CTOR = """
%s *rl_%s_view(sp_int cls_id, void *p, sp_RbVal owner) {
  rl_%s *self = (rl_%s *)sp_gc_alloc(sizeof(rl_%s), NULL, rl_%s_scan);
  self->cls_id = cls_id;
  self->p = (%s *)p;
  self->owner = owner;
  return self;
}
"""


def function_spans(text):
    """[(start, end, signature, body)] for every definition with a body."""
    out = []
    for m in re.finditer(r"(?m)^[A-Za-z_][^\n{};]*\)[^\n{}]*\{", text):
        brace = text.index("{", m.end() - 1)
        depth, k = 1, brace + 1
        while k < len(text) and depth:
            if text[k] == "{":
                depth += 1
            elif text[k] == "}":
                depth -= 1
            k += 1
        out.append((m.start(), k, text[m.start():brace], text[brace:k]))
    return out


def rewrite_body(body, var, macro):
    """`var->v.x` -> `macro(var)->x`; a bare `var->v` -> `(*macro(var))`."""
    body = re.sub(r"\b%s->v\.(\w+)" % re.escape(var),
                  r"%s(%s)->\1" % (macro, var), body)
    body = re.sub(r"\b%s->v\b(?!\.)" % re.escape(var),
                  r"(*%s(%s))" % (macro, var), body)
    return body


def add_struct_fields(text, name):
    pat = re.compile(r"typedef struct rl_%s_s \{\n(  sp_int cls_id;[^\n]*\n)" % name)
    if not pat.search(text):
        return text
    if re.search(r"typedef struct rl_%s_s \{[^}]*\b%s \*p;" % (name, name), text, re.S):
        return text
    ins = ("  %s *p;     /* NULL: owned (payload in v); non-NULL: a view */\n"
           "  sp_RbVal owner;  /* view: GC-marked reference to the owner */\n"
           % name)
    return pat.sub(lambda m: m.group(0) + ins, text, count=1)


def add_scan(text, name):
    pat = re.compile(r"static void rl_%s_scan\(void \*p\) \{ \(void\)p; \}\n" % name)
    return pat.sub(
        "static void rl_%s_scan(void *p) {\n"
        "  rl_%s *s = (rl_%s *)p;\n"
        "  if (s->p) sp_mark_rbval(s->owner);\n"
        "}\n" % (name, name, name), text, count=1)


def main():
    for fname in FILES:
        path = os.path.join(LIB, fname)
        text = open(path).read()
        missing = [line for line in MACROS.splitlines()
                   if line.startswith("#define")
                   and line.split("(")[0] not in text]
        if missing:
            m = re.search(r"^(#include .*\n)+", text, re.M)
            text = (text[:m.end()] + "\n"
                    + "/* --- P2 view payload access (owned vs view objects). */\n"
                    + "\n".join(missing) + "\n\n" + text[m.end():])
        for name, _macro in CLASSES:
            text = add_struct_fields(text, name)
            text = add_scan(text, name)

        edits = []
        stats = {"ctor": 0, "body": 0, "cast": 0}
        for start, end, sig, body in function_spans(text):
            m = re.search(r"rl_(\w+) \*(\w+)\s*(?:[\),]|\()", sig)
            if not m:
                continue
            macro = dict(CLASSES).get(m.group(1))
            if not macro:
                continue
            var = m.group(2)
            newbody = rewrite_body(body, var, macro)
            if newbody != body:
                stats["body"] += 1
                edits.append([start, end, sig + newbody])

        # constructor init: every object of the class allocated here gets p = NULL
        for name, _macro in CLASSES:
            alloc = re.compile(
                r"rl_%s \*(\w+) = \(rl_%s \*\)(?:sp_gc_alloc|malloc)\b"
                % (name, name))
            for am in alloc.finditer(text):
                var = am.group(1)
                if any(s <= am.start() < e for s, e, _r in edits):
                    continue
                init = re.compile(r"(\n(\s*)%s->cls_id = [^;]+;\n)" % re.escape(var))
                m2 = init.search(text, am.end())
                if m2 and "%s->p = NULL;" % var not in text[m2.start():m2.end() + 40]:
                    edits.append([m2.end(), m2.end(),
                                  "%s%s->p = NULL;\n" % (m2.group(2), var)])
                    stats["ctor"] += 1

        # cast sites: only those not inside a rewritten function body
        spans = [(s, e) for s, e, _rep in edits]
        claimed = []
        for name, macro in CLASSES:
            for m in re.finditer(r"\(\(rl_%s ?\*\)(\w+)\)->v\.(\w+)" % name, text):
                if any(s <= m.start() < e for s, e in spans):
                    continue
                edits.append([m.start(), m.end(),
                              "%s(%s)->%s" % (macro, m.group(1), m.group(2))])
                claimed.append((m.start(), m.end()))
                stats["cast"] += 1
            for m in re.finditer(r"\(\(rl_%s ?\*\)(\w+)\)->v\b" % name, text):
                if any(s <= m.start() < e for s, e in spans):
                    continue
                if any(s <= m.start() < e for s, e in claimed):
                    continue
                edits.append([m.start(), m.end(), "*%s(%s)" % (macro, m.group(1))])
                stats["cast"] += 1

        edits.sort(key=lambda ed: ed[0], reverse=True)
        for s, e, rep in edits:
            text = text[:s] + rep + text[e:]

        for name, _macro in (CLASSES if fname == "raylib_adapter.c" else ()):
            if "rl_%s_view(sp_int cls_id" % name in text:
                continue
            anchor = re.search(
                r"(?m)^(?:static )?rl_%s \*rl_%s_new\(sp_int cls_id[^\n]*\{\n(?:[^\n]*\n)*?\}\n"
                % (name, name), text)
            if not anchor:
                print("  !! no constructor anchor for", name, "in", fname)
                continue
            ctor = VIEW_CTOR % (name, name, name, name, name, name, name)
            text = text[:anchor.end()] + ctor + text[anchor.end():]

        open(path, "w").write(text)
        print("patched %-22s ctors=%d bodies=%d casts=%d"
              % (fname, stats["ctor"], stats["body"], stats["cast"]))


if __name__ == "__main__":
    main()
