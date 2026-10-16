# frozen_string_literal: true

# Pointer-typed struct fields, gem style: `mesh.vertices = MemAlloc(bytes)` then
# `mesh.vertices.put_array_of_float32(byte_offset, [floats])`. The readers wrap
# the field address in an FFI::Pointer subclass that adds the gem's method
# spelling (the package's own Pointer writes arrays at offset 0; the gem's take
# a byte offset), the writers are native_method declarations ([:any] + the C
# side unboxes what MemAlloc returned).
#
# Compat entry only: the base cannot name FFI::Pointer.

module Raylib
  # FFI::Pointer with the gem's scalar-array spellings. `self + offset` is a
  # byte-offset pointer in the package, which is what the gem's API expects.
  class Ptr < FFI::Pointer
    def put_array_of_float32(offset, values)
      (self + offset).write_array_of_float(values.map { |v| v.to_f })
    end
  end

  class Image
    def data = Ptr.new(Raylib.rl_m_Image_data(self))
  end

  class Mesh
    def vertices = Ptr.new(Raylib.rl_m_Mesh_vertices(self))
    def texcoords = Ptr.new(Raylib.rl_m_Mesh_texcoords(self))
    def texcoords2 = Ptr.new(Raylib.rl_m_Mesh_texcoords2(self))
    def normals = Ptr.new(Raylib.rl_m_Mesh_normals(self))
    def tangents = Ptr.new(Raylib.rl_m_Mesh_tangents(self))
    def colors = Ptr.new(Raylib.rl_m_Mesh_colors(self))
    def indices = Ptr.new(Raylib.rl_m_Mesh_indices(self))
  end
end
