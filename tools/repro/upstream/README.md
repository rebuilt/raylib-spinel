# Engine notes and upstream drafts from the raylib-spinel compat work

Two kinds of file live here:

- **Drafts for upstream** (`issue-*.md`): text I would submit to `matz/spinel`,
  with a reproduction and the exact toolchain version. Nothing is submitted
  without Nelson's go-ahead.
- **Internal notes** (`../engine-limitations.md`): findings in the compiler's
  undocumented `native_struct` layer. Those are constraints we design around,
  not upstream bugs -- the reasoning and the doc quotes are in that file.

Toolchain for every observation: `spinel 2026.09.12+10525 (8a51e2822)`
(re-verified 2026-10-17; the drafts were first written against
`+10301 (f90da21b9)`, installed 2026-10-16).

| file | subject | status |
| --- | --- | --- |
| `issue-d-string-pack-p.md` | `Array#pack("p*")` emits a single pointer regardless of the array size | **filed**: https://github.com/matz/spinel/issues/9349 |
| `issue-e-native-subclass-header.md` | a package outside the compiler's tree cannot use `native_subclass` (emitted `#include "../<header>"` is not searchable) | draft, **not filed** (verified 2026-10-17) |
| `native_subclass_header/` | repro for issue-e: a standalone spin project with its own carried C | evidence; build fails at the C compile step |
| `issue-f-require-gate-builtin.md` | `--require-gate` refuses `require "rbconfig"` / `"rubygems"`, whose constants the compiler splices itself; any gated build that uses `optparse` fails | **filed**: https://github.com/matz/spinel/issues/9441 (2026-10-17) |
| `require_gate_optapp/` | repro for issue-f: a two-file spin project whose only dependency is `optparse` | evidence; `spin build` refuses, `spinel bin/app.rb` compiles and runs |
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

## Running the issue-f repro (`require_gate_optapp/`)

```bash
cd require_gate_optapp
spin build                                   # refuses: cannot load such file -- rbconfig
spinel bin/app.rb -o app && ./app --name there   # ungated: builds and prints "hello there"
spinel -c rbconfig_probe.rb --require-gate -o /tmp/o.c   # the one-file form, rc=1
```

`bin/` and `spin.toml` are the whole spin project; `rbconfig_probe.rb` is the
single-file variant. Neither references anything outside the compiler.

The project is two spin projects (a local `thing` package carrying the C, and an
application using it) because a spin *application* cannot carry native C of its
own — the package is exactly spinel's "Path B typed object" shape, as used by
the bundled `stringio` package.

The `pack("p*")` repro is one file, no native code:

```bash
spinel pack_repro.rb -o pack_repro && ./pack_repro    # compare with: ruby pack_repro.rb
```

The `native_subclass` repro (issue-e) is one self-contained spin project; it is
expected to *fail*, at the C compile step:

```bash
cd native_subclass_header && spin build   # ../thing.h: No such file or directory
```

`b_writer_ptr_self/` is evidence for the internal note B (the shape that does
*not* trigger the refusal), not a repro of a filed issue.
