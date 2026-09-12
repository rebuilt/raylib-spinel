#include <rlgl.h>
#include <stdio.h>
#include <stdlib.h>
#include "spinel/runtime.h"

/* rlgl_adapter.c — sp_ shims for Spinel AOT */

/* Generated shims (tools/gen_rlgl.py) */

/* ================================================================
 * Generated shims (tools/gen_rlgl.py). Same conventions as the
 * hand-written shims above; keep in sync by re-running the generator.
 * ================================================================ */


/* sp_Vector2 — GC-embedded Vector2 (see rlgl_ffi.rb) */typedef struct sp_Vector2_s {
  sp_int cls_id;
  Vector2 v;
} sp_Vector2;
static void sp_Vector2_scan(void *p) { (void)p; }
sp_Vector2 *sp_Vector2_new(sp_int cls_id) {
  sp_Vector2 *self = (sp_Vector2 *)sp_gc_alloc(sizeof(sp_Vector2), NULL, sp_Vector2_scan);
  self->cls_id = cls_id;
  self->v = (Vector2){ 0 };
  return self;
}

/* sp_Vector3 — GC-embedded Vector3 (see rlgl_ffi.rb) */typedef struct sp_Vector3_s {
  sp_int cls_id;
  Vector3 v;
} sp_Vector3;
static void sp_Vector3_scan(void *p) { (void)p; }
sp_Vector3 *sp_Vector3_new(sp_int cls_id) {
  sp_Vector3 *self = (sp_Vector3 *)sp_gc_alloc(sizeof(sp_Vector3), NULL, sp_Vector3_scan);
  self->cls_id = cls_id;
  self->v = (Vector3){ 0 };
  return self;
}

/* sp_Vector4 — GC-embedded Vector4 (see rlgl_ffi.rb) */typedef struct sp_Vector4_s {
  sp_int cls_id;
  Vector4 v;
} sp_Vector4;
static void sp_Vector4_scan(void *p) { (void)p; }
sp_Vector4 *sp_Vector4_new(sp_int cls_id) {
  sp_Vector4 *self = (sp_Vector4 *)sp_gc_alloc(sizeof(sp_Vector4), NULL, sp_Vector4_scan);
  self->cls_id = cls_id;
  self->v = (Vector4){ 0 };
  return self;
}

/* sp_Matrix — GC-embedded Matrix (see rlgl_ffi.rb) */typedef struct sp_Matrix_s {
  sp_int cls_id;
  Matrix v;
} sp_Matrix;
static void sp_Matrix_scan(void *p) { (void)p; }
sp_Matrix *sp_Matrix_new(sp_int cls_id) {
  sp_Matrix *self = (sp_Matrix *)sp_gc_alloc(sizeof(sp_Matrix), NULL, sp_Matrix_scan);
  self->cls_id = cls_id;
  self->v = (Matrix){ 0 };
  return self;
}
double sp_Matrix_m0(sp_Matrix *self) {
  return (double)self->v.m0;
}
double sp_Matrix_set_m0(sp_Matrix *self, double m0) {
  self->v.m0 = (float)m0;
  return m0;
}
double sp_Matrix_m4(sp_Matrix *self) {
  return (double)self->v.m4;
}
double sp_Matrix_set_m4(sp_Matrix *self, double m4) {
  self->v.m4 = (float)m4;
  return m4;
}
double sp_Matrix_m8(sp_Matrix *self) {
  return (double)self->v.m8;
}
double sp_Matrix_set_m8(sp_Matrix *self, double m8) {
  self->v.m8 = (float)m8;
  return m8;
}
double sp_Matrix_m12(sp_Matrix *self) {
  return (double)self->v.m12;
}
double sp_Matrix_set_m12(sp_Matrix *self, double m12) {
  self->v.m12 = (float)m12;
  return m12;
}
double sp_Matrix_m1(sp_Matrix *self) {
  return (double)self->v.m1;
}
double sp_Matrix_set_m1(sp_Matrix *self, double m1) {
  self->v.m1 = (float)m1;
  return m1;
}
double sp_Matrix_m5(sp_Matrix *self) {
  return (double)self->v.m5;
}
double sp_Matrix_set_m5(sp_Matrix *self, double m5) {
  self->v.m5 = (float)m5;
  return m5;
}
double sp_Matrix_m9(sp_Matrix *self) {
  return (double)self->v.m9;
}
double sp_Matrix_set_m9(sp_Matrix *self, double m9) {
  self->v.m9 = (float)m9;
  return m9;
}
double sp_Matrix_m13(sp_Matrix *self) {
  return (double)self->v.m13;
}
double sp_Matrix_set_m13(sp_Matrix *self, double m13) {
  self->v.m13 = (float)m13;
  return m13;
}
double sp_Matrix_m2(sp_Matrix *self) {
  return (double)self->v.m2;
}
double sp_Matrix_set_m2(sp_Matrix *self, double m2) {
  self->v.m2 = (float)m2;
  return m2;
}
double sp_Matrix_m6(sp_Matrix *self) {
  return (double)self->v.m6;
}
double sp_Matrix_set_m6(sp_Matrix *self, double m6) {
  self->v.m6 = (float)m6;
  return m6;
}
double sp_Matrix_m10(sp_Matrix *self) {
  return (double)self->v.m10;
}
double sp_Matrix_set_m10(sp_Matrix *self, double m10) {
  self->v.m10 = (float)m10;
  return m10;
}
double sp_Matrix_m14(sp_Matrix *self) {
  return (double)self->v.m14;
}
double sp_Matrix_set_m14(sp_Matrix *self, double m14) {
  self->v.m14 = (float)m14;
  return m14;
}
double sp_Matrix_m3(sp_Matrix *self) {
  return (double)self->v.m3;
}
double sp_Matrix_set_m3(sp_Matrix *self, double m3) {
  self->v.m3 = (float)m3;
  return m3;
}
double sp_Matrix_m7(sp_Matrix *self) {
  return (double)self->v.m7;
}
double sp_Matrix_set_m7(sp_Matrix *self, double m7) {
  self->v.m7 = (float)m7;
  return m7;
}
double sp_Matrix_m11(sp_Matrix *self) {
  return (double)self->v.m11;
}
double sp_Matrix_set_m11(sp_Matrix *self, double m11) {
  self->v.m11 = (float)m11;
  return m11;
}
double sp_Matrix_m15(sp_Matrix *self) {
  return (double)self->v.m15;
}
double sp_Matrix_set_m15(sp_Matrix *self, double m15) {
  self->v.m15 = (float)m15;
  return m15;
}

