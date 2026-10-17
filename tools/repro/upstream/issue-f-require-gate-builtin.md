# Draft: `--require-gate` refuses a require that Spinel's own builtin satisfies

**Filed:** [matz/spinel#9441](https://github.com/matz/spinel/issues/9441),
2026-10-17, as: *"`--require-gate` refuses `require \"rbconfig\"` although the
parser splices `RbConfig` itself — every gated build of an `optparse` program
fails"*. Everything below `## Summary` is the filed body verbatim.

**Toolchain:** `spinel 2026.09.12+10525 (8a51e2822) [gcc 13.3.0]`
(verified 2026-10-17)

## Summary

`--require-gate` turns an unresolvable `require` into a compile-time refusal.
Three require names are refused although Spinel provides the constants they load
and the compiler splices them itself: `rbconfig`, `gem`, `rubygems`. Without the
gate the same programs compile and run correctly.

It matters because the gate is on by default in `spin` builds, and one of the
compiler's own bundled packages (`optparse`) contains a
`require "rbconfig"`. So a program whose only dependency is `optparse` no longer
builds:

```
$ spin build
build app
spinel: cannot load such file -- rbconfig (require "rbconfig")
spin: build failed (hint: an unresolved require may need a dependency: spin add <name> --path <dir>)
```

The message names no file and no line, and the require is inside a bundled
package the user cannot edit, so the failure is hard to diagnose: the hint
suggests vendoring a `rbconfig`, which would then shadow the builtin the
compiler already splices.

## Reproduction 1 — one file, no packages

```ruby
# rbconfig_probe.rb
require "rbconfig"
puts RbConfig::CONFIG["host_os"]
```

```
$ spinel rbconfig_probe.rb -o probe && ./probe
warning: 'rbconfig' is not available in Spinel; the require is ignored and code using it will fail
rbconfig_probe.rb -> probe
linux                                      # correct answer, from the spliced builtin

$ spinel -c rbconfig_probe.rb --require-gate -o probe.c
spinel: cannot load such file -- rbconfig (require "rbconfig")
$ echo $?
1
```

The two runs differ only by the gate. The value printed in the first run comes
from `builtins/rbconfig.rb`, which the parser splices whenever the program names
`RbConfig` — the require was already a no-op in a program that works.

Same shape for the RubyGems spellings (the require cannot break the program:
those names only exist to define `Gem`, which the parser splices when the
program names it):

| `require` | under `--require-gate` | without the gate | runs? |
| --- | --- | --- | --- |
| `"rbconfig"` | `cannot load such file -- rbconfig` | warning, ignored | yes → `linux` |
| `"rubygems"` | `cannot load such file -- rubygems` | warning, ignored | yes → `Gem::VERSION` = `4.0.20` |
| `"gem"` | `cannot load such file -- gem` | warning, ignored | yes → `4.0.20` |

## Reproduction 2 — a bare spin project (what a user actually hits)

```
$ ls -R
spin.toml  bin/app.rb
```

`spin.toml`:

```toml
[package]
name = "optapp"
version = "0.1.0"
```

`bin/app.rb`:

```ruby
require "optparse"

name = "world"
OptionParser.new do |o|
  o.banner = "usage: app [options]"
  o.on("--name NAME") { |v| name = v }
end.parse!
puts "hello #{name}"
```

Nothing else, no native code, no dependencies beyond the compiler:

```
$ spin flags
--require-gate -I /path/to/optapp       # the gate comes with the project, not with the flags I passed
$ spin build
build app
spinel: cannot load such file -- rbconfig (require "rbconfig")
spin: build failed (hint: an unresolved require may need a dependency: spin add <name> --path <dir>)
$ spin run
spinel: cannot load such file -- rbconfig (require "rbconfig")
spin: build failed (hint: ...)
```

and the same file under the ungated compiler:

```
$ spinel bin/app.rb -o app && ./app --name there
warning: 'rbconfig' is not available in Spinel; the require is ignored and code using it will fail
bin/app.rb -> app
hello there
```

(The `DidYouMean` warning that also appears on stderr comes from `optparse`
itself and is unrelated.) The program never mentions `rbconfig`:
`packages/optparse/optparse.rb` does, in `private def strip_ext`, whose regex
interpolation contains

```ruby
      require "rbconfig"
      Regexp.union(*RbConfig::CONFIG["EXECUTABLE_EXTS"]&.split(" "))
```

so the require is reached through a bundled package, not through user code.

## Mechanism

`src/spinel_parse.c`, the branch for a require that resolved to nothing (the
line numbers are from `8a51e2822`):

```c
      if (!content) {
        if (sp_lib_is_native(lib_name)) {            /* io/console, monitor, time, socket, ostruct */
          sp_feature_mark(lib_name); ...             /* silent no-op */
        }
else if (sp_require_tolerated(lib_name)) {      /* thread, enumerator, fiber, ffi, rational, complex, io/wait */
          content = strdup("# require no-op (core feature)"); ...
        }
else if (g_require_gate) {
          fprintf(stderr, "spinel: cannot load such file -- %s (require \"%s\")\n", lib_name, lib_name);
          exit(1);
        }
else { /* warning, ignored */ }
```

`rbconfig`, `gem` and `rubygems` are in neither list, so they fall through to
`exit(1)` under the gate. But they are exactly the category the second list
documents — "a core capability Spinel provides without a file ... CRuby
satisfies them silently for the same reason" — and the parser goes further than
being silent for these two: it splices real implementations a few lines later,
`src/spinel_parse.c:5272-5273`:

```c
  source = sp_splice_named_builtin(source, argv0, "Gem", "builtins/gem", &fsl, &fsl_n);
  source = sp_splice_named_builtin(source, argv0, "RbConfig", "builtins/rbconfig", &fsl, &fsl_n);
```

`builtins/rbconfig.rb` opens by describing precisely the require that is being
refused: *"The parser splices this file when the program names `RbConfig` and
defines none of its own."* Since the splices run after `resolve_requires`, the
gate cannot see that the constant is about to be provided — the require is
refused before the file that satisfies it is considered.

For contrast, the gate is right in the neighbouring cases, which shows the list
is doing real work: `set`, `thread` and `ostruct` resolve and build under the
gate, and `objspace` is refused under the gate *and* refused without it, for a
reason the compiler states (`ObjectSpace is not supported by AOT compilation:
there is no class-keyed allocation registry to walk`, pointing at
`docs/limitations.md`) — so the ask is only about the requires whose constants
the builtins do provide.

## Timeline (from this repository's history)

| commit | date | effect |
| --- | --- | --- |
| `891b94ef7` | 2026-06-29 | `require: compile-time error for an unsatisfiable require (phase 3)` — the gate |
| `28e70b46f` | 2026-09-29 | `Gem and RbConfig answer the questions library code asks them without a require` — `builtins/gem.rb`, `builtins/rbconfig.rb`, the splices |
| `40b56868e` | 2026-10-16 | `optparse is ruby/optparse v0.8.1, unchanged` — the vendored package carries `require "rbconfig"` |

Any two of these three are harmless; all three together make every gated build
of an `optparse` program fail. `optparse` is the only bundled package with such
a require (grepping the package tree finds it there alone), so user code that
writes `require "rbconfig"` or `require "rubygems"` — both ordinary CRuby — is
the other way in.

## Expected

- `rbconfig`, `gem` and `rubygems` join the tolerated set, or the gate consults
  the same table the splices use, so that a require whose constant Spinel
  provides is a no-op under the gate exactly as it is without it. `Gem` and
  `RbConfig` were deliberately made answerable *without* a require; library code
  that writes the require anyway — which is what CRuby allows — should not be a
  compile error.
- Failing that, make the refusal name the site: `cannot load such file --
  rbconfig (require "rbconfig")` carries no file and no line, and here the
  require is inside a bundled package, so the only way to find the cause is to
  grep the package tree. The non-gated warning at least says the require was
  ignored.
- And the `spin` hint (`spin add <name> --path <dir>`) points at vendoring a
  file that the compiler already splices; for these names the hint would lead a
  user to shadow a builtin.
