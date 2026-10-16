# Upstream drafts — Spinel AOT findings from the raylib-spinel compat work

Nothing here has been filed. Each `issue-*.md` is the text I would submit to
`matz/spinel`, with the reproduction and the exact toolchain version. Review
them, then say go (and for which ones).

Toolchain for every observation:

```
$ spinel --version
spinel 2026.09.12+10159 (a632e3b18)
```

AOT note: `7aa51b34f` (the `#9289` fix) is an ancestor, so the compiler is
current.

| draft | subject | standalone repro |
| --- | --- | --- |
| `issue-a-block-param-native-method.md` | a Ruby method on a native class is unreachable from a block parameter | **verified**: `a_block_param/` (dependency-free spin project, reproduces) |
| `issue-b-native-writer-ptr-self.md` | adding a Ruby writer to a native class breaks `self` in that class's `:ptr` parameters | **not yet minimised** — reproduced only inside raylib-spinel (`b_writer_ptr_self/` records the shape that does *not* trigger it) |
| `issue-c-ptr-union-poisoning.md` | an untyped helper's union return poisoning `:ptr` acceptance program-wide | **not yet minimised** — reproduced only inside raylib-spinel |
| `issue-d-string-pack-p.md` | `String#pack("p*")` emits a single pointer regardless of the array size | **verified**: `pack_repro.rb` (dependency-free, no native code) |

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
