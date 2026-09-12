#include <rcamera.h>
#include <stdio.h>
#include <stdlib.h>
#include "spinel/runtime.h"

/* rcamera_adapter.c — sp_ shims for Spinel AOT */

/* Generated shims (tools/gen_rcamera.py) */

/* ================================================================
 * Generated shims (tools/gen_rcamera.py). Same conventions as the
 * hand-written shims above; keep in sync by re-running the generator.
 * ================================================================ */


/* sp_Vector2 — GC-embedded Vector2 (see rcamera_ffi.rb) */typedef struct sp_Vector2_s {
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
double sp_Vector2_x(sp_Vector2 *self) {
  return (double)self->v.x;
}
double sp_Vector2_set_x(sp_Vector2 *self, double x) {
  self->v.x = (float)x;
  return x;
}
double sp_Vector2_y(sp_Vector2 *self) {
  return (double)self->v.y;
}
double sp_Vector2_set_y(sp_Vector2 *self, double y) {
  self->v.y = (float)y;
  return y;
}

/* sp_Vector3 — GC-embedded Vector3 (see rcamera_ffi.rb) */typedef struct sp_Vector3_s {
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
double sp_Vector3_x(sp_Vector3 *self) {
  return (double)self->v.x;
}
double sp_Vector3_set_x(sp_Vector3 *self, double x) {
  self->v.x = (float)x;
  return x;
}
double sp_Vector3_y(sp_Vector3 *self) {
  return (double)self->v.y;
}
double sp_Vector3_set_y(sp_Vector3 *self, double y) {
  self->v.y = (float)y;
  return y;
}
double sp_Vector3_z(sp_Vector3 *self) {
  return (double)self->v.z;
}
double sp_Vector3_set_z(sp_Vector3 *self, double z) {
  self->v.z = (float)z;
  return z;
}

/* sp_Camera — GC-embedded Camera (see rcamera_ffi.rb) */typedef struct sp_Camera_s {
  sp_int cls_id;
  Camera c;
} sp_Camera;
static void sp_Camera_scan(void *p) { (void)p; }
sp_Camera *sp_Camera_new(sp_int cls_id) {
  sp_Camera *self = (sp_Camera *)sp_gc_alloc(sizeof(sp_Camera), NULL, sp_Camera_scan);
  self->cls_id = cls_id;
  self->c = (Camera){ 0 };
  return self;
}

/* sp_Vector4 — GC-embedded Vector4 (see rcamera_ffi.rb) */typedef struct sp_Vector4_s {
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

/* sp_Matrix — GC-embedded Matrix (see rcamera_ffi.rb) */typedef struct sp_Matrix_s {
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

/* sp_Color — GC-embedded Color (see rcamera_ffi.rb) */typedef struct sp_Color_s {
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

/* sp_Rectangle — GC-embedded Rectangle (see rcamera_ffi.rb) */typedef struct sp_Rectangle_s {
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

/* ---- generated shims ---- */
/** GetCameraForward(params: void * camera, void * _out -> void) */
void sp_GetCameraForward(void * camera, void * _out) {
  ((sp_Vector3*)_out)->v = GetCameraForward(&((sp_Camera*)camera)->c);
}
/** GetCameraUp(params: void * camera, void * _out -> void) */
void sp_GetCameraUp(void * camera, void * _out) {
  ((sp_Vector3*)_out)->v = GetCameraUp(&((sp_Camera*)camera)->c);
}
/** GetCameraRight(params: void * camera, void * _out -> void) */
void sp_GetCameraRight(void * camera, void * _out) {
  ((sp_Vector3*)_out)->v = GetCameraRight(&((sp_Camera*)camera)->c);
}
/** CameraMoveForward(params: void * camera, float distance, _Bool moveInWorldPlane -> void) */
void sp_CameraMoveForward(void * camera, float distance, _Bool moveInWorldPlane) {
  CameraMoveForward(&((sp_Camera*)camera)->c, distance, moveInWorldPlane);
}
/** CameraMoveUp(params: void * camera, float distance -> void) */
void sp_CameraMoveUp(void * camera, float distance) {
  CameraMoveUp(&((sp_Camera*)camera)->c, distance);
}
/** CameraMoveRight(params: void * camera, float distance, _Bool moveInWorldPlane -> void) */
void sp_CameraMoveRight(void * camera, float distance, _Bool moveInWorldPlane) {
  CameraMoveRight(&((sp_Camera*)camera)->c, distance, moveInWorldPlane);
}
/** CameraMoveToTarget(params: void * camera, float delta -> void) */
void sp_CameraMoveToTarget(void * camera, float delta) {
  CameraMoveToTarget(&((sp_Camera*)camera)->c, delta);
}
/** CameraYaw(params: void * camera, float angle, _Bool rotateAroundTarget -> void) */
void sp_CameraYaw(void * camera, float angle, _Bool rotateAroundTarget) {
  CameraYaw(&((sp_Camera*)camera)->c, angle, rotateAroundTarget);
}
/** CameraPitch(params: void * camera, float angle, _Bool lockView, _Bool rotateAroundTarget, _Bool rotateUp -> void) */
void sp_CameraPitch(void * camera, float angle, _Bool lockView, _Bool rotateAroundTarget, _Bool rotateUp) {
  CameraPitch(&((sp_Camera*)camera)->c, angle, lockView, rotateAroundTarget, rotateUp);
}
/** CameraRoll(params: void * camera, float angle -> void) */
void sp_CameraRoll(void * camera, float angle) {
  CameraRoll(&((sp_Camera*)camera)->c, angle);
}
/** GetCameraViewMatrix(params: void * camera, void * _out -> void) */
void sp_GetCameraViewMatrix(void * camera, void * _out) {
  ((sp_Matrix*)_out)->v = GetCameraViewMatrix(&((sp_Camera*)camera)->c);
}
/** GetCameraProjectionMatrix(params: void * camera, float aspect, void * _out -> void) */
void sp_GetCameraProjectionMatrix(void * camera, float aspect, void * _out) {
  ((sp_Matrix*)_out)->v = GetCameraProjectionMatrix(&((sp_Camera*)camera)->c, aspect);
}
