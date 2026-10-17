# Draft: a package outside the compiler's tree cannot use `native_subclass`

**Title:** `native_subclass`'s emitted `#include "../<header>"` is searchable
only inside the compiler's own install tree; a package anywhere else needs two
undocumented tricks to use the feature at all

**Toolchain:** `spinel 2026.09.12+10525 (8a51e2822) [gcc 13.3.0]` (re-verified
2026-10-17; first observed on `2026.09.12+10301 (f90da21b9)`). The emit site and
`sp_require_tolerated` are unchanged on `origin/master` at `1e214014c`, 57
commits ahead, so this is still live there.

**Status: verified, dependency-free. A workaround exists and is measured below —
it does not change what the feature is supposed to do, only how much a package
has to know to reach it. Not filed.**

## Summary

`native_subclass` lets a program subclass a class a package binds to C:

```ruby
native_subclass "thing.h", "sp_Thing_scan"
```

When the program subclasses the class, the compiler adds that header to the
generated C with `../` in front of the path. At `8a51e2822`
(`src/codegen.c:18997-19000`):

```c
/* a native class the program subclasses (#9269): its package's header
   defines the struct the subclass embeds, named from the runtime's
   directory on the include path, which packages/ sits beside */
for (int nci = 0; nci < cf->nclasses; nci++) {
  if (!cf->classes[nci].is_native_class || !cf->classes[nci].native_sub_header) continue;
  int used = 0;
  for (int k = 0; k < cf->nclasses && !used; k++) used = cf->classes[k].nsub_root == nci + 1;
  if (used) buf_printf(b, "#include \"../%s\"\n", cf->classes[nci].native_sub_header);
}
```

The only include directories the compiler passes for the generated TU are the
runtime's own (`src/main.c:512`, `runtime_includes`):

```c
  snprintf(tmp, sizeof tmp, "-I\"%s\" -I\"%s%cregexp\" ", lib_dir, lib_dir, PATH_SEP); s_add(cmd, tmp);
```

`lib_dir` is the install tree's `lib/`, so `#include "../packages/stringio/sp_stringio.h"`
resolves for the bundled stringio (`<lib_dir>/../packages/stringio/sp_stringio.h`
exists — verified on an installed tree) and resolves for **nothing else**. The
generated TU itself lives in the scratch directory, so its own directory does not
help either. A package that is not part of the compiler's install tree cannot
name its own header, and the failure is a bare `cc` error naming neither the
declaration nor the package:

```
$ spin build
build p
/tmp/spinel_out_1818351_0.c:4: fatal error: ../thing.h: No such file or directory
compilation terminated.
spinel: C compilation failed
spinel: the generated C is kept at /tmp/spinel_out_1818351_0.c
spin: build failed
```

Behind that first wall are two more undocumented requirements, so a package that
works around the include path still cannot get there by reading the code:

- a subclass's constructor calls an in-place twin of the declared constructor,
  `sp_<Class>_init(<Struct> *, sp_int cls_id, <native_new's params>)`, which the
  package must define; a missing one is `undefined reference to sp_Thing_init`;
- the twin's shape and the whole `native_subclass` contract appear nowhere in the
  documentation: `grep -rn native_subclass docs/` finds one mention, inside a row
  of `docs/limitations.md`, and the `_init` convention exists only in the
  comments of the bundled stringio's C (`/* The in-place twins of the
  constructors (`_new` -> `_init`), for a subclass */`).

## Reproduction

A two-file package (`thing.h` + `thing.c`) and one executable, no other
dependency.

`spin.toml`:

```toml
[package]
name = "thing"
version = "0.1.0"
sources = ["thing.c"]
```

`thing.h` — the struct the subclass embeds, as the declaration requires:

```c
#ifndef THING_H
#define THING_H
#include "spinel/runtime.h"

typedef struct sp_Thing_s {
  sp_int cls_id;
  sp_int v;
} sp_Thing;

void sp_Thing_scan(void *p);
#endif
```

`thing.c` — the constructor, one accessor, and the scan hook the declaration
names:

```c
#include "thing.h"
#include <stdlib.h>

void sp_Thing_scan(void *p) { (void)p; }

sp_Thing *sp_Thing_new(sp_int cls_id, sp_int v) {
  sp_Thing *t = (sp_Thing *)sp_gc_alloc(sizeof(sp_Thing), NULL, sp_Thing_scan);
  t->cls_id = cls_id;
  t->v = v;
  return t;
}

sp_int sp_Thing_value(sp_Thing *t) { return t->v; }
```

`thing.rb` — the class, with the header declared beside it:

```ruby
module ThingLib
  native_struct "Thing", "sp_Thing"
  native_subclass "thing.h", "sp_Thing_scan"
  native_new [:int], "sp_Thing_new"
  native_method :c_value, [], :int, "sp_Thing_value"
end
```

`bin/p.rb` — the subclass the declaration exists to allow, including the case the
feature is for (the receiver is unpinned: a block parameter):

```ruby
require "thing"

class Sub < ThingLib::Thing
  def direct = c_value
end

things = [Sub.new(7), Sub.new(8)]
things.each { |t| puts "block receiver: direct -> #{t.direct}" }

