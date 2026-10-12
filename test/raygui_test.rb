require "raylib-spinel"
require "raylib-spinel/raygui"

# raygui's Spinel surface is float/pointer shims, so the MRI gem's raygui
# signatures differ; this snapshot pins the compiled (Spinel) behaviour.
# Only window-independent calls here (no InitWindow) so the test runs headless.
puts "raygui bindings loaded"

puts "locked: #{Raylib.GuiIsLocked}"
Raylib.GuiLock
puts "locked after lock: #{Raylib.GuiIsLocked}"
Raylib.GuiUnlock
puts "locked after unlock: #{Raylib.GuiIsLocked}"

puts "state: #{Raylib.GuiGetState}"

# Tooltip / icon-scale / HSV state round-trips through the new shims.
Raylib.GuiSetTooltip('tip')
Raylib.GuiEnableTooltip
Raylib.GuiDisableTooltip
Raylib.GuiSetIconScale(2)

Raylib.GuiSetColorHSV(0.5, 0.25, 0.75)
puts "hsv: #{Raylib.rl_Gui_GetHsvH} #{Raylib.rl_Gui_GetHsvS} #{Raylib.rl_Gui_GetHsvV}"

puts "style: #{Raylib.GuiGetStyle(Raylib::DEFAULT, Raylib::TEXT_SIZE)}"
