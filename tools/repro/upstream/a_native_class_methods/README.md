# Do monkey-patched Ruby methods on a native class work? (issue A experiment)

**Question.** With a class declared as `native_struct` + `native_new` and *no*
`native_method`, can we supply the accessors as Ruby methods that call
module-level `ffi_func`s, and reach them from a block parameter?

**Answer: no.** It compiles; it does not give the right answer; it is not a
pattern we can use.

```
$ cd program && spin build && ./build/bin/p
block (poly receiver): direct -> NoMethodError
block (poly receiver): direct -> NoMethodError
typed receiver:        direct -> 9 (expected 9)
```

The method is defined, the body is a direct C call, and a *statically typed*
receiver calls it correctly — but a poly receiver (a block parameter, an array
element) reaches no arm at all.

Note the output prints the *result*. An earlier probe of the same shape looked
like it worked ("no exception raised"); the value was `nil`. A native class
apparently has an arm for the name `value` that answers `nil`, which is a false
positive — check the value, not just the absence of an exception.

## The variant matrix (all on `spinel 2026.09.12+10301 (f90da21b9)`)

Every variant compiles. The columns are what differs; the result is the block
(poly) call.

| # | class methods | defined in | body | poly call | typed call |
| --- | --- | --- | --- | --- | --- |
| v1 | `native_method :c_value` + Ruby `doubled` | package files | C accessor / literal | NoMethodError | correct |
| v2 | Ruby `doubled` only (no `native_method`) | package file | literal `14` | NoMethodError | correct |
| v3 | Ruby `value` = `ThingLib.sp_Thing_value(self)`, `doubled` = `value * 2` | package file | direct C call / sibling call | `value`: **nil** (false positive), `doubled`: NoMethodError | correct |
| v4 | `native_method` **and** Ruby-over-ffi | package files | both | NoMethodError (both) | correct |
| v5 | six Ruby methods | **app** (monkey-patched) | direct C call, C+arith, sibling, two C calls, comparison | all NoMethodError | correct |
| v6/v7 | seven Ruby methods | package file | same set + object construction | all NoMethodError (1-element and 2-element arrays alike) | correct |
| v9 | v6 without the app-level reopening | package file | as above | all NoMethodError | correct |
| v10 | v3 plus an app-level reopening of another method | package + app | — | unchanged (`value`: nil, `doubled`: NoMethodError) | correct |
| v11 | v3 plus an unrelated class in the same file | package file | — | unchanged | correct |
| v12 | v3 with one-line `begin`/`rescue`…`end` | package file | — | unchanged | correct |
| v14 | one method per file: `pkg_direct` / `value` / `wrapped` | package file | direct C call | NoMethodError / **nil** / NoMethodError | correct |
| v15 | eight names: `value`, `size`, `length`, `count`, `wrapped`, `material`, `recs`, `texture` | package file | direct C call | NoMethodError, except the `value` nil false positive | correct |

What does **not** matter, each tested in isolation:

- whether a `native_method` exists at all (v2, v4 — the user's hypothesis, and
  its converse: removing them changes nothing);
- where the method is defined (package file, app-level monkey patch);
- the body shape (a direct C call, a C call plus arithmetic, a sibling Ruby
  call, two C calls, a comparison, wrapping the result in an object);
- the method name (only the name `value` behaves differently, and wrongly);
- the array size / element count.

Native *accessors* (`native_method`) are just as unreachable from a poly
receiver as Ruby methods (v1, v4), so the distinction is not "Ruby vs C
methods" but "poly receiver on a native class".

## Consequence

The gem examples that iterate a collection of native objects —
`models.each { |model| model.material(0) }` in `models_mesh_generation.rb`, and
anything similar over `Font`, `Mesh`, `Image`, `Texture2D` … — cannot be made to
work by moving the methods into Ruby. Typed receivers are the only ones that
resolve, which is why our own scenes (typed locals, direct calls) are unaffected
and `make check` stays green.

