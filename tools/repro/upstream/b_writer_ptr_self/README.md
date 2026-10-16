# `self` in a `:ptr` parameter + a Ruby writer — shape that does NOT trigger it

This project exists to record the *absence* of a reproduction, so nobody
re-files the shape below as the trigger.

Both variants use a native class (`native_struct "Thing", "sp_Thing"`) with an
`ffi_func :sp_Thing_addr, [:ptr], :long` helper called with `self`:

- `without_writer/` — compiles and runs (`addr nonzero=true`).
- `with_writer/` — adds `def flag=(v); self.value = v; end` to the class; it
  **also compiles and runs**.

So "a Ruby writer on the class" alone is *not* sufficient to reproduce the
refusal documented in `../issue-b-native-writer-ptr-self.md`. The trigger in
raylib-spinel must involve something this project does not model — the most
likely candidate is the view-class constructor shape
(`native_new [:any, :any], "rl_Font_view"`, a class constructible from a boxed
pointer and holding `p`/`owner`/`v`), which the `thing` package here does not
have (it is a plain payload object, the `stringio` shape).

Both variants build with:

```bash
cd without_writer && spin build && ./build/bin/repro_b
cd ../with_writer && spin build          # expected to fail per the draft; currently succeeds
```
