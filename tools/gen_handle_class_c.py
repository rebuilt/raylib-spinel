#!/usr/bin/env python3
"""gen_handle_class_c.py — emit the handle-class view machinery into an adapter.

For each class in the config below, emits (into lib/raylib_adapter.c):

  * a preamble section (after the includes): `RL_<X>` unwrap macros and the
    `rl_<Class>` wrapper structs, so migrated consumers earlier in the file can
    use them;
  * an implementation section (end of file): scan, owned ctor, view ctor
    (`[:any]` pointer + owner, unboxed in C), and the `rl_m_*` native
    accessors the Ruby native_methods bind to.

The sections are delimited by markers, so re-running replaces them instead of
appending. Run tools/add_handle_views.py afterwards to migrate the consumers.

Usage: python3 tools/gen_handle_class_c.py
"""

import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ADAPTER = os.path.join(ROOT, "lib", "raylib_adapter.c")
HEADER = os.path.join(ROOT, "lib", "rl_handle_views.h")
ADAPTERS = ["raylib_adapter.c", "raygui_adapter.c", "raymath_adapter.c",
            "rlgl_adapter.c", "rcamera_adapter.c", "physac_adapter.c"]

PRE_BEGIN = "/* ==== handle-class views: preamble (gen_handle_class_c.py) ==== */"
PRE_END = "/* ==== end handle-class views preamble ==== */"
IMP_BEGIN = "/* ==== handle-class views: implementation (gen_handle_class_c.py) ==== */"
IMP_END = "/* ==== end handle-class views implementation ==== */"

# class name, payload C type, macro, [(ruby field, C member expr, C return type)]
CLASSES = [
    ("Image", "Image", "RL_IMG", [
        ("width", "width", "int"), ("height", "height", "int"),
        ("mipmaps", "mipmaps", "int"), ("format", "format", "int")]),
    ("Texture2D", "Texture2D", "RL_TEX", [
        ("id", "id", "unsigned int"), ("width", "width", "int"),
        ("height", "height", "int"), ("mipmaps", "mipmaps", "int"),
        ("format", "format", "int")]),
    ("Font", "Font", "RL_FONT", [
        ("baseSize", "baseSize", "int"), ("glyphCount", "glyphCount", "int"),
        ("glyphPadding", "glyphPadding", "int")]),
    ("GlyphInfo", "GlyphInfo", "RL_GLYPH", [
        ("value", "value", "int"), ("offsetX", "offsetX", "int"),
        ("offsetY", "offsetY", "int"), ("advanceX", "advanceX", "int")]),
    ("RenderTexture", "RenderTexture", "RL_RT", []),
    ("Model", "Model", "RL_MODEL", [
        ("meshCount", "meshCount", "int"), ("materialCount", "materialCount", "int"),
        ("boneCount", "skeleton.boneCount", "int")]),
    ("Material", "Material", "RL_MAT", []),
    ("Mesh", "Mesh", "RL_MESH", [
        ("vertexCount", "vertexCount", "int"),
        ("triangleCount", "triangleCount", "int")]),
    ("Shader", "Shader", "RL_SHDR", [("id", "id", "int")]),
    ("ModelAnimation", "ModelAnimation", "RL_ANIM", [
        ("keyframeCount", "keyframeCount", "int"),
        ("boneCount", "boneCount", "int")]),
    ("BoneInfo", "BoneInfo", "RL_BONE", [
        ("parent_bone_index", "parent", "int")]),
]

# Classes whose struct comes from the migration script (no preamble/owned ctor
# emitted here): only an unboxing view ctor is added, after rl_h_unbox.
EXTRA_VIEW_CTORS = [("Transform", "Transform", "RL_TRANSFORM")]

INT_TYPES = {"int", "unsigned int", "unsigned char", "char", "short"}


def preamble():
    out = [PRE_BEGIN,
           "/* Handle classes use the same owned/view layout as the vectors:",
           " * payload in `v`, or a view over someone else's memory via `p`",
           " * (raw heap copies from the shims, interior pointers like",
           " * Font.texture). */"]
    for name, payload, macro, fields in CLASSES:
        out.append("typedef struct rl_%s_s {" % name)
        out.append("  sp_int cls_id;")
        out.append("  %s *p;            /* NULL: owned; non-NULL: view */" % payload)
        out.append("  sp_RbVal owner;    /* view: GC-marked owner (nil if none) */")
        out.append("  %s v;             /* owned payload */" % payload)
        out.append("} rl_%s;" % name)
        out.append("#define %s(o) (((rl_%s *)(o))->p ? ((rl_%s *)(o))->p : &((rl_%s *)(o))->v)"
                   % (macro, name, name, name))
    out.append(PRE_END)
    return "\n".join(out) + "\n"


