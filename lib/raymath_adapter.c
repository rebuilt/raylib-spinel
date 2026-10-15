#include <raylib.h>
#include <rlgl.h>
#include <raymath.h>
#include <stdio.h>
#include <stdlib.h>
#include "spinel/runtime.h"

/* --- P2 views: read the Vector2/Vector3 payload through the view pointer.
 * `p == NULL` for owned objects (payload in `v`); `p != NULL` for views built
 * by rl_VectorN_view, where the payload lives in the owner's C struct. */
#define RL_V2(o) (((rl_Vector2 *)(o))->p ? ((rl_Vector2 *)(o))->p : &((rl_Vector2 *)(o))->v)
#define RL_V3(o) (((rl_Vector3 *)(o))->p ? ((rl_Vector3 *)(o))->p : &((rl_Vector3 *)(o))->v)
#define RL_V4(o) (((rl_Vector4 *)(o))->p ? ((rl_Vector4 *)(o))->p : &((rl_Vector4 *)(o))->v)


/* raymath_adapter.c — rl_ shims for Spinel AOT */

/* Generated shims (tools/gen_raymath.py) */

/* ================================================================
 * Generated shims (tools/gen_raymath.py). Same conventions as the
 * hand-written shims above; keep in sync by re-running the generator.
 * ================================================================ */


/* rl_Vector2 — GC-embedded Vector2 (see raymath_ffi.rb) */typedef struct rl_Vector2_s {
  sp_int cls_id;
  Vector2 *p;     /* NULL: owned (payload in v); non-NULL: a view */
  sp_RbVal owner;  /* view: GC-marked reference to the owner */
  Vector2 v;
} rl_Vector2;
static void rl_Vector2_scan(void *p) {
  rl_Vector2 *s = (rl_Vector2 *)p;
  if (s->p) sp_mark_rbval(s->owner);
}
static rl_Vector2 *rl_Vector2_new(sp_int cls_id) {
  rl_Vector2 *self = (rl_Vector2 *)sp_gc_alloc(sizeof(rl_Vector2), NULL, rl_Vector2_scan);
  self->cls_id = cls_id;
  self->p = NULL;
  self->v = (Vector2){ 0 };
  return self;
}
static double rl_Vector2_x(rl_Vector2 *self) {
  return (double)RL_V2(self)->x;
}
static double rl_Vector2_set_x(rl_Vector2 *self, double x) {
  RL_V2(self)->x = (float)x;
  return x;
}
static double rl_Vector2_y(rl_Vector2 *self) {
  return (double)RL_V2(self)->y;
}
static double rl_Vector2_set_y(rl_Vector2 *self, double y) {
  RL_V2(self)->y = (float)y;
  return y;
}

/* rl_Vector3 — GC-embedded Vector3 (see raymath_ffi.rb) */typedef struct rl_Vector3_s {
  sp_int cls_id;
  Vector3 *p;     /* NULL: owned (payload in v); non-NULL: a view */
  sp_RbVal owner;  /* view: GC-marked reference to the owner */
  Vector3 v;
} rl_Vector3;
static void rl_Vector3_scan(void *p) {
  rl_Vector3 *s = (rl_Vector3 *)p;
  if (s->p) sp_mark_rbval(s->owner);
}
static rl_Vector3 *rl_Vector3_new(sp_int cls_id) {
  rl_Vector3 *self = (rl_Vector3 *)sp_gc_alloc(sizeof(rl_Vector3), NULL, rl_Vector3_scan);
  self->cls_id = cls_id;
  self->p = NULL;
  self->v = (Vector3){ 0 };
  return self;
}
static double rl_Vector3_x(rl_Vector3 *self) {
  return (double)RL_V3(self)->x;
}
static double rl_Vector3_y(rl_Vector3 *self) {
  return (double)RL_V3(self)->y;
}
static double rl_Vector3_z(rl_Vector3 *self) {
  return (double)RL_V3(self)->z;
}

/* rl_Vector4 — GC-embedded Vector4 (see raymath_ffi.rb) */typedef struct rl_Vector4_s {
  sp_int cls_id;
  Vector4 *p;     /* NULL: owned (payload in v); non-NULL: a view */
  sp_RbVal owner;  /* view: GC-marked reference to the owner */
  Vector4 v;
} rl_Vector4;
static void rl_Vector4_scan(void *p) {
  rl_Vector4 *s = (rl_Vector4 *)p;
  if (s->p) sp_mark_rbval(s->owner);
}
static rl_Vector4 *rl_Vector4_new(sp_int cls_id) {
  rl_Vector4 *self = (rl_Vector4 *)sp_gc_alloc(sizeof(rl_Vector4), NULL, rl_Vector4_scan);
  self->cls_id = cls_id;
  self->p = NULL;
  self->v = (Vector4){ 0 };
  return self;
}
static double rl_Vector4_x(rl_Vector4 *self) {
  return (double)RL_V4(self)->x;
}
static double rl_Vector4_set_x(rl_Vector4 *self, double x) {
  RL_V4(self)->x = (float)x;
  return x;
}
static double rl_Vector4_y(rl_Vector4 *self) {
  return (double)RL_V4(self)->y;
}
static double rl_Vector4_set_y(rl_Vector4 *self, double y) {
  RL_V4(self)->y = (float)y;
  return y;
}
static double rl_Vector4_z(rl_Vector4 *self) {
  return (double)RL_V4(self)->z;
}
static double rl_Vector4_set_z(rl_Vector4 *self, double z) {
  RL_V4(self)->z = (float)z;
  return z;
}
static double rl_Vector4_w(rl_Vector4 *self) {
  return (double)RL_V4(self)->w;
}
static double rl_Vector4_set_w(rl_Vector4 *self, double w) {
  RL_V4(self)->w = (float)w;
  return w;
}

/* rl_Quaternion — GC-embedded Quaternion (see raymath_ffi.rb) */typedef struct rl_Quaternion_s {
  sp_int cls_id;
  Quaternion v;
} rl_Quaternion;
static void rl_Quaternion_scan(void *p) { (void)p; }
rl_Quaternion *rl_Quaternion_new(sp_int cls_id) {
  rl_Quaternion *self = (rl_Quaternion *)sp_gc_alloc(sizeof(rl_Quaternion), NULL, rl_Quaternion_scan);
  self->cls_id = cls_id;
  self->v = (Quaternion){ 0 };
  return self;
}

