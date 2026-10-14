# windowed
# Gem image/texture surface: producers return structs with fields.
require "raylib-spinel"
include Raylib

Raylib.InitWindow(64, 64, "corpus-textures")
img = Raylib.GenImageColor(4, 4, Raylib::RAYWHITE)
puts "img=#{img.width}x#{img.height}"
sub = Raylib.ImageFromImage(img, Rectangle.create(1, 1, 2, 2))
puts "sub=#{sub.width}x#{sub.height}"
tex = Raylib.LoadTextureFromImage(sub)
puts "tex=#{tex.width}x#{tex.height}"
Raylib.UnloadTexture(tex)
Raylib.UnloadImage(sub)
Raylib.UnloadImage(img)
Raylib.CloseWindow
puts "done"
