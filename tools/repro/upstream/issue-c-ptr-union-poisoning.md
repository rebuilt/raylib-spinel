# Draft: an untyped helper's union return poisons `:ptr` acceptance program-wide

**Title:** a `:ptr` argument filled through a polymorphic helper makes the
compiler refuse unrelated `:ptr` call sites in the same program

**Toolchain:** `spinel 2026.09.12+10159 (a632e3b18)`

**Status: reproduced inside raylib-spinel only; a standalone minimisation is
still pending.** The diagnosis is precise (see below) but the report is not
worth filing until it is minimal.

## Summary

raylib-spinel wraps pointer-taking C functions with a coercion helper:

```ruby
def self.ptr_addr(x) = x.respond_to?(:address) ? x.address : x
```

Its return type is an untyped union (`Integer | anything`). When one wrapper
passes that result straight into a `:ptr` parameter:

```ruby
def self.UpdateTexture(texture, pixels)
  Raylib.rl_UpdateTexture(texture, Raylib.ptr_addr(pixels))    # pixels: :ptr
end
```

the compiler then refuses **unrelated** `:ptr` call sites elsewhere in the same
program — sites that pass native-class instances and compiled fine before the
wrapper above was changed:

```
textures_gif_player.rb  -> spinel-error
  lib/raylib_ffi.rb:1788: unsupported ffi pointer argument (a Ruby object has no
  C address; pass an IO::Buffer, a String or a :ptr value): node 48905
  (LocalVariableReadNode)                       # def self.UnloadImage(image)
  lib/raylib_ffi.rb:2214: unsupported ffi pointer argument (...):
  node 51007 (LocalVariableReadNode)            # def self.LoadModelFromMesh(mesh)
  lib/raylib_handles.rb:26: unsupported ffi pointer argument (...):
  node 35802 (SelfNode)                         # rl_Font_texture_ptr(self)
```

The reported sites are unrelated to `UpdateTexture`; the program is the same in
every other respect. Two observations that pin it down:

- reverting the `UpdateTexture` line makes all of them compile again;
- replacing the helper with one whose return type is pinned to Integer fixes it
  too, with no other change:

  ```ruby
  def self.ptr_int(x) = x.respond_to?(:address) ? x.address.to_i : x.to_i
  ```

  (`ptr_addr` still has callers that legitimately want the untaken branch —
  a bare boxed pointer passed to an `[:any]` setter — which is why both helpers
  exist now.)

## Why it matters

The failure surfaces at *unrelated* call sites, so the diagnostic names the
wrong place: it cost a long debugging cycle to trace back to the one wrapper
that introduced the union. Two requests:

1. If a `:ptr` parameter cannot accept an argument type, report it at the call
   site that produced the value (or at least treat it as a local error rather
   than poisoning the rest of the program), and
2. consider whether the union arm could be narrowed per call site, since the
   `respond_to?(:address)` branch is statically decidable for a typed receiver.

## Workaround in the tree

`Raylib.ptr_int` (Integer-pinned) is used for the pixel-buffer wrappers
(`UpdateTexture`, `UpdateTextureRec`); the synthetic corpus (`14/14`) and the
gif example pass again.