/* rl_Matrix — GC-embedded Matrix (see raymath_ffi.rb) */typedef struct rl_Matrix_s {
  sp_int cls_id;
  Matrix v;
} rl_Matrix;
static void rl_Matrix_scan(void *p) { (void)p; }
static rl_Matrix *rl_Matrix_new(sp_int cls_id) {
  rl_Matrix *self = (rl_Matrix *)sp_gc_alloc(sizeof(rl_Matrix), NULL, rl_Matrix_scan);
  self->cls_id = cls_id;
  self->v = (Matrix){ 0 };
  return self;
}
static double rl_Matrix_m0(rl_Matrix *self) {
  return (double)self->v.m0;
}
static double rl_Matrix_set_m0(rl_Matrix *self, double m0) {
  self->v.m0 = (float)m0;
  return m0;
}
static double rl_Matrix_m4(rl_Matrix *self) {
  return (double)self->v.m4;
}
static double rl_Matrix_set_m4(rl_Matrix *self, double m4) {
  self->v.m4 = (float)m4;
  return m4;
}
static double rl_Matrix_m8(rl_Matrix *self) {
  return (double)self->v.m8;
}
static double rl_Matrix_set_m8(rl_Matrix *self, double m8) {
  self->v.m8 = (float)m8;
  return m8;
}
static double rl_Matrix_m12(rl_Matrix *self) {
  return (double)self->v.m12;
}
static double rl_Matrix_set_m12(rl_Matrix *self, double m12) {
  self->v.m12 = (float)m12;
  return m12;
}
static double rl_Matrix_m1(rl_Matrix *self) {
  return (double)self->v.m1;
}
static double rl_Matrix_set_m1(rl_Matrix *self, double m1) {
  self->v.m1 = (float)m1;
  return m1;
}
static double rl_Matrix_m5(rl_Matrix *self) {
  return (double)self->v.m5;
}
static double rl_Matrix_set_m5(rl_Matrix *self, double m5) {
  self->v.m5 = (float)m5;
  return m5;
}
static double rl_Matrix_m9(rl_Matrix *self) {
  return (double)self->v.m9;
}
static double rl_Matrix_set_m9(rl_Matrix *self, double m9) {
  self->v.m9 = (float)m9;
  return m9;
}
static double rl_Matrix_m13(rl_Matrix *self) {
  return (double)self->v.m13;
}
static double rl_Matrix_set_m13(rl_Matrix *self, double m13) {
  self->v.m13 = (float)m13;
  return m13;
}
static double rl_Matrix_m2(rl_Matrix *self) {
  return (double)self->v.m2;
}
static double rl_Matrix_set_m2(rl_Matrix *self, double m2) {
  self->v.m2 = (float)m2;
  return m2;
}
static double rl_Matrix_m6(rl_Matrix *self) {
  return (double)self->v.m6;
}
static double rl_Matrix_set_m6(rl_Matrix *self, double m6) {
  self->v.m6 = (float)m6;
  return m6;
}
static double rl_Matrix_m10(rl_Matrix *self) {
  return (double)self->v.m10;
}
static double rl_Matrix_set_m10(rl_Matrix *self, double m10) {
  self->v.m10 = (float)m10;
  return m10;
}
static double rl_Matrix_m14(rl_Matrix *self) {
  return (double)self->v.m14;
}
static double rl_Matrix_set_m14(rl_Matrix *self, double m14) {
  self->v.m14 = (float)m14;
  return m14;
}
static double rl_Matrix_m3(rl_Matrix *self) {
  return (double)self->v.m3;
}
static double rl_Matrix_set_m3(rl_Matrix *self, double m3) {
  self->v.m3 = (float)m3;
  return m3;
}
static double rl_Matrix_m7(rl_Matrix *self) {
  return (double)self->v.m7;
}
static double rl_Matrix_set_m7(rl_Matrix *self, double m7) {
  self->v.m7 = (float)m7;
  return m7;
}
static double rl_Matrix_m11(rl_Matrix *self) {
  return (double)self->v.m11;
}
static double rl_Matrix_set_m11(rl_Matrix *self, double m11) {
  self->v.m11 = (float)m11;
  return m11;
}
static double rl_Matrix_m15(rl_Matrix *self) {
  return (double)self->v.m15;
}
static double rl_Matrix_set_m15(rl_Matrix *self, double m15) {
  self->v.m15 = (float)m15;
  return m15;
}

/* rl_Color — GC-embedded Color (see raymath_ffi.rb) */typedef struct rl_Color_s {
  sp_int cls_id;
  Color c;
} rl_Color;
static void rl_Color_scan(void *p) { (void)p; }
static rl_Color *rl_Color_new(sp_int cls_id) {
  rl_Color *self = (rl_Color *)sp_gc_alloc(sizeof(rl_Color), NULL, rl_Color_scan);
  self->cls_id = cls_id;
  self->c = (Color){ 0 };
  return self;
}

