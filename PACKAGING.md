# Packaging and publishing `raylib-spinel`

What it takes to hand this package to somebody who does not have our directory
layout, measured on 2026-10-17 with `spinel 2026.09.12+10525`, `spin` (the
`~/.local/lib/spinel/spin` install), gcc 13.3.0, Ubuntu.

## The two channels are different distributions

| channel | what a consumer does | what they get | gate |
| --- | --- | --- | --- |
| **spin** (the package channel, what `require "raylib"` needs) | `spin add raylib --git https://github.com/<repo>/raylib-spinel`, or from the spin index once it is published | a `git clone` of this repo: `spin.toml` (carried C), `raylib.rb`, `lib/` — plus `tools/` and `reference/`, which ride along and are excluded from the C sweep | `spin publish` wants a clean tree, HEAD on a *remote* branch, matching `version`, and a passing `spin test`; it writes an entry to https://github.com/matz/spin-index under a name policy |
| **rubygems** (the MRI channel) | `gem install raylib-spinel` → `require "raylib-spinel"` | only `s.files`: `lib/**/*.{rb,h}`, `raylib.rb`, `raylib-spinel.rb`, `spin.toml`, `README.md`, `LICENSE*` — no `.c`, no `.o` | `gem push`, no test gate |

The spin channel reads **the repository**, the rubygems channel reads
**`s.files`**. Nothing today keeps the two lists honest with each other.

## Measured: the package works from an unrelated directory

A consumer app created in `/tmp`, depending on a clone in another `/tmp`
directory, installed into spin's own package cache:

```bash
git clone --no-hardlinks ~/workspace/ruby/spinel/raylib-spinel /tmp/pkg/raylib-spinel
mkdir -p /tmp/consumer/bin && cd /tmp/consumer && spin init
printf '...' > bin/app.rb          # the preamble from raylib-bindings' examples/template.rb
spin add raylib --git file:///tmp/pkg/raylib-spinel
spin build && ./build/bin/app      # 4 frames, clean shutdown
```

Results:

* `require "raylib"` resolved to our `raylib.rb` out of
  `~/.cache/spin/packages/raylib-0.1.0/`, the eight carried C files compiled from
  there, and the program ran. Nothing in the Ruby layer reaches outside its own
  directory (`__dir__` only). **No sibling-checkout assumption.**
