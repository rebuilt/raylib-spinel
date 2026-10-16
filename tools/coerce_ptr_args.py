#!/usr/bin/env python3
"""coerce_ptr_args.py -- accept FFI::MemoryPointer at the buffer-shaped wrappers.

The gem's pointer arguments take FFI::MemoryPointer/FFI::Pointer objects (or
Strings/Integers). Under AOT a *statically typed* user-class instance cannot
fill a :ptr slot (src/codegen_call_class.c refuses it; a boxed one raises
TypeError at run time), while the Integer `#address` it holds is accepted.

This rewrites the wrapper bodies that carry flat buffers so they pass the
address instead of the object:

    def self.LoadImageAnim(fileName, frames)
      Image.new(Raylib.rl_LoadImageAnim(fileName, frames), nil)
    end
 ->
    def self.LoadImageAnim(fileName, frames)
      Image.new(Raylib.rl_LoadImageAnim(fileName, Raylib.ptr_addr(frames)), nil)
    end

Only the listed (function, parameter) pairs are touched -- arrays of structs
that gem code builds itself, and out-parameters the gem reads back through the
same MemoryPointer object. Idempotent; `--check` reports without writing.

Usage: python3 tools/coerce_ptr_args.py [--check]
"""

import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, "lib")

# file -> function -> parameters to coerce
# Functions whose pointer argument is filled with ptr_int (always an Integer
# address) rather than ptr_addr (an untyped union that would poison the AOT's
# :ptr acceptance for the whole program).
INT_SAFE = {"UpdateTexture", "UpdateTextureRec"}

TARGETS = {
    "raylib_ffi.rb": {
        # buffer out-parameters
        "LoadImageAnim": ["frames"],
        "UpdateTexture": ["pixels"],
        "UpdateTextureRec": ["pixels"],
        "LoadImageAnimFromMemory": ["frames"],
        "LoadModelAnimations": ["animCount"],
        "LoadFileData": ["dataSize"],
        "LoadCodepoints": ["count"],
        "LoadImagePalette": ["colorCount"],
        "EncodeDataBase64": ["outputSize"],
        # buffers in
        "LoadFontData": ["fileData", "codepoints"],
        "LoadFontFromMemory": ["fileData"],
        "LoadImageFromMemory": ["fileData"],
        "UpdateMeshBuffer": ["data"],
        "SetShaderValue": ["value"],
        "GenImageFontAtlas": ["glyphs", "glyphRecs"],
        # flat point buffers (const Vector2 * / const Vector3 *)
        "DrawLineStrip": ["points"],
        "DrawTriangleFan": ["points"],
        "DrawTriangleStrip": ["points"],
        "DrawTriangleStrip3D": ["points"],
        "DrawSplineLinear": ["points"],
        "DrawSplineBasis": ["points"],
        "DrawSplineCatmullRom": ["points"],
        "DrawSplineBezierQuadratic": ["points"],
        "DrawSplineBezierCubic": ["points"],
        "CheckCollisionPointPoly": ["points"],
        "ImageDrawLineStrip": ["points"],
        "ImageDrawTriangleFan": ["points"],
        "ImageDrawTriangleStrip": ["points"],
    },
    "rlgl_ffi.rb": {
        "rlUpdateShaderBuffer": ["data"],
        "rlReadShaderBuffer": ["dest"],
        "rlLoadShaderBuffer": ["data"],
    },
}

WRAPPER_RE = r"    def self\.%s\(([^)]*)\)\n(.*?\n)    end\n"


def coerce_args(call_line, params, wanted, func):
    """Rewrite the wanted argument positions of one call line.

    Parenthesis-aware: the shim call may sit inside another call
    (`Image.new(Raylib.rl_LoadImageAnim(fileName, frames), nil)`).
    """
    stripped = call_line.rstrip("\n")
    m = re.search(r"(?:Raylib|Rlgl)\.(?:rl_)?%s\(" % re.escape(func), stripped)
    if not m:
        return call_line, []
    start = m.end()
    depth, i = 1, start
    while i < len(stripped) and depth:
        if stripped[i] == "(":
            depth += 1
        elif stripped[i] == ")":
            depth -= 1
        i += 1
    inner = stripped[start:i - 1]
    args, d, cur = [], 0, ""
    for ch in inner:
        if ch == "(":
            d += 1
        elif ch == ")":
            d -= 1
        if ch == "," and d == 0:
            args.append(cur)
            cur = ""
        else:
            cur += ch
    args.append(cur)
    args = [a.strip() for a in args]
    changed = []
    for name in wanted:
        if name not in params:
            continue
        idx = params.index(name)
        if idx < len(args) and args[idx] == name:
            fn = "ptr_int" if func in INT_SAFE else "ptr_addr"
            args[idx] = "Raylib.%s(%s)" % (fn, name)
            changed.append(name)
    if not changed:
        return call_line, []
    return stripped[:start] + ", ".join(args) + stripped[i - 1:] + "\n", changed


def main():
    check_only = "--check" in sys.argv
    total, out_files = [], {}
    for fname, funcs in TARGETS.items():
        path = os.path.join(LIB, fname)
        text = open(path).read()
        for func, params in funcs.items():
            rx = re.compile(WRAPPER_RE % re.escape(func), re.S)
            m = rx.search(text)
            if not m:
                total.append((fname, func, "wrapper not found"))
                continue
            signature = [p.strip() for p in m.group(1).split(",") if p.strip()]
            body = m.group(2)
            lines = body.split("\n")
            done = []
            for i, line in enumerate(lines):
                if "rl%s(" % func in line or "rl_%s(" % func in line:
                    new, changed = coerce_args(line, signature, params, func)
                    if changed:
                        lines[i] = new
                        done.extend(changed)
            if not done:
                if any("ptr_addr" in l or "ptr_int" in l for l in lines):
                    continue  # already done
                total.append((fname, func, "no call line matched"))
                continue
            new_body = "\n".join(lines)
            text = text[:m.start(2)] + new_body + text[m.end(2):]
            total.append((fname, func, "coerced " + ", ".join(done)))
        out_files[fname] = text

    for fname, func, what in total:
        print("%-18s %-34s %s" % (fname, func, what))
    fixed = [t for t in total if t[2].startswith("coerced")]
    print("%d wrapper(s) %s" % (len(fixed), "need fixing" if check_only else "fixed"))
    if not check_only:
        for fname, text in out_files.items():
            # a coerced call line may keep the original line's newline; drop the
            # blank line that leaves inside the wrapper
            text = re.sub(r"(?m)(\n[ \t]+(?:Raylib|Rlgl)\.(?:rl_)?\w+\([^\n]*ptr_(?:addr|int)[^\n]*)\n\n(    end\n)",
                          r"\1\n\2", text)
            open(os.path.join(LIB, fname), "w").write(text)
    return 1 if (check_only and fixed) else 0


if __name__ == "__main__":
    sys.exit(main())