/* ---- generated shims ---- */
/** Vector2Zero(params: void * _out -> void) */
void rl_Vector2Zero(void * _out) {
  *RL_V2(_out) = Vector2Zero();
}
/** Vector2One(params: void * _out -> void) */
void rl_Vector2One(void * _out) {
  *RL_V2(_out) = Vector2One();
}
/** Vector2Add(params: void * v1, void * v2, void * _out -> void) */
static void rl_Vector2Add(void * v1, void * v2, void * _out) {
  *RL_V2(_out) = Vector2Add(*RL_V2(v1), *RL_V2(v2));
}
/** Vector2AddValue(params: void * v, float add, void * _out -> void) */
void rl_Vector2AddValue(void * v, float add, void * _out) {
  *RL_V2(_out) = Vector2AddValue(*RL_V2(v), add);
}
/** Vector2Subtract(params: void * v1, void * v2, void * _out -> void) */
void rl_Vector2Subtract(void * v1, void * v2, void * _out) {
  *RL_V2(_out) = Vector2Subtract(*RL_V2(v1), *RL_V2(v2));
}
/** Vector2SubtractValue(params: void * v, float sub, void * _out -> void) */
void rl_Vector2SubtractValue(void * v, float sub, void * _out) {
  *RL_V2(_out) = Vector2SubtractValue(*RL_V2(v), sub);
}
/** Vector2Length(params: void * v -> float) */
static float rl_Vector2Length(void * v) {
  return Vector2Length(*RL_V2(v));
}
/** Vector2LengthSqr(params: void * v -> float) */
float rl_Vector2LengthSqr(void * v) {
  return Vector2LengthSqr(*RL_V2(v));
}
/** Vector2DotProduct(params: void * v1, void * v2 -> float) */
float rl_Vector2DotProduct(void * v1, void * v2) {
  return Vector2DotProduct(*RL_V2(v1), *RL_V2(v2));
}
/** Vector2CrossProduct(params: void * v1, void * v2 -> float) */
float rl_Vector2CrossProduct(void * v1, void * v2) {
  return Vector2CrossProduct(*RL_V2(v1), *RL_V2(v2));
}
/** Vector2Distance(params: void * v1, void * v2 -> float) */
float rl_Vector2Distance(void * v1, void * v2) {
  return Vector2Distance(*RL_V2(v1), *RL_V2(v2));
}
/** Vector2DistanceSqr(params: void * v1, void * v2 -> float) */
float rl_Vector2DistanceSqr(void * v1, void * v2) {
  return Vector2DistanceSqr(*RL_V2(v1), *RL_V2(v2));
}
/** Vector2Angle(params: void * v1, void * v2 -> float) */
static float rl_Vector2Angle(void * v1, void * v2) {
  return Vector2Angle(*RL_V2(v1), *RL_V2(v2));
}
/** Vector2LineAngle(params: void * start, void * end -> float) */
float rl_Vector2LineAngle(void * start, void * end) {
  return Vector2LineAngle(*RL_V2(start), *RL_V2(end));
}
/** Vector2Scale(params: void * v, float scale, void * _out -> void) */
static void rl_Vector2Scale(void * v, float scale, void * _out) {
  *RL_V2(_out) = Vector2Scale(*RL_V2(v), scale);
}
/** Vector2Multiply(params: void * v1, void * v2, void * _out -> void) */
void rl_Vector2Multiply(void * v1, void * v2, void * _out) {
  *RL_V2(_out) = Vector2Multiply(*RL_V2(v1), *RL_V2(v2));
}
/** Vector2Negate(params: void * v, void * _out -> void) */
void rl_Vector2Negate(void * v, void * _out) {
  *RL_V2(_out) = Vector2Negate(*RL_V2(v));
}
/** Vector2Divide(params: void * v1, void * v2, void * _out -> void) */
void rl_Vector2Divide(void * v1, void * v2, void * _out) {
  *RL_V2(_out) = Vector2Divide(*RL_V2(v1), *RL_V2(v2));
}
/** Vector2Normalize(params: void * v, void * _out -> void) */
static void rl_Vector2Normalize(void * v, void * _out) {
  *RL_V2(_out) = Vector2Normalize(*RL_V2(v));
}
/** Vector2Transform(params: void * v, void * mat, void * _out -> void) */
void rl_Vector2Transform(void * v, void * mat, void * _out) {
  *RL_V2(_out) = Vector2Transform(*RL_V2(v), ((rl_Matrix*)mat)->v);
}
/** Vector2Lerp(params: void * v1, void * v2, float amount, void * _out -> void) */
static void rl_Vector2Lerp(void * v1, void * v2, float amount, void * _out) {
  *RL_V2(_out) = Vector2Lerp(*RL_V2(v1), *RL_V2(v2), amount);
}
/** Vector2Reflect(params: void * v, void * normal, void * _out -> void) */
void rl_Vector2Reflect(void * v, void * normal, void * _out) {
  *RL_V2(_out) = Vector2Reflect(*RL_V2(v), *RL_V2(normal));
}
/** Vector2Min(params: void * v1, void * v2, void * _out -> void) */
void rl_Vector2Min(void * v1, void * v2, void * _out) {
  *RL_V2(_out) = Vector2Min(*RL_V2(v1), *RL_V2(v2));
}
/** Vector2Max(params: void * v1, void * v2, void * _out -> void) */
void rl_Vector2Max(void * v1, void * v2, void * _out) {
  *RL_V2(_out) = Vector2Max(*RL_V2(v1), *RL_V2(v2));
}
/** Vector2Rotate(params: void * v, float angle, void * _out -> void) */
static void rl_Vector2Rotate(void * v, float angle, void * _out) {
  *RL_V2(_out) = Vector2Rotate(*RL_V2(v), angle);
}
/** Vector2MoveTowards(params: void * v, void * target, float maxDistance, void * _out -> void) */
void rl_Vector2MoveTowards(void * v, void * target, float maxDistance, void * _out) {
  *RL_V2(_out) = Vector2MoveTowards(*RL_V2(v), *RL_V2(target), maxDistance);
}
/** Vector2Invert(params: void * v, void * _out -> void) */
void rl_Vector2Invert(void * v, void * _out) {
  *RL_V2(_out) = Vector2Invert(*RL_V2(v));
}
/** Vector2Clamp(params: void * v, void * min, void * max, void * _out -> void) */
void rl_Vector2Clamp(void * v, void * min, void * max, void * _out) {
  *RL_V2(_out) = Vector2Clamp(*RL_V2(v), *RL_V2(min), *RL_V2(max));
}
/** Vector2ClampValue(params: void * v, float min, float max, void * _out -> void) */
void rl_Vector2ClampValue(void * v, float min, float max, void * _out) {
  *RL_V2(_out) = Vector2ClampValue(*RL_V2(v), min, max);
}
/** Vector2Equals(params: void * p, void * q -> int) */
int rl_Vector2Equals(void * p, void * q) {
  return Vector2Equals(*RL_V2(p), *RL_V2(q));
}
/** Vector2Refract(params: void * v, void * n, float r, void * _out -> void) */
void rl_Vector2Refract(void * v, void * n, float r, void * _out) {
  *RL_V2(_out) = Vector2Refract(*RL_V2(v), *RL_V2(n), r);
}
/** Vector3Zero(params: void * _out -> void) */
void rl_Vector3Zero(void * _out) {
  *RL_V3(_out) = Vector3Zero();
}
/** Vector3One(params: void * _out -> void) */
void rl_Vector3One(void * _out) {
  *RL_V3(_out) = Vector3One();
}
/** Vector3Add(params: void * v1, void * v2, void * _out -> void) */
void rl_Vector3Add(void * v1, void * v2, void * _out) {
  *RL_V3(_out) = Vector3Add(*RL_V3(v1), *RL_V3(v2));
}
/** Vector3AddValue(params: void * v, float add, void * _out -> void) */
void rl_Vector3AddValue(void * v, float add, void * _out) {
  *RL_V3(_out) = Vector3AddValue(*RL_V3(v), add);
}
/** Vector3Subtract(params: void * v1, void * v2, void * _out -> void) */
void rl_Vector3Subtract(void * v1, void * v2, void * _out) {
  *RL_V3(_out) = Vector3Subtract(*RL_V3(v1), *RL_V3(v2));
}
/** Vector3SubtractValue(params: void * v, float sub, void * _out -> void) */
void rl_Vector3SubtractValue(void * v, float sub, void * _out) {
  *RL_V3(_out) = Vector3SubtractValue(*RL_V3(v), sub);
}
/** Vector3Scale(params: void * v, float scalar, void * _out -> void) */
void rl_Vector3Scale(void * v, float scalar, void * _out) {
  *RL_V3(_out) = Vector3Scale(*RL_V3(v), scalar);
}
/** Vector3Multiply(params: void * v1, void * v2, void * _out -> void) */
void rl_Vector3Multiply(void * v1, void * v2, void * _out) {
  *RL_V3(_out) = Vector3Multiply(*RL_V3(v1), *RL_V3(v2));
}
/** Vector3CrossProduct(params: void * v1, void * v2, void * _out -> void) */
void rl_Vector3CrossProduct(void * v1, void * v2, void * _out) {
  *RL_V3(_out) = Vector3CrossProduct(*RL_V3(v1), *RL_V3(v2));
}
/** Vector3Perpendicular(params: void * v, void * _out -> void) */
void rl_Vector3Perpendicular(void * v, void * _out) {
  *RL_V3(_out) = Vector3Perpendicular(*RL_V3(v));
}
/** Vector3Length(params: void * v -> float) */
float rl_Vector3Length(void * v) {
  return Vector3Length(*RL_V3(v));
}
/** Vector3LengthSqr(params: void * v -> float) */
float rl_Vector3LengthSqr(void * v) {
  return Vector3LengthSqr(*RL_V3(v));
}
/** Vector3DotProduct(params: void * v1, void * v2 -> float) */
float rl_Vector3DotProduct(void * v1, void * v2) {
  return Vector3DotProduct(*RL_V3(v1), *RL_V3(v2));
}
/** Vector3Distance(params: void * v1, void * v2 -> float) */
float rl_Vector3Distance(void * v1, void * v2) {
  return Vector3Distance(*RL_V3(v1), *RL_V3(v2));
}
/** Vector3DistanceSqr(params: void * v1, void * v2 -> float) */
float rl_Vector3DistanceSqr(void * v1, void * v2) {
  return Vector3DistanceSqr(*RL_V3(v1), *RL_V3(v2));
}
/** Vector3Angle(params: void * v1, void * v2 -> float) */
float rl_Vector3Angle(void * v1, void * v2) {
  return Vector3Angle(*RL_V3(v1), *RL_V3(v2));
}
/** Vector3Negate(params: void * v, void * _out -> void) */
void rl_Vector3Negate(void * v, void * _out) {
  *RL_V3(_out) = Vector3Negate(*RL_V3(v));
}
/** Vector3Divide(params: void * v1, void * v2, void * _out -> void) */
void rl_Vector3Divide(void * v1, void * v2, void * _out) {
  *RL_V3(_out) = Vector3Divide(*RL_V3(v1), *RL_V3(v2));
}
/** Vector3Normalize(params: void * v, void * _out -> void) */
void rl_Vector3Normalize(void * v, void * _out) {
  *RL_V3(_out) = Vector3Normalize(*RL_V3(v));
}
/** Vector3Project(params: void * v1, void * v2, void * _out -> void) */
void rl_Vector3Project(void * v1, void * v2, void * _out) {
  *RL_V3(_out) = Vector3Project(*RL_V3(v1), *RL_V3(v2));
}
/** Vector3Reject(params: void * v1, void * v2, void * _out -> void) */
void rl_Vector3Reject(void * v1, void * v2, void * _out) {
  *RL_V3(_out) = Vector3Reject(*RL_V3(v1), *RL_V3(v2));
}
/** Vector3OrthoNormalize(params: void * v1, void * v2 -> void) */
void rl_Vector3OrthoNormalize(void * v1, void * v2) {
  Vector3OrthoNormalize(&*RL_V3(v1), &*RL_V3(v2));
}
/** Vector3Transform(params: void * v, void * mat, void * _out -> void) */
void rl_Vector3Transform(void * v, void * mat, void * _out) {
  *RL_V3(_out) = Vector3Transform(*RL_V3(v), ((rl_Matrix*)mat)->v);
}
/** Vector3RotateByQuaternion(params: void * v, void * q, void * _out -> void) */
void rl_Vector3RotateByQuaternion(void * v, void * q, void * _out) {
  *RL_V3(_out) = Vector3RotateByQuaternion(*RL_V3(v), ((rl_Quaternion*)q)->v);
}
/** Vector3RotateByAxisAngle(params: void * v, void * axis, float angle, void * _out -> void) */
void rl_Vector3RotateByAxisAngle(void * v, void * axis, float angle, void * _out) {
  *RL_V3(_out) = Vector3RotateByAxisAngle(*RL_V3(v), *RL_V3(axis), angle);
}
/** Vector3MoveTowards(params: void * v, void * target, float maxDistance, void * _out -> void) */
void rl_Vector3MoveTowards(void * v, void * target, float maxDistance, void * _out) {
  *RL_V3(_out) = Vector3MoveTowards(*RL_V3(v), *RL_V3(target), maxDistance);
}
/** Vector3Lerp(params: void * v1, void * v2, float amount, void * _out -> void) */
void rl_Vector3Lerp(void * v1, void * v2, float amount, void * _out) {
  *RL_V3(_out) = Vector3Lerp(*RL_V3(v1), *RL_V3(v2), amount);
}
/** Vector3CubicHermite(params: void * v1, void * tangent1, void * v2, void * tangent2, float amount, void * _out -> void) */
void rl_Vector3CubicHermite(void * v1, void * tangent1, void * v2, void * tangent2, float amount, void * _out) {
  *RL_V3(_out) = Vector3CubicHermite(*RL_V3(v1), *RL_V3(tangent1), *RL_V3(v2), *RL_V3(tangent2), amount);
}
/** Vector3Reflect(params: void * v, void * normal, void * _out -> void) */
void rl_Vector3Reflect(void * v, void * normal, void * _out) {
  *RL_V3(_out) = Vector3Reflect(*RL_V3(v), *RL_V3(normal));
}
/** Vector3Min(params: void * v1, void * v2, void * _out -> void) */
void rl_Vector3Min(void * v1, void * v2, void * _out) {
  *RL_V3(_out) = Vector3Min(*RL_V3(v1), *RL_V3(v2));
}
/** Vector3Max(params: void * v1, void * v2, void * _out -> void) */
void rl_Vector3Max(void * v1, void * v2, void * _out) {
  *RL_V3(_out) = Vector3Max(*RL_V3(v1), *RL_V3(v2));
}
/** Vector3Barycenter(params: void * p, void * a, void * b, void * c, void * _out -> void) */
void rl_Vector3Barycenter(void * p, void * a, void * b, void * c, void * _out) {
  *RL_V3(_out) = Vector3Barycenter(*RL_V3(p), *RL_V3(a), *RL_V3(b), *RL_V3(c));
}
/** Vector3Unproject(params: void * source, void * projection, void * view, void * _out -> void) */
void rl_Vector3Unproject(void * source, void * projection, void * view, void * _out) {
  *RL_V3(_out) = Vector3Unproject(*RL_V3(source), ((rl_Matrix*)projection)->v, ((rl_Matrix*)view)->v);
}
/** Vector3ToFloatV(params: void * v, float * _out -> void *) */
void * rl_Vector3ToFloatV(void * v, float * _out) {
  float3 *r = (float3 *)malloc(sizeof(float3));
  *r = Vector3ToFloatV(*RL_V3(v));
  return r;
}
/** Vector3Invert(params: void * v, void * _out -> void) */
void rl_Vector3Invert(void * v, void * _out) {
  *RL_V3(_out) = Vector3Invert(*RL_V3(v));
}
/** Vector3Clamp(params: void * v, void * min, void * max, void * _out -> void) */
void rl_Vector3Clamp(void * v, void * min, void * max, void * _out) {
  *RL_V3(_out) = Vector3Clamp(*RL_V3(v), *RL_V3(min), *RL_V3(max));
}
/** Vector3ClampValue(params: void * v, float min, float max, void * _out -> void) */
void rl_Vector3ClampValue(void * v, float min, float max, void * _out) {
  *RL_V3(_out) = Vector3ClampValue(*RL_V3(v), min, max);
}
/** Vector3Equals(params: void * p, void * q -> int) */
int rl_Vector3Equals(void * p, void * q) {
  return Vector3Equals(*RL_V3(p), *RL_V3(q));
}
/** Vector3Refract(params: void * v, void * n, float r, void * _out -> void) */
void rl_Vector3Refract(void * v, void * n, float r, void * _out) {
  *RL_V3(_out) = Vector3Refract(*RL_V3(v), *RL_V3(n), r);
}
/** Vector4Zero(params: void * _out -> void) */
void rl_Vector4Zero(void * _out) {
  *RL_V4(_out) = Vector4Zero();
}
/** Vector4One(params: void * _out -> void) */
void rl_Vector4One(void * _out) {
  *RL_V4(_out) = Vector4One();
}
/** Vector4Add(params: void * v1, void * v2, void * _out -> void) */
void rl_Vector4Add(void * v1, void * v2, void * _out) {
  *RL_V4(_out) = Vector4Add(*RL_V4(v1), *RL_V4(v2));
}
/** Vector4AddValue(params: void * v, float add, void * _out -> void) */
void rl_Vector4AddValue(void * v, float add, void * _out) {
  *RL_V4(_out) = Vector4AddValue(*RL_V4(v), add);
}
/** Vector4Subtract(params: void * v1, void * v2, void * _out -> void) */
void rl_Vector4Subtract(void * v1, void * v2, void * _out) {
  *RL_V4(_out) = Vector4Subtract(*RL_V4(v1), *RL_V4(v2));
}
/** Vector4SubtractValue(params: void * v, float add, void * _out -> void) */
void rl_Vector4SubtractValue(void * v, float add, void * _out) {
  *RL_V4(_out) = Vector4SubtractValue(*RL_V4(v), add);
}
/** Vector4Length(params: void * v -> float) */
float rl_Vector4Length(void * v) {
  return Vector4Length(*RL_V4(v));
}
/** Vector4LengthSqr(params: void * v -> float) */
float rl_Vector4LengthSqr(void * v) {
  return Vector4LengthSqr(*RL_V4(v));
}
/** Vector4DotProduct(params: void * v1, void * v2 -> float) */
float rl_Vector4DotProduct(void * v1, void * v2) {
  return Vector4DotProduct(*RL_V4(v1), *RL_V4(v2));
}
/** Vector4Distance(params: void * v1, void * v2 -> float) */
float rl_Vector4Distance(void * v1, void * v2) {
  return Vector4Distance(*RL_V4(v1), *RL_V4(v2));
}
/** Vector4DistanceSqr(params: void * v1, void * v2 -> float) */
float rl_Vector4DistanceSqr(void * v1, void * v2) {
  return Vector4DistanceSqr(*RL_V4(v1), *RL_V4(v2));
}
/** Vector4Scale(params: void * v, float scale, void * _out -> void) */
void rl_Vector4Scale(void * v, float scale, void * _out) {
  *RL_V4(_out) = Vector4Scale(*RL_V4(v), scale);
}
/** Vector4Multiply(params: void * v1, void * v2, void * _out -> void) */
void rl_Vector4Multiply(void * v1, void * v2, void * _out) {
  *RL_V4(_out) = Vector4Multiply(*RL_V4(v1), *RL_V4(v2));
}
/** Vector4Negate(params: void * v, void * _out -> void) */
void rl_Vector4Negate(void * v, void * _out) {
  *RL_V4(_out) = Vector4Negate(*RL_V4(v));
}
/** Vector4Divide(params: void * v1, void * v2, void * _out -> void) */
void rl_Vector4Divide(void * v1, void * v2, void * _out) {
  *RL_V4(_out) = Vector4Divide(*RL_V4(v1), *RL_V4(v2));
}
/** Vector4Normalize(params: void * v, void * _out -> void) */
void rl_Vector4Normalize(void * v, void * _out) {
  *RL_V4(_out) = Vector4Normalize(*RL_V4(v));
}
/** Vector4Min(params: void * v1, void * v2, void * _out -> void) */
void rl_Vector4Min(void * v1, void * v2, void * _out) {
  *RL_V4(_out) = Vector4Min(*RL_V4(v1), *RL_V4(v2));
}
/** Vector4Max(params: void * v1, void * v2, void * _out -> void) */
void rl_Vector4Max(void * v1, void * v2, void * _out) {
  *RL_V4(_out) = Vector4Max(*RL_V4(v1), *RL_V4(v2));
}
/** Vector4Lerp(params: void * v1, void * v2, float amount, void * _out -> void) */
void rl_Vector4Lerp(void * v1, void * v2, float amount, void * _out) {
  *RL_V4(_out) = Vector4Lerp(*RL_V4(v1), *RL_V4(v2), amount);
}
/** Vector4MoveTowards(params: void * v, void * target, float maxDistance, void * _out -> void) */
void rl_Vector4MoveTowards(void * v, void * target, float maxDistance, void * _out) {
  *RL_V4(_out) = Vector4MoveTowards(*RL_V4(v), *RL_V4(target), maxDistance);
}
/** Vector4Invert(params: void * v, void * _out -> void) */
void rl_Vector4Invert(void * v, void * _out) {
  *RL_V4(_out) = Vector4Invert(*RL_V4(v));
}
/** Vector4Equals(params: void * p, void * q -> int) */
int rl_Vector4Equals(void * p, void * q) {
  return Vector4Equals(*RL_V4(p), *RL_V4(q));
}
/** MatrixDeterminant(params: void * mat -> float) */
float rl_MatrixDeterminant(void * mat) {
  return MatrixDeterminant(((rl_Matrix*)mat)->v);
}
/** MatrixTrace(params: void * mat -> float) */
float rl_MatrixTrace(void * mat) {
  return MatrixTrace(((rl_Matrix*)mat)->v);
}
/** MatrixTranspose(params: void * mat, void * _out -> void) */
void rl_MatrixTranspose(void * mat, void * _out) {
  ((rl_Matrix*)_out)->v = MatrixTranspose(((rl_Matrix*)mat)->v);
}
/** MatrixInvert(params: void * mat, void * _out -> void) */
void rl_MatrixInvert(void * mat, void * _out) {
  ((rl_Matrix*)_out)->v = MatrixInvert(((rl_Matrix*)mat)->v);
}
/** MatrixIdentity(params: void * _out -> void) */
void rl_MatrixIdentity(void * _out) {
  ((rl_Matrix*)_out)->v = MatrixIdentity();
}
/** MatrixAdd(params: void * left, void * right, void * _out -> void) */
void rl_MatrixAdd(void * left, void * right, void * _out) {
  ((rl_Matrix*)_out)->v = MatrixAdd(((rl_Matrix*)left)->v, ((rl_Matrix*)right)->v);
}
/** MatrixSubtract(params: void * left, void * right, void * _out -> void) */
void rl_MatrixSubtract(void * left, void * right, void * _out) {
  ((rl_Matrix*)_out)->v = MatrixSubtract(((rl_Matrix*)left)->v, ((rl_Matrix*)right)->v);
}
/** MatrixMultiply(params: void * left, void * right, void * _out -> void) */
void rl_MatrixMultiply(void * left, void * right, void * _out) {
  ((rl_Matrix*)_out)->v = MatrixMultiply(((rl_Matrix*)left)->v, ((rl_Matrix*)right)->v);
}
/** MatrixMultiplyValue(params: void * left, float value, void * _out -> void) */
void rl_MatrixMultiplyValue(void * left, float value, void * _out) {
  ((rl_Matrix*)_out)->v = MatrixMultiplyValue(((rl_Matrix*)left)->v, value);
}
/** MatrixTranslate(params: float x, float y, float z, void * _out -> void) */
void rl_MatrixTranslate(float x, float y, float z, void * _out) {
  ((rl_Matrix*)_out)->v = MatrixTranslate(x, y, z);
}
/** MatrixRotate(params: void * axis, float angle, void * _out -> void) */
void rl_MatrixRotate(void * axis, float angle, void * _out) {
  ((rl_Matrix*)_out)->v = MatrixRotate(*RL_V3(axis), angle);
}
/** MatrixRotateX(params: float angle, void * _out -> void) */
void rl_MatrixRotateX(float angle, void * _out) {
  ((rl_Matrix*)_out)->v = MatrixRotateX(angle);
}
/** MatrixRotateY(params: float angle, void * _out -> void) */
void rl_MatrixRotateY(float angle, void * _out) {
  ((rl_Matrix*)_out)->v = MatrixRotateY(angle);
}
/** MatrixRotateZ(params: float angle, void * _out -> void) */
void rl_MatrixRotateZ(float angle, void * _out) {
  ((rl_Matrix*)_out)->v = MatrixRotateZ(angle);
}
/** MatrixRotateXYZ(params: void * angle, void * _out -> void) */
static void rl_MatrixRotateXYZ(void * angle, void * _out) {
  ((rl_Matrix*)_out)->v = MatrixRotateXYZ(*RL_V3(angle));
}
/** MatrixRotateZYX(params: void * angle, void * _out -> void) */
void rl_MatrixRotateZYX(void * angle, void * _out) {
  ((rl_Matrix*)_out)->v = MatrixRotateZYX(*RL_V3(angle));
}
/** MatrixScale(params: float x, float y, float z, void * _out -> void) */
void rl_MatrixScale(float x, float y, float z, void * _out) {
  ((rl_Matrix*)_out)->v = MatrixScale(x, y, z);
}
/** MatrixFrustum(params: double left, double right, double bottom, double top, double nearPlane, double farPlane, void * _out -> void) */
void rl_MatrixFrustum(double left, double right, double bottom, double top, double nearPlane, double farPlane, void * _out) {
  ((rl_Matrix*)_out)->v = MatrixFrustum(left, right, bottom, top, nearPlane, farPlane);
}
/** MatrixPerspective(params: double fovY, double aspect, double nearPlane, double farPlane, void * _out -> void) */
void rl_MatrixPerspective(double fovY, double aspect, double nearPlane, double farPlane, void * _out) {
  ((rl_Matrix*)_out)->v = MatrixPerspective(fovY, aspect, nearPlane, farPlane);
}
/** MatrixOrtho(params: double left, double right, double bottom, double top, double nearPlane, double farPlane, void * _out -> void) */
void rl_MatrixOrtho(double left, double right, double bottom, double top, double nearPlane, double farPlane, void * _out) {
  ((rl_Matrix*)_out)->v = MatrixOrtho(left, right, bottom, top, nearPlane, farPlane);
}
/** MatrixLookAt(params: void * eye, void * target, void * up, void * _out -> void) */
void rl_MatrixLookAt(void * eye, void * target, void * up, void * _out) {
  ((rl_Matrix*)_out)->v = MatrixLookAt(*RL_V3(eye), *RL_V3(target), *RL_V3(up));
}
/** MatrixToFloatV(params: void * mat -> void *) */
void * rl_MatrixToFloatV(void * mat) {
  float16 *r = (float16 *)malloc(sizeof(float16));
  *r = MatrixToFloatV(((rl_Matrix*)mat)->v);
  return r;
}
/** QuaternionAdd(params: void * q1, void * q2, void * _out -> void) */
void rl_QuaternionAdd(void * q1, void * q2, void * _out) {
  ((rl_Quaternion*)_out)->v = QuaternionAdd(((rl_Quaternion*)q1)->v, ((rl_Quaternion*)q2)->v);
}
/** QuaternionAddValue(params: void * q, float add, void * _out -> void) */
void rl_QuaternionAddValue(void * q, float add, void * _out) {
  ((rl_Quaternion*)_out)->v = QuaternionAddValue(((rl_Quaternion*)q)->v, add);
}
/** QuaternionSubtract(params: void * q1, void * q2, void * _out -> void) */
void rl_QuaternionSubtract(void * q1, void * q2, void * _out) {
  ((rl_Quaternion*)_out)->v = QuaternionSubtract(((rl_Quaternion*)q1)->v, ((rl_Quaternion*)q2)->v);
}
/** QuaternionSubtractValue(params: void * q, float sub, void * _out -> void) */
void rl_QuaternionSubtractValue(void * q, float sub, void * _out) {
  ((rl_Quaternion*)_out)->v = QuaternionSubtractValue(((rl_Quaternion*)q)->v, sub);
}
/** QuaternionIdentity(params: void * _out -> void) */
void rl_QuaternionIdentity(void * _out) {
  ((rl_Quaternion*)_out)->v = QuaternionIdentity();
}
/** QuaternionLength(params: void * q -> float) */
float rl_QuaternionLength(void * q) {
  return QuaternionLength(((rl_Quaternion*)q)->v);
}
/** QuaternionNormalize(params: void * q, void * _out -> void) */
void rl_QuaternionNormalize(void * q, void * _out) {
  ((rl_Quaternion*)_out)->v = QuaternionNormalize(((rl_Quaternion*)q)->v);
}
/** QuaternionInvert(params: void * q, void * _out -> void) */
void rl_QuaternionInvert(void * q, void * _out) {
  ((rl_Quaternion*)_out)->v = QuaternionInvert(((rl_Quaternion*)q)->v);
}
/** QuaternionMultiply(params: void * q1, void * q2, void * _out -> void) */
void rl_QuaternionMultiply(void * q1, void * q2, void * _out) {
  ((rl_Quaternion*)_out)->v = QuaternionMultiply(((rl_Quaternion*)q1)->v, ((rl_Quaternion*)q2)->v);
}
/** QuaternionScale(params: void * q, float mul, void * _out -> void) */
void rl_QuaternionScale(void * q, float mul, void * _out) {
  ((rl_Quaternion*)_out)->v = QuaternionScale(((rl_Quaternion*)q)->v, mul);
}
/** QuaternionDivide(params: void * q1, void * q2, void * _out -> void) */
void rl_QuaternionDivide(void * q1, void * q2, void * _out) {
  ((rl_Quaternion*)_out)->v = QuaternionDivide(((rl_Quaternion*)q1)->v, ((rl_Quaternion*)q2)->v);
}
/** QuaternionLerp(params: void * q1, void * q2, float amount, void * _out -> void) */
void rl_QuaternionLerp(void * q1, void * q2, float amount, void * _out) {
  ((rl_Quaternion*)_out)->v = QuaternionLerp(((rl_Quaternion*)q1)->v, ((rl_Quaternion*)q2)->v, amount);
}
/** QuaternionNlerp(params: void * q1, void * q2, float amount, void * _out -> void) */
void rl_QuaternionNlerp(void * q1, void * q2, float amount, void * _out) {
  ((rl_Quaternion*)_out)->v = QuaternionNlerp(((rl_Quaternion*)q1)->v, ((rl_Quaternion*)q2)->v, amount);
}
/** QuaternionSlerp(params: void * q1, void * q2, float amount, void * _out -> void) */
void rl_QuaternionSlerp(void * q1, void * q2, float amount, void * _out) {
  ((rl_Quaternion*)_out)->v = QuaternionSlerp(((rl_Quaternion*)q1)->v, ((rl_Quaternion*)q2)->v, amount);
}
/** QuaternionCubicHermiteSpline(params: void * q1, void * outTangent1, void * q2, void * inTangent2, float t, void * _out -> void) */
void rl_QuaternionCubicHermiteSpline(void * q1, void * outTangent1, void * q2, void * inTangent2, float t, void * _out) {
  ((rl_Quaternion*)_out)->v = QuaternionCubicHermiteSpline(((rl_Quaternion*)q1)->v, ((rl_Quaternion*)outTangent1)->v, ((rl_Quaternion*)q2)->v, ((rl_Quaternion*)inTangent2)->v, t);
}
/** QuaternionFromVector3ToVector3(params: void * from, void * to, void * _out -> void) */
void rl_QuaternionFromVector3ToVector3(void * from, void * to, void * _out) {
  ((rl_Quaternion*)_out)->v = QuaternionFromVector3ToVector3(*RL_V3(from), *RL_V3(to));
}
/** QuaternionFromMatrix(params: void * mat, void * _out -> void) */
void rl_QuaternionFromMatrix(void * mat, void * _out) {
  ((rl_Quaternion*)_out)->v = QuaternionFromMatrix(((rl_Matrix*)mat)->v);
}
/** QuaternionToMatrix(params: void * q, void * _out -> void) */
void rl_QuaternionToMatrix(void * q, void * _out) {
  ((rl_Matrix*)_out)->v = QuaternionToMatrix(((rl_Quaternion*)q)->v);
}
/** QuaternionFromAxisAngle(params: void * axis, float angle, void * _out -> void) */
void rl_QuaternionFromAxisAngle(void * axis, float angle, void * _out) {
  ((rl_Quaternion*)_out)->v = QuaternionFromAxisAngle(*RL_V3(axis), angle);
}
/** QuaternionToAxisAngle(params: void * q, void * outAxis, void * outAngle -> void) */
void rl_QuaternionToAxisAngle(void * q, void * outAxis, void * outAngle) {
  QuaternionToAxisAngle(((rl_Quaternion*)q)->v, &*RL_V3(outAxis), outAngle);
}
/** QuaternionFromEuler(params: float pitch, float yaw, float roll, void * _out -> void) */
void rl_QuaternionFromEuler(float pitch, float yaw, float roll, void * _out) {
  ((rl_Quaternion*)_out)->v = QuaternionFromEuler(pitch, yaw, roll);
}
/** QuaternionToEuler(params: void * q, void * _out -> void) */
void rl_QuaternionToEuler(void * q, void * _out) {
  *RL_V3(_out) = QuaternionToEuler(((rl_Quaternion*)q)->v);
}
/** QuaternionTransform(params: void * q, void * mat, void * _out -> void) */
void rl_QuaternionTransform(void * q, void * mat, void * _out) {
  ((rl_Quaternion*)_out)->v = QuaternionTransform(((rl_Quaternion*)q)->v, ((rl_Matrix*)mat)->v);
}
/** QuaternionEquals(params: void * p, void * q -> int) */
int rl_QuaternionEquals(void * p, void * q) {
  return QuaternionEquals(((rl_Quaternion*)p)->v, ((rl_Quaternion*)q)->v);
}
/** MatrixCompose(params: void * translation, void * rotation, void * scale, void * _out -> void) */
void rl_MatrixCompose(void * translation, void * rotation, void * scale, void * _out) {
  ((rl_Matrix*)_out)->v = MatrixCompose(*RL_V3(translation), ((rl_Quaternion*)rotation)->v, *RL_V3(scale));
}
/** MatrixDecompose(params: void * mat, void * translation, void * rotation, void * scale -> void) */
void rl_MatrixDecompose(void * mat, void * translation, void * rotation, void * scale) {
  MatrixDecompose(((rl_Matrix*)mat)->v, &*RL_V3(translation), &((rl_Quaternion*)rotation)->v, &*RL_V3(scale));
}