* The preamble real games copy — `Gem::Specification.find_by_name('raylib-bindings').full_gem_path + '/lib/'`
  plus `Raylib.load_lib(...)` (the only `Gem.` idiom in the gem's own examples) —
  died at startup with `uninitialized constant Gem::Specification (NameError)`.
  Under Spinel `Gem` is a module, `Gem::Specification` does not exist, and
  `require "rubygems"` is refused by `--require-gate` (that half is filed
  upstream as matz/spinel#9441). Fixed here: `lib/raylib_compat.rb` answers
  `find_by_name` with an object whose `full_gem_path` is empty, which is safe
  because the path is only ever handed to `Raylib.load_lib`, our no-op. Re-measured:
  the preamble now runs (`consumer preamble: ran 4 frames`).
* `raylib-spinel-0.1.0.gem` built and installed into a scratch `GEM_HOME` works
  for `require "raylib-spinel"` under MRI (loads `raylib-bindings` by absolute
  path, 1000 `Raylib` constants, `Raylib.InitWindow` attached). With both gems
  installed, `require "raylib"` answers **`raylib-bindings`** even when ours is
  the gem being activated: activating ours activates the dependency first, so
  its `lib/` sits ahead of our `.` on `$LOAD_PATH`. That is the right outcome —
  an MRI game gets the untouched gem API (`Raylib.load_lib` present, the
  functions attached by the game's own `load_lib` call), and our helper layer
  loads only through `require "raylib-spinel"`. It also means shipping
  `raylib.rb` in the gem changes nothing for MRI users; that file matters where
  name-based loading has no RubyGems competition (a checkout on the load path,
  or spin's package dir), and there the delegation is the point.

## Open before a real release

1. **~~`s.files` was not the package~~ (fixed).** `raylib.rb` — the entry point
   the README tells games to require — and `spin.toml` were absent from
   `s.files`, and the eight `lib/*.o` build artifacts were in it. The gemspec
   now names `lib/**/*.{rb,h}` plus the entry points, and describes what each
   channel consumes.
2. **`lib/*.o` are tracked in git.** Build output of the committed `.c` files:
   8 stale binaries on every clone, and they were about to ship in the gem.
   Untracked; the Makefile and spin both compile them.
3. **~~`tools/` and `reference/` ride with every clone~~ (fixed).** spin walks
   the package for carried C and warned about the repro programs it found —
   `spin: raylib/tools/repro/upstream/native_subclass_header/thing.c is not
   named by [package] sources and was NOT compiled.` five times, once per
   consumer build. `spin.toml` now declares `[package] exclude = ["tools",
   "reference"]` (globs pruned before the sweep, `spinel/tools/spin.rb`,
   `native_excludes`); re-measured with the older installed spin (+9071): zero
   warnings, program still builds and runs.
4. **`-I/usr/local/include` in `lib/raylib_ffi.rb`'s `ffi_cflags`** is the one
   place the package names a machine layout — and, measured, it is not even the
   flag that decides the include path. spin compiles carried C *itself*
   (`tools/spin.rb`, `native_objs_for`: `cc -O2 <pkg-config flags> -c x.c
   -I<package dir> -I<spinel headers>`); "the compiler itself never touches
   package C", so `ffi_cflags` reaches only the *program's* compile+link. That
   leaves the `-I` with nothing to do (the generated TU includes no raylib
   header), while the `-Wl,-rpath,'$ORIGIN/../raylib'` beside it is
   load-bearing — `spin` cannot pass link flags, so that rpath is how `spin run`
   finds the vendored libraylib (`AGENTS.md` §K). Keep the rpath, drop the `-I`.
   spin's portable mechanism for headers is `[native] pkg_config = ["raylib"]`,
   whose flags *do* reach the carried-C compile. Deliberately not used here:
   this box has two `raylib.pc` files and `pkg-config` answers `~/.local`
   (6.0.0 headers) while the `hello_raylib` Makefile compiles the same adapters
   against `/usr/local` (6.2-dev), so a `[native]` entry would let
   `PKG_CONFIG_PATH` decide which of the two build paths gets which headers. It
   is the right default for a package with one raylib to talk to.
5. **libraylib at runtime** is the first thing a new consumer hits, and the rule
   is narrower than "install raylib". `ffi_lib "raylib"` (spinel's
   `packages/ffi/ffi.rb`) dlopens the candidates `raylib` and `libraylib.so` —
   the *unversioned* name, which a runtime-only install does not ship
   (`libraylib.so.600` alone is never found) — and only then falls back to
   probing `libraylib.so` in `/usr/lib`, `/usr/local/lib`, `/opt/local/lib`,
   `/opt/homebrew/lib`. So: a source `make install` works (it puts
   `libraylib.so` into `/usr/local/lib`), a runtime-only package does not, and
   the rpath above is the vendoring hook — put a `libraylib.so` in a `raylib/`
   sibling of the binary's directory, which is how `hello_raylib` ships the
   `raylib-bindings` gem's known-good build. On this box `LD_LIBRARY_PATH` puts
   a 6.0.0 build first, which is the `AGENTS.md` §K weak-symbol story. The
   README says none of this yet.
6. **Publish gates.** `spin publish` needs `origin` (or `--repo`), HEAD pushed to
   a remote branch, `spin test` green, and the index name: `raylib` is free in
   the index today, and claiming it in matz's index is a naming decision, so
   publishing is Nelson's call (also `AGENTS.md` §0). **Neither
   `raylib-spinel` nor `hello_raylib` has a git remote at all** — so the first
   real step is a repo of ours, not the index: a `--git` dependency consumes any
   pushed repo, and needs nothing from matz.

## Does this touch draft E?

The point of the exercise. `native_subclass` from a package installed as a spin
dependency, i.e. in exactly this layout:

```bash
# /tmp/pkg/thing_{pristine,workaround}: the repro as its own package, git init'd
cd /tmp/consumer_thing_workaround && spin build && ./build/bin/app
# methods from a block param -> [7, 8]
# sub.is_a?(Thing)  -> true
# case/when Thing   -> Thing arm
cd /tmp/consumer_thing_pristine && spin build
# fatal error: ../thing.h: No such file or directory
```

The bug reproduces from the cache-installed dependency, and the two-part
workaround (`ffi_cflags "-I" + __dir__ + "/include"`, plus the `sp_<Class>_init`
twin) works there too, with correct `is_a?` / `case` semantics. So the subclass
design `tools/repro/upstream/issue-e-native-subclass-header.md` is written
around is reachable for a published package — which is what makes the
`is_a?`/`case` divergence of the wrapper design (plan item b) worth closing.
Draft E is still not filed.
