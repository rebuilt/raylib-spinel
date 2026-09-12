#include <physac.h>
#include <stdio.h>
#include <stdlib.h>
#include "spinel/runtime.h"

/* physac_adapter.c — sp_ shims for Spinel AOT */

/* sp_Color — native, GC-managed Color */
typedef struct sp_Color_s {
  sp_int cls_id;
  Color c;
} sp_Color;

static void sp_Color_scan(void *p) { (void)p; }

sp_Color *sp_Color_new(sp_int cls_id, sp_int r, sp_int g, sp_int b, sp_int a) {
  sp_Color *self = (sp_Color *)sp_gc_alloc(sizeof(sp_Color), NULL, sp_Color_scan);
  self->cls_id = cls_id;
  self->c = (Color){ (unsigned char)r, (unsigned char)g, (unsigned char)b, (unsigned char)a };
  return self;
}

/* Vector2 helper */
void *Vector2Create(float x, float y) {
  Vector2 *v = (Vector2 *)malloc(sizeof(Vector2));
  v->x = x;
  v->y = y;
  return v;
}

double Vector2GetX(void *v) { return ((Vector2 *)v)->x; }
double Vector2GetY(void *v) { return ((Vector2 *)v)->y; }
void Vector2SetX(void *v, float x) { ((Vector2 *)v)->x = x; }
void Vector2SetY(void *v, float y) { ((Vector2 *)v)->y = y; }

/* Generated shims (tools/gen_physac.py) */

/* ================================================================
 * Generated shims (tools/gen_physac.py). Same conventions as the
 * hand-written shims above; keep in sync by re-running the generator.
 * ================================================================ */


/* sp_Vector3 — GC-embedded Vector3 (see physac_ffi.rb) */typedef struct sp_Vector3_s {
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

/* sp_Vector4 — GC-embedded Vector4 (see physac_ffi.rb) */typedef struct sp_Vector4_s {
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

/* sp_Matrix — GC-embedded Matrix (see physac_ffi.rb) */typedef struct sp_Matrix_s {
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

/* ---- generated shims ---- */
/** CreatePhysicsBodyCircle(params: void * pos, float radius, float density -> void *) */
void * sp_CreatePhysicsBodyCircle(void * pos, float radius, float density) {
  PhysicsBody *r = (PhysicsBody *)malloc(sizeof(PhysicsBody));
  *r = CreatePhysicsBodyCircle(((sp_Vector2*)pos)->v, radius, density);
  return r;
}
/** CreatePhysicsBodyRectangle(params: void * pos, float width, float height, float density -> void *) */
void * sp_CreatePhysicsBodyRectangle(void * pos, float width, float height, float density) {
  PhysicsBody *r = (PhysicsBody *)malloc(sizeof(PhysicsBody));
  *r = CreatePhysicsBodyRectangle(((sp_Vector2*)pos)->v, width, height, density);
  return r;
}
/** CreatePhysicsBodyPolygon(params: void * pos, float radius, int sides, float density -> void *) */
void * sp_CreatePhysicsBodyPolygon(void * pos, float radius, int sides, float density) {
  PhysicsBody *r = (PhysicsBody *)malloc(sizeof(PhysicsBody));
  *r = CreatePhysicsBodyPolygon(((sp_Vector2*)pos)->v, radius, sides, density);
  return r;
}
/** DestroyPhysicsBody(params: void * body -> void) */
void sp_DestroyPhysicsBody(void * body) {
  DestroyPhysicsBody(*(PhysicsBody *)body);
}
/** PhysicsAddForce(params: void * body, void * force -> void) */
void sp_PhysicsAddForce(void * body, void * force) {
  PhysicsAddForce(*(PhysicsBody *)body, ((sp_Vector2*)force)->v);
}
/** PhysicsAddTorque(params: void * body, float amount -> void) */
void sp_PhysicsAddTorque(void * body, float amount) {
  PhysicsAddTorque(*(PhysicsBody *)body, amount);
}
/** PhysicsShatter(params: void * body, void * position, float force -> void) */
void sp_PhysicsShatter(void * body, void * position, float force) {
  PhysicsShatter(*(PhysicsBody *)body, ((sp_Vector2*)position)->v, force);
}
/** SetPhysicsBodyRotation(params: void * body, float radians -> void) */
void sp_SetPhysicsBodyRotation(void * body, float radians) {
  SetPhysicsBodyRotation(*(PhysicsBody *)body, radians);
}
/** GetPhysicsBody(params: int index -> void *) */
void * sp_GetPhysicsBody(int index) {
  PhysicsBody *r = (PhysicsBody *)malloc(sizeof(PhysicsBody));
  *r = GetPhysicsBody(index);
  return r;
}
/** GetPhysicsShapeVertex(params: void * body, int vertex, void * _out -> void) */
void sp_GetPhysicsShapeVertex(void * body, int vertex, void * _out) {
  ((sp_Vector2*)_out)->v = GetPhysicsShapeVertex(*(PhysicsBody *)body, vertex);
}
