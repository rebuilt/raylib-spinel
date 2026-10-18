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
* Re-run against the committed state (`afbeec4`), from a clone with no build
  output: the clone carries **zero `lib/*.o`** (so the carried C demonstrably
  compiles from `.c` alone), the build prints **zero** "not named by [package]
  sources" warnings, the app runs, and after `spin vendor` a rebuild from
  `vendor/packages/raylib-0.1.0/` builds and runs identically. All three
  consumption modes — git URL, spin's cache, `vendor/` — are green.
* `tools/repro/upstream/native_subclass_header_workaround/` was likewise
  re-verified *as an installed dependency* (see "Does this touch draft E?"
  below): pristine fails, workaround works, from `~/.cache/spin/packages/`.

## Run it again: `tools/publish_readiness.rb`

Every measurement above is scripted, so "does the package work for someone
else" is a command, not a memory:

```bash
ruby tools/publish_readiness.rb          # static checks + consumer matrix (~4 min)
ruby tools/publish_readiness.rb --fast   # static checks only (seconds)
ruby tools/publish_readiness.rb --keep   # leave the scratch tree for poking
```

Static gates: the two channels agree on the version; `s.files` ships both
entry points and no build output or dev tree; every `.c` in the tree is
declared carried C or excluded (the invariant behind the consumer-build
warnings). Matrix gates: fresh clone over a git URL builds and runs the
gem-preamble game, `spin vendor` builds and runs from `vendor/`, and the
installed gem answers `require "raylib-spinel"` under MRI while `require
"raylib"` still resolves to `raylib-bindings`. Notes, never failures: no
`origin`, a dirty tree, no xvfb. Wired into
`tools/full_validation.sh` as its last section.

## Publishing runbook (planned, NOT executed)

Nothing below has been run. Every step is an external write and needs Nelson's
explicit go (`AGENTS.md` §0). As of 2026-10-17 neither `raylib-spinel` nor
`hello_raylib` has a git remote, which gates all three routes; that is why the
spin cache test above used `file://` URLs, which only `publish` refuses.

**Step 0 — prerequisites (local, safe, run whenever):**

```bash
ruby tools/publish_readiness.rb   # must be all-PASS
spin test                         # the package's own gate, also spin publish's
git status --porcelain            # must be empty; spin publish refuses a dirty tree
```

**Route 1 — own GitHub repo (the first real step; the other two sit on it):**

```bash
gh repo create rebuilt/raylib-spinel --public --source . --push   # Nelson's account
# verify the published channel from a third directory:
mkdir -p /tmp/v/bin && cd /tmp/v && spin init
spin add raylib --git https://github.com/rebuilt/raylib-spinel
spin build && xvfb-run -a ./build/bin/<app>
```

Cost: a public repo of WIP material (`tools/repro/` is in it; it is
dependency-free C, but it is development scaffolding). Mitigation if that
stays: a publish branch or subtree with only `lib/`, the entry points,
`spin.toml`, README, LICENSE.

**Route 2 — rubygems (the MRI channel):**

```bash
gem build raylib_spinel.gemspec
gem push raylib-spinel-0.1.0.gem       # claims the name raylib-spinel; needs rubygems session/OTP
# verify, clean GEM_HOME:
GEM_PATH=/tmp/gh:$(gem env path) ruby -e 'gem "raylib-spinel"; require "raylib-spinel"; p Raylib.respond_to?(:InitWindow)'
```

`gem push` does not need the GitHub repo, but a gem without a homepage/repo to
file against is a bad citizen; route 1 first. Retraction exists (`gem yank
raylib-spinel -v 0.1.0`) but treat a pushed version as burned.

**Route 3 — spin index (claims the name `raylib` in matz's index):**

Needs route 1 (origin + HEAD pushed), `version` in `spin.toml` matching what
publish expects, `spin test` green, clean tree. Then `spin publish`. The name
`raylib` was free in the index when checked — claiming it for an unofficial
binding is a naming decision matz's policy governs and Nelson's call, not
ours by default; opening a `raylib`-named entry is functionally an upstream
interaction (`AGENTS.md` §0). Retraction means asking matz to remove the entry.

**Version bump ritual for any route:** bump `s.version` and `spin.toml`'s
`version` together (the readiness script now gates on their agreement), tag,
push, then push/publish the artifact.

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
   this box has two `raylib.pc` files that disagree with each other and with
   their own headers — `pkg-config` answers `~/.local` (`Version: 6.2.0`, 6.2
   headers) while `/usr/local`'s claims `6.0.0` under 6.1-dev headers — and the
   `hello_raylib` Makefile compiles the same adapters against `/usr/local`, so a
   `[native]` entry would let `PKG_CONFIG_PATH` decide which of the two build
   paths gets which headers. It
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
   `~/.local/lib` first, which ships both `libraylib.so` (a 6.2 build since
   2026-10-17) and `libraylib.so.600` — today a complete 6.1-dev build, but an
   incomplete one occupied that slot when the `AGENTS.md` §K weak-symbol story
   happened. `hello_raylib/tools/raylib_versions.rb` reports which file wins
   per build path. The
   README says none of this yet.
6. **Publish gates.** `spin publish` needs `origin` (or `--repo`), HEAD pushed to
   a remote branch, `spin test` green, and the index name: `raylib` is free in
   the index today, and claiming it in matz's index is a naming decision, so
   publishing is Nelson's call (also `AGENTS.md` §0). **Neither
   `raylib-spinel` nor `hello_raylib` has a git remote at all** — so the first
   real step is a repo of ours, not the index: a `--git` dependency consumes any
   pushed repo, and needs nothing from matz. The exact commands per route are in
   the runbook above; as decided on 2026-10-17, nothing is published and the
   runbook stays on the shelf until Nelson picks a route.

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
