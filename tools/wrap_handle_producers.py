#!/usr/bin/env python3
"""wrap_handle_producers.py — producer wrappers return handle views.

The adapters return raw pointers for the struct-by-value API (heap copies). The
Ruby wrappers must hand gem code a native view object instead, so this rewrites
the single-expression wrappers in lib/raylib_ffi.rb:

    def self.LoadTexture(fileName)
      Raylib.rl_LoadTexture(fileName)
    end
  ->
    def self.LoadTexture(fileName)
      Texture2D.new(Raylib.rl_LoadTexture(fileName), nil)
    end

tools/gen_raylib_ffi.py emits the same shape for regenerated wrappers. Idempotent
(an already-wrapped body no longer matches the plain shape).
"""

import json
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FFI = os.path.join(ROOT, "lib", "raylib_ffi.rb")
API = os.path.join(os.path.dirname(ROOT), "raylib-bindings", "generator",
                   "raylib_api.json")

HANDLES = {"Image", "Texture2D", "Font", "GlyphInfo", "RenderTexture"}

# custom shims whose wrappers return a handle (not in the API JSON)
CUSTOM = {
    "rl_ImageFromImageF_ptr": "Image",
    "rl_LoadFontAtlas_ptr": "Font",
    "rl_GetGlyphInfo": "GlyphInfo",
}


def handle_returns():
    data = json.load(open(API))
    fns = data["functions"] if isinstance(data, dict) else data
    out = {}
    for fn in fns:
        if fn.get("returnType") in HANDLES:
            out[fn["name"]] = fn["returnType"]
    return out


def wrap_wrapper(text, name, klass):
    """Wrap the single-expression body of `def self.<name>`; returns (text, n)."""
    pat = re.compile(r"(?m)^(    def self\.%s\(([^\n]*)\)\n)"
                     r"      Raylib\.(rl_%s[A-Za-z0-9_]*\(([^\n]*)\))\n    end\n"
                     % (re.escape(name), re.escape(name)))
    repl = (r"\g<1>      " + klass
            + r".new(Raylib.\g<3>, nil)\n    end\n")
    return pat.subn(repl, text)


def main():
    text = open(FFI).read()
    wanted = handle_returns()
    total = 0
    for name, klass in sorted(wanted.items()):
        text, n = wrap_wrapper(text, name, klass)
        total += n
    for shim, klass in CUSTOM.items():
        # the wrapper name matches the shim name for the custom ones
        text, n = wrap_wrapper(text, shim, klass)
        total += n
    open(FFI, "w").write(text)
    print("wrapped %d producer wrapper(s)" % total)

    # report producers that still look unwrapped (for manual review)
    for name, klass in sorted(wanted.items()):
        m = re.search(r"(?m)^    def self\.%s\([^\n]*\)\n(.*?)^    end\n"
                      % re.escape(name), text, re.S)
        if m and "%s.new(" % klass not in m.group(1):
            print("  NOT wrapped: %s (%s) -> %s" % (name, klass,
                                                    m.group(1).strip()[:70]))


if __name__ == "__main__":
    main()
