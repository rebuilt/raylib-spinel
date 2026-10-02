#include <raylib.h>
#include <rlgl.h>
#include <raymath.h>
#include <stdio.h>
#include <stdlib.h>
#include "spinel/runtime.h"

/* raymath_adapter.c — sp_ shims for Spinel AOT */

/* Generated shims (tools/gen_raymath.py) */

/* ================================================================
 * Generated shims (tools/gen_raymath.py). Same conventions as the
 * hand-written shims above; keep in sync by re-running the generator.
 * ================================================================ */


/* sp_Vector2 — GC-embedded Vector2 (see raymath_ffi.rb) */typedef struct sp_Vector2_s {
  sp_int cls_id;
  Vector2 v;
} sp_Vector2;
static void sp_Vector2_scan(void *p) { (void)p; }
static sp_Vector2 *sp_Vector2_new(sp_int cls_id) {
  sp_Vector2 *self = (sp_Vector2 *)sp_gc_alloc(sizeof(sp_Vector2), NULL, sp_Vector2_scan);
  self->cls_id = cls_id;
  self->v = (Vector2){ 0 };
  return self;
}
static double sp_Vector2_x(sp_Vector2 *self) {
  return (double)self->v.x;
}
static double sp_Vector2_set_x(sp_Vector2 *self, double x) {
  self->v.x = (float)x;
  return x;
}
static double sp_Vector2_y(sp_Vector2 *self) {
  return (double)self->v.y;
}
static double sp_Vector2_set_y(sp_Vector2 *self, double y) {
  self->v.y = (float)y;
  return y;
}

/* sp_Vector3 — GC-embedded Vector3 (see raymath_ffi.rb) */typedef struct sp_Vector3_s {
  sp_int cls_id;
  Vector3 v;
} sp_Vector3;
static void sp_Vector3_scan(void *p) { (void)p; }
static sp_Vector3 *sp_Vector3_new(sp_int cls_id) {
  sp_Vector3 *self = (sp_Vector3 *)sp_gc_alloc(sizeof(sp_Vector3), NULL, sp_Vector3_scan);
  self->cls_id = cls_id;
  self->v = (Vector3){ 0 };
  return self;
}
static double sp_Vector3_x(sp_Vector3 *self) {
  return (double)self->v.x;
}
double sp_Vector3_set_x(sp_Vector3 *self, double x) {
  self->v.x = (float)x;
  return x;
}
static double sp_Vector3_y(sp_Vector3 *self) {
  return (double)self->v.y;
}
double sp_Vector3_set_y(sp_Vector3 *self, double y) {
  self->v.y = (float)y;
  return y;
}
static double sp_Vector3_z(sp_Vector3 *self) {
  return (double)self->v.z;
}
double sp_Vector3_set_z(sp_Vector3 *self, double z) {
  self->v.z = (float)z;
  return z;
}

/* sp_Vector4 — GC-embedded Vector4 (see raymath_ffi.rb) */typedef struct sp_Vector4_s {
  sp_int cls_id;
  Vector4 v;
} sp_Vector4;
static void sp_Vector4_scan(void *p) { (void)p; }
static sp_Vector4 *sp_Vector4_new(sp_int cls_id) {
  sp_Vector4 *self = (sp_Vector4 *)sp_gc_alloc(sizeof(sp_Vector4), NULL, sp_Vector4_scan);
  self->cls_id = cls_id;
  self->v = (Vector4){ 0 };
  return self;
}
static double sp_Vector4_x(sp_Vector4 *self) {
  return (double)self->v.x;
}
static double sp_Vector4_set_x(sp_Vector4 *self, double x) {
  self->v.x = (float)x;
  return x;
}
static double sp_Vector4_y(sp_Vector4 *self) {
  return (double)self->v.y;
}
static double sp_Vector4_set_y(sp_Vector4 *self, double y) {
  self->v.y = (float)y;
  return y;
}
static double sp_Vector4_z(sp_Vector4 *self) {
  return (double)self->v.z;
}
static double sp_Vector4_set_z(sp_Vector4 *self, double z) {
  self->v.z = (float)z;
  return z;
}
static double sp_Vector4_w(sp_Vector4 *self) {
  return (double)self->v.w;
}
static double sp_Vector4_set_w(sp_Vector4 *self, double w) {
  self->v.w = (float)w;
  return w;
}

/* sp_Quaternion — GC-embedded Quaternion (see raymath_ffi.rb) */typedef struct sp_Quaternion_s {
  sp_int cls_id;
  Quaternion v;
} sp_Quaternion;
static void sp_Quaternion_scan(void *p) { (void)p; }
sp_Quaternion *sp_Quaternion_new(sp_int cls_id) {
  sp_Quaternion *self = (sp_Quaternion *)sp_gc_alloc(sizeof(sp_Quaternion), NULL, sp_Quaternion_scan);
  self->cls_id = cls_id;
  self->v = (Quaternion){ 0 };
  return self;
}

