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
# Vector2Length/Vector2Angle also exist as hand-written shims in
# raylib_adapter.c; their return type must match the :float ffi decls.
puts "Vector2Length #{f Raylib.Vector2Length(a)}"
puts "Vector2Angle #{f Raylib.Vector2Angle(a, b)}"
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
# Length/LengthSqr take "const Vector3" params in raymath_api.json; the
# adapter once misread the GC wrapper header instead of the payload.
puts "Vector3Length #{f Raylib.Vector3Length(v)}"
puts "Vector3LengthSqr #{f Raylib.Vector3LengthSqr(v)}"
c3 = Raylib.Vector3CrossProduct(v, w)
puts "Vector3CrossProduct #{f c3.x} #{f c3.y} #{f c3.z}"
lp = Raylib.Vector3Lerp(v, w, 0.5)
puts "Vector3Lerp #{f lp.x} #{f lp.y} #{f lp.z}"

# ---- Matrix (column-major: values[0..3] is column 0, so the translation
# lives at values[3], values[7], values[11] -> m12, m13, m14) ----
m = Raylib.Matrix([1.0, 0.0, 0.0, 10.0,
                   0.0, 1.0, 0.0, 20.0,
                   0.0, 0.0, 1.0, 30.0,
                   0.0, 0.0, 0.0, 1.0])
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

# ---- Quaternion/Matrix conversions (out-param wrappers that once had no
# PascalCase surface; MatrixToFloatV returns a raw pointer under Spinel so it
# is not differentially comparable) ----
qq = Raylib.QuaternionFromVector3ToVector3(Raylib::Vector3.new(0.0, 0.0, 1.0),
                                           Raylib::Vector3.new(1.0, 0.0, 0.0))
puts "QuaternionFromVector3ToVector3 #{f qq.x} #{f qq.y} #{f qq.z} #{f qq.w}"
qmm = Raylib.QuaternionToMatrix(qq)
puts "QuaternionToMatrix #{f qmm.m0} #{f qmm.m5} #{f qmm.m10}"
puts "snake quaternion_to_matrix #{f Raylib.quaternion_to_matrix(qq).m5}"

# ---- snake_case aliases (MRI gem naming) ----
puts "snake vector2_dot_product #{f Raylib.vector2_dot_product(a, b)}"
n3s = Raylib.vector3_normalize(v)
puts "snake vector3_normalize #{f n3s.x} #{f n3s.y} #{f n3s.z}"
puts "snake matrix_determinant #{f Raylib.matrix_determinant(m)}"
qs = Raylib.quaternion_from_axis_angle(Raylib::Vector3.new(0.0, 1.0, 0.0), 1.5707963705062866)
puts "snake quaternion_from_axis_angle #{f qs.x} #{f qs.y} #{f qs.z} #{f qs.w}"
# NOTE: the gem's conversion has no vector_4 fix, so Vector4Normalize's
# snake name is the quirky "vector_4normalize" — match it exactly.
puts "snake vector_4normalize #{f Raylib.vector_4normalize(p4).w}"