/* sp_Color — GC-embedded Color (see rlgl_ffi.rb) */typedef struct sp_Color_s {
  sp_int cls_id;
  Color c;
} sp_Color;
static void sp_Color_scan(void *p) { (void)p; }
sp_Color *sp_Color_new(sp_int cls_id) {
  sp_Color *self = (sp_Color *)sp_gc_alloc(sizeof(sp_Color), NULL, sp_Color_scan);
  self->cls_id = cls_id;
  self->c = (Color){ 0 };
  return self;
}

/* sp_Rectangle — GC-embedded Rectangle (see rlgl_ffi.rb) */typedef struct sp_Rectangle_s {
  sp_int cls_id;
  Rectangle v;
} sp_Rectangle;
static void sp_Rectangle_scan(void *p) { (void)p; }
sp_Rectangle *sp_Rectangle_new(sp_int cls_id) {
  sp_Rectangle *self = (sp_Rectangle *)sp_gc_alloc(sizeof(sp_Rectangle), NULL, sp_Rectangle_scan);
  self->cls_id = cls_id;
  self->v = (Rectangle){ 0 };
  return self;
}

/* sp_Camera2D — GC-embedded Camera2D (see rlgl_ffi.rb) */typedef struct sp_Camera2D_s {
  sp_int cls_id;
  Camera2D v;
} sp_Camera2D;
static void sp_Camera2D_scan(void *p) { (void)p; }
sp_Camera2D *sp_Camera2D_new(sp_int cls_id) {
  sp_Camera2D *self = (sp_Camera2D *)sp_gc_alloc(sizeof(sp_Camera2D), NULL, sp_Camera2D_scan);
  self->cls_id = cls_id;
  self->v = (Camera2D){ 0 };
  return self;
}

/* sp_BoundingBox — GC-embedded BoundingBox (see rlgl_ffi.rb) */typedef struct sp_BoundingBox_s {
  sp_int cls_id;
  BoundingBox v;
} sp_BoundingBox;
static void sp_BoundingBox_scan(void *p) { (void)p; }
sp_BoundingBox *sp_BoundingBox_new(sp_int cls_id) {
  sp_BoundingBox *self = (sp_BoundingBox *)sp_gc_alloc(sizeof(sp_BoundingBox), NULL, sp_BoundingBox_scan);
  self->cls_id = cls_id;
  self->v = (BoundingBox){ 0 };
  return self;
}

/* sp_Ray — GC-embedded Ray (see rlgl_ffi.rb) */typedef struct sp_Ray_s {
  sp_int cls_id;
  Ray v;
} sp_Ray;
static void sp_Ray_scan(void *p) { (void)p; }
sp_Ray *sp_Ray_new(sp_int cls_id) {
  sp_Ray *self = (sp_Ray *)sp_gc_alloc(sizeof(sp_Ray), NULL, sp_Ray_scan);
  self->cls_id = cls_id;
  self->v = (Ray){ 0 };
  return self;
}

/* sp_RayCollision — GC-embedded RayCollision (see rlgl_ffi.rb) */typedef struct sp_RayCollision_s {
  sp_int cls_id;
  RayCollision v;
} sp_RayCollision;
static void sp_RayCollision_scan(void *p) { (void)p; }
sp_RayCollision *sp_RayCollision_new(sp_int cls_id) {
  sp_RayCollision *self = (sp_RayCollision *)sp_gc_alloc(sizeof(sp_RayCollision), NULL, sp_RayCollision_scan);
  self->cls_id = cls_id;
  self->v = (RayCollision){ 0 };
  return self;
}

