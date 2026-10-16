# Engine-internal limitations we design around

Two findings from the gem-compat work live in a part of the compiler that makes
no promises, so they are recorded here rather than filed upstream. They are
constraints on raylib-spinel's design, not upstream bugs.

## Why these are our problem, not theirs

- `docs/limitations.md`, introduction: **"A successful compile does not
  establish CRuby-compatible behavior."**
- `docs/spin.md` ("Native C in a package") states the contract for carried C:
  *"Drop `.c`/`.h` files anywhere in the package tree and **bind them with the
  FFI declarations**"* — i.e. `ffi_func`, `ffi_lib`, `ffi_cflags`, `ffi_source`,
  `ffi_const`, `ffi_buffer`, `ffi_read_*`, `ffi_struct`, `ffi_callback`
  (`docs/FFI.md`).
- raylib-spinel's view layer is built on the **`native_struct` / `native_new` /
  `native_method`** DSL, which appears **nowhere in `docs/`**. Its only written
  contract is a comment at the top of `packages/stringio/stringio.rb`
  ("Path B typed object"): declarations are the compiler's entire knowledge of
  the class, constructors receive the assigned `cls_id`, and so on.
- `docs/FFI.md` §Limitations adds a rule our pointer-field work runs straight
  into: *"**Pointers can't enter polymorphic values.** Don't put a `:ptr` into a
  `poly_array` or a generic `Hash`; keep them as plain locals or wrap them in a
  class with a `ptr`-typed ivar."* Its `:ptr` argument spec accepts a `ptr`
  value or an `IO::Buffer` (base address) — an `FFI::Pointer` object is not on
  the list.

Both limitations below were reproduced with the compiler installed on
2026-10-16, `spinel 2026.09.12+10301 (f90da21b9)`.

## Limitation A — a native class's methods are unreachable from a poly receiver

**Symptom.** A method on a native class (`native_struct` + `native_new`, with or
without `native_method`) is not reachable when the receiver is a block parameter
or another poly value: the call raises `NoMethodError`, while a statically typed
receiver calls it correctly. The mechanism is the documented one — poly arms are
emitted for receivers whose static type names the class — and `docs/FFI.md`
§Limitations adds the pointer-in-poly rule on top.

**Experiment** (`upstream/a_native_class_methods/`, 16 variants on
`+10301 (f90da21b9)`): moving the accessors into Ruby over module-level
`ffi_func`s, with no `native_method` on the class, does **not** help. Definition
site (package file vs app-level monkey patch), body shape (direct C call, plus
arithmetic, sibling call, two C calls, comparison, object construction), method
name and array size are all irrelevant; a typed receiver is the only one that
resolves. `native_method` accessors behave the same way, so it is not a
Ruby-vs-C distinction.

**Trap.** A call named `value` does not raise — it answers `nil` — so a test
that only checks for the absence of an exception reports a false success.

**Workaround.** Keep the receiver statically typed. That is what our scenes do
(typed locals, direct calls), which is why `make check` is unaffected; it is why
the gem's `models.each { |model| model.material(0) }` cannot be fixed from our
side.

## Limitation B — a Ruby writer on a native class breaks `self` in that class's `:ptr` parameters

**Symptom.** Adding a plain Ruby writer to a native class makes every `self`
passed to an `ffi_func :ptr` shim in that class's *other* methods a compile
error:

```
spinel: lib/raylib_handles.rb:27: unsupported ffi pointer argument (a Ruby
object has no C address; pass an IO::Buffer, a String or a :ptr value):
node 35830 (SelfNode)
spinel: lib/raylib_pointer_fields.rb:22: unsupported ffi pointer argument (...):
node 93346 (SelfNode)
spinel: 2 refusals, nothing written
```

The writer that triggers it is ordinary Ruby (`def glyphs=(v) =
_assign_glyphs(Raylib.ptr_addr(v))`); removing it compiles again.

**Why we hit it.** Supporting the gem idiom `obj.field = buf.read_pointer`
needs the pointer unwrapped to an Integer address *before* the C call, and under
AOT that unwrapping has to happen in Ruby — i.e. exactly the writer above. The
alternatives were tried and each fails for its own reason (Recorded in the
git history around `10f5365`/`aa0ed29`):

- `native_method :field=, [:any]` — the C side receives a boxed Ruby object, not
  an address, so `rl_h_unbox` cannot recover the pointer (this is the
  pointer-in-poly case `docs/FFI.md` warns about).
- `ffi_func` with an `[:any]` parameter is not expressible; it renders as a bare
  C `void` parameter and the generated prototypes do not compile.
- `native_method :field=, [:ptr]` — a package `FFI::Pointer` instance is a plain
  Ruby object and is refused at the `:ptr` slot.

