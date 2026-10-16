# frozen_string_literal: true

# Camera field writers for the struct-typed fields: the generator emits
# writers for scalar fields only, so position/target/up (Camera3D, Vector3)
# and offset/target (Camera2D, Vector2) are declared here. Hand-written, not
# generated, so regenerating raylib_ffi.rb cannot drop them.
module Raylib
  native_struct "Camera", "rl_Camera"
  native_method :position=, [:ptr], :void, "rl_Camera_set_position"
  native_method :target=, [:ptr], :void, "rl_Camera_set_target"
  native_method :up=, [:ptr], :void, "rl_Camera_set_up"

  native_struct "Camera2D", "rl_Camera2D"
  native_method :offset=, [:ptr], :void, "rl_Camera2D_set_offset"
  native_method :target=, [:ptr], :void, "rl_Camera2D_set_target"
end
