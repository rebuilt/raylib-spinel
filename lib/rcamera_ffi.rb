# rcamera_ffi.rb — FFI declarations for Spinel AOT
# Under MRI, ffi_func/ffi_lib/ffi_cflags are no-ops defined in main.rb

module Rcamera
  ffi_lib "rcamera"
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
  native_struct "Vector2", "rl_Vector2"
  native_new [], "rl_Vector2_new"
  native_method :x, [], :float, "rl_Vector2_x"
  native_method :x=, [:float], :float, "rl_Vector2_set_x"
  native_method :y, [], :float, "rl_Vector2_y"
  native_method :y=, [:float], :float, "rl_Vector2_set_y"
  native_struct "Vector3", "rl_Vector3"
  native_new [], "rl_Vector3_new"
  native_method :x, [], :float, "rl_Vector3_x"
  native_method :x=, [:float], :float, "rl_Vector3_set_x"
  native_method :y, [], :float, "rl_Vector3_y"
  native_method :y=, [:float], :float, "rl_Vector3_set_y"
  native_method :z, [], :float, "rl_Vector3_z"
  native_method :z=, [:float], :float, "rl_Vector3_set_z"
  native_struct "Camera", "rl_Camera"
  native_new [], "rl_Camera_new"
  native_struct "Vector4", "rl_Vector4"
  native_new [], "rl_Vector4_new"
  native_struct "Matrix", "rl_Matrix"
  native_new [], "rl_Matrix_new"
  native_method :m0, [], :float, "rl_Matrix_m0"
  native_method :m0=, [:float], :float, "rl_Matrix_set_m0"
  native_method :m4, [], :float, "rl_Matrix_m4"
  native_method :m4=, [:float], :float, "rl_Matrix_set_m4"
  native_method :m8, [], :float, "rl_Matrix_m8"
  native_method :m8=, [:float], :float, "rl_Matrix_set_m8"
  native_method :m12, [], :float, "rl_Matrix_m12"
  native_method :m12=, [:float], :float, "rl_Matrix_set_m12"
  native_method :m1, [], :float, "rl_Matrix_m1"
  native_method :m1=, [:float], :float, "rl_Matrix_set_m1"
  native_method :m5, [], :float, "rl_Matrix_m5"
  native_method :m5=, [:float], :float, "rl_Matrix_set_m5"
  native_method :m9, [], :float, "rl_Matrix_m9"
  native_method :m9=, [:float], :float, "rl_Matrix_set_m9"
  native_method :m13, [], :float, "rl_Matrix_m13"
  native_method :m13=, [:float], :float, "rl_Matrix_set_m13"
  native_method :m2, [], :float, "rl_Matrix_m2"
  native_method :m2=, [:float], :float, "rl_Matrix_set_m2"
  native_method :m6, [], :float, "rl_Matrix_m6"
  native_method :m6=, [:float], :float, "rl_Matrix_set_m6"
  native_method :m10, [], :float, "rl_Matrix_m10"
  native_method :m10=, [:float], :float, "rl_Matrix_set_m10"
  native_method :m14, [], :float, "rl_Matrix_m14"
  native_method :m14=, [:float], :float, "rl_Matrix_set_m14"
  native_method :m3, [], :float, "rl_Matrix_m3"
  native_method :m3=, [:float], :float, "rl_Matrix_set_m3"
  native_method :m7, [], :float, "rl_Matrix_m7"
  native_method :m7=, [:float], :float, "rl_Matrix_set_m7"
  native_method :m11, [], :float, "rl_Matrix_m11"
  native_method :m11=, [:float], :float, "rl_Matrix_set_m11"
  native_method :m15, [], :float, "rl_Matrix_m15"
  native_method :m15=, [:float], :float, "rl_Matrix_set_m15"
  native_struct "Color", "rl_Color"
  native_new [], "rl_Color_new"
  native_struct "Rectangle", "rl_Rectangle"
  native_new [], "rl_Rectangle_new"

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
end
