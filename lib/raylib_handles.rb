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
  end

  class Font
    def texture = Texture2D.new(Raylib.rl_Font_texture_ptr(self), self)
    def recs = PtrAddr.new(Raylib.rl_Font_recs_addr(self))
    def glyphs = PtrAddr.new(Raylib.rl_Font_glyphs_addr(self))
  end

  class GlyphInfo
    def self.size = 40

    def image = Image.new(Raylib.rl_GlyphInfo_image_ptr(self), self)
  end

  class RenderTexture
    def texture = Texture2D.new(Raylib.rl_RenderTexture_texture_ptr(self), self)
    def depth = Texture2D.new(Raylib.rl_RenderTexture_depth_ptr(self), self)
  end

  class Model
    def material(index = 0) = Material.new(Raylib.rl_Model_material_ptr(self, index), self)
    def mesh(index = 0) = Mesh.new(Raylib.rl_Model_mesh_ptr(self, index), self)

    # gem helper name (raylib_helper.rb)
    def material_count = materialCount

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

  # Scene-facing names for the renamed raw shims: the *_ptr symbols return raw
  # interior/heap pointers, these return views.
  def self.rl_FontTexture(font) = font.texture
  def self.rl_RenderTexture_texture(target) = target.texture
  def self.rl_RenderTexture_depth(target) = target.depth
  def self.rl_Model_material(model, index) = model.material(index)
  def self.rl_Model_mesh(model, index) = model.mesh(index)

  def self.rl_ModelAnimationAt(anims, index)
    # `anims` is a raw heap pointer (LoadModelAnimations); no GC owner.
    ModelAnimation.new(Raylib.rl_ModelAnimationAt_ptr(anims, index), nil)
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
