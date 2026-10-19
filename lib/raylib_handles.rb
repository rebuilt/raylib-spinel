# frozen_string_literal: true

# raylib_handles.rb — the gem-shaped handle API on top of the native view
# classes (declared in raylib_handles_ffi.rb).
#
# Fields are native accessors; this file adds the sub-struct views (model
# material/mesh/transform, material shader), the gem's `size`/pointer helpers,
# and fresh definitions for the raw shims that used to return interior
# pointers (renamed to *_ptr in C so these names are new definitions, not
# redefinitions).
module Raylib
  # Interior arrays (events; font.recs/glyphs live next to their class in
  # raylib_handles_ffi.rb) travel as Raylib::Ptr: the gem indexes them with
  # `ptr + index * Rectangle.size`, and Spinel boxes :ptr arithmetic, so the
  # address itself is what Ptr#+ shifts. (This used to be a second,
  # near-identical wrapper class; one address-over-a-long class is what the C
  # side can unbox -- see rl_p_unbox in raylib_adapter.c.)
  class AutomationEvent
  end

  class AutomationEventList
    # the gem indexes the events array with AutomationEvent.size
    def events = Ptr.new(Raylib.rl_AutomationEventList_events_addr(self))
  end

  class Model

    # gem helper name (raylib_helper.rb)
    def material_count = materialCount

    def mesh_count = meshCount

    def transform
      m = Matrix.new
      Raylib.rl_Model_transform(self, m)
      m
    end
  end

  class Material
    def shader = Shader.new(Raylib.rl_Material_shader_ptr(self), self)
  end

  # MaterialMap: texture and color are stored by value, value is a float.
  class MaterialMap
    def pointer = self
    def texture = Texture2D.new(Raylib.rl_MaterialMap_texture_ptr(self), self)
def color
  c = Color.new
  Raylib.rl_MaterialMap_color(self, c)
  c