**What we do instead.** Pointer fields keep the box-friendly route:
`native_method :field=, [:any]` with the C side calling `rl_h_unbox`, which
covers pointers a raylib call returned (`MemAlloc`, `LoadFontData`) and Integer
addresses. Assigning a *package* `FFI::Pointer` (the `read_pointer` result) to a
pointer field is **not supported**, and gem code that does it must be adapted.
`tools/repro/upstream/b_writer_ptr_self/` records the shape that does *not*
trigger the refusal (a payload object without a view constructor), i.e. the
minimal case is still unminimised.

## Limitation C — an untyped helper's union return reaching one `:ptr` parameter poisons `:ptr` acceptance program-wide

**Symptom.** With

```ruby
def self.ptr_addr(x) = x.respond_to?(:address) ? x.address : x   # untyped union
```

used to fill a `:ptr` parameter in one wrapper (`UpdateTexture(texture,
ptr_addr(pixels))`), the compiler refuses **unrelated** `:ptr` call sites in the
same program — ones that pass native-class instances and compiled fine before
that line was changed:

```
lib/raylib_ffi.rb:1788: unsupported ffi pointer argument (...): node 48905 (LocalVariableReadNode)   # UnloadImage(image)
lib/raylib_ffi.rb:2214: unsupported ffi pointer argument (...): node 51007 (LocalVariableReadNode)   # LoadModelFromMesh(mesh)
lib/raylib_handles.rb:26: unsupported ffi pointer argument (...): node 35802 (SelfNode)              # rl_Font_texture_ptr(self)
spinel: 2 refusals, nothing written
```

Reverting the one line fixes all of them, and so does a helper whose return type
is pinned to Integer.

**Scope.** A documented-only rewrite of the same shape (`ffi_struct :Point` +
`ffi_func :memset, [:ptr, :int, :size_t], :ptr` + the same union helper)
**compiles and runs**, so the refusal needs a native *view* instance in the
`:ptr` slot. That places it in the same undocumented layer as B.

**What we do instead.** `Raylib.ptr_int` pins the result to an Integer for the
`:ptr`-shaped wrappers (`UpdateTexture`, `UpdateTextureRec`), while `ptr_addr`
stays for the `[:any]` setters that legitimately pass a box through.

The only part of C worth raising someday is the *diagnostic*: the refusal names
a call site unrelated to the line that caused it, which cost a long debugging
cycle. As long as the trigger is a view instance, it stays out of scope.

## Limitation D — op-assign through a `Struct` member that holds a native view

**Symptom.** After the 2026-10-16 toolchain move to `+10301 (f90da21b9)`, this
shape is refused where the previous compiler (`+10159 (a632e3b18)`) accepted it:

```
spinel: FILE:LINE: unsupported call operator write (unsupported receiver/attr):
node 94162 (CallOperatorWriteNode)
```

The minimal case:

```ruby
require "raylib"
include Raylib

S = Struct.new(:v)
s = S.new(Vector2.create(3.0, 4.0))
s.v.x *= 2.0          # refused
```

**Boundary** (all of these compile):

| shape | result |
| --- | --- |
| `v = Vector2.create(...); v.x *= 2.0` (a local) | compiles |
| `h.v.x += 1.0` (an `attr_accessor` member holding a view) | compiles |
| `s.v.x = 9.0` and `s.v.x = s.v.x + 2.0` (a `Struct` member, written explicitly) | compiles |
| `s.p.x *= 2.0` (`Struct` member holding a **plain** object with `x`/`x=`) | compiles |
| `s.v.x *= 2.0` (`Struct` member holding a **native view**) | refused |

So it needs the native-view receiver together with the `Struct` member and the
operator write; the documented-layer equivalent is fine. Same verdict as B and C:
ours to work around, not to file.

**Affected in our trees:** the raylib-bindings example
`textures_bunnymark_plain.rb` (`bunny.position.x += bunny.speed.x`, with `bunny`
a `Struct` whose members are `Vector2` views) now fails the examples analysis
section. Our own scenes keep floats in their structs and are unaffected
(`make check` stays green).

## Related

- `upstream/issue-a-block-param-native-method.md` — a Ruby method on a native
  class is unreachable from a block parameter. Also **not filed**: the mechanism
  (polymorphic arms are emitted for receivers with a static type) is a
  documented design property — `docs/limitations.md` records it for exceptions:
  *"the `#message`/`#to_s` arm is only emitted for a receiver whose static type
  names the exception class"* — and the class layer is the undocumented one. The
  documented `ffi_struct` layer cannot even express the shape (it yields `:ptr`
  values, with no class to define a method on).
- `upstream/issue-d-string-pack-p.md` — a genuine divergence in documented Ruby
  (`Array#pack("p*")` packs one pointer), filed upstream.
