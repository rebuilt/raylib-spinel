# rcamera_ffi.rb — rcamera bindings for Spinel AOT.
#
# Loaded only by `require "raylib-spinel/rcamera"` under Spinel (see
# raylib-spinel/rcamera.rb). Under MRI that require is a no-op because the
# raylib-bindings gem already binds every rcamera function onto Raylib
# (GetCameraForward, CameraYaw, ...), so game code is identical on both
# backends.
#
# rcamera is a header-only library: the rl_* pointer shims compile rcamera.h
# inline into rcamera_adapter.c (linked with --link lib/rcamera_adapter.o).
# No ffi_lib here on purpose — there is no librcamera to link against.
# The Ruby wrappers live on module Raylib (matching the MRI gem) and
# allocate the out-param (a native Vector3/Matrix) and return it.

module Raylib
  ffi_cflags "-I/usr/local/include"

# ====== generated: complete rcamera API surface ======
  ffi_func :rl_GetCameraForward, [:ptr, :ptr], :void
  ffi_func :rl_GetCameraUp, [:ptr, :ptr], :void
  ffi_func :rl_GetCameraRight, [:ptr, :ptr], :void
  ffi_func :rl_CameraMoveForward, [:ptr, :float, :bool], :void
  ffi_func :rl_CameraMoveUp, [:ptr, :float], :void
  ffi_func :rl_CameraMoveRight, [:ptr, :float, :bool], :void
  ffi_func :rl_CameraMoveToTarget, [:ptr, :float], :void
  ffi_func :rl_CameraYaw, [:ptr, :float, :bool], :void
  ffi_func :rl_CameraPitch, [:ptr, :float, :bool, :bool, :bool], :void
  ffi_func :rl_CameraRoll, [:ptr, :float], :void
  ffi_func :rl_GetCameraViewMatrix, [:ptr, :ptr], :void
  ffi_func :rl_GetCameraProjectionMatrix, [:ptr, :float, :ptr], :void

    # ====== generated: wrappers + constants ======
    def self.GetCameraForward(camera)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_GetCameraForward(camera, _out)
      _out
    end
    def self.GetCameraUp(camera)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_GetCameraUp(camera, _out)
      _out
    end
    def self.GetCameraRight(camera)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_GetCameraRight(camera, _out)
      _out
    end
    def self.CameraMoveForward(camera, distance, moveInWorldPlane)
      Raylib.rl_CameraMoveForward(camera, distance, moveInWorldPlane)
    end
    def self.CameraMoveUp(camera, distance)
      Raylib.rl_CameraMoveUp(camera, distance)
    end
    def self.CameraMoveRight(camera, distance, moveInWorldPlane)
      Raylib.rl_CameraMoveRight(camera, distance, moveInWorldPlane)
    end
    def self.CameraMoveToTarget(camera, delta)
      Raylib.rl_CameraMoveToTarget(camera, delta)
    end
    def self.CameraYaw(camera, angle, rotateAroundTarget)
      Raylib.rl_CameraYaw(camera, angle, rotateAroundTarget)
    end
    def self.CameraPitch(camera, angle, lockView, rotateAroundTarget, rotateUp)
      Raylib.rl_CameraPitch(camera, angle, lockView, rotateAroundTarget, rotateUp)
    end
    def self.CameraRoll(camera, angle)
      Raylib.rl_CameraRoll(camera, angle)
    end
    def self.GetCameraViewMatrix(camera)
      _out = Matrix.new
      Raylib.rl_GetCameraViewMatrix(camera, _out)
      _out
    end
    def self.GetCameraProjectionMatrix(camera, aspect)
      _out = Matrix.new
      Raylib.rl_GetCameraProjectionMatrix(camera, aspect, _out)
      _out
    end
    CAMERA_PERSPECTIVE = 0
    CAMERA_ORTHOGRAPHIC = 1
    CAMERA_CUSTOM = 0
    CAMERA_FREE = 1
    CAMERA_ORBITAL = 2
    CAMERA_FIRST_PERSON = 3
    CAMERA_THIRD_PERSON = 4
    CAMERA_CULL_DISTANCE_NEAR = 0.05
    CAMERA_CULL_DISTANCE_FAR = 4000.0
    CAMERA_MOVE_SPEED = 5.4
    CAMERA_ROTATION_SPEED = 0.03
    CAMERA_PAN_SPEED = 2.0
    CAMERA_MOUSE_MOVE_SENSITIVITY = 0.003
    CAMERA_ORBITAL_SPEED = 0.5

  # ====== generated: snake_case aliases (MRI gem naming) ======
  class << self
    alias_method :get_camera_forward, :GetCameraForward
    alias_method :get_camera_up, :GetCameraUp
    alias_method :get_camera_right, :GetCameraRight
    alias_method :camera_move_forward, :CameraMoveForward
    alias_method :camera_move_up, :CameraMoveUp
    alias_method :camera_move_right, :CameraMoveRight
    alias_method :camera_move_to_target, :CameraMoveToTarget
    alias_method :camera_yaw, :CameraYaw
    alias_method :camera_pitch, :CameraPitch
    alias_method :camera_roll, :CameraRoll
    alias_method :get_camera_view_matrix, :GetCameraViewMatrix
    alias_method :get_camera_projection_matrix, :GetCameraProjectionMatrix
  end
end