Recorded in `../engine-limitations.md` (limitation A).

## Follow-up experiments: what DOES work

The conclusion above is that the *class's own* methods are unreachable from a
poly receiver. Two follow-ups show a shape that is reachable, and both are built
from documented constructs.

| experiment | shape | poly (block) call |
| --- | --- | --- |
| literal seeding | `:direct` / `"direct"` mentioned as a literal in the program | no effect |
| `native_subclass` | `class Sub < ThingLib::Thing` (+ `native_subclass "hdr", "scan"` in the package) | blocked twice, see below |
| **wrapper, `:ptr` ivar** | user class holding `@ptr` from an `ffi_func :ptr` return; methods call `ffi_func`s with it | **works** (returns 7/14, correct per element) |
| **wrapper, view ivar** | user class holding the native *view*; methods delegate to a Ruby method on it (`@m.value`, `@m.value * 2`) | **works** (returns 7/14) |
| wrapper delegating a `native_method` | `@m.c_value` through the ivar | compiles Ruby, then **C codegen fails** (`invalid use of void expression`) |
| wrapper writing a native field | `@m.c_tag = v` through the ivar | `NoMethodError` at run time (the setter shape has no arm) |

So the usable pattern for a poly container is a **user-class wrapper whose
methods reach the native object through a statically typed ivar**, delegating
either to an `ffi_func` over a `:ptr` ivar or to a *Ruby* method on the native
class — not to a `native_method`, and not for field writes.

`native_subclass` is documented (`docs/limitations.md` names it as what makes a
C-bound class subclassable) but cannot be used by a third-party package:

1. `self` in a `:ptr` parameter is refused for a subclass method (the same shape
   as limitations B/C), so accessors must be `native_method`s on the base — and
2. the package's header is emitted as `#include "../<declared path>"` and
   resolved through the compiler's own include directory (`packages/` sits
   beside the runtime there), so a header outside the compiler's tree cannot be
   found:
   `fatal error: ../thing.h: No such file or directory`.

That second one is the only finding in this whole area that sits in documented
territory; it would need a drafted issue before anything is filed.

## The wrapper pattern, proven against the real library

A `ModelRef` user class holding the `Raylib::Model` view and delegating to the
Ruby methods the library already defines on it makes the exact failing shape
work, with no library change:

```ruby
class ModelRef
  def initialize(m) = @m = m
  def material(i = 0) = @m.material(i)
  def mesh(i = 0) = @m.mesh(i)
end

models = [ModelRef.new(LoadModelFromMesh(GenMeshPlane(2.0, 2.0, 5, 5))),
          ModelRef.new(LoadModelFromMesh(GenMeshCube(2.0, 1.0, 2.0))),
          ModelRef.new(LoadModelFromMesh(GenMeshSphere(2.0, 32, 32)))]

models.each do |model|
  SetMaterialTexture(model.material(0), MATERIAL_MAP_ALBEDO, texture)
end
```

```
each completed (3 models)
typed delegation: material=Raylib::Material mesh=Raylib::Mesh
typed SetMaterialTexture ok
done
```

That is `models_mesh_generation.rb` line 62, over wrappers instead of raw
views. The delegate must be a **Ruby** method on the native class (or an
`ffi_func` over a `:ptr` ivar); a `native_method` delegate fails C codegen and a
field write through the ivar raises at run time (table above).

## Warm-up attempts that do NOT seed the arm

| warm-up before the block call | result |
| --- | --- |
| `typed.respond_to?(:direct)` | still NoMethodError |
| `case typed when ThingLib::Thing` | still NoMethodError |
| `ThingLib::Thing === typed` | still NoMethodError |
| `typed.method(:direct)` then `.call` | still NoMethodError |

Still to read: `--emit-types` (see `docs/emit-types.md` for where the JSON
lands; a plain `--emit-types -c` run wrote the C only).
