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
