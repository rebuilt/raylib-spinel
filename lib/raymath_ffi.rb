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
  ffi_func :rl_MatrixToFloatV, %i[ptr ptr], :ptr
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
end