/* sp_Matrix — GC-embedded Matrix (see raymath_ffi.rb) */typedef struct sp_Matrix_s {
  sp_int cls_id;
  Matrix v;
} sp_Matrix;
static void sp_Matrix_scan(void *p) { (void)p; }
static sp_Matrix *sp_Matrix_new(sp_int cls_id) {
  sp_Matrix *self = (sp_Matrix *)sp_gc_alloc(sizeof(sp_Matrix), NULL, sp_Matrix_scan);
  self->cls_id = cls_id;
  self->v = (Matrix){ 0 };
  return self;
}
static double sp_Matrix_m0(sp_Matrix *self) {
  return (double)self->v.m0;
}
static double sp_Matrix_set_m0(sp_Matrix *self, double m0) {
  self->v.m0 = (float)m0;
  return m0;
}
static double sp_Matrix_m4(sp_Matrix *self) {
  return (double)self->v.m4;
}
static double sp_Matrix_set_m4(sp_Matrix *self, double m4) {
  self->v.m4 = (float)m4;
  return m4;
}
static double sp_Matrix_m8(sp_Matrix *self) {
  return (double)self->v.m8;
}
static double sp_Matrix_set_m8(sp_Matrix *self, double m8) {
  self->v.m8 = (float)m8;
  return m8;
}
static double sp_Matrix_m12(sp_Matrix *self) {
  return (double)self->v.m12;
}
static double sp_Matrix_set_m12(sp_Matrix *self, double m12) {
  self->v.m12 = (float)m12;
  return m12;
}
static double sp_Matrix_m1(sp_Matrix *self) {
  return (double)self->v.m1;
}
static double sp_Matrix_set_m1(sp_Matrix *self, double m1) {
  self->v.m1 = (float)m1;
  return m1;
}
static double sp_Matrix_m5(sp_Matrix *self) {
  return (double)self->v.m5;
}
static double sp_Matrix_set_m5(sp_Matrix *self, double m5) {
  self->v.m5 = (float)m5;
  return m5;
}
static double sp_Matrix_m9(sp_Matrix *self) {
  return (double)self->v.m9;
}
static double sp_Matrix_set_m9(sp_Matrix *self, double m9) {
  self->v.m9 = (float)m9;
  return m9;
}
static double sp_Matrix_m13(sp_Matrix *self) {
  return (double)self->v.m13;
}
static double sp_Matrix_set_m13(sp_Matrix *self, double m13) {
  self->v.m13 = (float)m13;
  return m13;
}
static double sp_Matrix_m2(sp_Matrix *self) {
  return (double)self->v.m2;
}
static double sp_Matrix_set_m2(sp_Matrix *self, double m2) {
  self->v.m2 = (float)m2;
  return m2;
}
static double sp_Matrix_m6(sp_Matrix *self) {
  return (double)self->v.m6;
}
static double sp_Matrix_set_m6(sp_Matrix *self, double m6) {
  self->v.m6 = (float)m6;
  return m6;
}
static double sp_Matrix_m10(sp_Matrix *self) {
  return (double)self->v.m10;
}
static double sp_Matrix_set_m10(sp_Matrix *self, double m10) {
  self->v.m10 = (float)m10;
  return m10;
}
static double sp_Matrix_m14(sp_Matrix *self) {
  return (double)self->v.m14;
}
static double sp_Matrix_set_m14(sp_Matrix *self, double m14) {
  self->v.m14 = (float)m14;
  return m14;
}
static double sp_Matrix_m3(sp_Matrix *self) {
  return (double)self->v.m3;
}
static double sp_Matrix_set_m3(sp_Matrix *self, double m3) {
  self->v.m3 = (float)m3;
  return m3;
}
static double sp_Matrix_m7(sp_Matrix *self) {
  return (double)self->v.m7;
}
static double sp_Matrix_set_m7(sp_Matrix *self, double m7) {
  self->v.m7 = (float)m7;
  return m7;
}
static double sp_Matrix_m11(sp_Matrix *self) {
  return (double)self->v.m11;
}
static double sp_Matrix_set_m11(sp_Matrix *self, double m11) {
  self->v.m11 = (float)m11;
  return m11;
}
static double sp_Matrix_m15(sp_Matrix *self) {
  return (double)self->v.m15;
}
static double sp_Matrix_set_m15(sp_Matrix *self, double m15) {
  self->v.m15 = (float)m15;
  return m15;
}

/* sp_Color — GC-embedded Color (see raymath_ffi.rb) */typedef struct sp_Color_s {
  sp_int cls_id;
  Color c;
} sp_Color;
static void sp_Color_scan(void *p) { (void)p; }
static sp_Color *sp_Color_new(sp_int cls_id) {
  sp_Color *self = (sp_Color *)sp_gc_alloc(sizeof(sp_Color), NULL, sp_Color_scan);
  self->cls_id = cls_id;
  self->c = (Color){ 0 };
  return self;
}

