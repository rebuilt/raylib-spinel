# Gem constants / enums.
require "raylib"
include Raylib

puts [KEY_A, KEY_SPACE, KEY_F5, KEY_RIGHT].inspect
puts [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT].inspect
puts [CAMERA_PERSPECTIVE, CAMERA_ORTHOGRAPHIC].inspect
puts [FLAG_VSYNC_HINT, FLAG_MSAA_4X_HINT].inspect
puts [BLEND_ALPHA, BLEND_ADDITIVE].inspect
puts Raylib::PI.round(5)
puts Raylib::DEG2RAD.round(6)
