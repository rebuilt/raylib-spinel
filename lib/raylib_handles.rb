# frozen_string_literal: true

# raylib_handles.rb — the gem-shaped handle API on top of the native view
# classes (declared in raylib_handles_ffi.rb).
#
# Fields are native accessors; this file adds the sub-struct views (font
# texture/glyphs/recs, glyph image, render target texture/depth), the gem's
# `size`/pointer-arithmetic helpers, and fresh definitions for the raw shims
# that used to return interior pointers (renamed to *_ptr in C so these names
# are new definitions, not redefinitions).
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

  # Scene-facing names for the renamed raw shims (see the C renames): the
  # _ptr symbols return interior/heap pointers, these return views.
  def self.rl_FontTexture(font) = font.texture
  def self.rl_RenderTexture_texture(target) = target.texture
  def self.rl_RenderTexture_depth(target) = target.depth

  def self.rl_ImageFromImageF(image, x, y, w, h) = Image.new(Raylib.rl_ImageFromImageF_ptr(image, x, y, w, h), nil)

  def self.rl_LoadFontAtlas(path, fontSize, loadGlyphCount, atlasGlyphCount, padding, packMethod, fontType)
    Font.new(Raylib.rl_LoadFontAtlas_ptr(path, fontSize, loadGlyphCount,
                                         atlasGlyphCount, padding, packMethod,
                                         fontType), nil)
  end
end