typed = Sub.new(9)
puts "typed receiver: direct -> #{typed.direct}"
```

`spin build` fails as quoted in the Summary: the TU contains

```c
#include "../thing.h"
```

and no include directory makes that resolve.

## Paths tried

| declared path (in `thing.rb`) | emitted include | result |
| --- | --- | --- |
| `"thing.h"` (beside the package files) | `#include "../thing.h"` | `fatal error: ../thing.h: No such file or directory` |
| `"thing/thing.h"` (package as the project root's child, app a sibling) | `#include "../thing/thing.h"` | `fatal error: ../thing/thing.h: No such file or directory` |
| `"/absolute/path/thing.h"` | `#include "..//absolute/path/thing.h"` | `fatal error: ..//absolute/path/thing.h: No such file or directory` |
| `"thing.h"`, with the compiler's own `-I DIR` flag | — | unchanged: `-I DIR` is a *feature search root for `require`* (`spinel --help`), it never reaches `cc` |

## Workaround (measured, so that the ask can be judged)

`#include "../P"` is searched in every include directory `D` as `D/../P`, and a
package can add include directories with `ffi_cflags`. So putting any directory
one level below the package root on the include path makes the emitted path
resolve, because `D/..` *is* the package root. Adding a real `include/` (which a
package carrying C has a reason to have anyway):

```ruby
module ThingLib
  native_struct "Thing", "sp_Thing"
  native_subclass "thing.h", "sp_Thing_scan"
  native_new [:int], "sp_Thing_new"
  native_method :c_value, [], :int, "sp_Thing_value"
  ffi_cflags "-I" + __dir__ + "/include"     # include/../thing.h == thing.h
end
```

(Interpolation is not accepted there; `"-I" + __dir__ + "/include"` is, since
`ffi_cflags` takes a literal, adjacent literals, `String#+`, `__dir__` or
`File.expand_path` of those.)

That clears the include, and the link then reports `undefined reference to
sp_Thing_init`. Defining the twin — stringio's C is the only place this is
written down — completes it:

```c
/* the in-place twin of sp_Thing_new, which a subclass's constructor needs */
void sp_Thing_init(sp_Thing *t, sp_int cls_id, sp_int v) {
  t->cls_id = cls_id;
  t->v = v;
}
```

and the program from the reproduction then builds and runs correctly:

```
$ spin build && ./build/bin/p
block receiver: direct -> 7
block receiver: direct -> 8
typed receiver: direct -> 9
```

with the subclass behaving as a real subclass, which is the point of the whole
declaration:

```
$ ./build/bin/parity
sub.is_a?(Thing)      -> true
sub.is_a?(Sub)        -> true
base.is_a?(Sub)       -> false
sub.class             -> Sub
case/when Thing       -> Thing arm
Array#map over mixed  -> [true, true]
```

So the feature works; a package outside the install tree just has to know the
include-directory trick and the `_init` convention from somewhere other than the
source or the docs, and the diagnostics teach it neither.

And the same holds for the package *consumed as a dependency*, which is the
state it would be in when published: installed from a git URL into spin's own
package cache, with nothing of the development layout beside it.

```
$ cd /tmp/consumer_thing_pristine && spin build
/tmp/spinel_out_1591991_0.c:5: fatal error: ../thing.h: No such file or directory
spinel: C compilation failed

$ cd /tmp/consumer_thing_workaround && spin build && ./build/bin/app
methods from a block param -> [7, 8]
sub.is_a?(Thing)  -> true
sub.class         -> Sub
case/when Thing   -> Thing arm
```

`~/.cache/spin/packages/thing-0.1.0/` is no more reachable through `..` than any
other directory outside the compiler's install tree; the include-directory trick
is what carries it, for a program that never sees the package's source tree.

## Expected

- Emit a path that resolves, rather than one that happens to. Either name the
  header absolutely — the compiler knows the package's root at analysis time —
  or pass the package's directory to `cc` as an include directory and emit the
  declared path unchanged, which also makes the `../` in `codegen.c` unnecessary.
- Refuse at analysis when the declared header cannot be resolved, naming the
  declaration and its file, instead of failing inside `cc` on a scratch file
  (`/tmp/spinel_out_<pid>_0.c`) that may or may not survive the failure.
- Document `native_subclass` and the `_init` twin. `docs/limitations.md` states
  the *requirement* (a class a package binds to C that "does not declare
  `native_subclass`" cannot be subclassed) without documenting the declaration
  that satisfies it.

## Why it matters

A package that binds a class to C and wants that class to carry Ruby methods has
two options today. It can forgo subclassing and hand out instances of a plain
Ruby wrapper class instead — which is what a package is pushed to — but then the
wrapper is not the bound class, and `is_a?`, `case`/`when`, `super` and
`rescue` against the bound class stop answering the way CRuby answers, which is
a compatibility problem for any library whose own API is the bound class. Or it
can use `native_subclass`, which gives all of that (measured above) — but only if
it can get the two undocumented things right, and its header is reachable at all
if it lives inside the compiler's install tree.

## Related, and independent

From a subclass method, passing `self` to an `ffi_func` declared `:ptr` is
refused, so a subclass cannot reach the embedded struct that way and needs its
accessors as `native_method`s on the base instead (which works: `c_value` above):

```ruby
module ThingLibExt
  ffi_func :val_ptr, [:ptr], :int, "sp_Thing_value"
end

class Sub5 < ThingLib::Thing
  def direct = ThingLibExt.val_ptr(self)     # refused
end
```

```
spinel: bin/selfptr.rb:8: unsupported ffi pointer argument (a Ruby object has no
C address; pass an IO::Buffer, a String or a :ptr value): node 53 (SelfNode)
spinel: 1 refusal, nothing written
```

Re-verified 2026-10-17 on `8a51e2822`, in a package that has the workaround
above — so it is not a consequence of the include failure, and it reproduces the
same way when the `ffi_func` is declared in the same module as the bound class.
Reported here only because it blocks the same feature; happy to split it into its
own issue if that is the preference.
