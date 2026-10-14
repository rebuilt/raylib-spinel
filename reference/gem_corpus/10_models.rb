# windowed
# Gem model surface: handles with fields + helper methods.
require "raylib-spinel"
include Raylib

Raylib.InitWindow(64, 64, "corpus-models")
mesh = Raylib.GenMeshCube(1.0, 1.0, 1.0)
model = Raylib.LoadModelFromMesh(mesh)
puts "meshes=#{model.meshCount}"
mat = model.material(0)
puts "material=#{!mat.nil?} count=#{model.material_count}"
bb = Raylib.GetModelBoundingBox(model)
puts "bb=#{bb.min.x.round(2)},#{bb.min.y.round(2)},#{bb.min.z.round(2)},#{bb.max.x.round(2)}"
Raylib.UnloadModel(model)
Raylib.CloseWindow
puts "done"
