# windowed
# RenderTexture round-trip: the API spells its type `RenderTexture2D`, the
# Ruby class is `RenderTexture`; LoadRenderTexture must wrap (not hand back a
# raw pointer), Begin/EndTextureMode must unwrap the view, and the result must
# read back through LoadImageFromTexture.
require "raylib"
include Raylib

Raylib.InitWindow(320, 240, "corpus-render-texture")
Raylib.SetTargetFPS(60)

target = Raylib.LoadRenderTexture(64, 64)
puts "texture: #{target.texture.width}x#{target.texture.height}"
puts "depth is texture: #{target.depth.width}x#{target.depth.height}"

Raylib.BeginTextureMode(target)
Raylib.ClearBackground(Raylib::BLACK)
Raylib.DrawRectangle(0, 0, 8, 8, Raylib::RED)
Raylib.DrawRectangle(56, 0, 8, 8, Raylib::RED)
Raylib.DrawRectangle(0, 56, 8, 8, Raylib::RED)
Raylib.DrawRectangle(56, 56, 8, 8, Raylib::RED)
Raylib.EndTextureMode()

# GL reads back bottom-up; all four corners are red, so the probes are
# orientation-independent while the middle stays black.
image = Raylib.LoadImageFromTexture(target.texture)
c = Raylib.GetImageColor(image, 2, 2)
puts "corner: #{c.r},#{c.g},#{c.b},#{c.a}"
c = Raylib.GetImageColor(image, 34, 34)
puts "middle: #{c.r},#{c.g},#{c.b},#{c.a}"
Raylib.UnloadImage(image)

Raylib.BeginDrawing
Raylib.ClearBackground(Raylib::RAYWHITE)
Raylib.DrawTextureRec(target.texture, Rectangle.create(0, 0, 64, -64),
                      Vector2.create(100, 100), Raylib::WHITE)
Raylib.EndDrawing
puts "drawn"

Raylib.UnloadRenderTexture(target)
Raylib.CloseWindow
