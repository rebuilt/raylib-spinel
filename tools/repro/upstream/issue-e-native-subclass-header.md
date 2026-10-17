# Draft: a package outside the compiler's tree cannot use `native_subclass`

**Title:** a package outside the compiler's tree cannot use `native_subclass`
(the emitted `#include "../<header>"` is not searchable)

**Toolchain:** `spinel 2026.09.12+10525 (8a51e2822) [gcc 13.3.0]`
(re-verified 2026-10-17; first observed on `2026.09.12+10301 (f90da21b9)`)

**Status: verified, dependency-free (a spin project with its own carried C).
Not filed.**

## Summary

A package can let a program subclass a class it binds to C. It declares that
with the class's header and a scan hook:

```ruby
native_subclass "thing.h", "sp_Thing_scan"
```

When the program subclasses the class, the compiler adds that header to the
generated C file and puts `../` in front of the path itself. At `8a51e2822`
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

The comment states the intent: the path is only meant to name files that sit
beside `packages/` inside the compiler's own tree. The generated C file,
however, is written to the scratch directory (`<TMPDIR>` or `/tmp`), and the
`-I` search path passed to `cc` does not include either the package or the
project. So `../thing.h` points one directory above `/tmp/spinel_out_<pid>_0.c`
and the header is never found:

```
$ cd native_subclass_header && spin build
build p
cc thing/thing.c
cc thing/thing.c (threaded)
/tmp/spinel_out_1299605_0.c:4: fatal error: ../thing.h: No such file or directory
compilation terminated.
spinel: C compilation failed
spinel: the generated C is kept at /tmp/spinel_out_1299605_0.c
spin: build failed
```

The only layout that works is a header inside the compiler's own tree, which is
where the compiler's bundled stringio package keeps its header
(`packages/stringio/stringio.rb`, verified at the same commit):

```ruby
# packages/stringio/stringio.rb
  native_struct "StringIO", "sp_StringIO", "sp_StringIO_free"
  native_subclass "packages/stringio/sp_stringio.h", "sp_StringIO_scan_gc"
  native_new [],                 "sp_StringIO_new"
  native_new [:string],          "sp_StringIO_new_s"
```

There the declared path (`packages/stringio/...`) is relative to the directory
that holds the runtime include dir, which is exactly what `../` lands on. Every
path a normal package can name fails the same way; the table below lists them.

## Reproduction

A two-file package (`thing.h` + `thing.c`) with one executable, no other
dependency. `tools/repro/upstream/native_subclass_header/` in our tree is
exactly this, and nothing in it is raylib-specific.

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

`thing.rb` — the class, with the header declared next to it:

```ruby
module ThingLib
  native_struct "Thing", "sp_Thing"
  native_subclass "thing.h", "sp_Thing_scan"
  native_new [:int], "sp_Thing_new"
  native_method :c_value, [], :int, "sp_Thing_value"
end
```

`bin/p.rb` — the subclass the declaration exists to allow:

```ruby
require "thing"

class Sub < ThingLib::Thing
  def direct = c_value
end

typed = Sub.new(9)
puts "subclass typed: direct -> #{typed.direct} (expected 9)"
```

Build:

```bash
spin build
```

The failure is at the C compile step, before any runtime behavior is reached:
the generated TU contains the declaration's header with a search path that does
not exist from where the TU is written.

```c
#include "../thing.h"
```

## Paths tried, all the same failure

Re-verified 2026-10-17; in each case `thing.rb` was the only file changed, and
the emitted include is the declared path with `../` prepended.

| declared path (in `thing.rb`) | emitted include | result |
| --- | --- | --- |
| `"thing.h"` (beside the package files) | `#include "../thing.h"` | `fatal error: ../thing.h: No such file or directory` |
| `"thing/thing.h"` (package as the project root's child, app a sibling) | `#include "../thing/thing.h"` | `fatal error: ../thing/thing.h: No such file or directory` |
| `"/absolute/path/thing.h"` | `#include "..//absolute/path/thing.h"` | `fatal error: ..//absolute/path/thing.h: No such file or directory` |

The only layout that resolves is one where the header sits at
`<runtime include dir>/../<declared path>`, i.e. inside the compiler's own tree.

## Expected

A package outside the compiler's tree should be able to declare
`native_subclass`. In the order I would guess at them:

- emit the header with an absolute path (the compiler knows the package root at
  analysis time);
- pass the package's directory to the C compiler as an include directory and
  emit the bare declared path;
- or give the declaration a way to state the include directory (something like
  the existing `ffi_cflags`) and refuse at compile time when the header cannot
  be resolved, rather than failing later inside `cc` on a file in a temporary
  directory — the current failure names neither the declaration nor the package,
  and the scratch TU it names (`/tmp/spinel_out_<pid>_0.c`) is deleted or left
  behind depending on the failure path, so the message alone is hard to act on.

## Why it matters here

We want the classes raylib-spinel binds to C to be subclassable, so that a user
subclass of one of them can carry Ruby methods. That is the only shape we have
found that might make methods on those objects reachable from a polymorphic
receiver (an array element, a block parameter). Today the class's own methods
raise `NoMethodError` there:

```ruby
models = [LoadModelFromMesh(GenMeshCube(2.0, 1.0, 2.0)), ...]

models.each do |model|
  model.material(0)          # NoMethodError: no arm for a native class
end
```

(`tools/repro/upstream/a_block_param/` and `a_native_class_methods/` in our tree
are the smaller reproductions of that runtime shape; the header problem above
means the subclass route cannot even be tried from a normal package.) Without a
usable `native_subclass` that route is closed for any package that is not part
of the compiler's own tree.

### Related, and independent

From a subclass method, passing `self` to an `ffi_func` declared `:ptr` is
refused, so a subclass cannot reach the embedded struct that way and needs its
accessors as `native_method`s on the base instead:

```ruby
module ThingLib
  native_struct "Thing", "sp_Thing"
  native_subclass "thing.h", "sp_Thing_scan"
  native_new [:int], "sp_Thing_new"
  ffi_func :sp_Thing_value, [:ptr], :int
end

class Sub < ThingLib::Thing
  def direct = ThingLib.sp_Thing_value(self)     # refused
end
```

```
spinel: bin/p.rb:4: unsupported ffi pointer argument (a Ruby object has no C
address; pass an IO::Buffer, a String or a :ptr value): node 34 (SelfNode)
spinel: 1 refusal, nothing written
```

(The line and node number are as measured on 2026-10-17; the refusal itself is
what matters.) Note this one is independent of the header bug — it reproduces
here even though the include failure would fail this program a moment later.
Reported together only because it blocks the same feature; happy to split it
into its own issue if that is the preference.
