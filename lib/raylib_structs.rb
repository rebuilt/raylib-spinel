# frozen_string_literal: true

# raylib_structs.rb — the gem's struct factories and helpers on the Spinel path.
#
# The MRI gem's struct classes are FFI::Struct subclasses; raylib_helper.rb adds
# `create`/`copy_from`/`set`/`to_a`, the Color constructors and the `size` class
# methods. Our classes are Spinel native structs with attribute accessors, so
# the same names and semantics are reimplemented here. Loaded by raylib.rb
# (Spinel path only); under MRI the gem provides them.
#
# Every numeric argument is coerced with `to_f`/`to_i` (AGENTS B4): with mixed
# Integer/Float call sites Spinel boxes the parameter, and a raw assignment to a
# native float field would then read the union payload as garbage.
module Raylib
  # Quaternion has Vector4's exact layout ({float x,y,z,w}).
  Quaternion = Vector4

  # The gem's Camera is Camera3D (raylib_main.rb: Camera = Camera3D).
  Camera3D = Camera

  # Degree/radian conversion (raylib_helper.rb).
  DEG2RAD = 0.017453292519943295
  RAD2DEG = 57.29577951308232

  class Vector2
    def self.create(x = 0.0, y = 0.0)
      v = Vector2.new
      v.x = x.to_f
      v.y = y.to_f
      v
    end

    def self.copy_from(vec)
      Vector2.create(vec.x, vec.y)
    end

    def self.size = 8

    def set(x, y)
      self.x = x.to_f
      self.y = y.to_f
      self
    end

    def add(x, y)
      self.x = x.to_f + self.x
      self.y = y.to_f + self.y
      self
    end

    def add_vector(v)
      self.x = v.x + self.x
      self.y = v.y + self.y
      self
    end

    def to_a
      [x, y]
    end
  end

  class Vector3
    def self.create(x = 0.0, y = 0.0, z = 0.0)
      v = Vector3.new(x.to_f, y.to_f, z.to_f)
      v
    end

    def self.copy_from(vec)
      Vector3.create(vec.x, vec.y, vec.z)
    end

    def self.size = 12

    def set(x, y, z)
      self.x = x.to_f
      self.y = y.to_f
      self.z = z.to_f
      self
    end

    def to_a
      [x, y, z]
    end
  end

  class Vector4
    def self.create(x = 0.0, y = 0.0, z = 0.0, w = 0.0)
      v = Vector4.new
      v.x = x.to_f
      v.y = y.to_f
      v.z = z.to_f
      v.w = w.to_f
      v
    end

    def self.copy_from(vec)
      Vector4.create(vec.x, vec.y, vec.z, vec.w)
    end

    def self.size = 16

    def set(x, y, z, w)
      self.x = x.to_f
      self.y = y.to_f
      self.z = z.to_f
      self.w = w.to_f
      self
    end

    def to_a
      [x, y, z, w]
    end
  end

  class Rectangle
    def self.create(x = 0.0, y = 0.0, width = 0.0, height = 0.0)
      r = Rectangle.new
      r.x = x.to_f
      r.y = y.to_f
      r.width = width.to_f
      r.height = height.to_f
      r
    end

    def self.copy_from(rec)
      Rectangle.create(rec.x, rec.y, rec.width, rec.height)
    end

    def self.size = 16

    def set(x, y, width, height)
      self.x = x.to_f
      self.y = y.to_f
      self.width = width.to_f
      self.height = height.to_f
      self
    end
  end

  class Color
    def self.from_u8(r = 0, g = 0, b = 0, a = 255)
      Color.new(r.to_i, g.to_i, b.to_i, a.to_i)
    end

    def self.from_u32(rgba = 255)
      r = (rgba >> 24) & 0xFF
      g = (rgba >> 16) & 0xFF
      b = (rgba >> 8) & 0xFF
      a = rgba & 0xFF
      Color.new(r, g, b, a)
    end

    def self.size = 4

    def set(r, g, b, a)
      self.r = r.to_i
      self.g = g.to_i
      self.b = b.to_i
      self.a = a.to_i
      self
    end

    def copy(other)
      self.r = other.r
      self.g = other.g
      self.b = other.b
      self.a = other.a
      self
    end
  end

  class Camera2D
    def self.size = 24
  end

  class Camera
    def self.size = 44
  end

  class BoundingBox
    def self.size = 24

    # The gem's 6-float form; the 2-argument (Vector3 min/max) form lives in
    # raylib_structs_views.rb with the sub-struct views.
    def self.create(x1, y1, z1, x2, y2, z2)
      bb = BoundingBox.new
      bb.with_min(x1.to_f, y1.to_f, z1.to_f)
      bb.with_max(x2.to_f, y2.to_f, z2.to_f)
      bb
    end
  end

  class Ray
    def self.size = 24
  end

  class RayCollision
    def self.size = 32
  end

  class Matrix
    def self.size = 64
  end

  # raylib's Vector3ToFloatV/MatrixToFloatV return the raw float arrays (the
  # gem's helpers unwrap [:v].to_a; the field order below is the struct order).
  def self.Vector3ToFloat(vec)
    [vec.x, vec.y, vec.z]
  end

  def self.MatrixToFloat(mat)
    [mat.m0, mat.m4, mat.m8, mat.m12,
     mat.m1, mat.m5, mat.m9, mat.m13,
     mat.m2, mat.m6, mat.m10, mat.m14,
     mat.m3, mat.m7, mat.m11, mat.m15]
  end
end
