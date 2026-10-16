# `Array#pack("p*")` emits a single pointer regardless of the array size

**Toolchain:** `spinel 2026.09.12+10301 (f90da21b9)` (also reproduces on
`+10159 (a632e3b18)`).

**Status: verified, dependency-free, no native code involved.**

## Summary

`Array#pack("p*")` — the idiom for building a `char **` / pointer array to hand
to a C function — produces 8 bytes (one pointer) no matter how many elements the
array has. CRuby produces `8 * n`. The `*` repetition works for the integer
directives, so this looks specific to the pointer directives `p`/`P`.

## Reproduction

```ruby
[2, 3].each do |n|
  a = (1..n).map { |i| "s#{i}" }.pack("p*")
  puts "n=#{n} bytesize=#{a.bytesize} (expected #{n * 8})"
end

b = ["This", "is"].pack("p*")
begin
  puts "unpack: #{b.unpack("p*").inspect}"
rescue => e
  puts "unpack: #{e.class}: #{e.message}"
end
```

```
$ spinel pack_repro.rb -o pack_repro && ./pack_repro
n=2 bytesize=8 (expected 16)
n=3 bytesize=8 (expected 24)
unpack: ArgumentError: no associated pointer
```

## Expected (CRuby)

```
n=2 bytesize=16 (expected 16)
n=3 bytesize=24 (expected 24)
unpack: ["This", "is"]
```

## The `*` works for other directives

```
                  CRuby   Spinel
[1, 2, 3].pack("C*").bytesize      3       3
[1, 2].pack("J*").bytesize         16      16
["a", "b"].pack("p*").bytesize     16       8      <- ignored
["a", "b"].pack("p").bytesize       8       8      (no star: correct, first element only)
```

`test/array_pack_native_ints.rb` covers single-element `p`/`P`, but no test in
the tree uses the `p*` / `P*` form.

## Impact

Any port of a program that builds an array of C strings this way passes a
truncated array to C. In raylib-bindings' `gui_controls.rb` example:

```ruby
listViewExList = ["This", "is", "a", "list view", "with", "disable",
                  "elements", "amazing!"].pack("p*")
...
RGuiListViewEx(rect, listViewExList, 8, scroll, active, focus)
```

the list view is handed a one-pointer blob with `count = 8`; raygui then reads
seven pointers past the buffer (SIGSEGV in `GuiDrawText` when the blob is used
directly). raylib-spinel now clamps the item count to the blob's byte length so
the program survives, and records the example as not-identical in its corpus
report (it draws one row where CRuby draws eight).

## Note

`p` (pointer) and `P` (freed pointer) both look affected; the length is the
symptom to check first. `unpack("p*")` failing on the compiler's own output
suggests the pack side writes a single pointer rather than an array. Repeat the
directive (CRuby's behaviour) or refuse it — silently writing one pointer is the
part that hurts.
