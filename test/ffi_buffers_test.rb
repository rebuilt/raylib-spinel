require "raylib"
require "ffi"

# CPU-side FFI buffer parity: the gem loads the ffi package, so MRI code
# allocates scratch buffers with FFI::MemoryPointer (gui text boxes, shader
# value outputs, animation counts). The AOT surface now loads the bundled ffi
# package from the entry point, so the constant and its read/write API behave
# the same. Headless.

ptr = FFI::MemoryPointer.new(:int, 1)
ptr.write_int(42)
puts "int round-trip: #{ptr.read_int}"
puts "address is Integer: #{ptr.address.is_a?(Integer)}"

floats = FFI::MemoryPointer.new(:float, 3)
floats.write_array_of_float([1.5, 2.5, 3.5])
puts "float array: #{floats.read_array_of_float(3).join(',')}"

chars = FFI::MemoryPointer.new(:char, 8)
chars.put_string(0, "abc")
puts "string: #{chars.read_string}"

# Pointer arithmetic over the same buffer, the idiom gem code uses to index
# struct arrays (LoadImageColors, LoadFontData, LoadModelAnimations, ...).
ints = FFI::MemoryPointer.new(:int, 4)
ints.put_array_of_int32(0, [7, 8, 9, 10])
second = ints + 4
puts "stride read: #{second.read_int} third: #{(ints + 8).read_int}"
