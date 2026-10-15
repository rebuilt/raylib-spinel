#include <raylib.h>
#include <stdbool.h>
#include <rcamera.h>
#include <stdio.h>
#include <stdlib.h>
#include "spinel/runtime.h"
#include "rl_handle_views.h"

/* --- P2 view payload access (owned vs view objects). */
#define RL_RECT(o) (((rl_Rectangle *)(o))->p ? ((rl_Rectangle *)(o))->p : &((rl_Rectangle *)(o))->v)


/* --- P2 views: read the Vector2/Vector3 payload through the view pointer.
 * `p == NULL` for owned objects (payload in `v`); `p != NULL` for views built
 * by rl_VectorN_view, where the payload lives in the owner's C struct. */
#define RL_V2(o) (((rl_Vector2 *)(o))->p ? ((rl_Vector2 *)(o))->p : &((rl_Vector2 *)(o))->v)
#define RL_V3(o) (((rl_Vector3 *)(o))->p ? ((rl_Vector3 *)(o))->p : &((rl_Vector3 *)(o))->v)
#define RL_V4(o) (((rl_Vector4 *)(o))->p ? ((rl_Vector4 *)(o))->p : &((rl_Vector4 *)(o))->v)


/* rcamera_adapter.c — rl_ shims for Spinel AOT */

/* Generated shims (tools/gen_rcamera.py) */

/* ================================================================
 * Generated shims (tools/gen_rcamera.py). Same conventions as the
 * hand-written shims above; keep in sync by re-running the generator.
 * ================================================================ */


/* rl_Vector2 — GC-embedded Vector2 (see rcamera_ffi.rb) */typedef struct rl_Vector2_s {
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

/* rl_Vector3 — GC-embedded Vector3 (see rcamera_ffi.rb) */typedef struct rl_Vector3_s {
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
static double rl_Vector3_set_x(rl_Vector3 *self, double x) {
  RL_V3(self)->x = (float)x;
  return x;
}
static double rl_Vector3_y(rl_Vector3 *self) {
  return (double)RL_V3(self)->y;
}
static double rl_Vector3_set_y(rl_Vector3 *self, double y) {
  RL_V3(self)->y = (float)y;
  return y;
}
static double rl_Vector3_z(rl_Vector3 *self) {
  return (double)RL_V3(self)->z;
}
static double rl_Vector3_set_z(rl_Vector3 *self, double z) {
  RL_V3(self)->z = (float)z;
  return z;
}

/* rl_Camera — GC-embedded Camera (see rcamera_ffi.rb) */typedef struct rl_Camera_s {
  sp_int cls_id;
  Camera c;
} rl_Camera;
static void rl_Camera_scan(void *p) { (void)p; }
static rl_Camera *rl_Camera_new(sp_int cls_id) {
  rl_Camera *self = (rl_Camera *)sp_gc_alloc(sizeof(rl_Camera), NULL, rl_Camera_scan);
  self->cls_id = cls_id;
  self->c = (Camera){ 0 };
  return self;
}

/* rl_Vector4 — GC-embedded Vector4 (see rcamera_ffi.rb) */typedef struct rl_Vector4_s {
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

/* rl_Matrix — GC-embedded Matrix (see rcamera_ffi.rb) */typedef struct rl_Matrix_s {
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

/* rl_Color — GC-embedded Color (see rcamera_ffi.rb) */typedef struct rl_Color_s {
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

/* rl_Rectangle — GC-embedded Rectangle (see rcamera_ffi.rb) */typedef struct rl_Rectangle_s {
  sp_int cls_id;
  Rectangle *p;     /* NULL: owned (payload in v); non-NULL: a view */
  sp_RbVal owner;  /* view: GC-marked reference to the owner */
  Rectangle v;
} rl_Rectangle;
static void rl_Rectangle_scan(void *p) {
  rl_Rectangle *s = (rl_Rectangle *)p;
  if (s->p) sp_mark_rbval(s->owner);
}
static rl_Rectangle *rl_Rectangle_new(sp_int cls_id) {
  rl_Rectangle *self = (rl_Rectangle *)sp_gc_alloc(sizeof(rl_Rectangle), NULL, rl_Rectangle_scan);
  self->cls_id = cls_id;
  self->p = NULL;
  self->v = (Rectangle){ 0 };
  return self;
}

/* ---- generated shims ---- */
/** GetCameraForward(params: void * camera, void * _out -> void) */
void rl_GetCameraForward(void * camera, void * _out) {
  *RL_V3(_out) = GetCameraForward(&((rl_Camera*)camera)->c);
}
/** GetCameraUp(params: void * camera, void * _out -> void) */
void rl_GetCameraUp(void * camera, void * _out) {
  *RL_V3(_out) = GetCameraUp(&((rl_Camera*)camera)->c);
}
/** GetCameraRight(params: void * camera, void * _out -> void) */
void rl_GetCameraRight(void * camera, void * _out) {
  *RL_V3(_out) = GetCameraRight(&((rl_Camera*)camera)->c);
}
/** CameraMoveForward(params: void * camera, float distance, _Bool moveInWorldPlane -> void) */
void rl_CameraMoveForward(void * camera, float distance, _Bool moveInWorldPlane) {
  CameraMoveForward(&((rl_Camera*)camera)->c, distance, moveInWorldPlane);
}
/** CameraMoveUp(params: void * camera, float distance -> void) */
void rl_CameraMoveUp(void * camera, float distance) {
  CameraMoveUp(&((rl_Camera*)camera)->c, distance);
}
/** CameraMoveRight(params: void * camera, float distance, _Bool moveInWorldPlane -> void) */
void rl_CameraMoveRight(void * camera, float distance, _Bool moveInWorldPlane) {
  CameraMoveRight(&((rl_Camera*)camera)->c, distance, moveInWorldPlane);
}
/** CameraMoveToTarget(params: void * camera, float delta -> void) */
void rl_CameraMoveToTarget(void * camera, float delta) {
  CameraMoveToTarget(&((rl_Camera*)camera)->c, delta);
}
/** CameraYaw(params: void * camera, float angle, _Bool rotateAroundTarget -> void) */
void rl_CameraYaw(void * camera, float angle, _Bool rotateAroundTarget) {
  CameraYaw(&((rl_Camera*)camera)->c, angle, rotateAroundTarget);
}
/** CameraPitch(params: void * camera, float angle, _Bool lockView, _Bool rotateAroundTarget, _Bool rotateUp -> void) */
void rl_CameraPitch(void * camera, float angle, _Bool lockView, _Bool rotateAroundTarget, _Bool rotateUp) {
  CameraPitch(&((rl_Camera*)camera)->c, angle, lockView, rotateAroundTarget, rotateUp);
}
/** CameraRoll(params: void * camera, float angle -> void) */
void rl_CameraRoll(void * camera, float angle) {
  CameraRoll(&((rl_Camera*)camera)->c, angle);
}
/** GetCameraViewMatrix(params: void * camera, void * _out -> void) */
void rl_GetCameraViewMatrix(void * camera, void * _out) {
  ((rl_Matrix*)_out)->v = GetCameraViewMatrix(&((rl_Camera*)camera)->c);
}
/** GetCameraProjectionMatrix(params: void * camera, float aspect, void * _out -> void) */
void rl_GetCameraProjectionMatrix(void * camera, float aspect, void * _out) {
  ((rl_Matrix*)_out)->v = GetCameraProjectionMatrix(&((rl_Camera*)camera)->c, aspect);
}
