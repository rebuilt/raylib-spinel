#include <raylib.h>
#include <rlgl.h>
#include <stdio.h>
#include <stdlib.h>
#include "spinel/runtime.h"

/* --- P2 views: read the Vector2/Vector3 payload through the view pointer.
 * `p == NULL` for owned objects (payload in `v`); `p != NULL` for views built
 * by rl_VectorN_view, where the payload lives in the owner's C struct. */
#define RL_V2(o) (((rl_Vector2 *)(o))->p ? ((rl_Vector2 *)(o))->p : &((rl_Vector2 *)(o))->v)
#define RL_V3(o) (((rl_Vector3 *)(o))->p ? ((rl_Vector3 *)(o))->p : &((rl_Vector3 *)(o))->v)
#define RL_V4(o) (((rl_Vector4 *)(o))->p ? ((rl_Vector4 *)(o))->p : &((rl_Vector4 *)(o))->v)


/* rlgl_adapter.c — rl_ shims for Spinel AOT */

/* Generated shims (tools/gen_rlgl.py) */

/* ================================================================
 * Generated shims (tools/gen_rlgl.py). Same conventions as the
 * hand-written shims above; keep in sync by re-running the generator.
 * ================================================================ */


/* rl_Vector2 — GC-embedded Vector2 (see rlgl_ffi.rb) */typedef struct rl_Vector2_s {
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

/* rl_Vector3 — GC-embedded Vector3 (see rlgl_ffi.rb) */typedef struct rl_Vector3_s {
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

/* rl_Vector4 — GC-embedded Vector4 (see rlgl_ffi.rb) */typedef struct rl_Vector4_s {
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

/* rl_Matrix — GC-embedded Matrix (see rlgl_ffi.rb) */typedef struct rl_Matrix_s {
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

/* rl_Color — GC-embedded Color (see rlgl_ffi.rb) */typedef struct rl_Color_s {
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

/* rl_Rectangle — GC-embedded Rectangle (see rlgl_ffi.rb) */typedef struct rl_Rectangle_s {
  sp_int cls_id;
  Rectangle v;
} rl_Rectangle;
static void rl_Rectangle_scan(void *p) { (void)p; }
static rl_Rectangle *rl_Rectangle_new(sp_int cls_id) {
  rl_Rectangle *self = (rl_Rectangle *)sp_gc_alloc(sizeof(rl_Rectangle), NULL, rl_Rectangle_scan);
  self->cls_id = cls_id;
  self->v = (Rectangle){ 0 };
  return self;
}

/* rl_Camera2D — GC-embedded Camera2D (see rlgl_ffi.rb) */typedef struct rl_Camera2D_s {
  sp_int cls_id;
  Camera2D v;
} rl_Camera2D;
static void rl_Camera2D_scan(void *p) { (void)p; }
static rl_Camera2D *rl_Camera2D_new(sp_int cls_id) {
  rl_Camera2D *self = (rl_Camera2D *)sp_gc_alloc(sizeof(rl_Camera2D), NULL, rl_Camera2D_scan);
  self->cls_id = cls_id;
  self->v = (Camera2D){ 0 };
  return self;
}

/* rl_BoundingBox — GC-embedded BoundingBox (see rlgl_ffi.rb) */typedef struct rl_BoundingBox_s {
  sp_int cls_id;
  BoundingBox v;
} rl_BoundingBox;
static void rl_BoundingBox_scan(void *p) { (void)p; }
static rl_BoundingBox *rl_BoundingBox_new(sp_int cls_id) {
  rl_BoundingBox *self = (rl_BoundingBox *)sp_gc_alloc(sizeof(rl_BoundingBox), NULL, rl_BoundingBox_scan);
  self->cls_id = cls_id;
  self->v = (BoundingBox){ 0 };
  return self;
}

/* rl_Ray — GC-embedded Ray (see rlgl_ffi.rb) */typedef struct rl_Ray_s {
  sp_int cls_id;
  Ray v;
} rl_Ray;
static void rl_Ray_scan(void *p) { (void)p; }
static rl_Ray *rl_Ray_new(sp_int cls_id) {
  rl_Ray *self = (rl_Ray *)sp_gc_alloc(sizeof(rl_Ray), NULL, rl_Ray_scan);
  self->cls_id = cls_id;
  self->v = (Ray){ 0 };
  return self;
}

/* rl_RayCollision — GC-embedded RayCollision (see rlgl_ffi.rb) */typedef struct rl_RayCollision_s {
  sp_int cls_id;
  RayCollision v;
} rl_RayCollision;
static void rl_RayCollision_scan(void *p) { (void)p; }
static rl_RayCollision *rl_RayCollision_new(sp_int cls_id) {
  rl_RayCollision *self = (rl_RayCollision *)sp_gc_alloc(sizeof(rl_RayCollision), NULL, rl_RayCollision_scan);
  self->cls_id = cls_id;
  self->v = (RayCollision){ 0 };
  return self;
}

/* rl_NPatchInfo — GC-embedded NPatchInfo (see rlgl_ffi.rb) */typedef struct rl_NPatchInfo_s {
  sp_int cls_id;
  NPatchInfo v;
} rl_NPatchInfo;
static void rl_NPatchInfo_scan(void *p) { (void)p; }
static rl_NPatchInfo *rl_NPatchInfo_new(sp_int cls_id) {
  rl_NPatchInfo *self = (rl_NPatchInfo *)sp_gc_alloc(sizeof(rl_NPatchInfo), NULL, rl_NPatchInfo_scan);
  self->cls_id = cls_id;
  self->v = (NPatchInfo){ 0 };
  return self;
}

/* rl_VrDeviceInfo — GC-embedded VrDeviceInfo (see rlgl_ffi.rb) */typedef struct rl_VrDeviceInfo_s {
  sp_int cls_id;
  VrDeviceInfo v;
} rl_VrDeviceInfo;
static void rl_VrDeviceInfo_scan(void *p) { (void)p; }
static rl_VrDeviceInfo *rl_VrDeviceInfo_new(sp_int cls_id) {
  rl_VrDeviceInfo *self = (rl_VrDeviceInfo *)sp_gc_alloc(sizeof(rl_VrDeviceInfo), NULL, rl_VrDeviceInfo_scan);
  self->cls_id = cls_id;
  self->v = (VrDeviceInfo){ 0 };
  return self;
}

/* rl_VrStereoConfig — GC-embedded VrStereoConfig (see rlgl_ffi.rb) */typedef struct rl_VrStereoConfig_s {
  sp_int cls_id;
  VrStereoConfig v;
} rl_VrStereoConfig;
static void rl_VrStereoConfig_scan(void *p) { (void)p; }
static rl_VrStereoConfig *rl_VrStereoConfig_new(sp_int cls_id) {
  rl_VrStereoConfig *self = (rl_VrStereoConfig *)sp_gc_alloc(sizeof(rl_VrStereoConfig), NULL, rl_VrStereoConfig_scan);
  self->cls_id = cls_id;
  self->v = (VrStereoConfig){ 0 };
  return self;
}

/* ---- generated shims ---- */
/** rlUnloadRenderBatch(params: void * batch -> void) */
void rl_rlUnloadRenderBatch(void * batch) {
  rlUnloadRenderBatch(*(rlRenderBatch *)batch);
}
/** rlSetUniformMatrix(params: int locIndex, void * mat -> void) */
void rl_rlSetUniformMatrix(int locIndex, void * mat) {
  rlSetUniformMatrix(locIndex, ((rl_Matrix*)mat)->v);
}
/** rlGetMatrixModelview(params: void * _out -> void) */
void rl_rlGetMatrixModelview(void * _out) {
  ((rl_Matrix*)_out)->v = rlGetMatrixModelview();
}
/** rlGetMatrixProjection(params: void * _out -> void) */
void rl_rlGetMatrixProjection(void * _out) {
  ((rl_Matrix*)_out)->v = rlGetMatrixProjection();
}
/** rlGetMatrixTransform(params: void * _out -> void) */
void rl_rlGetMatrixTransform(void * _out) {
  ((rl_Matrix*)_out)->v = rlGetMatrixTransform();
}
/** rlGetMatrixProjectionStereo(params: int eye, void * _out -> void) */
void rl_rlGetMatrixProjectionStereo(int eye, void * _out) {
  ((rl_Matrix*)_out)->v = rlGetMatrixProjectionStereo(eye);
}
/** rlGetMatrixViewOffsetStereo(params: int eye, void * _out -> void) */
void rl_rlGetMatrixViewOffsetStereo(int eye, void * _out) {
  ((rl_Matrix*)_out)->v = rlGetMatrixViewOffsetStereo(eye);
}
/** rlSetMatrixProjection(params: void * proj -> void) */
void rl_rlSetMatrixProjection(void * proj) {
  rlSetMatrixProjection(((rl_Matrix*)proj)->v);
}
/** rlSetMatrixModelview(params: void * view -> void) */
void rl_rlSetMatrixModelview(void * view) {
  rlSetMatrixModelview(((rl_Matrix*)view)->v);
}
/** rlSetMatrixProjectionStereo(params: void * right, void * left -> void) */
void rl_rlSetMatrixProjectionStereo(void * right, void * left) {
  rlSetMatrixProjectionStereo(((rl_Matrix*)right)->v, ((rl_Matrix*)left)->v);
}
/** rlSetMatrixViewOffsetStereo(params: void * right, void * left -> void) */
void rl_rlSetMatrixViewOffsetStereo(void * right, void * left) {
  rlSetMatrixViewOffsetStereo(((rl_Matrix*)right)->v, ((rl_Matrix*)left)->v);
}
