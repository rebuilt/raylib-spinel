# raymath_ffi.rb — demo-scoped raymath bindings for Spinel AOT.
#
# Loaded only by `require "raylib-spinel/raymath"` under Spinel (see
# raylib-spinel/raymath.rb). Under MRI that require is a no-op because the
# raylib-bindings gem already defines every raymath function on Raylib
# (Vector2Add, Vector2Scale, ...), so game code is identical on both backends.
#
# raymath's Vector2 functions pass/return the struct by value; Spinel's FFI
# cannot, so each one is a `sp_*` pointer shim declared here and implemented
# in raylib_adapter.c (linked into every scene). The Ruby wrapper allocates the
# out-param (a native Vector2) and returns it. Only the functions the demo
# exercises are bound; extend this file (and raylib_adapter.c) as needed.

module Raylib
  ffi_lib "raylib"
  ffi_cflags "-I/usr/local/include"

  ffi_func :sp_Vector2Add, %i[ptr ptr ptr], :void
  ffi_func :sp_Vector2Scale, %i[ptr float ptr], :void
  ffi_func :sp_Vector2Rotate, %i[ptr float ptr], :void
  ffi_func :sp_Vector2Normalize, %i[ptr ptr], :void
  ffi_func :sp_Vector2Length, [:ptr], :float
  ffi_func :sp_Vector2Lerp, %i[ptr ptr float ptr], :void
  ffi_func :sp_Vector2Angle, %i[ptr ptr], :float
  ffi_func :sp_Vector3Zero, %i[ptr], :void
  ffi_func :sp_Vector3Add, %i[ptr ptr ptr], :void
  ffi_func :sp_Vector3AddValue, %i[ptr float ptr], :void
  ffi_func :sp_Vector3Subtract, %i[ptr ptr ptr], :void
  ffi_func :sp_Vector3Scale, %i[ptr float ptr], :void
  ffi_func :sp_Vector3LengthSqr, %i[ptr], :float
  ffi_func :sp_Vector3DotProduct, %i[ptr ptr], :float
  ffi_func :sp_Vector3ClampValue, %i[ptr float float ptr], :void
  ffi_func :sp_MatrixIdentity, %i[ptr], :void
  ffi_func :sp_MatrixToFloatV, %i[ptr ptr], :ptr
  ffi_func :sp_QuaternionFromVector3ToVector3, %i[ptr ptr ptr], :void
  ffi_func :sp_QuaternionToMatrix, %i[ptr ptr], :void
  ffi_func :sp_QuaternionToMatrix3, %i[ptr ptr], :void
  ffi_func :sp_rlMultMatrixfFloats, %i[ptr int], :void
  ffi_func :sp_rlMultMatrixfForDir, %i[ptr], :void

  def self.Vector3Zero
    _out = Vector3.new(0.0, 0.0, 0.0)
    Raylib.sp_Vector3Zero(_out)
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

  def self.Vector3Scale(v, scalar)
    _out = Vector3.new(0.0, 0.0, 0.0)
    Raylib.sp_Vector3Scale(v, scalar, _out)
    _out
  end

  def self.Vector3LengthSqr(v)
    Raylib.sp_Vector3LengthSqr(v)
  end

  def self.Vector3DotProduct(v1, v2)
    Raylib.sp_Vector3DotProduct(v1, v2)
  end

  def self.Vector3ClampValue(v, min, max)
    _out = Vector3.new(0.0, 0.0, 0.0)
    Raylib.sp_Vector3ClampValue(v, min, max, _out)
    _out
  end

  def self.MatrixIdentity
    _out = Matrix.new
    Raylib.sp_MatrixIdentity(_out)
    _out
  end

  # Fills *out[0..15] with the 16 floats of the rotation matrix that maps the
  # +z axis onto dir (used by the boids scene for rlMultMatrixf).
  def self.rlMultMatrixfForDir(dir)
    Raylib.sp_rlMultMatrixfForDir(dir)
  end
  def self.Vector2Add(v1, v2)
    _out = Vector2.new
    Raylib.sp_Vector2Add(v1, v2, _out)
    _out
  end

  def self.Vector2Scale(v, scale)
    _out = Vector2.new
    Raylib.sp_Vector2Scale(v, scale, _out)
    _out
  end

  def self.Vector2Rotate(v, angle)
    _out = Vector2.new
    Raylib.sp_Vector2Rotate(v, angle, _out)
    _out
  end

  def self.Vector2Normalize(v)
    _out = Vector2.new
    Raylib.sp_Vector2Normalize(v, _out)
    _out
  end

  def self.Vector2Length(v)
    Raylib.sp_Vector2Length(v)
  end

  def self.Vector2Lerp(v1, v2, amount)
    _out = Vector2.new
    Raylib.sp_Vector2Lerp(v1, v2, amount, _out)
    _out
  end

  def self.Vector2Angle(v1, v2)
    Raylib.sp_Vector2Angle(v1, v2)
  end
end