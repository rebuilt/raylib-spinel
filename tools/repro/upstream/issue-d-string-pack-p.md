# Draft: `String#pack("p*")` allocates one pointer whatever the element count

**Title:** `String#pack("p*")` emits a single pointer regardless of the array
size (and `unpack("p*")` raises)

**Toolchain:** `spinel 2026.09.12+10159 (a632e3b18)`

**Status: verified, dependency-free, no native code involved.**

## Summary

`Array#pack("p*")` — the idiom for building a `char **` / pointer array to hand
to a C function — produces 8 bytes (one pointer) no matter how many elements the
array has. CRuby produces `8 * n`.

## Reproduction

```ruby
[2, 3].each do |n|
  a = (1..n).map { |i| "s#{i}" }.pack("p*")
  puts "n=#{n} bytesize=#{a.bytesize} (expected #{n * 8})"
end

b = ["This", "is"].pack("p*")
puts "unpack: #{b.unpack("p*").inspect}"
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
suggests the pack side writes a single pointer rather than an array.