/* ---- generated shims ---- */
/** Vector2Zero(params: void * _out -> void) */
void sp_Vector2Zero(void * _out) {
  ((sp_Vector2*)_out)->v = Vector2Zero();
}
/** Vector2One(params: void * _out -> void) */
void sp_Vector2One(void * _out) {
  ((sp_Vector2*)_out)->v = Vector2One();
}
/** Vector2Add(params: void * v1, void * v2, void * _out -> void) */
static void sp_Vector2Add(void * v1, void * v2, void * _out) {
  ((sp_Vector2*)_out)->v = Vector2Add(((sp_Vector2*)v1)->v, ((sp_Vector2*)v2)->v);
}
/** Vector2AddValue(params: void * v, float add, void * _out -> void) */
void sp_Vector2AddValue(void * v, float add, void * _out) {
  ((sp_Vector2*)_out)->v = Vector2AddValue(((sp_Vector2*)v)->v, add);
}
/** Vector2Subtract(params: void * v1, void * v2, void * _out -> void) */
void sp_Vector2Subtract(void * v1, void * v2, void * _out) {
  ((sp_Vector2*)_out)->v = Vector2Subtract(((sp_Vector2*)v1)->v, ((sp_Vector2*)v2)->v);
}
/** Vector2SubtractValue(params: void * v, float sub, void * _out -> void) */
void sp_Vector2SubtractValue(void * v, float sub, void * _out) {
  ((sp_Vector2*)_out)->v = Vector2SubtractValue(((sp_Vector2*)v)->v, sub);
}
/** Vector2Length(params: void * v -> float) */
static float sp_Vector2Length(void * v) {
  return Vector2Length(((sp_Vector2*)v)->v);
}
/** Vector2LengthSqr(params: void * v -> float) */
float sp_Vector2LengthSqr(void * v) {
  return Vector2LengthSqr(((sp_Vector2*)v)->v);
}
/** Vector2DotProduct(params: void * v1, void * v2 -> float) */
float sp_Vector2DotProduct(void * v1, void * v2) {
  return Vector2DotProduct(((sp_Vector2*)v1)->v, ((sp_Vector2*)v2)->v);
}
/** Vector2CrossProduct(params: void * v1, void * v2 -> float) */
float sp_Vector2CrossProduct(void * v1, void * v2) {
  return Vector2CrossProduct(((sp_Vector2*)v1)->v, ((sp_Vector2*)v2)->v);
}
/** Vector2Distance(params: void * v1, void * v2 -> float) */
float sp_Vector2Distance(void * v1, void * v2) {
  return Vector2Distance(((sp_Vector2*)v1)->v, ((sp_Vector2*)v2)->v);
}
/** Vector2DistanceSqr(params: void * v1, void * v2 -> float) */
float sp_Vector2DistanceSqr(void * v1, void * v2) {
  return Vector2DistanceSqr(((sp_Vector2*)v1)->v, ((sp_Vector2*)v2)->v);
}
/** Vector2Angle(params: void * v1, void * v2 -> float) */
static float sp_Vector2Angle(void * v1, void * v2) {
  return Vector2Angle(((sp_Vector2*)v1)->v, ((sp_Vector2*)v2)->v);
}
/** Vector2LineAngle(params: void * start, void * end -> float) */
float sp_Vector2LineAngle(void * start, void * end) {
  return Vector2LineAngle(((sp_Vector2*)start)->v, ((sp_Vector2*)end)->v);
}
/** Vector2Scale(params: void * v, float scale, void * _out -> void) */
static void sp_Vector2Scale(void * v, float scale, void * _out) {
  ((sp_Vector2*)_out)->v = Vector2Scale(((sp_Vector2*)v)->v, scale);
}
/** Vector2Multiply(params: void * v1, void * v2, void * _out -> void) */
void sp_Vector2Multiply(void * v1, void * v2, void * _out) {
  ((sp_Vector2*)_out)->v = Vector2Multiply(((sp_Vector2*)v1)->v, ((sp_Vector2*)v2)->v);
}
/** Vector2Negate(params: void * v, void * _out -> void) */
void sp_Vector2Negate(void * v, void * _out) {
  ((sp_Vector2*)_out)->v = Vector2Negate(((sp_Vector2*)v)->v);
}
/** Vector2Divide(params: void * v1, void * v2, void * _out -> void) */
void sp_Vector2Divide(void * v1, void * v2, void * _out) {
  ((sp_Vector2*)_out)->v = Vector2Divide(((sp_Vector2*)v1)->v, ((sp_Vector2*)v2)->v);
}
/** Vector2Normalize(params: void * v, void * _out -> void) */
static void sp_Vector2Normalize(void * v, void * _out) {
  ((sp_Vector2*)_out)->v = Vector2Normalize(((sp_Vector2*)v)->v);
}
/** Vector2Transform(params: void * v, void * mat, void * _out -> void) */
void sp_Vector2Transform(void * v, void * mat, void * _out) {
  ((sp_Vector2*)_out)->v = Vector2Transform(((sp_Vector2*)v)->v, ((sp_Matrix*)mat)->v);
}
/** Vector2Lerp(params: void * v1, void * v2, float amount, void * _out -> void) */
static void sp_Vector2Lerp(void * v1, void * v2, float amount, void * _out) {
  ((sp_Vector2*)_out)->v = Vector2Lerp(((sp_Vector2*)v1)->v, ((sp_Vector2*)v2)->v, amount);
}
/** Vector2Reflect(params: void * v, void * normal, void * _out -> void) */
void sp_Vector2Reflect(void * v, void * normal, void * _out) {
  ((sp_Vector2*)_out)->v = Vector2Reflect(((sp_Vector2*)v)->v, ((sp_Vector2*)normal)->v);
}
/** Vector2Min(params: void * v1, void * v2, void * _out -> void) */
void sp_Vector2Min(void * v1, void * v2, void * _out) {
  ((sp_Vector2*)_out)->v = Vector2Min(((sp_Vector2*)v1)->v, ((sp_Vector2*)v2)->v);
}
/** Vector2Max(params: void * v1, void * v2, void * _out -> void) */
void sp_Vector2Max(void * v1, void * v2, void * _out) {
  ((sp_Vector2*)_out)->v = Vector2Max(((sp_Vector2*)v1)->v, ((sp_Vector2*)v2)->v);
}
/** Vector2Rotate(params: void * v, float angle, void * _out -> void) */
static void sp_Vector2Rotate(void * v, float angle, void * _out) {
  ((sp_Vector2*)_out)->v = Vector2Rotate(((sp_Vector2*)v)->v, angle);
}
/** Vector2MoveTowards(params: void * v, void * target, float maxDistance, void * _out -> void) */
void sp_Vector2MoveTowards(void * v, void * target, float maxDistance, void * _out) {
  ((sp_Vector2*)_out)->v = Vector2MoveTowards(((sp_Vector2*)v)->v, ((sp_Vector2*)target)->v, maxDistance);
}
/** Vector2Invert(params: void * v, void * _out -> void) */
void sp_Vector2Invert(void * v, void * _out) {
  ((sp_Vector2*)_out)->v = Vector2Invert(((sp_Vector2*)v)->v);
}
/** Vector2Clamp(params: void * v, void * min, void * max, void * _out -> void) */
void sp_Vector2Clamp(void * v, void * min, void * max, void * _out) {
  ((sp_Vector2*)_out)->v = Vector2Clamp(((sp_Vector2*)v)->v, ((sp_Vector2*)min)->v, ((sp_Vector2*)max)->v);
}
/** Vector2ClampValue(params: void * v, float min, float max, void * _out -> void) */
void sp_Vector2ClampValue(void * v, float min, float max, void * _out) {
  ((sp_Vector2*)_out)->v = Vector2ClampValue(((sp_Vector2*)v)->v, min, max);
}
/** Vector2Equals(params: void * p, void * q -> int) */
int sp_Vector2Equals(void * p, void * q) {
  return Vector2Equals(((sp_Vector2*)p)->v, ((sp_Vector2*)q)->v);
}
/** Vector2Refract(params: void * v, void * n, float r, void * _out -> void) */
void sp_Vector2Refract(void * v, void * n, float r, void * _out) {
  ((sp_Vector2*)_out)->v = Vector2Refract(((sp_Vector2*)v)->v, ((sp_Vector2*)n)->v, r);
}
/** Vector3Zero(params: void * _out -> void) */
void sp_Vector3Zero(void * _out) {
  ((sp_Vector3*)_out)->v = Vector3Zero();
}
/** Vector3One(params: void * _out -> void) */
void sp_Vector3One(void * _out) {
  ((sp_Vector3*)_out)->v = Vector3One();
}
/** Vector3Add(params: void * v1, void * v2, void * _out -> void) */
void sp_Vector3Add(void * v1, void * v2, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3Add(((sp_Vector3*)v1)->v, ((sp_Vector3*)v2)->v);
}
/** Vector3AddValue(params: void * v, float add, void * _out -> void) */
void sp_Vector3AddValue(void * v, float add, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3AddValue(((sp_Vector3*)v)->v, add);
}
/** Vector3Subtract(params: void * v1, void * v2, void * _out -> void) */
void sp_Vector3Subtract(void * v1, void * v2, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3Subtract(((sp_Vector3*)v1)->v, ((sp_Vector3*)v2)->v);
}
/** Vector3SubtractValue(params: void * v, float sub, void * _out -> void) */
void sp_Vector3SubtractValue(void * v, float sub, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3SubtractValue(((sp_Vector3*)v)->v, sub);
}
/** Vector3Scale(params: void * v, float scalar, void * _out -> void) */
void sp_Vector3Scale(void * v, float scalar, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3Scale(((sp_Vector3*)v)->v, scalar);
}
/** Vector3Multiply(params: void * v1, void * v2, void * _out -> void) */
void sp_Vector3Multiply(void * v1, void * v2, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3Multiply(((sp_Vector3*)v1)->v, ((sp_Vector3*)v2)->v);
}
/** Vector3CrossProduct(params: void * v1, void * v2, void * _out -> void) */
void sp_Vector3CrossProduct(void * v1, void * v2, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3CrossProduct(((sp_Vector3*)v1)->v, ((sp_Vector3*)v2)->v);
}
/** Vector3Perpendicular(params: void * v, void * _out -> void) */
void sp_Vector3Perpendicular(void * v, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3Perpendicular(((sp_Vector3*)v)->v);
}
/** Vector3Length(params: void * v -> float) */
float sp_Vector3Length(void * v) {
  return Vector3Length(*(const Vector3 *)v);
}
/** Vector3LengthSqr(params: void * v -> float) */
float sp_Vector3LengthSqr(void * v) {
  return Vector3LengthSqr(*(const Vector3 *)v);
}
/** Vector3DotProduct(params: void * v1, void * v2 -> float) */
float sp_Vector3DotProduct(void * v1, void * v2) {
  return Vector3DotProduct(((sp_Vector3*)v1)->v, ((sp_Vector3*)v2)->v);
}
/** Vector3Distance(params: void * v1, void * v2 -> float) */
float sp_Vector3Distance(void * v1, void * v2) {
  return Vector3Distance(((sp_Vector3*)v1)->v, ((sp_Vector3*)v2)->v);
}
/** Vector3DistanceSqr(params: void * v1, void * v2 -> float) */
float sp_Vector3DistanceSqr(void * v1, void * v2) {
  return Vector3DistanceSqr(((sp_Vector3*)v1)->v, ((sp_Vector3*)v2)->v);
}
/** Vector3Angle(params: void * v1, void * v2 -> float) */
float sp_Vector3Angle(void * v1, void * v2) {
  return Vector3Angle(((sp_Vector3*)v1)->v, ((sp_Vector3*)v2)->v);
}
/** Vector3Negate(params: void * v, void * _out -> void) */
void sp_Vector3Negate(void * v, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3Negate(((sp_Vector3*)v)->v);
}
/** Vector3Divide(params: void * v1, void * v2, void * _out -> void) */
void sp_Vector3Divide(void * v1, void * v2, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3Divide(((sp_Vector3*)v1)->v, ((sp_Vector3*)v2)->v);
}
/** Vector3Normalize(params: void * v, void * _out -> void) */
void sp_Vector3Normalize(void * v, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3Normalize(((sp_Vector3*)v)->v);
}
/** Vector3Project(params: void * v1, void * v2, void * _out -> void) */
void sp_Vector3Project(void * v1, void * v2, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3Project(((sp_Vector3*)v1)->v, ((sp_Vector3*)v2)->v);
}
/** Vector3Reject(params: void * v1, void * v2, void * _out -> void) */
void sp_Vector3Reject(void * v1, void * v2, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3Reject(((sp_Vector3*)v1)->v, ((sp_Vector3*)v2)->v);
}
/** Vector3OrthoNormalize(params: void * v1, void * v2 -> void) */
void sp_Vector3OrthoNormalize(void * v1, void * v2) {
  Vector3OrthoNormalize(&((sp_Vector3*)v1)->v, &((sp_Vector3*)v2)->v);
}
/** Vector3Transform(params: void * v, void * mat, void * _out -> void) */
void sp_Vector3Transform(void * v, void * mat, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3Transform(((sp_Vector3*)v)->v, ((sp_Matrix*)mat)->v);
}
/** Vector3RotateByQuaternion(params: void * v, void * q, void * _out -> void) */
void sp_Vector3RotateByQuaternion(void * v, void * q, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3RotateByQuaternion(((sp_Vector3*)v)->v, ((sp_Quaternion*)q)->v);
}
/** Vector3RotateByAxisAngle(params: void * v, void * axis, float angle, void * _out -> void) */
void sp_Vector3RotateByAxisAngle(void * v, void * axis, float angle, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3RotateByAxisAngle(((sp_Vector3*)v)->v, ((sp_Vector3*)axis)->v, angle);
}
/** Vector3MoveTowards(params: void * v, void * target, float maxDistance, void * _out -> void) */
void sp_Vector3MoveTowards(void * v, void * target, float maxDistance, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3MoveTowards(((sp_Vector3*)v)->v, ((sp_Vector3*)target)->v, maxDistance);
}
/** Vector3Lerp(params: void * v1, void * v2, float amount, void * _out -> void) */
void sp_Vector3Lerp(void * v1, void * v2, float amount, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3Lerp(((sp_Vector3*)v1)->v, ((sp_Vector3*)v2)->v, amount);
}
/** Vector3CubicHermite(params: void * v1, void * tangent1, void * v2, void * tangent2, float amount, void * _out -> void) */
void sp_Vector3CubicHermite(void * v1, void * tangent1, void * v2, void * tangent2, float amount, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3CubicHermite(((sp_Vector3*)v1)->v, ((sp_Vector3*)tangent1)->v, ((sp_Vector3*)v2)->v, ((sp_Vector3*)tangent2)->v, amount);
}
/** Vector3Reflect(params: void * v, void * normal, void * _out -> void) */
void sp_Vector3Reflect(void * v, void * normal, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3Reflect(((sp_Vector3*)v)->v, ((sp_Vector3*)normal)->v);
}
/** Vector3Min(params: void * v1, void * v2, void * _out -> void) */
void sp_Vector3Min(void * v1, void * v2, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3Min(((sp_Vector3*)v1)->v, ((sp_Vector3*)v2)->v);
}
/** Vector3Max(params: void * v1, void * v2, void * _out -> void) */
void sp_Vector3Max(void * v1, void * v2, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3Max(((sp_Vector3*)v1)->v, ((sp_Vector3*)v2)->v);
}
/** Vector3Barycenter(params: void * p, void * a, void * b, void * c, void * _out -> void) */
void sp_Vector3Barycenter(void * p, void * a, void * b, void * c, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3Barycenter(((sp_Vector3*)p)->v, ((sp_Vector3*)a)->v, ((sp_Vector3*)b)->v, ((sp_Vector3*)c)->v);
}
/** Vector3Unproject(params: void * source, void * projection, void * view, void * _out -> void) */
void sp_Vector3Unproject(void * source, void * projection, void * view, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3Unproject(((sp_Vector3*)source)->v, ((sp_Matrix*)projection)->v, ((sp_Matrix*)view)->v);
}
/** Vector3ToFloatV(params: void * v, float * _out -> void *) */
void * sp_Vector3ToFloatV(void * v, float * _out) {
  float3 *r = (float3 *)malloc(sizeof(float3));
  *r = Vector3ToFloatV(((sp_Vector3*)v)->v);
  return r;
}
/** Vector3Invert(params: void * v, void * _out -> void) */
void sp_Vector3Invert(void * v, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3Invert(((sp_Vector3*)v)->v);
}
/** Vector3Clamp(params: void * v, void * min, void * max, void * _out -> void) */
void sp_Vector3Clamp(void * v, void * min, void * max, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3Clamp(((sp_Vector3*)v)->v, ((sp_Vector3*)min)->v, ((sp_Vector3*)max)->v);
}
/** Vector3ClampValue(params: void * v, float min, float max, void * _out -> void) */
void sp_Vector3ClampValue(void * v, float min, float max, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3ClampValue(((sp_Vector3*)v)->v, min, max);
}
/** Vector3Equals(params: void * p, void * q -> int) */
int sp_Vector3Equals(void * p, void * q) {
  return Vector3Equals(((sp_Vector3*)p)->v, ((sp_Vector3*)q)->v);
}
/** Vector3Refract(params: void * v, void * n, float r, void * _out -> void) */
void sp_Vector3Refract(void * v, void * n, float r, void * _out) {
  ((sp_Vector3*)_out)->v = Vector3Refract(((sp_Vector3*)v)->v, ((sp_Vector3*)n)->v, r);
}
/** Vector4Zero(params: void * _out -> void) */
void sp_Vector4Zero(void * _out) {
  ((sp_Vector4*)_out)->v = Vector4Zero();
}
/** Vector4One(params: void * _out -> void) */
void sp_Vector4One(void * _out) {
  ((sp_Vector4*)_out)->v = Vector4One();
}
/** Vector4Add(params: void * v1, void * v2, void * _out -> void) */
void sp_Vector4Add(void * v1, void * v2, void * _out) {
  ((sp_Vector4*)_out)->v = Vector4Add(((sp_Vector4*)v1)->v, ((sp_Vector4*)v2)->v);
}
/** Vector4AddValue(params: void * v, float add, void * _out -> void) */
void sp_Vector4AddValue(void * v, float add, void * _out) {
  ((sp_Vector4*)_out)->v = Vector4AddValue(((sp_Vector4*)v)->v, add);
}
/** Vector4Subtract(params: void * v1, void * v2, void * _out -> void) */
void sp_Vector4Subtract(void * v1, void * v2, void * _out) {
  ((sp_Vector4*)_out)->v = Vector4Subtract(((sp_Vector4*)v1)->v, ((sp_Vector4*)v2)->v);
}
/** Vector4SubtractValue(params: void * v, float add, void * _out -> void) */
void sp_Vector4SubtractValue(void * v, float add, void * _out) {
  ((sp_Vector4*)_out)->v = Vector4SubtractValue(((sp_Vector4*)v)->v, add);
}
/** Vector4Length(params: void * v -> float) */
float sp_Vector4Length(void * v) {
  return Vector4Length(((sp_Vector4*)v)->v);
}
/** Vector4LengthSqr(params: void * v -> float) */
float sp_Vector4LengthSqr(void * v) {
  return Vector4LengthSqr(((sp_Vector4*)v)->v);
}
/** Vector4DotProduct(params: void * v1, void * v2 -> float) */
float sp_Vector4DotProduct(void * v1, void * v2) {
  return Vector4DotProduct(((sp_Vector4*)v1)->v, ((sp_Vector4*)v2)->v);
}
/** Vector4Distance(params: void * v1, void * v2 -> float) */
float sp_Vector4Distance(void * v1, void * v2) {
  return Vector4Distance(((sp_Vector4*)v1)->v, ((sp_Vector4*)v2)->v);
}
/** Vector4DistanceSqr(params: void * v1, void * v2 -> float) */
float sp_Vector4DistanceSqr(void * v1, void * v2) {
  return Vector4DistanceSqr(((sp_Vector4*)v1)->v, ((sp_Vector4*)v2)->v);
}
/** Vector4Scale(params: void * v, float scale, void * _out -> void) */
void sp_Vector4Scale(void * v, float scale, void * _out) {
  ((sp_Vector4*)_out)->v = Vector4Scale(((sp_Vector4*)v)->v, scale);
}
/** Vector4Multiply(params: void * v1, void * v2, void * _out -> void) */
void sp_Vector4Multiply(void * v1, void * v2, void * _out) {
  ((sp_Vector4*)_out)->v = Vector4Multiply(((sp_Vector4*)v1)->v, ((sp_Vector4*)v2)->v);
}
/** Vector4Negate(params: void * v, void * _out -> void) */
void sp_Vector4Negate(void * v, void * _out) {
  ((sp_Vector4*)_out)->v = Vector4Negate(((sp_Vector4*)v)->v);
}
/** Vector4Divide(params: void * v1, void * v2, void * _out -> void) */
void sp_Vector4Divide(void * v1, void * v2, void * _out) {
  ((sp_Vector4*)_out)->v = Vector4Divide(((sp_Vector4*)v1)->v, ((sp_Vector4*)v2)->v);
}
/** Vector4Normalize(params: void * v, void * _out -> void) */
void sp_Vector4Normalize(void * v, void * _out) {
  ((sp_Vector4*)_out)->v = Vector4Normalize(((sp_Vector4*)v)->v);
}
/** Vector4Min(params: void * v1, void * v2, void * _out -> void) */
void sp_Vector4Min(void * v1, void * v2, void * _out) {
  ((sp_Vector4*)_out)->v = Vector4Min(((sp_Vector4*)v1)->v, ((sp_Vector4*)v2)->v);
}
/** Vector4Max(params: void * v1, void * v2, void * _out -> void) */
void sp_Vector4Max(void * v1, void * v2, void * _out) {
  ((sp_Vector4*)_out)->v = Vector4Max(((sp_Vector4*)v1)->v, ((sp_Vector4*)v2)->v);
}
/** Vector4Lerp(params: void * v1, void * v2, float amount, void * _out -> void) */
void sp_Vector4Lerp(void * v1, void * v2, float amount, void * _out) {
  ((sp_Vector4*)_out)->v = Vector4Lerp(((sp_Vector4*)v1)->v, ((sp_Vector4*)v2)->v, amount);
}
/** Vector4MoveTowards(params: void * v, void * target, float maxDistance, void * _out -> void) */
void sp_Vector4MoveTowards(void * v, void * target, float maxDistance, void * _out) {
  ((sp_Vector4*)_out)->v = Vector4MoveTowards(((sp_Vector4*)v)->v, ((sp_Vector4*)target)->v, maxDistance);
}
/** Vector4Invert(params: void * v, void * _out -> void) */
void sp_Vector4Invert(void * v, void * _out) {
  ((sp_Vector4*)_out)->v = Vector4Invert(((sp_Vector4*)v)->v);
}
/** Vector4Equals(params: void * p, void * q -> int) */
int sp_Vector4Equals(void * p, void * q) {
  return Vector4Equals(((sp_Vector4*)p)->v, ((sp_Vector4*)q)->v);
}
/** MatrixDeterminant(params: void * mat -> float) */
float sp_MatrixDeterminant(void * mat) {
  return MatrixDeterminant(((sp_Matrix*)mat)->v);
}
/** MatrixTrace(params: void * mat -> float) */
float sp_MatrixTrace(void * mat) {
  return MatrixTrace(((sp_Matrix*)mat)->v);
}
/** MatrixTranspose(params: void * mat, void * _out -> void) */
void sp_MatrixTranspose(void * mat, void * _out) {
  ((sp_Matrix*)_out)->v = MatrixTranspose(((sp_Matrix*)mat)->v);
}
/** MatrixInvert(params: void * mat, void * _out -> void) */
void sp_MatrixInvert(void * mat, void * _out) {
  ((sp_Matrix*)_out)->v = MatrixInvert(((sp_Matrix*)mat)->v);
}
/** MatrixIdentity(params: void * _out -> void) */
void sp_MatrixIdentity(void * _out) {
  ((sp_Matrix*)_out)->v = MatrixIdentity();
}
/** MatrixAdd(params: void * left, void * right, void * _out -> void) */
void sp_MatrixAdd(void * left, void * right, void * _out) {
  ((sp_Matrix*)_out)->v = MatrixAdd(((sp_Matrix*)left)->v, ((sp_Matrix*)right)->v);
}
/** MatrixSubtract(params: void * left, void * right, void * _out -> void) */
void sp_MatrixSubtract(void * left, void * right, void * _out) {
  ((sp_Matrix*)_out)->v = MatrixSubtract(((sp_Matrix*)left)->v, ((sp_Matrix*)right)->v);
}
/** MatrixMultiply(params: void * left, void * right, void * _out -> void) */
void sp_MatrixMultiply(void * left, void * right, void * _out) {
  ((sp_Matrix*)_out)->v = MatrixMultiply(((sp_Matrix*)left)->v, ((sp_Matrix*)right)->v);
}
/** MatrixMultiplyValue(params: void * left, float value, void * _out -> void) */
void sp_MatrixMultiplyValue(void * left, float value, void * _out) {
  ((sp_Matrix*)_out)->v = MatrixMultiplyValue(((sp_Matrix*)left)->v, value);
}
/** MatrixTranslate(params: float x, float y, float z, void * _out -> void) */
void sp_MatrixTranslate(float x, float y, float z, void * _out) {
  ((sp_Matrix*)_out)->v = MatrixTranslate(x, y, z);
}
/** MatrixRotate(params: void * axis, float angle, void * _out -> void) */
void sp_MatrixRotate(void * axis, float angle, void * _out) {
  ((sp_Matrix*)_out)->v = MatrixRotate(((sp_Vector3*)axis)->v, angle);
}
/** MatrixRotateX(params: float angle, void * _out -> void) */
void sp_MatrixRotateX(float angle, void * _out) {
  ((sp_Matrix*)_out)->v = MatrixRotateX(angle);
}
/** MatrixRotateY(params: float angle, void * _out -> void) */
void sp_MatrixRotateY(float angle, void * _out) {
  ((sp_Matrix*)_out)->v = MatrixRotateY(angle);
}
/** MatrixRotateZ(params: float angle, void * _out -> void) */
void sp_MatrixRotateZ(float angle, void * _out) {
  ((sp_Matrix*)_out)->v = MatrixRotateZ(angle);
}
/** MatrixRotateXYZ(params: void * angle, void * _out -> void) */
static void sp_MatrixRotateXYZ(void * angle, void * _out) {
  ((sp_Matrix*)_out)->v = MatrixRotateXYZ(((sp_Vector3*)angle)->v);
}
/** MatrixRotateZYX(params: void * angle, void * _out -> void) */
void sp_MatrixRotateZYX(void * angle, void * _out) {
  ((sp_Matrix*)_out)->v = MatrixRotateZYX(((sp_Vector3*)angle)->v);
}
/** MatrixScale(params: float x, float y, float z, void * _out -> void) */
void sp_MatrixScale(float x, float y, float z, void * _out) {
  ((sp_Matrix*)_out)->v = MatrixScale(x, y, z);
}
/** MatrixFrustum(params: double left, double right, double bottom, double top, double nearPlane, double farPlane, void * _out -> void) */
void sp_MatrixFrustum(double left, double right, double bottom, double top, double nearPlane, double farPlane, void * _out) {
  ((sp_Matrix*)_out)->v = MatrixFrustum(left, right, bottom, top, nearPlane, farPlane);
}
/** MatrixPerspective(params: double fovY, double aspect, double nearPlane, double farPlane, void * _out -> void) */
void sp_MatrixPerspective(double fovY, double aspect, double nearPlane, double farPlane, void * _out) {
  ((sp_Matrix*)_out)->v = MatrixPerspective(fovY, aspect, nearPlane, farPlane);
}
/** MatrixOrtho(params: double left, double right, double bottom, double top, double nearPlane, double farPlane, void * _out -> void) */
void sp_MatrixOrtho(double left, double right, double bottom, double top, double nearPlane, double farPlane, void * _out) {
  ((sp_Matrix*)_out)->v = MatrixOrtho(left, right, bottom, top, nearPlane, farPlane);
}
/** MatrixLookAt(params: void * eye, void * target, void * up, void * _out -> void) */
void sp_MatrixLookAt(void * eye, void * target, void * up, void * _out) {
  ((sp_Matrix*)_out)->v = MatrixLookAt(((sp_Vector3*)eye)->v, ((sp_Vector3*)target)->v, ((sp_Vector3*)up)->v);
}
/** MatrixToFloatV(params: void * mat, float * _out -> void *) */
void * sp_MatrixToFloatV(void * mat, float * _out) {
  float16 *r = (float16 *)malloc(sizeof(float16));
  *r = MatrixToFloatV(((sp_Matrix*)mat)->v);
  return r;
}
/** QuaternionAdd(params: void * q1, void * q2, void * _out -> void) */
void sp_QuaternionAdd(void * q1, void * q2, void * _out) {
  ((sp_Quaternion*)_out)->v = QuaternionAdd(((sp_Quaternion*)q1)->v, ((sp_Quaternion*)q2)->v);
}
/** QuaternionAddValue(params: void * q, float add, void * _out -> void) */
void sp_QuaternionAddValue(void * q, float add, void * _out) {
  ((sp_Quaternion*)_out)->v = QuaternionAddValue(((sp_Quaternion*)q)->v, add);
}
/** QuaternionSubtract(params: void * q1, void * q2, void * _out -> void) */
void sp_QuaternionSubtract(void * q1, void * q2, void * _out) {
  ((sp_Quaternion*)_out)->v = QuaternionSubtract(((sp_Quaternion*)q1)->v, ((sp_Quaternion*)q2)->v);
}
/** QuaternionSubtractValue(params: void * q, float sub, void * _out -> void) */
void sp_QuaternionSubtractValue(void * q, float sub, void * _out) {
  ((sp_Quaternion*)_out)->v = QuaternionSubtractValue(((sp_Quaternion*)q)->v, sub);
}
/** QuaternionIdentity(params: void * _out -> void) */
void sp_QuaternionIdentity(void * _out) {
  ((sp_Quaternion*)_out)->v = QuaternionIdentity();
}
/** QuaternionLength(params: void * q -> float) */
float sp_QuaternionLength(void * q) {
  return QuaternionLength(((sp_Quaternion*)q)->v);
}
/** QuaternionNormalize(params: void * q, void * _out -> void) */
void sp_QuaternionNormalize(void * q, void * _out) {
  ((sp_Quaternion*)_out)->v = QuaternionNormalize(((sp_Quaternion*)q)->v);
}
/** QuaternionInvert(params: void * q, void * _out -> void) */
void sp_QuaternionInvert(void * q, void * _out) {
  ((sp_Quaternion*)_out)->v = QuaternionInvert(((sp_Quaternion*)q)->v);
}
/** QuaternionMultiply(params: void * q1, void * q2, void * _out -> void) */
void sp_QuaternionMultiply(void * q1, void * q2, void * _out) {
  ((sp_Quaternion*)_out)->v = QuaternionMultiply(((sp_Quaternion*)q1)->v, ((sp_Quaternion*)q2)->v);
}
/** QuaternionScale(params: void * q, float mul, void * _out -> void) */
void sp_QuaternionScale(void * q, float mul, void * _out) {
  ((sp_Quaternion*)_out)->v = QuaternionScale(((sp_Quaternion*)q)->v, mul);
}
/** QuaternionDivide(params: void * q1, void * q2, void * _out -> void) */
void sp_QuaternionDivide(void * q1, void * q2, void * _out) {
  ((sp_Quaternion*)_out)->v = QuaternionDivide(((sp_Quaternion*)q1)->v, ((sp_Quaternion*)q2)->v);
}
/** QuaternionLerp(params: void * q1, void * q2, float amount, void * _out -> void) */
void sp_QuaternionLerp(void * q1, void * q2, float amount, void * _out) {
  ((sp_Quaternion*)_out)->v = QuaternionLerp(((sp_Quaternion*)q1)->v, ((sp_Quaternion*)q2)->v, amount);
}
/** QuaternionNlerp(params: void * q1, void * q2, float amount, void * _out -> void) */
void sp_QuaternionNlerp(void * q1, void * q2, float amount, void * _out) {
  ((sp_Quaternion*)_out)->v = QuaternionNlerp(((sp_Quaternion*)q1)->v, ((sp_Quaternion*)q2)->v, amount);
}
/** QuaternionSlerp(params: void * q1, void * q2, float amount, void * _out -> void) */
void sp_QuaternionSlerp(void * q1, void * q2, float amount, void * _out) {
  ((sp_Quaternion*)_out)->v = QuaternionSlerp(((sp_Quaternion*)q1)->v, ((sp_Quaternion*)q2)->v, amount);
}
/** QuaternionCubicHermiteSpline(params: void * q1, void * outTangent1, void * q2, void * inTangent2, float t, void * _out -> void) */
void sp_QuaternionCubicHermiteSpline(void * q1, void * outTangent1, void * q2, void * inTangent2, float t, void * _out) {
  ((sp_Quaternion*)_out)->v = QuaternionCubicHermiteSpline(((sp_Quaternion*)q1)->v, ((sp_Quaternion*)outTangent1)->v, ((sp_Quaternion*)q2)->v, ((sp_Quaternion*)inTangent2)->v, t);
}
/** QuaternionFromVector3ToVector3(params: void * from, void * to, void * _out -> void) */
void sp_QuaternionFromVector3ToVector3(void * from, void * to, void * _out) {
  ((sp_Quaternion*)_out)->v = QuaternionFromVector3ToVector3(((sp_Vector3*)from)->v, ((sp_Vector3*)to)->v);
}
/** QuaternionFromMatrix(params: void * mat, void * _out -> void) */
void sp_QuaternionFromMatrix(void * mat, void * _out) {
  ((sp_Quaternion*)_out)->v = QuaternionFromMatrix(((sp_Matrix*)mat)->v);
}
/** QuaternionToMatrix(params: void * q, void * _out -> void) */
void sp_QuaternionToMatrix(void * q, void * _out) {
  ((sp_Matrix*)_out)->v = QuaternionToMatrix(((sp_Quaternion*)q)->v);
}
/** QuaternionFromAxisAngle(params: void * axis, float angle, void * _out -> void) */
void sp_QuaternionFromAxisAngle(void * axis, float angle, void * _out) {
  ((sp_Quaternion*)_out)->v = QuaternionFromAxisAngle(((sp_Vector3*)axis)->v, angle);
}
/** QuaternionToAxisAngle(params: void * q, void * outAxis, void * outAngle -> void) */
void sp_QuaternionToAxisAngle(void * q, void * outAxis, void * outAngle) {
  QuaternionToAxisAngle(((sp_Quaternion*)q)->v, &((sp_Vector3*)outAxis)->v, outAngle);
}
/** QuaternionFromEuler(params: float pitch, float yaw, float roll, void * _out -> void) */
void sp_QuaternionFromEuler(float pitch, float yaw, float roll, void * _out) {
  ((sp_Quaternion*)_out)->v = QuaternionFromEuler(pitch, yaw, roll);
}
/** QuaternionToEuler(params: void * q, void * _out -> void) */
void sp_QuaternionToEuler(void * q, void * _out) {
  ((sp_Vector3*)_out)->v = QuaternionToEuler(((sp_Quaternion*)q)->v);
}
/** QuaternionTransform(params: void * q, void * mat, void * _out -> void) */
void sp_QuaternionTransform(void * q, void * mat, void * _out) {
  ((sp_Quaternion*)_out)->v = QuaternionTransform(((sp_Quaternion*)q)->v, ((sp_Matrix*)mat)->v);
}
/** QuaternionEquals(params: void * p, void * q -> int) */
int sp_QuaternionEquals(void * p, void * q) {
  return QuaternionEquals(((sp_Quaternion*)p)->v, ((sp_Quaternion*)q)->v);
}
/** MatrixCompose(params: void * translation, void * rotation, void * scale, void * _out -> void) */
void sp_MatrixCompose(void * translation, void * rotation, void * scale, void * _out) {
  ((sp_Matrix*)_out)->v = MatrixCompose(((sp_Vector3*)translation)->v, ((sp_Quaternion*)rotation)->v, ((sp_Vector3*)scale)->v);
}
/** MatrixDecompose(params: void * mat, void * translation, void * rotation, void * scale -> void) */
void sp_MatrixDecompose(void * mat, void * translation, void * rotation, void * scale) {
  MatrixDecompose(((sp_Matrix*)mat)->v, &((sp_Vector3*)translation)->v, &((sp_Quaternion*)rotation)->v, &((sp_Vector3*)scale)->v);
}

/* Boid helper: write the 16 floats of QuaternionToMatrix(QuaternionFromVector3ToVector3(+z, dir))
 * into a caller-provided float array. Also feed the same matrix to rlMultMatrixf. */
void sp_QuaternionToMatrix3(void *dir, float *out) {
  Vector3 z = (Vector3){ 0.0f, 0.0f, 1.0f };
  Quaternion q = QuaternionFromVector3ToVector3(z, ((sp_Vector3 *)dir)->v);
  Matrix m = QuaternionToMatrix(q);
  float *f = (float *)&m;
  for (int i = 0; i < 16; i++) out[i] = f[i];
}
void sp_rlMultMatrixfFloats(float *floats, int index) {
  rlMultMatrixf(floats + index * 16);
}

/* Boids helper: rotate the model matrix so +z points along dir, then feed it
 * to rlMultMatrixf (single call from Ruby). */
void sp_rlMultMatrixfForDir(void *dir) {
  Vector3 z = (Vector3){ 0.0f, 0.0f, 1.0f };
  Quaternion q = QuaternionFromVector3ToVector3(z, ((sp_Vector3 *)dir)->v);
  Matrix m = QuaternionToMatrix(q);
  rlMultMatrixf((float *)&m);
}
