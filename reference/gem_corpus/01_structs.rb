# Gem-API struct surface: factories, fields, to_a, sizes, nested structs.
require "raylib-spinel"
include Raylib

v = Vector2.create(1.5, -2.25)
puts "v=#{v.x},#{v.y} to_a=#{v.to_a.inspect} size=#{Vector2.size}"
v.set(3.0, 4.0)
puts "v2=#{v.x},#{v.y}"
w = Vector2.create(3.0, 4.0)
puts "w=#{w.add_vector(v).to_a.inspect}"

r = Rectangle.create(1, 2, 3, 4)
puts "r=#{r.x},#{r.y},#{r.width},#{r.height} size=#{Rectangle.size}"

bb = BoundingBox.create(0, 1, 2, 3, 4, 5)
puts "bb=#{bb.min.x},#{bb.min.z},#{bb.max.x},#{bb.max.z}"
bb2 = BoundingBox.create(Vector3.create(1, 1, 1), Vector3.create(2, 2, 2))
puts "bb2=#{bb2.min.x},#{bb2.max.y}"

c = Color.from_u8(10, 20, 30, 40)
puts "c=#{c.r},#{c.g},#{c.b},#{c.a}"
c2 = Color.from_u32(0x11223344)
puts "c2=#{c2.r},#{c2.g},#{c2.b},#{c2.a}"

q = Quaternion.create(1, 2, 3, 4)
puts "q=#{q.x},#{q.y},#{q.z},#{q.w} to_a=#{q.to_a.inspect}"

t = Transform.new
t.t.set(1.0, 2.0, 3.0)
puts "t=#{t.t.x},#{t.t.y},#{t.t.z}"

cam = Camera3D.new
cam.position.set(1.0, 2.0, 3.0)
cam.fovy = 45.0
puts "cam=#{cam.position.x},#{cam.position.y},#{cam.position.z},#{cam.fovy},#{cam.projection}"
puts "camera_alias=#{Camera == Camera3D}"
