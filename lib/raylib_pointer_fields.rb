# frozen_string_literal: true

# Pointer-typed struct fields, gem style: `mesh.vertices = MemAlloc(bytes)` then
# `mesh.vertices.put_array_of_float32(byte_offset, [floats])`. The readers wrap
# the field address in Raylib::Ptr, which adds the gem's method spelling (the
# package's own Pointer writes arrays at offset 0; the gem's take a byte offset).
# The writers are native_method declarations ([:any], and the C side unboxes the
# three shapes a pointer value arrives as -- see rl_p_unbox in raylib_adapter.c).
#
# Compat entry only: the base cannot name FFI::Pointer.

module Raylib
  # A pointer value over a raw address, with the gem's spellings (the package's
  # own Pointer writes arrays at offset 0; the gem's take a byte offset). A
  # plain class, not an FFI::Pointer subclass: under AOT a subclass of the
  # package class inherits neither its constructor ("expected 0") nor its
  # accessors ("undefined method 'address'").
  #
  # Its one ivar IS the address, and the C side of the raw-pointer field writers
  # reads it in place, because the frozen ABI cannot call #address from C (see
  # rl_p_unbox in raylib_adapter.c). For that read to be defined, @address must
  # have the SAME layout in every program -- and its inferred type is otherwise
  # program-dependent (measured: sp_int in scene binaries, sp_RbVal once the ffi
  # package loads: a polymorphic `address`/`to_i` send -- the package's Pointer
  # family shares the names -- merges the arms' return types, and a method that
  # returns the ivar *is* the ivar to the type analyzer, which then widens it).
  # So initialize deliberately boxes it: [address, nil] cannot become a typed
  # int array, its .first is an sp_RbVal, and the ivar is an INT-boxed int in
  # every program (measured: sp_RbVal iv_address here even with no operand on
  # the ivar at all -- the widening is unavoidable, so it is forced instead).
  # rl_p_unbox then reads the box's payload, which also makes the package's own
  # FFI::Pointer/MemoryPointer objects (first ivar @address, likewise boxed)
  # unboxable -- the corpus writes a field through all three shapes.
  #
  # Never assign a non-Integer to @address: a boxed STR/FLOAT payload under the
  # OBJ branch reads the wrong union arm, exactly the bug class this fixes.
  #
  # reference/gem_corpus/13_pointer_fields.rb round-trips fields through their
  # readers, a bare address, and an FFI::Pointer, loading the ffi package; it is
  # the guard that all of this stayed true.
  class Ptr
    def initialize(address)
      @address = [address, nil].first
    end

    def address = @address
    def to_i = @address

    # byte-offset pointer arithmetic, the gem's shape. (@address is a box, so
    # arithmetic goes through polymorphic dispatch; copying to a local first is
    # just where the operand shape is explicit.)
    def +(offset)
      addr = @address
      addr + offset
    end

    # the gem's scalar-array write: byte offset, then each element
    def put_array_of_float32(offset, values)
      addr = @address
      i = 0
      while i < values.length
        Raylib.rl_PtrWriteFloat(addr, offset + i * 4, values[i].to_f)
        i += 1
      end
    end

    # 16-bit PCM, the same shape (byte offset, then each element)
    def put_array_of_int16(offset, values)
      addr = @address
      i = 0
      while i < values.length
        Raylib.rl_PtrWriteInt16(addr, offset + i * 2, values[i].to_i)
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
