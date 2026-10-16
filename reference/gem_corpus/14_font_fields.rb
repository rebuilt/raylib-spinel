# windowed
# Font fields: LoadFont plus the pointer-field setters (the gem's MemAlloc
# idiom). `font.recs = buf.read_pointer` is not supported under AOT (a package
# FFI::Pointer boxes as a Ruby object, not an address), so the writable form
# pinned here is the boxed-pointer one.
require "raylib"
include Raylib

TTF = ENV["RAYLIB_CORPUS_TTF"] ||
      "/tmp/opencode/corpus_assets/text/resources/anonymous_pro_bold.ttf"

Raylib.InitWindow(320, 240, "corpus-font-fields")

font = LoadFont(TTF)
puts "loaded: baseSize=#{font.baseSize} glyphCount=#{font.glyphCount}"
size = MeasureTextEx(font, "Hello", 16.0, 0)
puts "measure: #{size.x.round},#{size.y.round}"
BeginDrawing()
  ClearBackground(RAYWHITE)
  DrawTextEx(font, "Hello", Vector2.create(10, 10), 16.0, 0, BLACK)
  DrawTexture(font.texture, 10, 40, BLACK)
EndDrawing()

built = Font.new
built.baseSize = 16
built.glyphCount = 7
built.glyphs = MemAlloc(64)
built.recs = MemAlloc(64)
puts "assigned: baseSize=#{built.baseSize} glyphCount=#{built.glyphCount}"

UnloadFont(font)
# `built` is deliberately not unloaded: its glyphs/recs were assigned by hand
# from MemAlloc buffers, and freeing a hand-built font here is not part of what
# this program pins.
Raylib.CloseWindow
