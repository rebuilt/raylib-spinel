# rcamera_ffi.rb — FFI declarations for Spinel AOT
# Under MRI, ffi_func/ffi_lib/ffi_cflags are no-ops defined in main.rb

module Rcamera
  ffi_lib "rcamera"
  ffi_cflags "-I/usr/local/include"

# ====== generated: complete rcamera API surface ======
  ffi_func :sp_GetCameraForward, [:ptr, :ptr], :void
  ffi_func :sp_GetCameraUp, [:ptr, :ptr], :void
  ffi_func :sp_GetCameraRight, [:ptr, :ptr], :void
  ffi_func :sp_CameraMoveForward, [:ptr, :float, :bool], :void
  ffi_func :sp_CameraMoveUp, [:ptr, :float], :void
  ffi_func :sp_CameraMoveRight, [:ptr, :float, :bool], :void
  ffi_func :sp_CameraMoveToTarget, [:ptr, :float], :void
  ffi_func :sp_CameraYaw, [:ptr, :float, :bool], :void
  ffi_func :sp_CameraPitch, [:ptr, :float, :bool, :bool, :bool], :void
  ffi_func :sp_CameraRoll, [:ptr, :float], :void
  ffi_func :sp_GetCameraViewMatrix, [:ptr, :ptr], :void
  ffi_func :sp_GetCameraProjectionMatrix, [:ptr, :float, :ptr], :void
  native_struct "Vector2", "sp_Vector2"
  native_new [], "sp_Vector2_new"
  native_method :x, [], :float, "sp_Vector2_x"
  native_method :x=, [:float], :float, "sp_Vector2_set_x"
  native_method :y, [], :float, "sp_Vector2_y"
  native_method :y=, [:float], :float, "sp_Vector2_set_y"
  native_struct "Vector3", "sp_Vector3"
  native_new [], "sp_Vector3_new"
  native_method :x, [], :float, "sp_Vector3_x"
  native_method :x=, [:float], :float, "sp_Vector3_set_x"
  native_method :y, [], :float, "sp_Vector3_y"
  native_method :y=, [:float], :float, "sp_Vector3_set_y"
  native_method :z, [], :float, "sp_Vector3_z"
  native_method :z=, [:float], :float, "sp_Vector3_set_z"
  native_struct "Camera", "sp_Camera"
  native_new [], "sp_Camera_new"
  native_struct "Vector4", "sp_Vector4"
  native_new [], "sp_Vector4_new"
  native_struct "Matrix", "sp_Matrix"
  native_new [], "sp_Matrix_new"
  native_method :m0, [], :float, "sp_Matrix_m0"
  native_method :m0=, [:float], :float, "sp_Matrix_set_m0"
  native_method :m4, [], :float, "sp_Matrix_m4"
  native_method :m4=, [:float], :float, "sp_Matrix_set_m4"
  native_method :m8, [], :float, "sp_Matrix_m8"
  native_method :m8=, [:float], :float, "sp_Matrix_set_m8"
  native_method :m12, [], :float, "sp_Matrix_m12"
  native_method :m12=, [:float], :float, "sp_Matrix_set_m12"
  native_method :m1, [], :float, "sp_Matrix_m1"
  native_method :m1=, [:float], :float, "sp_Matrix_set_m1"
  native_method :m5, [], :float, "sp_Matrix_m5"
  native_method :m5=, [:float], :float, "sp_Matrix_set_m5"
  native_method :m9, [], :float, "sp_Matrix_m9"
  native_method :m9=, [:float], :float, "sp_Matrix_set_m9"
  native_method :m13, [], :float, "sp_Matrix_m13"
  native_method :m13=, [:float], :float, "sp_Matrix_set_m13"
  native_method :m2, [], :float, "sp_Matrix_m2"
  native_method :m2=, [:float], :float, "sp_Matrix_set_m2"
  native_method :m6, [], :float, "sp_Matrix_m6"
  native_method :m6=, [:float], :float, "sp_Matrix_set_m6"
  native_method :m10, [], :float, "sp_Matrix_m10"
  native_method :m10=, [:float], :float, "sp_Matrix_set_m10"
  native_method :m14, [], :float, "sp_Matrix_m14"
  native_method :m14=, [:float], :float, "sp_Matrix_set_m14"
  native_method :m3, [], :float, "sp_Matrix_m3"
  native_method :m3=, [:float], :float, "sp_Matrix_set_m3"
  native_method :m7, [], :float, "sp_Matrix_m7"
  native_method :m7=, [:float], :float, "sp_Matrix_set_m7"
  native_method :m11, [], :float, "sp_Matrix_m11"
  native_method :m11=, [:float], :float, "sp_Matrix_set_m11"
  native_method :m15, [], :float, "sp_Matrix_m15"
  native_method :m15=, [:float], :float, "sp_Matrix_set_m15"
  native_struct "Color", "sp_Color"
  native_new [], "sp_Color_new"
  native_struct "Rectangle", "sp_Rectangle"
  native_new [], "sp_Rectangle_new"

  # Camera
  ffi_func :InitCamera, [], :void
  ffi_func :SetCameraMode, [%i[ptr int]]
  ffi_func :SetCameraPanZoom, [%i[ptr float float]]
  ffi_func :UpdateCamera, [%i[ptr int]]
  ffi_func :BeginMode2D, [%i[ptr]]
  ffi_func :EndMode2D, []
  ffi_func :BeginMode3D, [%i[ptr]]
  ffi_func :EndMode3D, []
  ffi_func :BeginModeStereo, [%i[ptr]]
  ffi_func :EndModeStereo, []
  ffi_func :MoveCamera, [%i[ptr float float float]]
  ffi_func :CameraMove, [%i[ptr float float float]]
  ffi_func :CameraRotate, [%i[ptr float float float]]
  ffi_func :CameraZoom, [%i[ptr float]]
  ffi_func :SetShadesValue, [%i[ptr int int]]
  ffi_func :GetCameraWidth, [%i[ptr]] :int
  ffi_func :GetCameraHeight, [%i[ptr]] :int

  # Vector3
  ffi_func :Vector3Create, %i[float float float], :ptr
  ffi_func :Vector3GetX, [:ptr], :float
  ffi_func :Vector3GetY, [:ptr], :float
  ffi_func :Vector3GetZ, [:ptr], :float

  # Enums
  CAMERA_CUSTOM = 0
  CAMERA_FREE = 1
  CAMERA_ORBITAL = 2
  CAMERA_FIRST_PERSON = 3
  CAMERA_THIRD_PERSON = 4
  CAMERA_ORTHOGRAPHIC = 5
  CAMERA_PERSPECTIVE = 0

  # Constants

    # ====== generated: wrappers + constants ======
    def self.GetCameraForward(camera)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_GetCameraForward(camera, _out)
      _out
    end
    def self.GetCameraUp(camera)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_GetCameraUp(camera, _out)
      _out
    end
    def self.GetCameraRight(camera)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_GetCameraRight(camera, _out)
      _out
    end
    def self.CameraMoveForward(camera, distance, moveInWorldPlane)
      Raylib.sp_CameraMoveForward(camera, distance, moveInWorldPlane)
    end
    def self.CameraMoveUp(camera, distance)
      Raylib.sp_CameraMoveUp(camera, distance)
    end
    def self.CameraMoveRight(camera, distance, moveInWorldPlane)
      Raylib.sp_CameraMoveRight(camera, distance, moveInWorldPlane)
    end
    def self.CameraMoveToTarget(camera, delta)
      Raylib.sp_CameraMoveToTarget(camera, delta)
    end
    def self.CameraYaw(camera, angle, rotateAroundTarget)
      Raylib.sp_CameraYaw(camera, angle, rotateAroundTarget)
    end
    def self.CameraPitch(camera, angle, lockView, rotateAroundTarget, rotateUp)
      Raylib.sp_CameraPitch(camera, angle, lockView, rotateAroundTarget, rotateUp)
    end
    def self.CameraRoll(camera, angle)
      Raylib.sp_CameraRoll(camera, angle)
    end
    def self.GetCameraViewMatrix(camera)
      _out = Matrix.new
      Raylib.sp_GetCameraViewMatrix(camera, _out)
      _out
    end
    def self.GetCameraProjectionMatrix(camera, aspect)
      _out = Matrix.new
      Raylib.sp_GetCameraProjectionMatrix(camera, aspect, _out)
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
end
