# Engine notes and upstream drafts from the raylib-spinel compat work

Two kinds of file live here:

- **Drafts for upstream** (`issue-*.md`): text I would submit to `matz/spinel`,
  with a reproduction and the exact toolchain version. Nothing is submitted
  without Nelson's go-ahead.
- **Internal notes** (`../engine-limitations.md`): findings in the compiler's
  undocumented `native_struct` layer. Those are constraints we design around,
  not upstream bugs -- the reasoning and the doc quotes are in that file.

Toolchain for every observation: `spinel 2026.09.12+10301 (f90da21b9)`
(installed 2026-10-16; earlier runs used `+10159 (a632e3b18)`).

| file | subject | status |
| --- | --- | --- |
| `issue-d-string-pack-p.md` | `Array#pack("p*")` emits a single pointer regardless of the array size | **filed**: https://github.com/matz/spinel/issues/9349 |
| `issue-a-block-param-native-method.md` | a Ruby method on a native class is unreachable from a block parameter | draft, **not filed** (undocumented layer; mechanism is documented design) |
| `a_native_class_methods/` | experiment: monkey-patched Ruby accessors on a `native_struct` class, 16 variants | evidence; **does not work** — see its README |
| `../engine-limitations.md` | a Ruby writer on a native class breaks `self` in `:ptr` parameters; a union return poisons `:ptr` acceptance program-wide | internal notes, no filing |

## Running the verified repro

```bash
cd a_block_param/program
spin build
./build/bin/repro_a          # the failing case (see the draft for expected/actual)
./build/bin/plain_control    # control: a plain Ruby class in a block works
ruby bin/plain_control.rb    # the same control under CRuby (identical output)
```

The project is two spin projects (a local `thing` package carrying the C, and an
application using it) because a spin *application* cannot carry native C of its
own — the package is exactly spinel's "Path B typed object" shape, as used by
the bundled `stringio` package.

The `pack("p*")` repro is one file, no native code:

```bash
spinel pack_repro.rb -o pack_repro && ./pack_repro    # compare with: ruby pack_repro.rb
```

`b_writer_ptr_self/` is evidence for the internal note B (the shape that does
*not* trigger the refusal), not a repro of a filed issue.
