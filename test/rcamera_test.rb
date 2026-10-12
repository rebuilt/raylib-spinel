# Differential test: rcamera surface under Spinel vs the raylib-bindings gem.
# No .expected snapshot, so `spin test` runs this under CRuby (which loads the
# gem) and diffs the Spinel-compiled binary's output against it. Pure math on
# a Camera struct: no window, deterministic inputs, 3-decimal formatting.
require "raylib-spinel"
require "raylib-spinel/rcamera"

def f(x)
  format("%.3f", x.to_f + 0.0)
end

cam = Raylib::Camera.new
  .with_position(0.0, 0.0, 0.0)
  .with_target(0.0, 0.0, -1.0)
  .with_up(0.0, 1.0, 0.0)

fwd = Raylib.GetCameraForward(cam)
puts "GetCameraForward #{f fwd.x} #{f fwd.y} #{f fwd.z}"
up = Raylib.GetCameraUp(cam)
puts "GetCameraUp #{f up.x} #{f up.y} #{f up.z}"

Raylib.CameraYaw(cam, 0.5, true)
fwd = Raylib.GetCameraForward(cam)
puts "CameraYaw #{f fwd.x} #{f fwd.y} #{f fwd.z}"

Raylib.CameraPitch(cam, 0.3, true, true, true)
fwd = Raylib.GetCameraForward(cam)
puts "CameraPitch #{f fwd.x} #{f fwd.y} #{f fwd.z}"

vm = Raylib.GetCameraViewMatrix(cam)
puts "GetCameraViewMatrix #{f vm.m0} #{f vm.m5}"

pm = Raylib.GetCameraProjectionMatrix(cam, 1.5)
puts "GetCameraProjectionMatrix #{f pm.m0} #{f pm.m5}"

# snake_case alias (MRI gem naming)
Raylib.camera_move_forward(cam, 2.0, true)
puts "snake camera_move_forward ok"
