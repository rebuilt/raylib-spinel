# windowed
# Gem draw surface with by-value structs.
require "raylib"
include Raylib

Raylib.InitWindow(320, 240, "corpus-shapes")
rec = Rectangle.create(10, 10, 100, 50)
col = Color.from_u8(255, 0, 0, 255)
2.times do
  Raylib.BeginDrawing
  Raylib.ClearBackground(Raylib::RAYWHITE)
  Raylib.DrawRectangleRec(rec, col)
  Raylib.DrawRectanglePro(Rectangle.create(10, 80, 50, 50), Vector2.create(25, 25), 45.0, col)
  Raylib.DrawRectangleRounded(Rectangle.create(100, 80, 50, 50), 0.5, 8, col)
  Raylib.EndDrawing
end
puts "drawn"
Raylib.CloseWindow
