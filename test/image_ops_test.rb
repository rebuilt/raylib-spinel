require "raylib"
include Raylib

# Headless pinning test for the handle-view surface: image operations are
# CPU-side, so this runs without InitWindow under both the MRI gem and
# raylib-spinel. It exercises the shapes the AOT view layer has to unwrap:
#   * Image* in-place functions (Image *image): ImageFormat, ImageResize,
#     ImageRotate, ImageFlipVertical, ImageDrawPixel
#   * Class.size (FFI::Struct.size in the gem) for the pointer-arithmetic
#     idioms (`font.recs + i * Rectangle.size`)
#   * field access on a produced handle (img.width / img.format)
# A raw view forwarded to raylib corrupts the payload (ImageFormat freeing
# 0xc) or silently misreads the struct, so a wrong unwrap fails loudly here.

image = GenImageColor(8, 8, Color.new(255, 0, 0, 255))
puts "created: #{image.width}x#{image.height} format=#{image.format}"

ImageFormat(image, PIXELFORMAT_UNCOMPRESSED_R8G8B8A8)
puts "format after ImageFormat: #{image.format}"

ImageDrawPixel(image, 1, 1, Color.new(0, 255, 0, 255))
c = GetImageColor(image, 1, 1)
puts "pixel(1,1): #{c.r},#{c.g},#{c.b},#{c.a}"

ImageFlipVertical(image)
c = GetImageColor(image, 1, 6)
puts "pixel(1,6) after flip: #{c.r},#{c.g},#{c.b},#{c.a}"

ImageResize(image, 4, 4)
puts "after ImageResize: #{image.width}x#{image.height}"
c = GetImageColor(image, 0, 3)
puts "pixel(0,3) after resize: #{c.r},#{c.g},#{c.b},#{c.a}"

ImageRotateCW(image)
puts "after ImageRotateCW: #{image.width}x#{image.height}"

ImageColorGrayscale(image)
c = GetImageColor(image, 2, 1)
puts "pixel(2,1) after grayscale: #{c.r},#{c.g},#{c.b},#{c.a}"

UnloadImage(image)

# Struct sizes drive pointer arithmetic in gem code (glyph recs, model
# materials, palettes); the AOT surface derives them from C sizeof.
puts "sizes: v2=#{Vector2.size} v3=#{Vector3.size} rect=#{Rectangle.size} " \
     "color=#{Color.size} glyph=#{GlyphInfo.size} transform=#{Transform.size}"
puts "sizes: font=#{Font.size} image=#{Image.size} texture=#{Texture2D.size} " \
     "material=#{Material.size} mesh=#{Mesh.size} model=#{Model.size}"
puts "sizes: camera=#{Camera3D.size} camera2d=#{Camera2D.size} " \
     "bbox=#{BoundingBox.size} matrix=#{Matrix.size} anim=#{ModelAnimation.size}"
