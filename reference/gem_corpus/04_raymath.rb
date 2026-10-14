# Gem raymath surface (by-value Vector/Matrix in and out).
require "raylib-spinel"
include Raylib

a = Vector2.create(1.0, 2.0)
b = Vector2.create(3.0, 4.0)
puts Vector2Add(a, b).to_a.inspect
puts Vector2Length(a).round(4)
puts Vector2DotProduct(a, b).round(1)
n = Vector3Normalize(Vector3.create(3.0, 0.0, 0.0))
puts [n.x, n.y, n.z].inspect
cross = Vector3CrossProduct(Vector3.create(1.0, 0.0, 0.0), Vector3.create(0.0, 1.0, 0.0))
puts [cross.x, cross.y, cross.z].inspect
m = MatrixRotateXYZ(Vector3.create(0.0, 0.0, 0.0))
puts [m.m0.round(2), m.m5.round(2), m.m15.round(2)].inspect
