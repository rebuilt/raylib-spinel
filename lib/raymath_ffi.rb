# raymath_ffi.rb — demo-scoped raymath bindings for Spinel AOT.
#
# Loaded only by `require "raylib-spinel/raymath"` under Spinel (see
# raylib-spinel/raymath.rb). Under MRI that require is a no-op because the
# raylib-bindings gem already defines every raymath function on Raylib
# (Vector2Add, Vector2Scale, ...), so game code is identical on both backends.
#
# raymath's Vector2 functions pass/return the struct by value; Spinel's FFI
# cannot, so each one is a `rl_*` pointer shim declared here and implemented
# in raylib_adapter.c (linked into every scene). The Ruby wrapper allocates the
# out-param (a native Vector2) and returns it. Only the functions the demo
# exercises are bound; extend this file (and raylib_adapter.c) as needed.

module Raylib
  ffi_lib "raylib"
  ffi_cflags "-I/usr/local/include"

# ====== generated: complete raymath API surface ======
  ffi_func :rl_Vector2Zero, [:ptr], :void
  ffi_func :rl_Vector2One, [:ptr], :void
  ffi_func :rl_Vector2AddValue, [:ptr, :float, :ptr], :void
  ffi_func :rl_Vector2Subtract, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector2SubtractValue, [:ptr, :float, :ptr], :void
  ffi_func :rl_Vector2LengthSqr, [:ptr], :float
  ffi_func :rl_Vector2DotProduct, [:ptr, :ptr], :float
  ffi_func :rl_Vector2CrossProduct, [:ptr, :ptr], :float
  ffi_func :rl_Vector2Distance, [:ptr, :ptr], :float
  ffi_func :rl_Vector2DistanceSqr, [:ptr, :ptr], :float
  ffi_func :rl_Vector2LineAngle, [:ptr, :ptr], :float
  ffi_func :rl_Vector2Multiply, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector2Negate, [:ptr, :ptr], :void
  ffi_func :rl_Vector2Divide, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector2Transform, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector2Reflect, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector2Min, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector2Max, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector2MoveTowards, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_Vector2Invert, [:ptr, :ptr], :void
  ffi_func :rl_Vector2Clamp, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector2ClampValue, [:ptr, :float, :float, :ptr], :void
  ffi_func :rl_Vector2Equals, [:ptr, :ptr], :int
  ffi_func :rl_Vector2Refract, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_Vector3One, [:ptr], :void
  ffi_func :rl_Vector3SubtractValue, [:ptr, :float, :ptr], :void
  ffi_func :rl_Vector3Multiply, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector3CrossProduct, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector3Perpendicular, [:ptr, :ptr], :void
  ffi_func :rl_Vector3Length, [:ptr], :float
  ffi_func :rl_Vector3Distance, [:ptr, :ptr], :float
  ffi_func :rl_Vector3DistanceSqr, [:ptr, :ptr], :float
  ffi_func :rl_Vector3Angle, [:ptr, :ptr], :float
  ffi_func :rl_Vector3Negate, [:ptr, :ptr], :void
  ffi_func :rl_Vector3Divide, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector3Normalize, [:ptr, :ptr], :void
  ffi_func :rl_Vector3Project, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector3Reject, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector3OrthoNormalize, [:ptr, :ptr], :void
  ffi_func :rl_Vector3Transform, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector3RotateByQuaternion, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector3RotateByAxisAngle, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_Vector3MoveTowards, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_Vector3Lerp, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_Vector3CubicHermite, [:ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_Vector3Reflect, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector3Min, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector3Max, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector3Barycenter, [:ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector3Unproject, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector3ToFloatV, [:ptr, :float], :ptr
  ffi_func :rl_Vector3Invert, [:ptr, :ptr], :void
  ffi_func :rl_Vector3Clamp, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector3Equals, [:ptr, :ptr], :int
  ffi_func :rl_Vector3Refract, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_Vector4Zero, [:ptr], :void
  ffi_func :rl_Vector4One, [:ptr], :void
  ffi_func :rl_Vector4Add, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector4AddValue, [:ptr, :float, :ptr], :void
  ffi_func :rl_Vector4Subtract, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector4SubtractValue, [:ptr, :float, :ptr], :void
  ffi_func :rl_Vector4Length, [:ptr], :float
  ffi_func :rl_Vector4LengthSqr, [:ptr], :float
  ffi_func :rl_Vector4DotProduct, [:ptr, :ptr], :float
  ffi_func :rl_Vector4Distance, [:ptr, :ptr], :float
  ffi_func :rl_Vector4DistanceSqr, [:ptr, :ptr], :float
  ffi_func :rl_Vector4Scale, [:ptr, :float, :ptr], :void
  ffi_func :rl_Vector4Multiply, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector4Negate, [:ptr, :ptr], :void
  ffi_func :rl_Vector4Divide, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector4Normalize, [:ptr, :ptr], :void
  ffi_func :rl_Vector4Min, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector4Max, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_Vector4Lerp, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_Vector4MoveTowards, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_Vector4Invert, [:ptr, :ptr], :void
  ffi_func :rl_Vector4Equals, [:ptr, :ptr], :int
  ffi_func :rl_MatrixDeterminant, [:ptr], :float
  ffi_func :rl_MatrixTrace, [:ptr], :float
  ffi_func :rl_MatrixTranspose, [:ptr, :ptr], :void
  ffi_func :rl_MatrixInvert, [:ptr, :ptr], :void
  ffi_func :rl_MatrixAdd, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_MatrixSubtract, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_MatrixMultiply, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_MatrixMultiplyValue, [:ptr, :float, :ptr], :void
  ffi_func :rl_MatrixTranslate, [:float, :float, :float, :ptr], :void
  ffi_func :rl_MatrixRotate, [:ptr, :float, :ptr], :void
  ffi_func :rl_MatrixRotateX, [:float, :ptr], :void
  ffi_func :rl_MatrixRotateY, [:float, :ptr], :void
  ffi_func :rl_MatrixRotateZ, [:float, :ptr], :void
  ffi_func :rl_MatrixRotateXYZ, [:ptr, :ptr], :void
  ffi_func :rl_MatrixRotateZYX, [:ptr, :ptr], :void
  ffi_func :rl_MatrixScale, [:float, :float, :float, :ptr], :void
  ffi_func :rl_MatrixFrustum, [:double, :double, :double, :double, :double, :double, :ptr], :void
  ffi_func :rl_MatrixPerspective, [:double, :double, :double, :double, :ptr], :void
  ffi_func :rl_MatrixOrtho, [:double, :double, :double, :double, :double, :double, :ptr], :void
  ffi_func :rl_MatrixLookAt, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_QuaternionAdd, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_QuaternionAddValue, [:ptr, :float, :ptr], :void
  ffi_func :rl_QuaternionSubtract, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_QuaternionSubtractValue, [:ptr, :float, :ptr], :void
  ffi_func :rl_QuaternionIdentity, [:ptr], :void
  ffi_func :rl_QuaternionLength, [:ptr], :float
  ffi_func :rl_QuaternionNormalize, [:ptr, :ptr], :void
  ffi_func :rl_QuaternionInvert, [:ptr, :ptr], :void
  ffi_func :rl_QuaternionMultiply, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_QuaternionScale, [:ptr, :float, :ptr], :void
  ffi_func :rl_QuaternionDivide, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_QuaternionLerp, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_QuaternionNlerp, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_QuaternionSlerp, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_QuaternionCubicHermiteSpline, [:ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_QuaternionFromMatrix, [:ptr, :ptr], :void
  ffi_func :rl_QuaternionFromAxisAngle, [:ptr, :float, :ptr], :void
  ffi_func :rl_QuaternionToAxisAngle, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_QuaternionFromEuler, [:float, :float, :float, :ptr], :void
  ffi_func :rl_QuaternionToEuler, [:ptr, :ptr], :void
  ffi_func :rl_QuaternionTransform, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_QuaternionEquals, [:ptr, :ptr], :int
  ffi_func :rl_MatrixCompose, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_MatrixDecompose, [:ptr, :ptr, :ptr, :ptr], :void
  native_struct "Quaternion", "rl_Quaternion"
  native_new [], "rl_Quaternion_new"
  native_method :x, [], :float, "rl_Quaternion_x"
  native_method :x=, [:float], :float, "rl_Quaternion_set_x"
  native_method :y, [], :float, "rl_Quaternion_y"
  native_method :y=, [:float], :float, "rl_Quaternion_set_y"
  native_method :z, [], :float, "rl_Quaternion_z"
  native_method :z=, [:float], :float, "rl_Quaternion_set_z"
  native_method :w, [], :float, "rl_Quaternion_w"
  native_method :w=, [:float], :float, "rl_Quaternion_set_w"

# ====== generated: complete raymath API surface ======
  ffi_func :Clamp, [:float, :float, :float], :float
  ffi_func :Lerp, [:float, :float, :float], :float
  ffi_func :Normalize, [:float, :float, :float], :float
  ffi_func :Remap, [:float, :float, :float, :float, :float], :float
  ffi_func :Wrap, [:float, :float, :float], :float
  ffi_func :FloatEquals, [:float, :float], :int

  ffi_func :rl_Vector2Add, %i[ptr ptr ptr], :void
  ffi_func :rl_Vector2Scale, %i[ptr float ptr], :void
  ffi_func :rl_Vector2Rotate, %i[ptr float ptr], :void
  ffi_func :rl_Vector2Normalize, %i[ptr ptr], :void
  ffi_func :rl_Vector2Length, [:ptr], :float
  ffi_func :rl_Vector2Lerp, %i[ptr ptr float ptr], :void
  ffi_func :rl_Vector2Angle, %i[ptr ptr], :float
  ffi_func :rl_Vector3Zero, %i[ptr], :void
  ffi_func :rl_Vector3Add, %i[ptr ptr ptr], :void
  ffi_func :rl_Vector3AddValue, %i[ptr float ptr], :void
  ffi_func :rl_Vector3Subtract, %i[ptr ptr ptr], :void
  ffi_func :rl_Vector3Scale, %i[ptr float ptr], :void
  ffi_func :rl_Vector3LengthSqr, %i[ptr], :float
  ffi_func :rl_Vector3DotProduct, %i[ptr ptr], :float
  ffi_func :rl_Vector3ClampValue, %i[ptr float float ptr], :void
  ffi_func :rl_MatrixIdentity, %i[ptr], :void
  ffi_func :rl_MatrixToFloatV, [:ptr], :ptr
  ffi_func :rl_QuaternionFromVector3ToVector3, %i[ptr ptr ptr], :void
  ffi_func :rl_QuaternionToMatrix, %i[ptr ptr], :void
  ffi_func :rl_QuaternionToMatrix3, %i[ptr ptr], :void
  ffi_func :rl_rlMultMatrixfFloats, %i[ptr int], :void
  ffi_func :rl_rlMultMatrixfForDir, %i[ptr], :void

  def self.Vector3Zero
    _out = Vector3.new(0.0, 0.0, 0.0)
    Raylib.rl_Vector3Zero(_out)
    _out
  end

  def self.Vector3Add(v1, v2)
    _out = Vector3.new(0.0, 0.0, 0.0)
    Raylib.rl_Vector3Add(v1, v2, _out)
    _out
  end

  def self.Vector3AddValue(v, add)
    _out = Vector3.new(0.0, 0.0, 0.0)
    Raylib.rl_Vector3AddValue(v, add, _out)
    _out
  end

  def self.Vector3Subtract(v1, v2)
    _out = Vector3.new(0.0, 0.0, 0.0)
    Raylib.rl_Vector3Subtract(v1, v2, _out)
    _out
  end

  def self.Vector3Scale(v, scalar)
    _out = Vector3.new(0.0, 0.0, 0.0)
    Raylib.rl_Vector3Scale(v, scalar, _out)
    _out
  end

  def self.Vector3LengthSqr(v)
    Raylib.rl_Vector3LengthSqr(v)
  end

  def self.Vector3DotProduct(v1, v2)
    Raylib.rl_Vector3DotProduct(v1, v2)
  end

  def self.Vector3ClampValue(v, min, max)
    _out = Vector3.new(0.0, 0.0, 0.0)
    Raylib.rl_Vector3ClampValue(v, min, max, _out)
    _out
  end

  def self.MatrixIdentity
    _out = Matrix.new
    Raylib.rl_MatrixIdentity(_out)
    _out
  end

  # Fills *out[0..15] with the 16 floats of the rotation matrix that maps the
  # +z axis onto dir (used by the boids scene for rlMultMatrixf).
  def self.rlMultMatrixfForDir(dir)
    Raylib.rl_rlMultMatrixfForDir(dir)
  end
  def self.Vector2Add(v1, v2)
    _out = Vector2.new
    Raylib.rl_Vector2Add(v1, v2, _out)
    _out
  end

  def self.Vector2Scale(v, scale)
    _out = Vector2.new
    Raylib.rl_Vector2Scale(v, scale, _out)
    _out
  end

  def self.Vector2Rotate(v, angle)
    _out = Vector2.new
    Raylib.rl_Vector2Rotate(v, angle, _out)
    _out
  end

  def self.Vector2Normalize(v)
    _out = Vector2.new
    Raylib.rl_Vector2Normalize(v, _out)
    _out
  end

  def self.Vector2Length(v)
    Raylib.rl_Vector2Length(v)
  end

  def self.Vector2Lerp(v1, v2, amount)
    _out = Vector2.new
    Raylib.rl_Vector2Lerp(v1, v2, amount, _out)
    _out
  end

  def self.Vector2Angle(v1, v2)
    Raylib.rl_Vector2Angle(v1, v2)
  end

    # ====== generated: wrappers + constants ======
    PI = 3.141592653589793
    EPSILON = 1e-06

    # ====== generated: wrappers + constants ======
    def self.Vector2Zero()
      _out = Vector2.new
      Raylib.rl_Vector2Zero(_out)
      _out
    end
    def self.Vector2One()
      _out = Vector2.new
      Raylib.rl_Vector2One(_out)
      _out
    end
    def self.Vector2AddValue(v, add)
      _out = Vector2.new
      Raylib.rl_Vector2AddValue(v, add, _out)
      _out
    end
    def self.Vector2Subtract(v1, v2)
      _out = Vector2.new
      Raylib.rl_Vector2Subtract(v1, v2, _out)
      _out
    end
    def self.Vector2SubtractValue(v, sub)
      _out = Vector2.new
      Raylib.rl_Vector2SubtractValue(v, sub, _out)
      _out
    end
    def self.Vector2LengthSqr(v)
      Raylib.rl_Vector2LengthSqr(v)
    end
    def self.Vector2DotProduct(v1, v2)
      Raylib.rl_Vector2DotProduct(v1, v2)
    end
    def self.Vector2CrossProduct(v1, v2)
      Raylib.rl_Vector2CrossProduct(v1, v2)
    end
    def self.Vector2Distance(v1, v2)
      Raylib.rl_Vector2Distance(v1, v2)
    end
    def self.Vector2DistanceSqr(v1, v2)
      Raylib.rl_Vector2DistanceSqr(v1, v2)
    end
    def self.Vector2LineAngle(start, kw_end)
      Raylib.rl_Vector2LineAngle(start, kw_end)
    end
    def self.Vector2Multiply(v1, v2)
      _out = Vector2.new
      Raylib.rl_Vector2Multiply(v1, v2, _out)
      _out
    end
    def self.Vector2Negate(v)
      _out = Vector2.new
      Raylib.rl_Vector2Negate(v, _out)
      _out
    end
    def self.Vector2Divide(v1, v2)
      _out = Vector2.new
      Raylib.rl_Vector2Divide(v1, v2, _out)
      _out
    end
    def self.Vector2Transform(v, mat)
      _out = Vector2.new
      Raylib.rl_Vector2Transform(v, mat, _out)
      _out
    end
    def self.Vector2Reflect(v, normal)
      _out = Vector2.new
      Raylib.rl_Vector2Reflect(v, normal, _out)
      _out
    end
    def self.Vector2Min(v1, v2)
      _out = Vector2.new
      Raylib.rl_Vector2Min(v1, v2, _out)
      _out
    end
    def self.Vector2Max(v1, v2)
      _out = Vector2.new
      Raylib.rl_Vector2Max(v1, v2, _out)
      _out
    end
    def self.Vector2MoveTowards(v, target, maxDistance)
      _out = Vector2.new
      Raylib.rl_Vector2MoveTowards(v, target, maxDistance, _out)
      _out
    end
    def self.Vector2Invert(v)
      _out = Vector2.new
      Raylib.rl_Vector2Invert(v, _out)
      _out
    end
    def self.Vector2Clamp(v, min, max)
      _out = Vector2.new
      Raylib.rl_Vector2Clamp(v, min, max, _out)
      _out
    end
    def self.Vector2ClampValue(v, min, max)
      _out = Vector2.new
      Raylib.rl_Vector2ClampValue(v, min, max, _out)
      _out
    end
    def self.Vector2Equals(p, q)
      Raylib.rl_Vector2Equals(p, q)
    end
    def self.Vector2Refract(v, n, r)
      _out = Vector2.new
      Raylib.rl_Vector2Refract(v, n, r, _out)
      _out
    end
    def self.Vector3One()
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3One(_out)
      _out
    end
    def self.Vector3SubtractValue(v, sub)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3SubtractValue(v, sub, _out)
      _out
    end
    def self.Vector3Multiply(v1, v2)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3Multiply(v1, v2, _out)
      _out
    end
    def self.Vector3CrossProduct(v1, v2)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3CrossProduct(v1, v2, _out)
      _out
    end
    def self.Vector3Perpendicular(v)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3Perpendicular(v, _out)
      _out
    end
    def self.Vector3Length(v)
      Raylib.rl_Vector3Length(v)
    end
    def self.Vector3Distance(v1, v2)
      Raylib.rl_Vector3Distance(v1, v2)
    end
    def self.Vector3DistanceSqr(v1, v2)
      Raylib.rl_Vector3DistanceSqr(v1, v2)
    end
    def self.Vector3Angle(v1, v2)
      Raylib.rl_Vector3Angle(v1, v2)
    end
    def self.Vector3Negate(v)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3Negate(v, _out)
      _out
    end
    def self.Vector3Divide(v1, v2)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3Divide(v1, v2, _out)
      _out
    end
    def self.Vector3Normalize(v)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3Normalize(v, _out)
      _out
    end
    def self.Vector3Project(v1, v2)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3Project(v1, v2, _out)
      _out
    end
    def self.Vector3Reject(v1, v2)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3Reject(v1, v2, _out)
      _out
    end
    def self.Vector3OrthoNormalize(v1, v2)
      Raylib.rl_Vector3OrthoNormalize(v1, v2)
    end
    def self.Vector3Transform(v, mat)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3Transform(v, mat, _out)
      _out
    end
    def self.Vector3RotateByQuaternion(v, q)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3RotateByQuaternion(v, q, _out)
      _out
    end
    def self.Vector3RotateByAxisAngle(v, axis, angle)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3RotateByAxisAngle(v, axis, angle, _out)
      _out
    end
    def self.Vector3MoveTowards(v, target, maxDistance)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3MoveTowards(v, target, maxDistance, _out)
      _out
    end
    def self.Vector3Lerp(v1, v2, amount)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3Lerp(v1, v2, amount, _out)
      _out
    end
    def self.Vector3CubicHermite(v1, tangent1, v2, tangent2, amount)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3CubicHermite(v1, tangent1, v2, tangent2, amount, _out)
      _out
    end
    def self.Vector3Reflect(v, normal)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3Reflect(v, normal, _out)
      _out
    end
    def self.Vector3Min(v1, v2)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3Min(v1, v2, _out)
      _out
    end
    def self.Vector3Max(v1, v2)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3Max(v1, v2, _out)
      _out
    end
    def self.Vector3Barycenter(p, a, b, c)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3Barycenter(p, a, b, c, _out)
      _out
    end
    def self.Vector3Unproject(source, projection, view)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3Unproject(source, projection, view, _out)
      _out
    end
    def self.Vector3ToFloatV(v)
      Raylib.rl_Vector3ToFloatV(v)
    end
    def self.Vector3Invert(v)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3Invert(v, _out)
      _out
    end
    def self.Vector3Clamp(v, min, max)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3Clamp(v, min, max, _out)
      _out
    end
    def self.Vector3Equals(p, q)
      Raylib.rl_Vector3Equals(p, q)
    end
    def self.Vector3Refract(v, n, r)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Vector3Refract(v, n, r, _out)
      _out
    end
    def self.Vector4Zero()
      _out = Vector4.new
      Raylib.rl_Vector4Zero(_out)
      _out
    end
    def self.Vector4One()
      _out = Vector4.new
      Raylib.rl_Vector4One(_out)
      _out
    end
    def self.Vector4Add(v1, v2)
      _out = Vector4.new
      Raylib.rl_Vector4Add(v1, v2, _out)
      _out
    end
    def self.Vector4AddValue(v, add)
      _out = Vector4.new
      Raylib.rl_Vector4AddValue(v, add, _out)
      _out
    end
    def self.Vector4Subtract(v1, v2)
      _out = Vector4.new
      Raylib.rl_Vector4Subtract(v1, v2, _out)
      _out
    end
    def self.Vector4SubtractValue(v, add)
      _out = Vector4.new
      Raylib.rl_Vector4SubtractValue(v, add, _out)
      _out
    end
    def self.Vector4Length(v)
      Raylib.rl_Vector4Length(v)
    end
    def self.Vector4LengthSqr(v)
      Raylib.rl_Vector4LengthSqr(v)
    end
    def self.Vector4DotProduct(v1, v2)
      Raylib.rl_Vector4DotProduct(v1, v2)
    end
    def self.Vector4Distance(v1, v2)
      Raylib.rl_Vector4Distance(v1, v2)
    end
    def self.Vector4DistanceSqr(v1, v2)
      Raylib.rl_Vector4DistanceSqr(v1, v2)
    end
    def self.Vector4Scale(v, scale)
      _out = Vector4.new
      Raylib.rl_Vector4Scale(v, scale, _out)
      _out
    end
    def self.Vector4Multiply(v1, v2)
      _out = Vector4.new
      Raylib.rl_Vector4Multiply(v1, v2, _out)
      _out
    end
    def self.Vector4Negate(v)
      _out = Vector4.new
      Raylib.rl_Vector4Negate(v, _out)
      _out
    end
    def self.Vector4Divide(v1, v2)
      _out = Vector4.new
      Raylib.rl_Vector4Divide(v1, v2, _out)
      _out
    end
    def self.Vector4Normalize(v)
      _out = Vector4.new
      Raylib.rl_Vector4Normalize(v, _out)
      _out
    end
    def self.Vector4Min(v1, v2)
      _out = Vector4.new
      Raylib.rl_Vector4Min(v1, v2, _out)
      _out
    end
    def self.Vector4Max(v1, v2)
      _out = Vector4.new
      Raylib.rl_Vector4Max(v1, v2, _out)
      _out
    end
    def self.Vector4Lerp(v1, v2, amount)
      _out = Vector4.new
      Raylib.rl_Vector4Lerp(v1, v2, amount, _out)
      _out
    end
    def self.Vector4MoveTowards(v, target, maxDistance)
      _out = Vector4.new
      Raylib.rl_Vector4MoveTowards(v, target, maxDistance, _out)
      _out
    end
    def self.Vector4Invert(v)
      _out = Vector4.new
      Raylib.rl_Vector4Invert(v, _out)
      _out
    end
    def self.Vector4Equals(p, q)
      Raylib.rl_Vector4Equals(p, q)
    end
    def self.MatrixDeterminant(mat)
      Raylib.rl_MatrixDeterminant(mat)
    end
    def self.MatrixTrace(mat)
      Raylib.rl_MatrixTrace(mat)
    end
    def self.MatrixTranspose(mat)
      _out = Matrix.new
      Raylib.rl_MatrixTranspose(mat, _out)
      _out
    end
    def self.MatrixInvert(mat)
      _out = Matrix.new
      Raylib.rl_MatrixInvert(mat, _out)
      _out
    end
    def self.MatrixAdd(left, right)
      _out = Matrix.new
      Raylib.rl_MatrixAdd(left, right, _out)
      _out
    end
    def self.MatrixSubtract(left, right)
      _out = Matrix.new
      Raylib.rl_MatrixSubtract(left, right, _out)
      _out
    end
    def self.MatrixMultiply(left, right)
      _out = Matrix.new
      Raylib.rl_MatrixMultiply(left, right, _out)
      _out
    end
    def self.MatrixMultiplyValue(left, value)
      _out = Matrix.new
      Raylib.rl_MatrixMultiplyValue(left, value, _out)
      _out
    end
    def self.MatrixTranslate(x, y, z)
      _out = Matrix.new
      Raylib.rl_MatrixTranslate(x, y, z, _out)
      _out
    end
    def self.MatrixRotate(axis, angle)
      _out = Matrix.new
      Raylib.rl_MatrixRotate(axis, angle, _out)
      _out
    end
    def self.MatrixRotateX(angle)
      _out = Matrix.new
      Raylib.rl_MatrixRotateX(angle, _out)
      _out
    end
    def self.MatrixRotateY(angle)
      _out = Matrix.new
      Raylib.rl_MatrixRotateY(angle, _out)
      _out
    end
    def self.MatrixRotateZ(angle)
      _out = Matrix.new
      Raylib.rl_MatrixRotateZ(angle, _out)
      _out
    end
    def self.MatrixRotateXYZ(angle)
      _out = Matrix.new
      Raylib.rl_MatrixRotateXYZ(angle, _out)
      _out
    end
    def self.MatrixRotateZYX(angle)
      _out = Matrix.new
      Raylib.rl_MatrixRotateZYX(angle, _out)
      _out
    end
    def self.MatrixScale(x, y, z)
      _out = Matrix.new
      Raylib.rl_MatrixScale(x, y, z, _out)
      _out
    end
    def self.MatrixFrustum(left, right, bottom, top, nearPlane, farPlane)
      _out = Matrix.new
      Raylib.rl_MatrixFrustum(left, right, bottom, top, nearPlane, farPlane, _out)
      _out
    end
    def self.MatrixPerspective(fovY, aspect, nearPlane, farPlane)
      _out = Matrix.new
      Raylib.rl_MatrixPerspective(fovY, aspect, nearPlane, farPlane, _out)
      _out
    end
    def self.MatrixOrtho(left, right, bottom, top, nearPlane, farPlane)
      _out = Matrix.new
      Raylib.rl_MatrixOrtho(left, right, bottom, top, nearPlane, farPlane, _out)
      _out
    end
    def self.MatrixLookAt(eye, target, up)
      _out = Matrix.new
      Raylib.rl_MatrixLookAt(eye, target, up, _out)
      _out
    end
    def self.MatrixToFloatV(mat)
      Raylib.rl_MatrixToFloatV(mat)
    end
    def self.QuaternionFromVector3ToVector3(from, to)
      _out = Quaternion.new
      Raylib.rl_QuaternionFromVector3ToVector3(from, to, _out)
      _out
    end
    def self.QuaternionToMatrix(q)
      _out = Matrix.new
      Raylib.rl_QuaternionToMatrix(q, _out)
      _out
    end
    def self.QuaternionAdd(q1, q2)
      _out = Quaternion.new
      Raylib.rl_QuaternionAdd(q1, q2, _out)
      _out
    end
    def self.QuaternionAddValue(q, add)
      _out = Quaternion.new
      Raylib.rl_QuaternionAddValue(q, add, _out)
      _out
    end
    def self.QuaternionSubtract(q1, q2)
      _out = Quaternion.new
      Raylib.rl_QuaternionSubtract(q1, q2, _out)
      _out
    end
    def self.QuaternionSubtractValue(q, sub)
      _out = Quaternion.new
      Raylib.rl_QuaternionSubtractValue(q, sub, _out)
      _out
    end
    def self.QuaternionIdentity()
      _out = Quaternion.new
      Raylib.rl_QuaternionIdentity(_out)
      _out
    end
    def self.QuaternionLength(q)
      Raylib.rl_QuaternionLength(q)
    end
    def self.QuaternionNormalize(q)
      _out = Quaternion.new
      Raylib.rl_QuaternionNormalize(q, _out)
      _out
    end
    def self.QuaternionInvert(q)
      _out = Quaternion.new
      Raylib.rl_QuaternionInvert(q, _out)
      _out
    end
    def self.QuaternionMultiply(q1, q2)
      _out = Quaternion.new
      Raylib.rl_QuaternionMultiply(q1, q2, _out)
      _out
    end
    def self.QuaternionScale(q, mul)
      _out = Quaternion.new
      Raylib.rl_QuaternionScale(q, mul, _out)
      _out
    end
    def self.QuaternionDivide(q1, q2)
      _out = Quaternion.new
      Raylib.rl_QuaternionDivide(q1, q2, _out)
      _out
    end
    def self.QuaternionLerp(q1, q2, amount)
      _out = Quaternion.new
      Raylib.rl_QuaternionLerp(q1, q2, amount, _out)
      _out
    end
    def self.QuaternionNlerp(q1, q2, amount)
      _out = Quaternion.new
      Raylib.rl_QuaternionNlerp(q1, q2, amount, _out)
      _out
    end
    def self.QuaternionSlerp(q1, q2, amount)
      _out = Quaternion.new
      Raylib.rl_QuaternionSlerp(q1, q2, amount, _out)
      _out
    end
    def self.QuaternionCubicHermiteSpline(q1, outTangent1, q2, inTangent2, t)
      _out = Quaternion.new
      Raylib.rl_QuaternionCubicHermiteSpline(q1, outTangent1, q2, inTangent2, t, _out)
      _out
    end
    def self.QuaternionFromMatrix(mat)
      _out = Quaternion.new
      Raylib.rl_QuaternionFromMatrix(mat, _out)
      _out
    end
    def self.QuaternionFromAxisAngle(axis, angle)
      _out = Quaternion.new
      Raylib.rl_QuaternionFromAxisAngle(axis, angle, _out)
      _out
    end
    def self.QuaternionToAxisAngle(q, outAxis, outAngle)
      Raylib.rl_QuaternionToAxisAngle(q, outAxis, outAngle)
    end
    def self.QuaternionFromEuler(pitch, yaw, roll)
      _out = Quaternion.new
      Raylib.rl_QuaternionFromEuler(pitch, yaw, roll, _out)
      _out
    end
    def self.QuaternionToEuler(q)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_QuaternionToEuler(q, _out)
      _out
    end
    def self.QuaternionTransform(q, mat)
      _out = Quaternion.new
      Raylib.rl_QuaternionTransform(q, mat, _out)
      _out
    end
    def self.QuaternionEquals(p, q)
      Raylib.rl_QuaternionEquals(p, q)
    end
    def self.MatrixCompose(translation, rotation, scale)
      _out = Matrix.new
      Raylib.rl_MatrixCompose(translation, rotation, scale, _out)
      _out
    end
    def self.MatrixDecompose(mat, translation, rotation, scale)
      Raylib.rl_MatrixDecompose(mat, translation, rotation, scale)
    end

    # ====== generated: wrappers + constants ======

  # ====== generated: snake_case aliases (MRI gem naming) ======
  def self.clamp(p0, p1, p2)
    Raylib.Clamp(p0, p1, p2)
  end
  def self.lerp(p0, p1, p2)
    Raylib.Lerp(p0, p1, p2)
  end
  def self.normalize(p0, p1, p2)
    Raylib.Normalize(p0, p1, p2)
  end
  def self.remap(p0, p1, p2, p3, p4)
    Raylib.Remap(p0, p1, p2, p3, p4)
  end
  def self.wrap(p0, p1, p2)
    Raylib.Wrap(p0, p1, p2)
  end
  def self.float_equals(p0, p1)
    Raylib.FloatEquals(p0, p1)
  end
  class << self
    alias_method :matrix_to_float_v, :MatrixToFloatV
    alias_method :quaternion_from_vector3_to_vector3, :QuaternionFromVector3ToVector3
    alias_method :quaternion_to_matrix, :QuaternionToMatrix
    alias_method :vector2_zero, :Vector2Zero
    alias_method :vector2_one, :Vector2One
    alias_method :vector2_add, :Vector2Add
    alias_method :vector2_add_value, :Vector2AddValue
    alias_method :vector2_subtract, :Vector2Subtract
    alias_method :vector2_subtract_value, :Vector2SubtractValue
    alias_method :vector2_length, :Vector2Length
    alias_method :vector2_length_sqr, :Vector2LengthSqr
    alias_method :vector2_dot_product, :Vector2DotProduct
    alias_method :vector2_cross_product, :Vector2CrossProduct
    alias_method :vector2_distance, :Vector2Distance
    alias_method :vector2_distance_sqr, :Vector2DistanceSqr
    alias_method :vector2_angle, :Vector2Angle
    alias_method :vector2_line_angle, :Vector2LineAngle
    alias_method :vector2_scale, :Vector2Scale
    alias_method :vector2_multiply, :Vector2Multiply
    alias_method :vector2_negate, :Vector2Negate
    alias_method :vector2_divide, :Vector2Divide
    alias_method :vector2_normalize, :Vector2Normalize
    alias_method :vector2_transform, :Vector2Transform
    alias_method :vector2_lerp, :Vector2Lerp
    alias_method :vector2_reflect, :Vector2Reflect
    alias_method :vector2_min, :Vector2Min
    alias_method :vector2_max, :Vector2Max
    alias_method :vector2_rotate, :Vector2Rotate
    alias_method :vector2_move_towards, :Vector2MoveTowards
    alias_method :vector2_invert, :Vector2Invert
    alias_method :vector2_clamp, :Vector2Clamp
    alias_method :vector2_clamp_value, :Vector2ClampValue
    alias_method :vector2_equals, :Vector2Equals
    alias_method :vector2_refract, :Vector2Refract
    alias_method :vector3_zero, :Vector3Zero
    alias_method :vector3_one, :Vector3One
    alias_method :vector3_add, :Vector3Add
    alias_method :vector3_add_value, :Vector3AddValue
    alias_method :vector3_subtract, :Vector3Subtract
    alias_method :vector3_subtract_value, :Vector3SubtractValue
    alias_method :vector3_scale, :Vector3Scale
    alias_method :vector3_multiply, :Vector3Multiply
    alias_method :vector3_cross_product, :Vector3CrossProduct
    alias_method :vector3_perpendicular, :Vector3Perpendicular
    alias_method :vector3_length, :Vector3Length
    alias_method :vector3_length_sqr, :Vector3LengthSqr
    alias_method :vector3_dot_product, :Vector3DotProduct
    alias_method :vector3_distance, :Vector3Distance
    alias_method :vector3_distance_sqr, :Vector3DistanceSqr
    alias_method :vector3_angle, :Vector3Angle
    alias_method :vector3_negate, :Vector3Negate
    alias_method :vector3_divide, :Vector3Divide
    alias_method :vector3_normalize, :Vector3Normalize
    alias_method :vector3_project, :Vector3Project
    alias_method :vector3_reject, :Vector3Reject
    alias_method :vector3_ortho_normalize, :Vector3OrthoNormalize
    alias_method :vector3_transform, :Vector3Transform
    alias_method :vector3_rotate_by_quaternion, :Vector3RotateByQuaternion
    alias_method :vector3_rotate_by_axis_angle, :Vector3RotateByAxisAngle
    alias_method :vector3_move_towards, :Vector3MoveTowards
    alias_method :vector3_lerp, :Vector3Lerp
    alias_method :vector3_cubic_hermite, :Vector3CubicHermite
    alias_method :vector3_reflect, :Vector3Reflect
    alias_method :vector3_min, :Vector3Min
    alias_method :vector3_max, :Vector3Max
    alias_method :vector3_barycenter, :Vector3Barycenter
    alias_method :vector3_unproject, :Vector3Unproject
    alias_method :vector3_to_float_v, :Vector3ToFloatV
    alias_method :vector3_invert, :Vector3Invert
    alias_method :vector3_clamp, :Vector3Clamp
    alias_method :vector3_clamp_value, :Vector3ClampValue
    alias_method :vector3_equals, :Vector3Equals
    alias_method :vector3_refract, :Vector3Refract
    alias_method :vector_4zero, :Vector4Zero
    alias_method :vector_4one, :Vector4One
    alias_method :vector_4add, :Vector4Add
    alias_method :vector_4add_value, :Vector4AddValue
    alias_method :vector_4subtract, :Vector4Subtract
    alias_method :vector_4subtract_value, :Vector4SubtractValue
    alias_method :vector_4length, :Vector4Length
    alias_method :vector_4length_sqr, :Vector4LengthSqr
    alias_method :vector_4dot_product, :Vector4DotProduct
    alias_method :vector_4distance, :Vector4Distance
    alias_method :vector_4distance_sqr, :Vector4DistanceSqr
    alias_method :vector_4scale, :Vector4Scale
    alias_method :vector_4multiply, :Vector4Multiply
    alias_method :vector_4negate, :Vector4Negate
    alias_method :vector_4divide, :Vector4Divide
    alias_method :vector_4normalize, :Vector4Normalize
    alias_method :vector_4min, :Vector4Min
    alias_method :vector_4max, :Vector4Max
    alias_method :vector_4lerp, :Vector4Lerp
    alias_method :vector_4move_towards, :Vector4MoveTowards
    alias_method :vector_4invert, :Vector4Invert
    alias_method :vector_4equals, :Vector4Equals
    alias_method :matrix_determinant, :MatrixDeterminant
    alias_method :matrix_trace, :MatrixTrace
    alias_method :matrix_transpose, :MatrixTranspose
    alias_method :matrix_invert, :MatrixInvert
    alias_method :matrix_identity, :MatrixIdentity
    alias_method :matrix_add, :MatrixAdd
    alias_method :matrix_subtract, :MatrixSubtract
    alias_method :matrix_multiply, :MatrixMultiply
    alias_method :matrix_multiply_value, :MatrixMultiplyValue
    alias_method :matrix_translate, :MatrixTranslate
    alias_method :matrix_rotate, :MatrixRotate
    alias_method :matrix_rotate_x, :MatrixRotateX
    alias_method :matrix_rotate_y, :MatrixRotateY
    alias_method :matrix_rotate_z, :MatrixRotateZ
    alias_method :matrix_rotate_xyz, :MatrixRotateXYZ
    alias_method :matrix_rotate_zyx, :MatrixRotateZYX
    alias_method :matrix_scale, :MatrixScale
    alias_method :matrix_frustum, :MatrixFrustum
    alias_method :matrix_perspective, :MatrixPerspective
    alias_method :matrix_ortho, :MatrixOrtho
    alias_method :matrix_look_at, :MatrixLookAt
    alias_method :quaternion_add, :QuaternionAdd
    alias_method :quaternion_add_value, :QuaternionAddValue
    alias_method :quaternion_subtract, :QuaternionSubtract
    alias_method :quaternion_subtract_value, :QuaternionSubtractValue
    alias_method :quaternion_identity, :QuaternionIdentity
    alias_method :quaternion_length, :QuaternionLength
    alias_method :quaternion_normalize, :QuaternionNormalize
    alias_method :quaternion_invert, :QuaternionInvert
    alias_method :quaternion_multiply, :QuaternionMultiply
    alias_method :quaternion_scale, :QuaternionScale
    alias_method :quaternion_divide, :QuaternionDivide
    alias_method :quaternion_lerp, :QuaternionLerp
    alias_method :quaternion_nlerp, :QuaternionNlerp
    alias_method :quaternion_slerp, :QuaternionSlerp
    alias_method :quaternion_cubic_hermite_spline, :QuaternionCubicHermiteSpline
    alias_method :quaternion_from_matrix, :QuaternionFromMatrix
    alias_method :quaternion_from_axis_angle, :QuaternionFromAxisAngle
    alias_method :quaternion_to_axis_angle, :QuaternionToAxisAngle
    alias_method :quaternion_from_euler, :QuaternionFromEuler
    alias_method :quaternion_to_euler, :QuaternionToEuler
    alias_method :quaternion_transform, :QuaternionTransform
    alias_method :quaternion_equals, :QuaternionEquals
    alias_method :matrix_compose, :MatrixCompose
    alias_method :matrix_decompose, :MatrixDecompose
  end
end
