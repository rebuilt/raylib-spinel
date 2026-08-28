require "raylib_ffi"

v = Raylib.GetRandomValue(0, 100)
puts "raylib bindings loaded"
puts "GetRandomValue(0, 100) in range: #{v >= 0 && v <= 100}"