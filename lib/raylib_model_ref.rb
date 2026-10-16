# frozen_string_literal: true

# ModelRef — a user-class wrapper over Raylib::Model.
#
# Why this exists: a Ruby method defined on a *native* class has no arm in a
# polymorphic dispatch, so `models.each { |model| model.material(0) }` raises
# NoMethodError when the array holds native Model views (see
# tools/repro/upstream/a_native_class_methods/). A *user class* does get arms.
#
# Every reader and writer below therefore calls a module ffi_func with @model
# (the native view) as its argument — the shape that resolves from a poly
# receiver. Delegating instead to a Ruby method on Model through the ivar
# (`@model.material_count`) only works while the ivar's type is pinned to Model
# and goes poly (NoMethodError) as soon as it is a union, which is what two gem
# corpus programs hit.
#
# The Model factories return this wrapper, and the helpers that take a Model
# unwrap it again with #model.
module Raylib
  class ModelRef
    def initialize(model)
      @model = model
    end

    # The underlying native view, for the helpers that hand it to C.
    def model = @model
    alias pointer model

    def material(index = 0) = Material.new(Raylib.rl_Model_material_ptr(@model, index), @model)
    def mesh(index = 0) = Mesh.new(Raylib.rl_Model_mesh_ptr(@model, index), @model)
    def bone_info(index = 0) = BoneInfo.new(Raylib.rl_Model_bone_ptr(@model, index), @model)

    def bind_pose_transform(index = 0) =
      Transform.new(Raylib.rl_Model_bind_pose_ptr(@model, index), @model)

    def transform
      m = Matrix.new
      Raylib.rl_Model_transform(@model, m)
      m
    end

    def transform=(matrix)
      Raylib.rl_Model_set_transform(@model, matrix)
    end

    # counts, gem names and snake names
    def meshCount = Raylib.rl_m_Model_meshCount_v(@model)
    def materialCount = Raylib.rl_m_Model_materialCount_v(@model)
    def boneCount = Raylib.rl_m_Model_boneCount_v(@model)
    def mesh_count = meshCount
    def material_count = materialCount
    def bone_count = boneCount

    # pointer fields, gem names
    def meshes = Ptr.new(Raylib.rl_m_Model_meshes(@model))
    def materials = Ptr.new(Raylib.rl_m_Model_materials(@model))
    def meshMaterial = Ptr.new(Raylib.rl_m_Model_meshMaterial(@model))
    def currentPose = Ptr.new(Raylib.rl_m_Model_currentPose(@model))
    def boneMatrices = Ptr.new(Raylib.rl_m_Model_boneMatrices(@model))

    def meshes=(v)
      Raylib.rl_Model_set_meshes_ptr(@model, Raylib.ptr_addr(v))
    end

    def materials=(v)
      Raylib.rl_Model_set_materials_ptr(@model, Raylib.ptr_addr(v))
    end

    def meshMaterial=(v)
      Raylib.rl_Model_set_meshMaterial_ptr(@model, Raylib.ptr_addr(v))
    end

    def currentPose=(v)
      Raylib.rl_Model_set_currentPose_ptr(@model, Raylib.ptr_addr(v))
    end

    def boneMatrices=(v)
      Raylib.rl_Model_set_boneMatrices_ptr(@model, Raylib.ptr_addr(v))
    end

    # The field index, reads only. The writes stay out until Model#[]= no longer
    # refuses a nullable value ("incompatible types when assigning to type
    # sp_oint from type sp_int"); the writers above cover the fields directly.
    def [](key)
      case key
      when :meshCount then meshCount
      when :materialCount then materialCount
      when :boneCount then boneCount
      else raise KeyError, "no such field: #{key}"
      end
    end
  end
end