/* sp_NPatchInfo — GC-embedded NPatchInfo (see rlgl_ffi.rb) */typedef struct sp_NPatchInfo_s {
  sp_int cls_id;
  NPatchInfo v;
} sp_NPatchInfo;
static void sp_NPatchInfo_scan(void *p) { (void)p; }
sp_NPatchInfo *sp_NPatchInfo_new(sp_int cls_id) {
  sp_NPatchInfo *self = (sp_NPatchInfo *)sp_gc_alloc(sizeof(sp_NPatchInfo), NULL, sp_NPatchInfo_scan);
  self->cls_id = cls_id;
  self->v = (NPatchInfo){ 0 };
  return self;
}

/* sp_VrDeviceInfo — GC-embedded VrDeviceInfo (see rlgl_ffi.rb) */typedef struct sp_VrDeviceInfo_s {
  sp_int cls_id;
  VrDeviceInfo v;
} sp_VrDeviceInfo;
static void sp_VrDeviceInfo_scan(void *p) { (void)p; }
sp_VrDeviceInfo *sp_VrDeviceInfo_new(sp_int cls_id) {
  sp_VrDeviceInfo *self = (sp_VrDeviceInfo *)sp_gc_alloc(sizeof(sp_VrDeviceInfo), NULL, sp_VrDeviceInfo_scan);
  self->cls_id = cls_id;
  self->v = (VrDeviceInfo){ 0 };
  return self;
}

/* sp_VrStereoConfig — GC-embedded VrStereoConfig (see rlgl_ffi.rb) */typedef struct sp_VrStereoConfig_s {
  sp_int cls_id;
  VrStereoConfig v;
} sp_VrStereoConfig;
static void sp_VrStereoConfig_scan(void *p) { (void)p; }
sp_VrStereoConfig *sp_VrStereoConfig_new(sp_int cls_id) {
  sp_VrStereoConfig *self = (sp_VrStereoConfig *)sp_gc_alloc(sizeof(sp_VrStereoConfig), NULL, sp_VrStereoConfig_scan);
  self->cls_id = cls_id;
  self->v = (VrStereoConfig){ 0 };
  return self;
}

/* ---- generated shims ---- */
/** rlUnloadRenderBatch(params: void * batch -> void) */
void sp_rlUnloadRenderBatch(void * batch) {
  rlUnloadRenderBatch(*(rlRenderBatch *)batch);
}
/** rlSetUniformMatrix(params: int locIndex, void * mat -> void) */
void sp_rlSetUniformMatrix(int locIndex, void * mat) {
  rlSetUniformMatrix(locIndex, ((sp_Matrix*)mat)->v);
}
/** rlGetMatrixModelview(params: void * _out -> void) */
void sp_rlGetMatrixModelview(void * _out) {
  ((sp_Matrix*)_out)->v = rlGetMatrixModelview();
}
/** rlGetMatrixProjection(params: void * _out -> void) */
void sp_rlGetMatrixProjection(void * _out) {
  ((sp_Matrix*)_out)->v = rlGetMatrixProjection();
}
/** rlGetMatrixTransform(params: void * _out -> void) */
void sp_rlGetMatrixTransform(void * _out) {
  ((sp_Matrix*)_out)->v = rlGetMatrixTransform();
}
/** rlGetMatrixProjectionStereo(params: int eye, void * _out -> void) */
void sp_rlGetMatrixProjectionStereo(int eye, void * _out) {
  ((sp_Matrix*)_out)->v = rlGetMatrixProjectionStereo(eye);
}
/** rlGetMatrixViewOffsetStereo(params: int eye, void * _out -> void) */
void sp_rlGetMatrixViewOffsetStereo(int eye, void * _out) {
  ((sp_Matrix*)_out)->v = rlGetMatrixViewOffsetStereo(eye);
}
/** rlSetMatrixProjection(params: void * proj -> void) */
void sp_rlSetMatrixProjection(void * proj) {
  rlSetMatrixProjection(((sp_Matrix*)proj)->v);
}
/** rlSetMatrixModelview(params: void * view -> void) */
void sp_rlSetMatrixModelview(void * view) {
  rlSetMatrixModelview(((sp_Matrix*)view)->v);
}
/** rlSetMatrixProjectionStereo(params: void * right, void * left -> void) */
void sp_rlSetMatrixProjectionStereo(void * right, void * left) {
  rlSetMatrixProjectionStereo(((sp_Matrix*)right)->v, ((sp_Matrix*)left)->v);
}
/** rlSetMatrixViewOffsetStereo(params: void * right, void * left -> void) */
void sp_rlSetMatrixViewOffsetStereo(void * right, void * left) {
  rlSetMatrixViewOffsetStereo(((sp_Matrix*)right)->v, ((sp_Matrix*)left)->v);
}