end
  end

  # Material's remaining fields: the two pointers, with writer shims.
  class Material
    def maps = Ptr.new(Raylib.rl_m_Material_maps(self))
    def params = Ptr.new(Raylib.rl_m_Material_params(self))

    def maps=(v)
      Raylib.rl_Material_set_maps_ptr(self, Raylib.ptr_addr(v))
    end

    def params=(v)
      Raylib.rl_Material_set_params_ptr(self, Raylib.ptr_addr(v))
    end
  end

  class Model
    def bone_info(index = 0) = BoneInfo.new(Raylib.rl_Model_bone_ptr(self, index), self)

    # gem helper names (raylib_helper.rb)
    def bone_count = boneCount

    def bind_pose_transform(index = 0) =
      Transform.new(Raylib.rl_Model_bind_pose_ptr(self, index), self)

    # Pointer fields, gem names. Readers hand back a pointer object; the writers
    # go through the *_ptr shims so a wrapper can delegate to them.
    def meshes = Ptr.new(Raylib.rl_m_Model_meshes(self))
    def materials = Ptr.new(Raylib.rl_m_Model_materials(self))
    def meshMaterial = Ptr.new(Raylib.rl_m_Model_meshMaterial(self))
    def currentPose = Ptr.new(Raylib.rl_m_Model_currentPose(self))
    def boneMatrices = Ptr.new(Raylib.rl_m_Model_boneMatrices(self))

    def meshes=(v)
      Raylib.rl_Model_set_meshes_ptr(self, Raylib.ptr_addr(v))
    end

    def materials=(v)
      Raylib.rl_Model_set_materials_ptr(self, Raylib.ptr_addr(v))
    end

    def meshMaterial=(v)
      Raylib.rl_Model_set_meshMaterial_ptr(self, Raylib.ptr_addr(v))
    end

    def currentPose=(v)
      Raylib.rl_Model_set_currentPose_ptr(self, Raylib.ptr_addr(v))
    end

    def boneMatrices=(v)
      Raylib.rl_Model_set_boneMatrices_ptr(self, Raylib.ptr_addr(v))
    end

    # transform is stored by value: read above, write copies the Matrix view
    def transform=(matrix)
      Raylib.rl_Model_set_transform(self, matrix)
    end

    # skeleton is stored by value too: the reader wraps the embedded struct, the
    # writer copies a ModelSkeleton view back over it
    def skeleton = ModelSkeleton.new(Raylib.rl_Model_skeleton_ptr(self), self)

    def skeleton=(s)
      Raylib.rl_Model_set_skeleton(self, s)
    end
  end

  # ModelSkeleton: bones and bindPose are pointers into raylib-owned arrays.
  class ModelSkeleton
    def bone_count = boneCount
    def bones = Ptr.new(Raylib.rl_m_ModelSkeleton_bones(self))
    def bindPose = Ptr.new(Raylib.rl_m_ModelSkeleton_bindPose(self))
    def pointer = self

    def bones=(v)
      Raylib.rl_ModelSkeleton_set_bones_ptr(self, Raylib.ptr_addr(v))
    end

    def bindPose=(v)
      Raylib.rl_ModelSkeleton_set_bindPose_ptr(self, Raylib.ptr_addr(v))
    end
  end

  # The gem's ModelAnimations helper (raylib_helper.rb) over the raw
  # LoadModelAnimations pointer + per-animation views.
  class ModelAnimations
    def initialize
      @anims = nil
      @anims_ptr = nil
    end

    def anim(index) = @anims[index]
    def anims_count = @anims.length
    def frame_count(index) = @anims[index].keyframeCount

    def bone_transform_of_frame_pose(anim_index, frame, bone_index)
      a = anim(anim_index)
      Transform.new(Raylib.rl_ModelAnimation_frame_pose_bone_ptr(a, frame, bone_index), a)
    end

    def setup(file_name)
      buffer = Raylib.rl_IntAlloc
      ptr = Raylib.LoadModelAnimations(file_name, buffer)
      count = Raylib.rl_IntGet(buffer)
      Raylib.rl_IntFree(buffer)
      @anims_ptr = ptr
      @anims = []
      count.times do |i|
        @anims << ModelAnimation.new(Raylib.rl_ModelAnimationAt_ptr(ptr, i), nil)
      end
      self
    end

    def cleanup
      Raylib.UnloadModelAnimations(@anims_ptr, @anims.length)
    end
  end

  # gem helper names (raylib_helper.rb)
  def self.LoadAndAllocateModelAnimations(file_name)
    buffer = Raylib.rl_IntAlloc
    ptr = Raylib.LoadModelAnimations(file_name, buffer)
    count = Raylib.rl_IntGet(buffer)
    Raylib.rl_IntFree(buffer)
    anims = []
    count.times do |i|
      anims << ModelAnimation.new(Raylib.rl_ModelAnimationAt_ptr(ptr, i), nil)
    end
    [anims, ptr]
  end

  def self.UnloadAndFreeModelAnimations(anims, anim_ptrs)
    Raylib.UnloadModelAnimations(anim_ptrs, anims.length)
  end

  class ModelAnimation
    # the gem's ModelAnimations helper reads keyframeCount as frame_count
    def frame_count = keyframeCount

    def name = Raylib.rl_ModelAnimation_name(self)
    def keyframePoses = Ptr.new(Raylib.rl_m_ModelAnimation_keyframePoses(self))

    def name=(s)
      Raylib.rl_ModelAnimation_set_name(self, s)
    end
  end

  # The gem's FFI::Struct#pointer (hand the struct to a C function) is the
  # single most common struct idiom, e.g. UpdateCamera(camera.pointer, mode),
  # SetAutomationEventList(list.pointer), ImageFlipVertical(image.pointer).
  # Our views are native-class instances: a :ptr slot hands C their struct
  # address, so `pointer` is the view itself. (A native_method returning :ptr
  # would hand the box instead, which raylib then reads as the struct.)
  class Vector2
    def pointer = self
  end
  class Vector3
    def pointer = self
  end
  class Vector4
    def pointer = self
  end
  class Color
    def pointer = self
  end
  class Rectangle
    def pointer = self
  end
  class Camera
    def pointer = self
  end
  class Camera2D
    def pointer = self
  end
  class BoundingBox
    def pointer = self
  end
  class Shader
    def locs = Ptr.new(Raylib.rl_m_Shader_locs(self))
  end
  class NPatchInfo
    def source
      r = Rectangle(0.0, 0.0, 0.0, 0.0)
      Raylib.rl_NPatchInfo_source(self, r)
      r
    end
  end
  class FilePathList
    def paths = Ptr.new(Raylib.rl_m_FilePathList_paths(self))
    # gem-shaped per-entry path string (mirror of the MRI helper in
    # raylib_ruby.rb). The C shim returns "" for a null handle/index.
    def path(index) = Raylib.rl_FilePathList_path(self, index)
  end
  class VrDeviceInfo
    # The gem's inline arrays read as value arrays (element-indexed, see
    # Raylib::FloatArrayPtr); the writers take a boxed source pointer.
    def lensDistortionValues = FloatArrayPtr.new(Raylib.rl_m_VrDeviceInfo_lensDistortionValues(self))
    def chromaAbCorrection = FloatArrayPtr.new(Raylib.rl_m_VrDeviceInfo_chromaAbCorrection(self))
  end

  class VrStereoConfig
    def projection = Ptr.new(Raylib.rl_m_VrStereoConfig_projection(self))
    def viewOffset = Ptr.new(Raylib.rl_m_VrStereoConfig_viewOffset(self))
    def leftLensCenter = FloatArrayPtr.new(Raylib.rl_m_VrStereoConfig_leftLensCenter(self))
    def rightLensCenter = FloatArrayPtr.new(Raylib.rl_m_VrStereoConfig_rightLensCenter(self))
    def leftScreenCenter = FloatArrayPtr.new(Raylib.rl_m_VrStereoConfig_leftScreenCenter(self))
    def rightScreenCenter = FloatArrayPtr.new(Raylib.rl_m_VrStereoConfig_rightScreenCenter(self))
    def scale = FloatArrayPtr.new(Raylib.rl_m_VrStereoConfig_scale(self))
    def scaleIn = FloatArrayPtr.new(Raylib.rl_m_VrStereoConfig_scaleIn(self))
  end

  class AutomationEvent
    def params = Ptr.new(Raylib.rl_m_AutomationEvent_params(self))
  end

  class Ray
    def pointer = self
    def position
      v = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Ray_position(self, v)
      v
    end

    def direction
      v = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_Ray_direction(self, v)
      v
    end
  end
  class RayCollision
    def pointer = self
    def point
      v = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_RayCollision_point(self, v)
      v
    end

    def normal
      v = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_RayCollision_normal(self, v)
      v
    end
  end
  class Matrix
    def pointer = self
  end
  class NPatchInfo
    def pointer = self
  end
  class VrDeviceInfo
    def pointer = self
  end
  class VrStereoConfig
    def pointer = self
  end
  class FilePathList
    def pointer = self
  end
  class Transform
    def pointer = self
  end
  class AutomationEvent
    def pointer = self
  end
  class AutomationEventList
    def pointer = self
  end
  class Image
    def pointer = self
  end
  class Texture2D
    def pointer = self
  end
  class Font
    def pointer = self
  end
  class GlyphInfo
    def pointer = self
  end
  class RenderTexture
    def pointer = self
  end
  class Model
    def pointer = self
  end
  class Material
    def pointer = self
  end
  class Mesh
    def pointer = self
  end
  class Shader
    def pointer = self
  end
  class ModelAnimation
    def pointer = self
  end
  class BoneInfo
    def pointer = self
    def name = Raylib.rl_BoneInfo_name(self)

    def name=(s)
      Raylib.rl_BoneInfo_set_name(self, s)
    end
  end

  # FFI::MemoryPointer/FFI::Pointer (the gem idiom) has no C address the AOT
  # compiler can hand to a :ptr slot; the Integer #address it holds is accepted
  # (src/codegen_call_class.c: an Integer, a String, an IO::Buffer or a native
  # class instance may fill a pointer argument). Values without an address —
  # Integer addresses, boxed pointers returned by :ptr functions, nil — pass
  # through untouched.
  def self.ptr_addr(x) = x.respond_to?(:address) ? x.address : x

  # Integer address for a :ptr slot. ptr_addr's untyped union poisons the AOT's
  # :ptr acceptance program-wide when its result reaches a :ptr parameter (the
  # compiler then refuses view instances elsewhere), so wrappers that take
  # pointer-shaped arguments pin the type here.
  def self.ptr_int(x) = x.respond_to?(:address) ? x.address.to_i : x.to_i

  # View -> payload address for raygui's struct-pointer parameters (the gem
  # hands an FFI::Struct's address; ours sits behind the view). Integer
  # addresses and address-like objects pass through ptr_addr.
  def self.vector2_addr(v) = v.is_a?(Vector2) ? Raylib.rl_Vector2_payload(v) : Raylib.ptr_addr(v)
  def self.vector3_addr(v) = v.is_a?(Vector3) ? Raylib.rl_Vector3_payload(v) : Raylib.ptr_addr(v)
  def self.color_addr(v) = v.is_a?(Color) ? Raylib.rl_Color_payload(v) : Raylib.ptr_addr(v)
  def self.rectangle_addr(v) = v.is_a?(Rectangle) ? Raylib.rl_Rectangle_payload(v) : Raylib.ptr_addr(v)

  # Scene-facing names for the renamed raw shims: the *_ptr symbols return raw
  # interior/heap pointers, these return views. They build the view straight
  # from the pointer shim instead of sending the Ruby accessor: when the AOT
  # compiler cannot pin the receiver's type (an array element, a struct field),
  # a `font.texture` send becomes a polymorphic call that misses the native
  # class arm ("undefined method 'texture' for an instance of Raylib::Font"),
  # while an ffi_func argument unboxes the same value.
  def self.rl_FontTexture(font) =
    Texture2D.new(Raylib.rl_Font_texture_ptr(font), font)
  def self.rl_RenderTexture_texture(target) =
    Texture2D.new(Raylib.rl_RenderTexture_texture_ptr(target), target)
  def self.rl_RenderTexture_depth(target) =
    Texture2D.new(Raylib.rl_RenderTexture_depth_ptr(target), target)
  def self.rl_Model_material(model, index) =
    Material.new(Raylib.rl_Model_material_ptr(model, index), model)
  def self.rl_Model_mesh(model, index) =
    Mesh.new(Raylib.rl_Model_mesh_ptr(model, index), model)

  def self.rl_ModelAnimationAt(anims, index)
    # `anims` is the raw heap pointer from LoadModelAnimations. Passing it as
    # the owner marks the view borrowed: UnloadModelAnimation must not free a
    # pointer into the animations array.
    ModelAnimation.new(Raylib.rl_ModelAnimationAt_ptr(anims, index), anims)
  end

  def self.rl_LoadShaderFS(fsFileName)
    Shader.new(Raylib.rl_LoadShaderFS_ptr(fsFileName), nil)
  end

  def self.rl_ImageFromImageF(image, x, y, w, h) = Image.new(Raylib.rl_ImageFromImageF_ptr(image, x, y, w, h), nil)

  def self.rl_LoadFontAtlas(path, fontSize, loadGlyphCount, atlasGlyphCount, padding, packMethod, fontType)
    Font.new(Raylib.rl_LoadFontAtlas_ptr(path, fontSize, loadGlyphCount,
                                         atlasGlyphCount, padding, packMethod,
                                         fontType), nil)
  end
end