def implementation():
    out = [IMP_BEGIN,
           "/* Handles are normally views: the producers return a raw pointer to",
           " * a heap copy (or an interior pointer), and the Ruby layer wraps it",
           " * with <Class>.new(ptr, owner). The owned ctor exists for symmetry. */",
           "static void *rl_h_unbox(sp_RbVal v) {",
           "  if (v.tag == SP_TAG_INT) return (void *)(intptr_t)v.v.i;",
           "  if (v.tag == SP_TAG_OBJ) return v.v.p;",
           "  return NULL;",
           "}",
           ""]
    for name, payload, macro, fields in CLASSES:
        out.append("static void rl_%s_scan(void *p) {" % name)
        out.append("  rl_%s *s = (rl_%s *)p;" % (name, name))
        out.append("  if (s->p) sp_mark_rbval(s->owner);")
        out.append("}")
        out.append("rl_%s *rl_%s_new(sp_int cls_id) {" % (name, name))
        out.append("  rl_%s *s = (rl_%s *)sp_gc_alloc(sizeof(rl_%s), NULL, rl_%s_scan);"
                   % (name, name, name, name))
        out.append("  memset(s, 0, sizeof *s);")
        out.append("  s->cls_id = cls_id;")
        out.append("  return s;")
        out.append("}")
        out.append("rl_%s *rl_%s_view(sp_int cls_id, sp_RbVal pv, sp_RbVal owner) {"
                   % (name, name))
        out.append("  rl_%s *s = (rl_%s *)sp_gc_alloc(sizeof(rl_%s), NULL, rl_%s_scan);"
                   % (name, name, name, name))
        out.append("  s->cls_id = cls_id;")
        out.append("  s->p = (%s *)rl_h_unbox(pv);" % payload)
        out.append("  s->owner = owner;")
        out.append("  return s;")
        out.append("}")
        for field, member, ctype in fields:
            ret = "double" if ctype in ("float", "double") else "sp_int"
            cast = "(sp_int)" if ret == "sp_int" else "(double)"
            out.append("%s rl_m_%s_%s(rl_%s *self) { return %s%s(self)->%s; }"
                       % (ret, name, field, name, cast, macro, member))
        out.append("rl_%s *rl_%s_view_addr(sp_int cls_id, sp_RbVal addr) {" % (name, name))
        out.append("  rl_%s *s = (rl_%s *)sp_gc_alloc(sizeof(rl_%s), NULL, rl_%s_scan);"
                   % (name, name, name, name))
        out.append("  s->cls_id = cls_id;")
        out.append("  s->p = (%s *)rl_h_unbox(addr);" % payload)
        out.append("  s->owner = sp_box_nil();")
        out.append("  return s;")
        out.append("}")
        out.append("")
    for name, payload, macro in EXTRA_VIEW_CTORS:
        out.append("rl_%s *rl_%s_view_any(sp_int cls_id, sp_RbVal pv, sp_RbVal owner) {"
                   % (name, name))
        out.append("  rl_%s *s = (rl_%s *)sp_gc_alloc(sizeof(rl_%s), NULL, rl_%s_scan);"
                   % (name, name, name, name))
        out.append("  s->cls_id = cls_id;")
        out.append("  s->p = (%s *)rl_h_unbox(pv);" % payload)
        out.append("  s->owner = owner;")
        out.append("  return s;")
        out.append("}")
        out.append("")
    out.append("/* Rectangle view from an address Integer (the gem idiom")
    out.append(" * `Rectangle.new(font.recs + i * Rectangle.size)`; the argument is a")
    out.append(" * boxed Integer because Spinel boxes poly arithmetic). */")
    out.append("Rectangle *rl_Rectangle_view_addr(sp_int cls_id, sp_RbVal addr) {")
    out.append("  Rectangle *payload = (Rectangle *)(intptr_t)(addr.tag == SP_TAG_INT"
               " ? addr.v.i : 0);")
    out.append("  rl_Rectangle *s = (rl_Rectangle *)sp_gc_alloc(sizeof(rl_Rectangle),"
               " NULL, rl_Rectangle_scan);")
    out.append("  s->cls_id = cls_id;")
    out.append("  s->p = payload;")
    out.append("  s->owner = sp_box_nil();")
    out.append("  return s;")
    out.append("}")
    out.append(IMP_END)
    return "\n".join(out) + "\n"


def replace_section(text, begin, end, block):
    pat = re.compile(re.escape(begin) + r".*?" + re.escape(end) + r"\n", re.S)
    if pat.search(text):
        return pat.sub(lambda m: block, text, count=1)
    return None


def main():
    pre = preamble()
    imp = implementation()
    open(HEADER, "w").write(pre)
    print("wrote %s (%d classes)" % (HEADER, len(CLASSES)))

    lib = os.path.join(ROOT, "lib")
    for fname in ADAPTERS:
        path = os.path.join(lib, fname)
        if not os.path.exists(path):
            continue
        text = open(path).read()
        # drop a previous in-file preamble (older layout)
        text = replace_section(text, PRE_BEGIN, PRE_END, "") or text
        if '#include "rl_handle_views.h"' not in text:
            m = re.search(r"^(#include .*\n)+", text, re.M)
            text = text[:m.end()] + '#include "rl_handle_views.h"\n' + text[m.end():]
        if fname == "raylib_adapter.c":
            if IMP_BEGIN in text:
                text = replace_section(text, IMP_BEGIN, IMP_END, imp)
            else:
                text = text.rstrip() + "\n\n" + imp
        open(path, "w").write(text)
        print("patched", fname)
    print("done")


if __name__ == "__main__":
    main()
