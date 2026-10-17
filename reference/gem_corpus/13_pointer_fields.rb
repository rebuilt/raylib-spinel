# windowed
# Pointer fields and the gem's Color idioms (regressions for today's fixes):
# Color.new + copy / from_u8 / from_u32, and the Mesh pointer-field idiom
# (Mesh.new, field writes, MemAlloc buffers filled with put_array_of_float32,
# UploadMesh), all differentially against the gem.
require "raylib"
include Raylib

Raylib.InitWindow(320, 240, "corpus-pointer-fields")

c = Color.new.copy(RED)
puts "copy: #{c.r},#{c.g},#{c.b},#{c.a}"
u8 = Color.from_u8(1, 2, 3, 4)
puts "from_u8: #{u8.r},#{u8.g},#{u8.b},#{u8.a}"
u32 = Color.from_u32(0x01020304)
puts "from_u32: #{u32.r},#{u32.g},#{u32.b},#{u32.a}"

mesh = Mesh.new
mesh.triangleCount = 1
mesh.vertexCount = mesh.triangleCount * 3
sf = FFI.type_size(:float)
mesh.vertices = MemAlloc(mesh.vertexCount * 3 * sf)
mesh.texcoords = MemAlloc(mesh.vertexCount * 2 * sf)
mesh.normals = MemAlloc(mesh.vertexCount * 3 * sf)
mesh.vertices.put_array_of_float32(0, [0, 0, 0])
mesh.vertices.put_array_of_float32(3 * sf, [1, 0, 2])
mesh.vertices.put_array_of_float32(6 * sf, [2, 0, 0])
mesh.normals.put_array_of_float32(0, [0, 1, 0])
mesh.texcoords.put_array_of_float32(0, [0, 0])
puts "mesh: #{mesh.vertexCount} vertices, #{mesh.triangleCount} triangles"

# The three spellings FFI accepts for a pointer field, each read back through
# the field's own reader: the reader's value round-tripped (regression: the
# Spinel side stored the wrapper object itself into the struct, so the field
# read back a heap address and UnloadMesh freed that), a bare address, and a
# freshly wrapped pointer. This program loads the ffi package, whose Pointer
# family sends `address` polymorphically -- that widens Raylib::Ptr#@address to
# a box, and both sides now rely on the box's payload (see the Ptr class
# comment), so a layout or inference change fails HERE. Addresses differ per
# run, so print equality.
v = mesh.vertices
mesh.vertices = v
puts "vertices round trip: #{mesh.vertices.address == v.address}"
addr = mesh.normals.address
mesh.normals = addr
puts "normals address write: #{mesh.normals.address == addr}"
mesh.normals = FFI::Pointer.new(addr)
puts "FFI::Pointer write: #{mesh.normals.address == addr}"

UploadMesh(mesh, false)
model = LoadModelFromMesh(mesh)
puts "model: #{model.materialCount} material(s)"
image = GenImageColor(4, 4, BLUE)
texture = LoadTextureFromImage(image)
UnloadImage(image)
SetMaterialTexture(model.material(0), MATERIAL_MAP_ALBEDO, texture)
puts "material texture set"

UnloadModel(model)
UnloadTexture(texture)
Raylib.CloseWindow
