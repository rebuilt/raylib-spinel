# Draft: `native_subclass`'s header cannot be reached from a package outside the compiler tree

**Title:** a package outside the compiler's tree cannot use `native_subclass`
(the emitted `#include "../<header>"` is not searchable)

**Toolchain:** `spinel 2026.09.12+10301 (f90da21b9)`

**Status: verified, dependency-free (`native_subclass_header/`, a spin project
with its own carried C). Not filed.**

## Summary

`native_subclass "header", "scan"` (the declaration `docs/limitations.md` names
as what makes a class a package binds to C subclassable, and what
`packages/stringio/stringio.rb` uses) makes the compiler emit the package's
header into the generated translation unit as

```c
#include "../<declared path>"
```

`src/codegen.c`:

```c
/* a native class the program subclasses (#9269): its package's header
   defines the struct the subclass embeds, named from the runtime's
   directory on the include path, which packages/ sits beside */
...
  if (used) buf_printf(b, "#include \"../%s\"\n", cf->classes[nci].native_sub_header);
```

The generated TU is written outside the package (in the compiler's temporary
directory), so a quoted include resolves relative to *that* file's directory and
to the compiler's own include path — where the spinel tree's `packages/` sits
beside the runtime. A package anywhere else cannot satisfy it:

```
$ cd native_subclass_header && spin build
cc thing.c
/tmp/spinel_out_584385_0.c:4: fatal error: ../thing.h: No such file or directory
```

## Reproduction

`native_subclass_header/` is a two-file package (`thing.h` + `thing.c`) plus one
executable, and the declaration:

```ruby
module ThingLib
  native_struct "Thing", "sp_Thing"
  native_subclass "thing.h", "sp_Thing_scan"     # the header sits beside this file
  native_new [:int], "sp_Thing_new"
  native_method :c_value, [], :int, "sp_Thing_value"
end
```

```ruby
class Sub < ThingLib::Thing
  def direct = c_value
end

things = [Sub.new(7), Sub.new(8)]
things.each { |t| puts t.direct }        # never reached: the build stops at C
```

```bash
$ cd native_subclass_header && spin build
```

## Paths tried, all the same failure

| declared path | emitted include | result |
| --- | --- | --- |
| `thing.h` (beside the package files) | `../thing.h` | not found |
| `thing/thing.h` (package as the project root's child, app a sibling) | `../thing/thing.h` | not found |
| `/absolute/path/thing.h` | `..//absolute/path/thing.h` | not found |

The declaration is package-relative and the `../` prefix is unconditional, so
the only layout that resolves is one where the header sits at
`<runtime include dir>/../<declared path>` — i.e. inside the compiler's own
tree, as `packages/stringio/sp_stringio.h` does.

## Expected

A package outside the compiler's tree should be able to declare
`native_subclass`. Options, in the order I would guess at them:

- emit the header with an absolute path (the compiler knows the package root at
  analysis time);
- pass the package's directory to the C compiler as an include directory and
  emit the bare declared path;
- or document a flag/declaration for it (something like `native_cflags`) and
  refuse the declaration at compile time when the header cannot be resolved,
  rather than failing later in C with `fatal error`.

A compile-time refusal would already be an improvement: today the failure
surfaces from `cc` on a generated file in a temporary directory, which says
nothing about the declaration that caused it.

## Why it matters here

We would like to make the classes raylib-spinel binds subclassable so that a
*user* subclass of them can carry Ruby methods — the documented "a subclass of a
class a package binds to C that declares `native_subclass`" path, and the one
shape that might make methods on those objects reachable from a polymorphic
receiver (a block parameter over an array of them). Without it that route is
closed for any package that is not part of the compiler's own tree.

Related, and independent of this draft: from a subclass method, passing `self`
to an `ffi_func` declared `:ptr` is refused (`unsupported ffi pointer
argument`), so such a subclass would need its accessors as `native_method`s on
the base class.
