# Differential test: raymath surface under Spinel vs the raylib-bindings gem.
# No .expected snapshot, so `spin test` runs this under CRuby (which loads the
# gem) and diffs the Spinel-compiled binary's output against it. Pure math
# only: no window, deterministic inputs, 3-decimal formatting.
require "raylib-spinel"
require "raylib-spinel/raymath"

def f(x)
  format("%.3f", x.to_f + 0.0) # +0.0 folds -0.0 so both backends print alike
end

# ---- Vector2 ----
a = Raylib.Vector2(3.0, 4.0)
b = Raylib.Vector2(1.0, 2.0)
puts "Vector2LengthSqr #{f Raylib.Vector2LengthSqr(a)}"
puts "Vector2DotProduct #{f Raylib.Vector2DotProduct(a, b)}"
puts "Vector2CrossProduct #{f Raylib.Vector2CrossProduct(a, b)}"
puts "Vector2Distance #{f Raylib.Vector2Distance(a, Raylib.Vector2(0.0, 0.0))}"
n2 = Raylib.Vector2Normalize(a)
puts "Vector2Normalize #{f n2.x} #{f n2.y}"

# ---- Vector3 ----
v = Raylib::Vector3.new(1.0, 2.0, 3.0)
w = Raylib::Vector3.new(4.0, -5.0, 6.0)
n3 = Raylib.Vector3Normalize(v)
puts "Vector3Normalize #{f n3.x} #{f n3.y} #{f n3.z}"
c3 = Raylib.Vector3CrossProduct(v, w)
puts "Vector3CrossProduct #{f c3.x} #{f c3.y} #{f c3.z}"
lp = Raylib.Vector3Lerp(v, w, 0.5)
puts "Vector3Lerp #{f lp.x} #{f lp.y} #{f lp.z}"

# ---- Matrix (column-major; translation in m12..m14) ----
m = Raylib.Matrix([1.0, 0.0, 0.0, 0.0,
                   0.0, 1.0, 0.0, 0.0,
                   0.0, 0.0, 1.0, 0.0,
                   10.0, 20.0, 30.0, 1.0])
tv = Raylib.Vector3Transform(v, m)
puts "Vector3Transform #{f tv.x} #{f tv.y} #{f tv.z}"
puts "MatrixDeterminant #{f Raylib.MatrixDeterminant(m)}"
mi = Raylib.MatrixInvert(m)
puts "MatrixInvert #{f mi.m12} #{f mi.m13} #{f mi.m14}"

# ---- Quaternion ----
q = Raylib.QuaternionFromAxisAngle(Raylib::Vector3.new(0.0, 1.0, 0.0), 1.5707963705062866)
puts "QuaternionFromAxisAngle #{f q.x} #{f q.y} #{f q.z} #{f q.w}"
qm = Raylib.QuaternionMultiply(q, q)
puts "QuaternionMultiply #{f qm.x} #{f qm.y} #{f qm.z} #{f qm.w}"
rv = Raylib.Vector3RotateByQuaternion(v, q)
puts "Vector3RotateByQuaternion #{f rv.x} #{f rv.y} #{f rv.z}"

# ---- Vector4 ----
p4 = Raylib.Vector4(1.0, 2.0, 3.0, 4.0)
s4 = Raylib.Vector4(5.0, 6.0, 7.0, 8.0)
puts "Vector4LengthSqr #{f Raylib.Vector4LengthSqr(p4)}"
l4 = Raylib.Vector4Lerp(p4, s4, 0.25)
puts "Vector4Lerp #{f l4.x} #{f l4.y} #{f l4.z} #{f l4.w}"
n4 = Raylib.Vector4Normalize(p4)
puts "Vector4Normalize #{f n4.x} #{f n4.y} #{f n4.z} #{f n4.w}"
