#!/usr/bin/env python3
"""wrap_model.py -- the Model factories return a ModelRef, and the Model-taking
helpers unwrap it again.

Why: a Ruby method on a *native* class has no arm in a polymorphic dispatch, so
`models.each { |model| model.material(0) }` raises NoMethodError when the array
holds native Model views (raylib-bindings' models_mesh_generation.rb). A user
class's methods do resolve, and can reach the native object through a typed
ivar. lib/raylib_model_ref.rb defines the wrapper; this rewrites the generated
wrappers in lib/raylib_ffi.rb:

    def self.LoadModelFromMesh(mesh)
      Model.new(Raylib.rl_LoadModelFromMesh(mesh), nil)
    end
 ->
    def self.LoadModelFromMesh(mesh)
      ModelRef.new(Model.new(Raylib.rl_LoadModelFromMesh(mesh), nil))
    end

    def self.DrawModel(model, position, scale, tint)
      Raylib.rl_DrawModel(model, position, scale, tint)
    end
 ->
    def self.DrawModel(model, position, scale, tint)
      model = model.model
      Raylib.rl_DrawModel(model, position, scale, tint)
    end

Every Model in the programs we run comes from a factory, so the unwrap resolves;
a native Model reaching a helper would raise, loudly, rather than pass a wrapper
to C. Idempotent; `--check` reports without writing.

Usage: python3 tools/wrap_model.py [--check]
"""

import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, "lib")

FFI = "raylib_ffi.rb"

# factories that should hand back a wrapper
FACTORIES = ["LoadModel", "LoadModelFromMesh"]

# helpers that take a Model and pass it to C
UNWRAP = ["DrawModel", "DrawModelEx", "UnloadModel",
          "UpdateModelAnimation", "UpdateModelAnimationEx",
          "IsModelValid", "GetModelBoundingBox"]


def wrap_factory(text, name):
    pat = re.compile(r"(    def self\.%s\([^)]*\)\n)(.*?)(\n    end\n)" % re.escape(name),
                     re.S)
    m = pat.search(text)
    if not m:
        return text, None
    body = m.group(2).strip()
    if body.startswith("ModelRef.new("):
        return text, None
    return text[:m.start(2)] + "      ModelRef.new(" + body + ")" + text[m.end(2):], name


def unwrap_helper(text, name):
    pat = re.compile(r"(    def self\.%s\(model[,)][^\n]*\n)" % re.escape(name))
    m = pat.search(text)
    if not m:
        return text, None
    if text[m.end(1):m.end(1) + 40].lstrip().startswith("model = model.model"):
        return text, None
    return text[:m.end(1)] + "      model = model.model\n" + text[m.end(1):], name


def main():
    check_only = "--check" in sys.argv
    path = os.path.join(LIB, FFI)
    text = open(path).read()
    changed = []
    for name in FACTORIES:
        text, hit = wrap_factory(text, name)
        if hit:
            changed.append(("factory", hit))
    for name in UNWRAP:
        text, hit = unwrap_helper(text, name)
        if hit:
            changed.append(("unwrap", hit))
    for kind, name in changed:
        print("%-18s %-28s %s" % (FFI, name, kind))
    print("%d wrapper(s) %s" % (len(changed), "need fixing" if check_only else "fixed"))
    if not check_only and changed:
        open(path, "w").write(text)
    return 1 if (check_only and changed) else 0


if __name__ == "__main__":
    sys.exit(main())
