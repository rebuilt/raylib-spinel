# frozen_string_literal: true

# raylib_structs.rb — the gem's struct factories and helpers on the Spinel path.
#
# The MRI gem's struct classes are FFI::Struct subclasses; raylib_helper.rb adds
# `create`/`copy_from`/`set`/`to_a`, the Color constructors and the `size` class
# methods. Our classes are Spinel native structs with attribute accessors, so
# the same names and semantics are reimplemented here. Loaded by raylib.rb
# (Spinel path only); under MRI the gem provides them. The Color helpers and
# the Vector2/Rectangle `.create` factories live in raylib_ffi.rb instead, so
# the `require "raylib-spinel"` entry gets them too.
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
    # `.create` lives in raylib_ffi.rb (fill-factory route, both entries).
    def self.copy_from(vec)
      Vector2.create(vec.x, vec.y)
    end


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
    # `.create` lives in raylib_ffi.rb (fill-factory route, both entries).
    def self.copy_from(rec)
      Rectangle.create(rec.x, rec.y, rec.width, rec.height)
    end


    def set(x, y, width, height)
      self.x = x.to_f
      self.y = y.to_f
      self.width = width.to_f
      self.height = height.to_f
      self
    end
  end

  class Camera2D

    # Sub-struct views (the gem's camera.offset / camera.target Vector2s).
    def offset = Vector2.new(offset_ptr, self)
    def target = Vector2.new(target_ptr, self)

    def with_offset(x, y)
      offset.set(x, y)
      self
    end

    def with_target(x, y)
      target.set(x, y)
      self
    end

    def with_rotation(rotation)
      self.rotation = rotation
      self
    end

    def with_zoom(zoom)
      self.zoom = zoom
      self
    end
  end

  class Camera

    # Sub-struct views (the gem's camera.position / .target / .up Vector3s).
    def position = Vector3.new(position_ptr, self)
    def target = Vector3.new(target_ptr, self)
    def up = Vector3.new(up_ptr, self)

    def with_position(x, y, z)
      position.set(x, y, z)
      self
    end

    def with_target(x, y, z)
      target.set(x, y, z)
      self
    end

    def with_up(x, y, z)
      up.set(x, y, z)
      self
    end

    def with_fovy(fovy)
      self.fovy = fovy
      self
    end

    def with_projection(projection)
      self.projection = projection
      self
    end
  end

  class BoundingBox

    # Sub-struct views (bounding_box.min / .max Vector3s).
    def min = Vector3.new(min_ptr, self)
    def max = Vector3.new(max_ptr, self)

    # The gem's factory: create(min_vector, max_vector) or
    # create(min_x, min_y, min_z, max_x, max_y, max_z). The optional tail keeps
    # both arities in one method; the branches read either the vectors or the
    # scalars, so each call site stays typed.
    def self.create(a, b, c = nil, d = nil, e = nil, f = nil)
      bb = BoundingBox.new
      if c.nil?
        bb.min.set(a.x, a.y, a.z)
        bb.max.set(b.x, b.y, b.z)
      else
        bb.with_min(a.to_f, b.to_f, c.to_f)
        bb.with_max(d.to_f, e.to_f, f.to_f)
      end
      bb
    end
  end

  class Transform

    # raylib's Transform { Vector3 translation; Quaternion rotation; Vector3
    # scale; } (rotation is 16 bytes, hence size 40). The gem exposes both the
    # layout names and the t/r/s shorthand; all are reads (views).
    def translation = Vector3.new(t_ptr, self)
    def rotation = Vector4.new(r_ptr, self)
    def scale = Vector3.new(s_ptr, self)

    def t = translation
    def r = rotation
    def s = scale
  end

  class Ray
  end

  class RayCollision
  end

  class Matrix
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
