# raymath_ffi.rb — FFI declarations for Spinel AOT
# Under MRI, ffi_func/ffi_lib/ffi_cflags are no-ops defined in main.rb

module Raymath
  ffi_lib "raymath"
  ffi_cflags "-I/usr/local/include"
  ffi_cflags "-Wl,-rpath,/usr/local/lib"

# ====== generated: complete raymath API surface ======
  ffi_func :Clamp, [:float, :float, :float], :float
  ffi_func :Lerp, [:float, :float, :float], :float
  ffi_func :Normalize, [:float, :float, :float], :float
  ffi_func :Remap, [:float, :float, :float, :float, :float], :float
  ffi_func :Wrap, [:float, :float, :float], :float
  ffi_func :FloatEquals, [:float, :float], :int
  ffi_func :sp_Vector2Zero, [:ptr], :void
  ffi_func :sp_Vector2One, [:ptr], :void
  ffi_func :sp_Vector2Add, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector2AddValue, [:ptr, :float, :ptr], :void
  ffi_func :sp_Vector2Subtract, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector2SubtractValue, [:ptr, :float, :ptr], :void
  ffi_func :sp_Vector2Length, [:ptr], :float
  ffi_func :sp_Vector2LengthSqr, [:ptr], :float
  ffi_func :sp_Vector2DotProduct, [:ptr, :ptr], :float
  ffi_func :sp_Vector2CrossProduct, [:ptr, :ptr], :float
  ffi_func :sp_Vector2Distance, [:ptr, :ptr], :float
  ffi_func :sp_Vector2DistanceSqr, [:ptr, :ptr], :float
  ffi_func :sp_Vector2Angle, [:ptr, :ptr], :float
  ffi_func :sp_Vector2LineAngle, [:ptr, :ptr], :float
  ffi_func :sp_Vector2Scale, [:ptr, :float, :ptr], :void
  ffi_func :sp_Vector2Multiply, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector2Negate, [:ptr, :ptr], :void
  ffi_func :sp_Vector2Divide, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector2Normalize, [:ptr, :ptr], :void
  ffi_func :sp_Vector2Transform, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector2Lerp, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_Vector2Reflect, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector2Min, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector2Max, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector2Rotate, [:ptr, :float, :ptr], :void
  ffi_func :sp_Vector2MoveTowards, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_Vector2Invert, [:ptr, :ptr], :void
  ffi_func :sp_Vector2Clamp, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector2ClampValue, [:ptr, :float, :float, :ptr], :void
  ffi_func :sp_Vector2Equals, [:ptr, :ptr], :int
  ffi_func :sp_Vector2Refract, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_Vector3Zero, [:ptr], :void
  ffi_func :sp_Vector3One, [:ptr], :void
  ffi_func :sp_Vector3Add, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector3AddValue, [:ptr, :float, :ptr], :void
  ffi_func :sp_Vector3Subtract, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector3SubtractValue, [:ptr, :float, :ptr], :void
  ffi_func :sp_Vector3Scale, [:ptr, :float, :ptr], :void
  ffi_func :sp_Vector3Multiply, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector3CrossProduct, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector3Perpendicular, [:ptr, :ptr], :void
  ffi_func :sp_Vector3Length, [:ptr], :float
  ffi_func :sp_Vector3LengthSqr, [:ptr], :float
  ffi_func :sp_Vector3DotProduct, [:ptr, :ptr], :float
  ffi_func :sp_Vector3Distance, [:ptr, :ptr], :float
  ffi_func :sp_Vector3DistanceSqr, [:ptr, :ptr], :float
  ffi_func :sp_Vector3Angle, [:ptr, :ptr], :float
  ffi_func :sp_Vector3Negate, [:ptr, :ptr], :void
  ffi_func :sp_Vector3Divide, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector3Normalize, [:ptr, :ptr], :void
  ffi_func :sp_Vector3Project, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector3Reject, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector3OrthoNormalize, [:ptr, :ptr], :void
  ffi_func :sp_Vector3Transform, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector3RotateByQuaternion, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector3RotateByAxisAngle, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_Vector3MoveTowards, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_Vector3Lerp, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_Vector3CubicHermite, [:ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_Vector3Reflect, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector3Min, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector3Max, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector3Barycenter, [:ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector3Unproject, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector3ToFloatV, [:ptr, :float], :ptr
  ffi_func :sp_Vector3Invert, [:ptr, :ptr], :void
  ffi_func :sp_Vector3Clamp, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector3ClampValue, [:ptr, :float, :float, :ptr], :void
  ffi_func :sp_Vector3Equals, [:ptr, :ptr], :int
  ffi_func :sp_Vector3Refract, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_Vector4Zero, [:ptr], :void
  ffi_func :sp_Vector4One, [:ptr], :void
  ffi_func :sp_Vector4Add, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector4AddValue, [:ptr, :float, :ptr], :void
  ffi_func :sp_Vector4Subtract, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector4SubtractValue, [:ptr, :float, :ptr], :void
  ffi_func :sp_Vector4Length, [:ptr], :float
  ffi_func :sp_Vector4LengthSqr, [:ptr], :float
  ffi_func :sp_Vector4DotProduct, [:ptr, :ptr], :float
  ffi_func :sp_Vector4Distance, [:ptr, :ptr], :float
  ffi_func :sp_Vector4DistanceSqr, [:ptr, :ptr], :float
  ffi_func :sp_Vector4Scale, [:ptr, :float, :ptr], :void
  ffi_func :sp_Vector4Multiply, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector4Negate, [:ptr, :ptr], :void
  ffi_func :sp_Vector4Divide, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector4Normalize, [:ptr, :ptr], :void
  ffi_func :sp_Vector4Min, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector4Max, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_Vector4Lerp, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_Vector4MoveTowards, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_Vector4Invert, [:ptr, :ptr], :void
  ffi_func :sp_Vector4Equals, [:ptr, :ptr], :int
  ffi_func :sp_MatrixDeterminant, [:ptr], :float
  ffi_func :sp_MatrixTrace, [:ptr], :float
  ffi_func :sp_MatrixTranspose, [:ptr, :ptr], :void
  ffi_func :sp_MatrixInvert, [:ptr, :ptr], :void
  ffi_func :sp_MatrixIdentity, [:ptr], :void
  ffi_func :sp_MatrixAdd, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_MatrixSubtract, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_MatrixMultiply, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_MatrixMultiplyValue, [:ptr, :float, :ptr], :void
  ffi_func :sp_MatrixTranslate, [:float, :float, :float, :ptr], :void
  ffi_func :sp_MatrixRotate, [:ptr, :float, :ptr], :void
  ffi_func :sp_MatrixRotateX, [:float, :ptr], :void
  ffi_func :sp_MatrixRotateY, [:float, :ptr], :void
  ffi_func :sp_MatrixRotateZ, [:float, :ptr], :void
  ffi_func :sp_MatrixRotateXYZ, [:ptr, :ptr], :void
  ffi_func :sp_MatrixRotateZYX, [:ptr, :ptr], :void
  ffi_func :sp_MatrixScale, [:float, :float, :float, :ptr], :void
  ffi_func :sp_MatrixFrustum, [:double, :double, :double, :double, :double, :double, :ptr], :void
  ffi_func :sp_MatrixPerspective, [:double, :double, :double, :double, :ptr], :void
  ffi_func :sp_MatrixOrtho, [:double, :double, :double, :double, :double, :double, :ptr], :void
  ffi_func :sp_MatrixLookAt, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_MatrixToFloatV, [:ptr, :float], :ptr
  ffi_func :sp_QuaternionAdd, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_QuaternionAddValue, [:ptr, :float, :ptr], :void
  ffi_func :sp_QuaternionSubtract, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_QuaternionSubtractValue, [:ptr, :float, :ptr], :void
  ffi_func :sp_QuaternionIdentity, [:ptr], :void
  ffi_func :sp_QuaternionLength, [:ptr], :float
  ffi_func :sp_QuaternionNormalize, [:ptr, :ptr], :void
  ffi_func :sp_QuaternionInvert, [:ptr, :ptr], :void
  ffi_func :sp_QuaternionMultiply, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_QuaternionScale, [:ptr, :float, :ptr], :void
  ffi_func :sp_QuaternionDivide, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_QuaternionLerp, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_QuaternionNlerp, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_QuaternionSlerp, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_QuaternionCubicHermiteSpline, [:ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_QuaternionFromVector3ToVector3, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_QuaternionFromMatrix, [:ptr, :ptr], :void
  ffi_func :sp_QuaternionToMatrix, [:ptr, :ptr], :void
  ffi_func :sp_QuaternionFromAxisAngle, [:ptr, :float, :ptr], :void
  ffi_func :sp_QuaternionToAxisAngle, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_QuaternionFromEuler, [:float, :float, :float, :ptr], :void
  ffi_func :sp_QuaternionToEuler, [:ptr, :ptr], :void
  ffi_func :sp_QuaternionTransform, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_QuaternionEquals, [:ptr, :ptr], :int
  ffi_func :sp_MatrixCompose, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_MatrixDecompose, [:ptr, :ptr, :ptr, :ptr], :void
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
  native_struct "Vector4", "sp_Vector4"
  native_new [], "sp_Vector4_new"
  native_method :x, [], :float, "sp_Vector4_x"
  native_method :x=, [:float], :float, "sp_Vector4_set_x"
  native_method :y, [], :float, "sp_Vector4_y"
  native_method :y=, [:float], :float, "sp_Vector4_set_y"
  native_method :z, [], :float, "sp_Vector4_z"
  native_method :z=, [:float], :float, "sp_Vector4_set_z"
  native_method :w, [], :float, "sp_Vector4_w"
  native_method :w=, [:float], :float, "sp_Vector4_set_w"
  native_struct "Quaternion", "sp_Quaternion"
  native_new [], "sp_Quaternion_new"
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

  # Vector2
  ffi_func :Vector2Create, %i[float float], :ptr
  ffi_func :Vector2GetX, [:ptr], :float
  ffi_func :Vector2GetY, [:ptr], :float
  ffi_func :Vector2SetX, %i[ptr float], :void
  ffi_func :Vector2SetY, %i[ptr float], :void

  # Vector3
  ffi_func :Vector3Create, %i[float float float], :ptr
  ffi_func :Vector3GetX, [:ptr], :float
  ffi_func :Vector3GetY, [:ptr], :float
  ffi_func :Vector3GetZ, [:ptr], :float

  # Vector4
  ffi_func :Vector4Create, %i[float float float float], :ptr
  ffi_func :Vector4GetX, [:ptr], :float
  ffi_func :Vector4GetY, [:ptr], :float
  ffi_func :Vector4GetZ, [:ptr], :float
  ffi_func :Vector4GetW, [:ptr], :float

  # Matrix
  ffi_func :MatrixCreate, [], :ptr
  ffi_func :MatrixGetElement, [%i[ptr int], :float]
  ffi_func :MatrixSetElement, [%i[ptr int float], :void]

  # Color
  ffi_func :ColorNew, %i[int int int int], :ptr
  ffi_func :ColorGetR, [:ptr], :int
  ffi_func :ColorGetG, [:ptr], :int
  ffi_func :ColorGetB, [:ptr], :int
  ffi_func :ColorGetA, [:ptr], :int

  # Rectangle
  ffi_func :RectangleNew, %i[float float float float], :ptr
  ffi_func :RectangleGetX, [:ptr], :float
  ffi_func :RectangleGetY, [:ptr], :float
  ffi_func :RectangleGetWidth, [:ptr], :float
  ffi_func :RectangleGetHeight, [:ptr], :float

  # Camera2D
  ffi_func :Camera2DNew, %i[float float float float float], :ptr
  ffi_func :Camera2DGetTarget, [:ptr], %i[float float]
  ffi_func :Camera2DGetOffset, [:ptr], %i[float float]
  ffi_func :Camera2DGetRotation, [:ptr], :float
  ffi_func :Camera2DGetZoom, [:ptr], :float

  # Camera3D
  ffi_func :Camera3DNew, %i[float float float float float int], :ptr
  ffi_func :Camera3DGetPosition, [:ptr], %i[float float float]
  ffi_func :Camera3DGetTarget, [:ptr], %i[float float float]
  ffi_func :Camera3DGetUp, [:ptr], %i[float float float]
  ffi_func :Camera3DGetFovy, [:ptr], :float
  ffi_func :Camera3DGetProjection, [:ptr], :int

  # Enums
  RAYGUI_VERTICAL_SLIDER = 0
  RAYGUI_HORIZONTAL_SLIDER = 1
  RAYGUI_TOGGLE_BUTTON = 2
  RAYGUI_TOGGLE_GROUP = 3
  RAYGUI_BUTTON = 4
  RAYGUI_CHECKBOX = 5
  RAYGUI_LABEL = 6
  RAYGUI_TEXT_INPUTBOX = 7
  RAYGUI_SPINNER = 8
  RAYGUI_SCROLLBAR = 9
  RAYGUI_COMBOBOX = 10
  RAYGUI_COLOR_PICKER = 11
  RAYGUI_FILEIO = 12

  # Constants

    # ====== generated: wrappers + constants ======
    def self.Vector2Zero()
      _out = Vector2.new
      Raylib.sp_Vector2Zero(_out)
      _out
    end
    def self.Vector2One()
      _out = Vector2.new
      Raylib.sp_Vector2One(_out)
      _out
    end
    def self.Vector2Add(v1, v2)
      _out = Vector2.new
      Raylib.sp_Vector2Add(v1, v2, _out)
      _out
    end
    def self.Vector2AddValue(v, add)
      _out = Vector2.new
      Raylib.sp_Vector2AddValue(v, add, _out)
      _out
    end
    def self.Vector2Subtract(v1, v2)
      _out = Vector2.new
      Raylib.sp_Vector2Subtract(v1, v2, _out)
      _out
    end
    def self.Vector2SubtractValue(v, sub)
      _out = Vector2.new
      Raylib.sp_Vector2SubtractValue(v, sub, _out)
      _out
    end
    def self.Vector2Length(v)
      Raylib.sp_Vector2Length(v)
    end
    def self.Vector2LengthSqr(v)
      Raylib.sp_Vector2LengthSqr(v)
    end
    def self.Vector2DotProduct(v1, v2)
      Raylib.sp_Vector2DotProduct(v1, v2)
    end
    def self.Vector2CrossProduct(v1, v2)
      Raylib.sp_Vector2CrossProduct(v1, v2)
    end
    def self.Vector2Distance(v1, v2)
      Raylib.sp_Vector2Distance(v1, v2)
    end
    def self.Vector2DistanceSqr(v1, v2)
      Raylib.sp_Vector2DistanceSqr(v1, v2)
    end
    def self.Vector2Angle(v1, v2)
      Raylib.sp_Vector2Angle(v1, v2)
    end
    def self.Vector2LineAngle(start, kw_end)
      Raylib.sp_Vector2LineAngle(start, kw_end)
    end
    def self.Vector2Scale(v, scale)
      _out = Vector2.new
      Raylib.sp_Vector2Scale(v, scale, _out)
      _out
    end
    def self.Vector2Multiply(v1, v2)
      _out = Vector2.new
      Raylib.sp_Vector2Multiply(v1, v2, _out)
      _out
    end
    def self.Vector2Negate(v)
      _out = Vector2.new
      Raylib.sp_Vector2Negate(v, _out)
      _out
    end
    def self.Vector2Divide(v1, v2)
      _out = Vector2.new
      Raylib.sp_Vector2Divide(v1, v2, _out)
      _out
    end
    def self.Vector2Normalize(v)
      _out = Vector2.new
      Raylib.sp_Vector2Normalize(v, _out)
      _out
    end
    def self.Vector2Transform(v, mat)
      _out = Vector2.new
      Raylib.sp_Vector2Transform(v, mat, _out)
      _out
    end
    def self.Vector2Lerp(v1, v2, amount)
      _out = Vector2.new
      Raylib.sp_Vector2Lerp(v1, v2, amount, _out)
      _out
    end
    def self.Vector2Reflect(v, normal)
      _out = Vector2.new
      Raylib.sp_Vector2Reflect(v, normal, _out)
      _out
    end
    def self.Vector2Min(v1, v2)
      _out = Vector2.new
      Raylib.sp_Vector2Min(v1, v2, _out)
      _out
    end
    def self.Vector2Max(v1, v2)
      _out = Vector2.new
      Raylib.sp_Vector2Max(v1, v2, _out)
      _out
    end
    def self.Vector2Rotate(v, angle)
      _out = Vector2.new
      Raylib.sp_Vector2Rotate(v, angle, _out)
      _out
    end
    def self.Vector2MoveTowards(v, target, maxDistance)
      _out = Vector2.new
      Raylib.sp_Vector2MoveTowards(v, target, maxDistance, _out)
      _out
    end
    def self.Vector2Invert(v)
      _out = Vector2.new
      Raylib.sp_Vector2Invert(v, _out)
      _out
    end
    def self.Vector2Clamp(v, min, max)
      _out = Vector2.new
      Raylib.sp_Vector2Clamp(v, min, max, _out)
      _out
    end
    def self.Vector2ClampValue(v, min, max)
      _out = Vector2.new
      Raylib.sp_Vector2ClampValue(v, min, max, _out)
      _out
    end
    def self.Vector2Equals(p, q)
      Raylib.sp_Vector2Equals(p, q)
    end
    def self.Vector2Refract(v, n, r)
      _out = Vector2.new
      Raylib.sp_Vector2Refract(v, n, r, _out)
      _out
    end
    def self.Vector3Zero()
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3Zero(_out)
      _out
    end
    def self.Vector3One()
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3One(_out)
      _out
    end
    def self.Vector3Add(v1, v2)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3Add(v1, v2, _out)
      _out
    end
    def self.Vector3AddValue(v, add)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3AddValue(v, add, _out)
      _out
    end
    def self.Vector3Subtract(v1, v2)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3Subtract(v1, v2, _out)
      _out
    end
    def self.Vector3SubtractValue(v, sub)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3SubtractValue(v, sub, _out)
      _out
    end
    def self.Vector3Scale(v, scalar)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3Scale(v, scalar, _out)
      _out
    end
    def self.Vector3Multiply(v1, v2)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3Multiply(v1, v2, _out)
      _out
    end
    def self.Vector3CrossProduct(v1, v2)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3CrossProduct(v1, v2, _out)
      _out
    end
    def self.Vector3Perpendicular(v)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3Perpendicular(v, _out)
      _out
    end
    def self.Vector3Length(v)
      Raylib.sp_Vector3Length(v)
    end
    def self.Vector3LengthSqr(v)
      Raylib.sp_Vector3LengthSqr(v)
    end
    def self.Vector3DotProduct(v1, v2)
      Raylib.sp_Vector3DotProduct(v1, v2)
    end
    def self.Vector3Distance(v1, v2)
      Raylib.sp_Vector3Distance(v1, v2)
    end
    def self.Vector3DistanceSqr(v1, v2)
      Raylib.sp_Vector3DistanceSqr(v1, v2)
    end
    def self.Vector3Angle(v1, v2)
      Raylib.sp_Vector3Angle(v1, v2)
    end
    def self.Vector3Negate(v)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3Negate(v, _out)
      _out
    end
    def self.Vector3Divide(v1, v2)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3Divide(v1, v2, _out)
      _out
    end
    def self.Vector3Normalize(v)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3Normalize(v, _out)
      _out
    end
    def self.Vector3Project(v1, v2)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3Project(v1, v2, _out)
      _out
    end
    def self.Vector3Reject(v1, v2)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3Reject(v1, v2, _out)
      _out
    end
    def self.Vector3OrthoNormalize(v1, v2)
      Raylib.sp_Vector3OrthoNormalize(v1, v2)
    end
    def self.Vector3Transform(v, mat)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3Transform(v, mat, _out)
      _out
    end
    def self.Vector3RotateByQuaternion(v, q)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3RotateByQuaternion(v, q, _out)
      _out
    end
    def self.Vector3RotateByAxisAngle(v, axis, angle)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3RotateByAxisAngle(v, axis, angle, _out)
      _out
    end
    def self.Vector3MoveTowards(v, target, maxDistance)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3MoveTowards(v, target, maxDistance, _out)
      _out
    end
    def self.Vector3Lerp(v1, v2, amount)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3Lerp(v1, v2, amount, _out)
      _out
    end
    def self.Vector3CubicHermite(v1, tangent1, v2, tangent2, amount)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3CubicHermite(v1, tangent1, v2, tangent2, amount, _out)
      _out
    end
    def self.Vector3Reflect(v, normal)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3Reflect(v, normal, _out)
      _out
    end
    def self.Vector3Min(v1, v2)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3Min(v1, v2, _out)
      _out
    end
    def self.Vector3Max(v1, v2)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3Max(v1, v2, _out)
      _out
    end
    def self.Vector3Barycenter(p, a, b, c)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3Barycenter(p, a, b, c, _out)
      _out
    end
    def self.Vector3Unproject(source, projection, view)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3Unproject(source, projection, view, _out)
      _out
    end
    def self.Vector3ToFloatV(v)
      Raylib.sp_Vector3ToFloatV(v)
    end
    def self.Vector3Invert(v)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3Invert(v, _out)
      _out
    end
    def self.Vector3Clamp(v, min, max)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3Clamp(v, min, max, _out)
      _out
    end
    def self.Vector3ClampValue(v, min, max)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3ClampValue(v, min, max, _out)
      _out
    end
    def self.Vector3Equals(p, q)
      Raylib.sp_Vector3Equals(p, q)
    end
    def self.Vector3Refract(v, n, r)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_Vector3Refract(v, n, r, _out)
      _out
    end
    def self.Vector4Zero()
      _out = Vector4.new
      Raylib.sp_Vector4Zero(_out)
      _out
    end
    def self.Vector4One()
      _out = Vector4.new
      Raylib.sp_Vector4One(_out)
      _out
    end
    def self.Vector4Add(v1, v2)
      _out = Vector4.new
      Raylib.sp_Vector4Add(v1, v2, _out)
      _out
    end
    def self.Vector4AddValue(v, add)
      _out = Vector4.new
      Raylib.sp_Vector4AddValue(v, add, _out)
      _out
    end
    def self.Vector4Subtract(v1, v2)
      _out = Vector4.new
      Raylib.sp_Vector4Subtract(v1, v2, _out)
      _out
    end
    def self.Vector4SubtractValue(v, add)
      _out = Vector4.new
      Raylib.sp_Vector4SubtractValue(v, add, _out)
      _out
    end
    def self.Vector4Length(v)
      Raylib.sp_Vector4Length(v)
    end
    def self.Vector4LengthSqr(v)
      Raylib.sp_Vector4LengthSqr(v)
    end
    def self.Vector4DotProduct(v1, v2)
      Raylib.sp_Vector4DotProduct(v1, v2)
    end
    def self.Vector4Distance(v1, v2)
      Raylib.sp_Vector4Distance(v1, v2)
    end
    def self.Vector4DistanceSqr(v1, v2)
      Raylib.sp_Vector4DistanceSqr(v1, v2)
    end
    def self.Vector4Scale(v, scale)
      _out = Vector4.new
      Raylib.sp_Vector4Scale(v, scale, _out)
      _out
    end
    def self.Vector4Multiply(v1, v2)
      _out = Vector4.new
      Raylib.sp_Vector4Multiply(v1, v2, _out)
      _out
    end
    def self.Vector4Negate(v)
      _out = Vector4.new
      Raylib.sp_Vector4Negate(v, _out)
      _out
    end
    def self.Vector4Divide(v1, v2)
      _out = Vector4.new
      Raylib.sp_Vector4Divide(v1, v2, _out)
      _out
    end
    def self.Vector4Normalize(v)
      _out = Vector4.new
      Raylib.sp_Vector4Normalize(v, _out)
      _out
    end
    def self.Vector4Min(v1, v2)
      _out = Vector4.new
      Raylib.sp_Vector4Min(v1, v2, _out)
      _out
    end
    def self.Vector4Max(v1, v2)
      _out = Vector4.new
      Raylib.sp_Vector4Max(v1, v2, _out)
      _out
    end
    def self.Vector4Lerp(v1, v2, amount)
      _out = Vector4.new
      Raylib.sp_Vector4Lerp(v1, v2, amount, _out)
      _out
    end
    def self.Vector4MoveTowards(v, target, maxDistance)
      _out = Vector4.new
      Raylib.sp_Vector4MoveTowards(v, target, maxDistance, _out)
      _out
    end
    def self.Vector4Invert(v)
      _out = Vector4.new
      Raylib.sp_Vector4Invert(v, _out)
      _out
    end
    def self.Vector4Equals(p, q)
      Raylib.sp_Vector4Equals(p, q)
    end
    def self.MatrixDeterminant(mat)
      Raylib.sp_MatrixDeterminant(mat)
    end
    def self.MatrixTrace(mat)
      Raylib.sp_MatrixTrace(mat)
    end
    def self.MatrixTranspose(mat)
      _out = Matrix.new
      Raylib.sp_MatrixTranspose(mat, _out)
      _out
    end
    def self.MatrixInvert(mat)
      _out = Matrix.new
      Raylib.sp_MatrixInvert(mat, _out)
      _out
    end
    def self.MatrixIdentity()
      _out = Matrix.new
      Raylib.sp_MatrixIdentity(_out)
      _out
    end
    def self.MatrixAdd(left, right)
      _out = Matrix.new
      Raylib.sp_MatrixAdd(left, right, _out)
      _out
    end
    def self.MatrixSubtract(left, right)
      _out = Matrix.new
      Raylib.sp_MatrixSubtract(left, right, _out)
      _out
    end
    def self.MatrixMultiply(left, right)
      _out = Matrix.new
      Raylib.sp_MatrixMultiply(left, right, _out)
      _out
    end
    def self.MatrixMultiplyValue(left, value)
      _out = Matrix.new
      Raylib.sp_MatrixMultiplyValue(left, value, _out)
      _out
    end
    def self.MatrixTranslate(x, y, z)
      _out = Matrix.new
      Raylib.sp_MatrixTranslate(x, y, z, _out)
      _out
    end
    def self.MatrixRotate(axis, angle)
      _out = Matrix.new
      Raylib.sp_MatrixRotate(axis, angle, _out)
      _out
    end
    def self.MatrixRotateX(angle)
      _out = Matrix.new
      Raylib.sp_MatrixRotateX(angle, _out)
      _out
    end
    def self.MatrixRotateY(angle)
      _out = Matrix.new
      Raylib.sp_MatrixRotateY(angle, _out)
      _out
    end
    def self.MatrixRotateZ(angle)
      _out = Matrix.new
      Raylib.sp_MatrixRotateZ(angle, _out)
      _out
    end
    def self.MatrixRotateXYZ(angle)
      _out = Matrix.new
      Raylib.sp_MatrixRotateXYZ(angle, _out)
      _out
    end
    def self.MatrixRotateZYX(angle)
      _out = Matrix.new
      Raylib.sp_MatrixRotateZYX(angle, _out)
      _out
    end
    def self.MatrixScale(x, y, z)
      _out = Matrix.new
      Raylib.sp_MatrixScale(x, y, z, _out)
      _out
    end
    def self.MatrixFrustum(left, right, bottom, top, nearPlane, farPlane)
      _out = Matrix.new
      Raylib.sp_MatrixFrustum(left, right, bottom, top, nearPlane, farPlane, _out)
      _out
    end
    def self.MatrixPerspective(fovY, aspect, nearPlane, farPlane)
      _out = Matrix.new
      Raylib.sp_MatrixPerspective(fovY, aspect, nearPlane, farPlane, _out)
      _out
    end
    def self.MatrixOrtho(left, right, bottom, top, nearPlane, farPlane)
      _out = Matrix.new
      Raylib.sp_MatrixOrtho(left, right, bottom, top, nearPlane, farPlane, _out)
      _out
    end
    def self.MatrixLookAt(eye, target, up)
      _out = Matrix.new
      Raylib.sp_MatrixLookAt(eye, target, up, _out)
      _out
    end
    def self.MatrixToFloatV(mat)
      Raylib.sp_MatrixToFloatV(mat)
    end
    def self.QuaternionAdd(q1, q2)
      _out = Quaternion.new
      Raylib.sp_QuaternionAdd(q1, q2, _out)
      _out
    end
    def self.QuaternionAddValue(q, add)
      _out = Quaternion.new
      Raylib.sp_QuaternionAddValue(q, add, _out)
      _out
    end
    def self.QuaternionSubtract(q1, q2)
      _out = Quaternion.new
      Raylib.sp_QuaternionSubtract(q1, q2, _out)
      _out
    end
    def self.QuaternionSubtractValue(q, sub)
      _out = Quaternion.new
      Raylib.sp_QuaternionSubtractValue(q, sub, _out)
      _out
    end
    def self.QuaternionIdentity()
      _out = Quaternion.new
      Raylib.sp_QuaternionIdentity(_out)
      _out
    end
    def self.QuaternionLength(q)
      Raylib.sp_QuaternionLength(q)
    end
    def self.QuaternionNormalize(q)
      _out = Quaternion.new
      Raylib.sp_QuaternionNormalize(q, _out)
      _out
    end
    def self.QuaternionInvert(q)
      _out = Quaternion.new
      Raylib.sp_QuaternionInvert(q, _out)
      _out
    end
    def self.QuaternionMultiply(q1, q2)
      _out = Quaternion.new
      Raylib.sp_QuaternionMultiply(q1, q2, _out)
      _out
    end
    def self.QuaternionScale(q, mul)
      _out = Quaternion.new
      Raylib.sp_QuaternionScale(q, mul, _out)
      _out
    end
    def self.QuaternionDivide(q1, q2)
      _out = Quaternion.new
      Raylib.sp_QuaternionDivide(q1, q2, _out)
      _out
    end
    def self.QuaternionLerp(q1, q2, amount)
      _out = Quaternion.new
      Raylib.sp_QuaternionLerp(q1, q2, amount, _out)
      _out
    end
    def self.QuaternionNlerp(q1, q2, amount)
      _out = Quaternion.new
      Raylib.sp_QuaternionNlerp(q1, q2, amount, _out)
      _out
    end
    def self.QuaternionSlerp(q1, q2, amount)
      _out = Quaternion.new
      Raylib.sp_QuaternionSlerp(q1, q2, amount, _out)
      _out
    end
    def self.QuaternionCubicHermiteSpline(q1, outTangent1, q2, inTangent2, t)
      _out = Quaternion.new
      Raylib.sp_QuaternionCubicHermiteSpline(q1, outTangent1, q2, inTangent2, t, _out)
      _out
    end
    def self.QuaternionFromVector3ToVector3(from, to)
      _out = Quaternion.new
      Raylib.sp_QuaternionFromVector3ToVector3(from, to, _out)
      _out
    end
    def self.QuaternionFromMatrix(mat)
      _out = Quaternion.new
      Raylib.sp_QuaternionFromMatrix(mat, _out)
      _out
    end
    def self.QuaternionToMatrix(q)
      _out = Matrix.new
      Raylib.sp_QuaternionToMatrix(q, _out)
      _out
    end
    def self.QuaternionFromAxisAngle(axis, angle)
      _out = Quaternion.new
      Raylib.sp_QuaternionFromAxisAngle(axis, angle, _out)
      _out
    end
    def self.QuaternionToAxisAngle(q, outAxis, outAngle)
      Raylib.sp_QuaternionToAxisAngle(q, outAxis, outAngle)
    end
    def self.QuaternionFromEuler(pitch, yaw, roll)
      _out = Quaternion.new
      Raylib.sp_QuaternionFromEuler(pitch, yaw, roll, _out)
      _out
    end
    def self.QuaternionToEuler(q)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_QuaternionToEuler(q, _out)
      _out
    end
    def self.QuaternionTransform(q, mat)
      _out = Quaternion.new
      Raylib.sp_QuaternionTransform(q, mat, _out)
      _out
    end
    def self.QuaternionEquals(p, q)
      Raylib.sp_QuaternionEquals(p, q)
    end
    def self.MatrixCompose(translation, rotation, scale)
      _out = Matrix.new
      Raylib.sp_MatrixCompose(translation, rotation, scale, _out)
      _out
    end
    def self.MatrixDecompose(mat, translation, rotation, scale)
      Raylib.sp_MatrixDecompose(mat, translation, rotation, scale)
    end
    PI = 3.141592653589793
    EPSILON = 1e-06
  end
end
