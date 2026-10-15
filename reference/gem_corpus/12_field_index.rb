# windowed
# The gem's FFI::Struct#[] reads fields (model[:materials], node[:position]);
# our views need the same shape. This records what the AOT's class-valued
# fallback does at run time, differentially against the gem.
require "raylib"
include Raylib

Raylib.InitWindow(320, 240, "corpus-field-index")
mesh = Raylib.GenMeshCube(1.0, 1.0, 1.0)
puts "direct: #{mesh.vertexCount}/#{mesh.triangleCount}"
begin
  puts "index: #{mesh[:vertexCount]}/#{mesh[:triangleCount]}"
rescue => e
  puts "index raised: #{e.class}"
end
begin
  puts "index assignment: #{mesh[:vertexCount] = 3}"
rescue => e
  puts "index assignment raised: #{e.class}"
end
Raylib.CloseWindow
