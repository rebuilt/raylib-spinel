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
# A pointer value over a raw address, with the gem's spellings. A plain class,
# not an FFI::Pointer subclass: under AOT a subclass of the package class
# inherits neither its constructor ("expected 0") nor its accessors
# ("undefined method 'address'").
class Ptr
  def initialize(address)
    @address = address
  end

  def address = @address
  def to_i = @address
  def +(offset) = @address + offset

  # the gem's scalar-array write: byte offset, then each element
  def put_array_of_float32(offset, values)
    i = 0
    while i < values.length
      Raylib.rl_PtrWriteFloat(@address, offset + i * 4, values[i].to_f)
      i += 1
    end
  end

  # 16-bit PCM, the same shape (byte offset, then each element)
  def put_array_of_int16(offset, values)
    i = 0
    while i < values.length
      Raylib.rl_PtrWriteInt16(@address, offset + i * 2, values[i].to_i)
      i += 1
    end
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
    def animVertices = Ptr.new(Raylib.rl_m_Mesh_animVertices(self))
    def animNormals = Ptr.new(Raylib.rl_m_Mesh_animNormals(self))
    def boneIndices = Ptr.new(Raylib.rl_m_Mesh_boneIndices(self))
    def boneWeights = Ptr.new(Raylib.rl_m_Mesh_boneWeights(self))
    def vboId = Ptr.new(Raylib.rl_m_Mesh_vboId(self))
  end
end
