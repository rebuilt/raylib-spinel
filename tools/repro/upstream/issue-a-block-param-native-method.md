# Draft: Ruby methods on a native class are unreachable from a block parameter

**Title:** Ruby method defined on a native class raises NoMethodError when the
receiver is a block parameter

**Toolchain:** reproduces on `2026.09.12+10301 (f90da21b9)`, and on the earlier
`+10159 (a632e3b18)` and `+10027 (bcba2dbb7)`

**Status: kept as a record, not filed.** The mechanism is a documented design
property -- `docs/limitations.md` records the same rule for exceptions ("the
`#message`/`#to_s` arm is only emitted for a receiver whose static type names
the exception class") -- and the class layer here is the undocumented
`native_struct`/`native_method` DSL, which tries to reach a C-bound class the
documented promise does not cover. See `../engine-limitations.md`.

## Summary

A Ruby method defined on a **native class** (`native_struct` + `native_new` +
`native_method`, i.e. a "Path B typed object") is not reachable when the
receiver is a **block parameter**, even though the object's class is correct and
the same method works on a typed local or on an array element assigned to a
local. The compiler emits a polymorphic dispatch whose only arm is
`default: raise NoMethodError`, so the failure is at run time:

```
undefined method 'doubled' for an instance of ThingLib::Thing (NoMethodError)
```

Native accessors (`native_method`, resolved statically) and Ruby methods on
*ordinary* classes in blocks are unaffected.

## Reproduction

A dependency-free spin project (no raylib, no gems). The carried C is the shape
used by spinel's own bundled `stringio` package: the struct owns `cls_id`, the
constructor is stamped by the compiler.

`thing/spin.toml`:

```toml
[package]
name = "thing"
version = "0.1.0"
sources = ["thing.c"]
```

`thing/thing.c`:

```c
#include "spinel/runtime.h"

typedef struct sp_Thing_s {
  sp_int cls_id;
  sp_int v;
} sp_Thing;

sp_Thing *sp_Thing_new(sp_int cls_id, sp_int v) {
  sp_Thing *t = (sp_Thing *)sp_gc_alloc(sizeof(sp_Thing), NULL, NULL);
  t->cls_id = cls_id;
  t->v = v;
  return t;
}

sp_int sp_Thing_value(sp_Thing *t) { return t->v; }
```

`thing/thing.rb`:

```ruby
module ThingLib
  native_struct "Thing", "sp_Thing"
  native_new [:int], "sp_Thing_new"
  native_method :value, [], :int, "sp_Thing_value"

  class Thing
    def doubled = 14          # a plain Ruby method on the native class
  end
end
```

`program/spin.toml`:

```toml
[dependencies]
thing = { path = "../thing" }
```

`program/bin/repro_a.rb`:

```ruby
require "thing"

class ThingLib::Thing
  def doubled = 14
end

things = [ThingLib::Thing.new(7), ThingLib::Thing.new(8)]

things.each do |t|
  puts "block parameter class: #{t.class}"
  begin
    t.doubled
    puts "ruby method from block: 14"
  rescue NoMethodError => e
    puts "ruby method from block: #{e.class}: #{e.message}"
  end
end

typed = ThingLib::Thing.new(9)
puts "ruby method on a typed local: #{typed.doubled}"

first = things[0]
puts "ruby method on an array element: #{first.doubled}"
```

```
$ cd program && spin build && ./build/bin/repro_a
```

## Observed

```
block parameter class: ThingLib::Thing
ruby method from block: NoMethodError: undefined method 'doubled' for an instance of ThingLib::Thing
block parameter class: ThingLib::Thing
ruby method from block: NoMethodError: undefined method 'doubled' for an instance of ThingLib::Thing
ruby method on a typed local: 14
ruby method on an array element: 14
```

## Expected

```
ruby method from block: 14
ruby method from block: 14
```

(as the same class prints for a typed local and for an array element in the
same program — the last two lines of the observed output — and as the plain
class in `program/bin/plain_control.rb` prints from a block).

Note the program itself cannot run under CRuby: `native_struct`/`native_new`/
`native_method` are Spinel's binding DSL. The expected output is established by
the controls inside the same program.

## Generated code

The block-parameter call compiles to a dispatch with no arm for the class:

```c
({ sp_RbVal _t11 = lv_t; sp_int _t12 = 0;
   switch (_t11.cls_id) {
     default: sp_raise_nomethod(sp_nomethod_msg("doubled", _t11)); break;
   }
   _t12; });
```

while the typed-local and array-element calls are direct static calls:

```c
sp_int _t14 = sp_Thing_doubled((sp_Thing *)lv_typed);
sp_int _t17 = sp_Thing_doubled((sp_Thing *)lv_first);
```

So the poly arm table built for the block parameter is missing the native
class's Ruby methods entirely.

## Scope and workarounds tried (none help)

- A Ruby method on an **ordinary** class, called from a block, works (a class
  with `def value = 7` prints `7` from `[Thing.new].each { |t| t.value }`).
- A native **accessor** (`native_method`) is affected too: it is equally
  unreachable from a poly receiver. The distinction is "poly receiver on a
  native class", not "Ruby method vs C method".
- Supplying the accessors as Ruby methods that call module-level `ffi_func`s —
  no `native_method` in the class at all — changes nothing (see
  `a_native_class_methods/`, which runs that experiment across 16 variants).
  Neither does where the method is defined (package file or app-level monkey
  patch), the body shape (a direct C call, a C call plus arithmetic, a sibling
  call, two C calls, a comparison, wrapping the result in an object), the method
  name, or the array size.
- Beware a false positive when testing this: a call named `value` does not
  raise, and answers `nil` (not the method's value). Check the value, not just
  the absence of an exception.
- Reaching the same object through a typed local, or through an array element
  assigned to a local, works.
- Adding the method through an included module (`class Model; include Helpers;
  end`) does **not** help.
- A statically typed call to the same method elsewhere in the program does
  **not** help.

## Impact

This blocks the idiomatic gem pattern of iterating a collection of native
objects and calling a library method on each element. The concrete case that
found it: the raylib-bindings gem example `models_mesh_generation.rb`, line 62:

```ruby
models.each do |model|
  SetMaterialTexture(model.material(0), MATERIAL_MAP_ALBEDO, texture)
end
```

which fails with `undefined method 'material' for an instance of Raylib::Model`
even though `Raylib::Model#material` is defined and works on a typed local.
`Model` is a native class in raylib-spinel; the same shape fails for `Font`,
`Image`, `Mesh` and the rest of the library's native classes.
