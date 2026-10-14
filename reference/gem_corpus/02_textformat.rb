# Gem string formatting helpers (TextFormat returns a pointer).
require "raylib-spinel"
include Raylib

puts Raylib.TextFormat("hello %s %d %.1f", :string, "world", :int, 42, :float, 1.5).read_string
puts Raylib.TextFormat("%03d-%s", :int, 7, :string, "x").read_string
puts Raylib.TextToInteger("123"), Raylib.TextToFloat("1.5").round(2)
puts Raylib.TextSubtext("hello world", 6, 5)
puts Raylib.TextToUpper("abc"), Raylib.TextToLower("ABC")
