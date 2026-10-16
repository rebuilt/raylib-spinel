# frozen_string_literal: true

# raylib_handles.rb — the gem-shaped handle API on top of the native view
# classes (declared in raylib_handles_ffi.rb).
#
# Fields are native accessors; this file adds the sub-struct views (font
# texture/glyphs/recs, glyph image, render target texture/depth, model
# material/mesh/transform, material shader), the gem's `size`/pointer helpers,
# and fresh definitions for the raw shims that used to return interior
# pointers (renamed to *_ptr in C so these names are new definitions, not
# redefinitions).
module Raylib
  # `font.recs + index * Rectangle.size` / `font.glyphs + index * GlyphInfo.size`:
  # Spinel boxes :ptr arithmetic, so the address travels as an Integer.
  class PtrAddr
    def initialize(addr)
      @addr = addr
    end

    def +(offset) = @addr + offset
    def to_i = @addr
    def address = @addr
  end

  class Font
    def texture = Texture2D.new(Raylib.rl_Font_texture_ptr(self), self)
    def recs = PtrAddr.new(Raylib.rl_Font_recs_addr(self))
    def glyphs = PtrAddr.new(Raylib.rl_Font_glyphs_addr(self))
  end

  class GlyphInfo

    def image = Image.new(Raylib.rl_GlyphInfo_image_ptr(self), self)
  end

  class AutomationEvent
  end

  class AutomationEventList
    # the gem indexes the events array with AutomationEvent.size
    def events = PtrAddr.new(Raylib.rl_AutomationEventList_events_addr(self))
  end

  class RenderTexture
    def texture = Texture2D.new(Raylib.rl_RenderTexture_texture_ptr(self), self)
    def depth = Texture2D.new(Raylib.rl_RenderTexture_depth_ptr(self), self)
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

  class Model
    def bone_info(index = 0) = BoneInfo.new(Raylib.rl_Model_bone_ptr(self, index), self)

    # gem helper names (raylib_helper.rb)
    def bone_count = boneCount

    def bind_pose_transform(index = 0) =
      Transform.new(Raylib.rl_Model_bind_pose_ptr(self, index), self)
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
  class Ray
    def pointer = self
  end
  class RayCollision
    def pointer = self
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
