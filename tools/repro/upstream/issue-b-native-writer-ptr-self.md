# Draft: adding a Ruby writer to a native class breaks `self` in that class's `:ptr` parameters

**Title:** Defining a Ruby writer on a native class makes `self` unusable as a
`:ptr` argument in that class's other methods

**Toolchain:** `spinel 2026.09.12+10159 (a632e3b18)`

**Status: reproduced inside raylib-spinel only; a standalone minimisation is
still pending.** I am recording it because it is a real compiler refusal with a
one-line cause, but I would not file it before it is minimised outside our
library. The `b_writer_ptr_self/` project shows the shape that does *not*
trigger it.

## Summary

A native class (raylib-spinel's `Raylib::Font`, a view class with
`native_struct "Font", "rl_Font"`, `native_new [:any, :any], "rl_Font_view"`)
has accessor methods that pass `self` to an `ffi_func :ptr` shim:

```ruby
class Raylib::Font
  def texture = Texture2D.new(Raylib.rl_Font_texture_ptr(self), self)
  def recs    = PtrAddr.new(Raylib.rl_Font_recs_addr(self))
  def glyphs  = PtrAddr.new(Raylib.rl_Font_glyphs_addr(self))
end
```

Adding a Ruby writer to the same class — the natural way to accept more than one
shape of pointer, so that gem code assigning `font.recs = buf.read_pointer`
works — makes every one of those `self` arguments a compile error:

```
$ spinel <program>
spinel: lib/raylib_handles.rb:27: unsupported ffi pointer argument (a Ruby
object has no C address; pass an IO::Buffer, a String or a :ptr value):
node 35830 (SelfNode)
spinel: lib/raylib_pointer_fields.rb:22: unsupported ffi pointer argument (...):
node 93346 (SelfNode)
spinel: 2 refusals, nothing written
```

The writer that triggers it is ordinary Ruby:

```ruby
class Raylib::Font
  def glyphs=(v)
    _assign_glyphs(Raylib.ptr_addr(v))       # _assign_glyphs is a native_method
  end

  def recs=(v)
    _assign_recs(Raylib.ptr_addr(v))
  end
end
```

Removing the writers compiles again (that is the current state of the tree).

## Why it matters

Supporting a gem-shaped pointer field setter (`obj.field = <package
FFI::Pointer>`) requires unwrapping the object to its Integer address *before*
the C call; under AOT that has to happen in Ruby, i.e. exactly the writer above.
The alternatives all fail for other reasons (documented in the same session):

- `native_method :recs=, [:any]`: the C side receives a boxed **Ruby object**,
  not an address, so `rl_h_unbox` cannot recover the pointer.
- `ffi_func` with an `[:any]` parameter is not expressible (it renders as a
  bare C `void` parameter and the generated prototypes do not compile).
- `native_method :recs=, [:ptr]`: a package `FFI::Pointer` instance is a plain
  Ruby object and is refused by the `:ptr` slot.

## Requests

1. `define a writer without breaking `self`-as-`:ptr``: the current behaviour
   makes the two features mutually exclusive on one class.
2. (secondary) consider accepting an `FFI::Pointer`/`AbstractMemory` object in a
   `:ptr` slot by using its `#address` — that would remove the need for the Ruby
   writer entirely.

## Evidence in the tree

The bisection is one edit: `git diff` on
`lib/raylib_handles_ffi.rb` (adding `native_method :glyphs=, [:any], …`) plus
the writer block above in `lib/raylib_pointer_fields.rb`; the refusal points at
the two `self` arguments. Removing them restores a green build (`make check`,
`synthetic corpus 14/14`).
