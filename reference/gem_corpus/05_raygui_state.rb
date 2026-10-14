# Gem raygui state surface (headless).
require "raylib"
include Raylib

puts "locked=#{Raylib.GuiIsLocked}"
Raylib.GuiLock
puts "locked=#{Raylib.GuiIsLocked}"
Raylib.GuiUnlock
puts "locked=#{Raylib.GuiIsLocked}"
puts "state=#{Raylib.GuiGetState}"
puts "style=#{Raylib.GuiGetStyle(Raylib::DEFAULT, Raylib::TEXT_SIZE)}"
Raylib.GuiSetState(Raylib.GuiGetState)
puts "done"
