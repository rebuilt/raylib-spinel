# windowed
# Gem window lifecycle, fixed frames.
require "raylib"
include Raylib

Raylib.InitWindow(320, 240, "corpus-window")
Raylib.SetTargetFPS(60)
3.times do
  Raylib.BeginDrawing
  Raylib.ClearBackground(Raylib::RAYWHITE)
  Raylib.EndDrawing
end
puts "ready=#{Raylib.IsWindowReady}"
puts "size=#{Raylib.GetScreenWidth}x#{Raylib.GetScreenHeight}"
Raylib.CloseWindow
puts "closed"
