# raylib-spinel conventions

The canonical conventions live in `../hello_raylib/AGENTS.md` (scene protocol,
the three registries, the Spinel AOT constraints, the verification commands).
Read those first; this file covers the package itself.

## Packaging

`PACKAGING.md` records what a consumer actually gets from each channel — spin
clones the repository and compiles `spin.toml`'s carried C; rubygems ships
`raylib_spinel.gemspec`'s `s.files` — and what is still open before a release.
Two rules follow from it:

- `s.files` and `spin.toml`'s `sources`/`exclude` describe the same package to
  two different tools. Change one with the other: an entry point in the README
  that `s.files` does not ship, or C that `exclude` hides from a consumer's
  build, is invisible until somebody else installs the package.
- Nothing is published without Nelson's go (`AGENTS.md` §0 upstream rule, and
  `spin publish` writes to matz/spin-index while `gem push` writes to
  rubygems). Note also that neither this repository nor `hello_raylib` has a
  git remote, so `spin publish` and `spin add --git` both need a repo of ours
  first.

## Tooling: write new tools in Ruby

This is a Ruby codebase. New tools under `tools/` are Ruby.

- The Python tools here predate the rule (the generators, `coerce_ptr_args.py`,
  `check_shim_unwraps.py`, `fix_pointer_handle_shims.py`,
  `coverage_audit.py`, `gem_compat_audit.py`, ...). Leave them alone unless a
  change needs one, and port one when you touch it rather than adding a Python
  sibling.
- Ruby tools may use `Prism` for parsing (see `tools/check_duplicate_methods.rb`
  and `tools/gem_surface_audit.rb`): a name lands on the class it is defined in,
  which a grep cannot do across the files that reopen `module Raylib`.
- An audit reports gaps and gates on regressions (a committed baseline JSON plus
  `--check`), and is wired into a gate: `make check` in `../hello_raylib`, or
  `tools/full_validation.sh` for the slow sections.

## Post-processors for the generated files

`lib/raylib_ffi.rb`, `lib/raylib_include.rb`, `lib/raylib_field_index.rb` and
friends are generated. A behaviour change to a generated wrapper belongs in a
post-processor with a `--check` mode (e.g. `tools/wrap_model.rb`,
`tools/coerce_ptr_args.py`), wired into `make check`, so re-running the
generator cannot silently revert it.