/* Boid helper: write the 16 floats of QuaternionToMatrix(QuaternionFromVector3ToVector3(+z, dir))
 * into a caller-provided float array. Also feed the same matrix to rlMultMatrixf. */
void rl_QuaternionToMatrix3(void *dir, float *out) {
  Vector3 z = (Vector3){ 0.0f, 0.0f, 1.0f };
  Quaternion q = QuaternionFromVector3ToVector3(z, *RL_V3(dir));
  Matrix m = QuaternionToMatrix(q);
  float *f = (float *)&m;
  for (int i = 0; i < 16; i++) out[i] = f[i];
}
void rl_rlMultMatrixfFloats(float *floats, int index) {
  rlMultMatrixf(floats + index * 16);
}

/* Boids helper: rotate the model matrix so +z points along dir, then feed it
 * to rlMultMatrixf (single call from Ruby). */
void rl_rlMultMatrixfForDir(void *dir) {
  Vector3 z = (Vector3){ 0.0f, 0.0f, 1.0f };
  Quaternion q = QuaternionFromVector3ToVector3(z, *RL_V3(dir));
  Matrix m = QuaternionToMatrix(q);
  rlMultMatrixf((float *)&m);
}

/* ================================================================
 * Generated shims (tools/gen_raymath.py). Same conventions as the
 * hand-written shims above; keep in sync by re-running the generator.
 * ================================================================ */

double rl_Quaternion_x(rl_Quaternion *self) {
  return (double)self->v.x;
}
double rl_Quaternion_set_x(rl_Quaternion *self, double x) {
  self->v.x = (float)x;
  return x;
}
double rl_Quaternion_y(rl_Quaternion *self) {
  return (double)self->v.y;
}
double rl_Quaternion_set_y(rl_Quaternion *self, double y) {
  self->v.y = (float)y;
  return y;
}
double rl_Quaternion_z(rl_Quaternion *self) {
  return (double)self->v.z;
}
double rl_Quaternion_set_z(rl_Quaternion *self, double z) {
  self->v.z = (float)z;
  return z;
}
double rl_Quaternion_w(rl_Quaternion *self) {
  return (double)self->v.w;
}
double rl_Quaternion_set_w(rl_Quaternion *self, double w) {
  self->v.w = (float)w;
  return w;
}

/* ---- generated shims ---- */
