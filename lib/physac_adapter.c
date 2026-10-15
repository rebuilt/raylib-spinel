#include <raylib.h>
#include "physac.h"
#include <stdlib.h>
#include "spinel/runtime.h"
#include "rl_handle_views.h"

/* --- P2 view payload access (owned vs view objects). */
#define RL_TRANSFORM(o) (((rl_Transform *)(o))->p ? ((rl_Transform *)(o))->p : &((rl_Transform *)(o))->v)


/* --- P2 view payload access (owned vs view objects). */
#define RL_COLOR(o) (((rl_Color *)(o))->p ? ((rl_Color *)(o))->p : &((rl_Color *)(o))->c)


/* --- P2 view payload access (owned vs view objects). */
#define RL_RECT(o) (((rl_Rectangle *)(o))->p ? ((rl_Rectangle *)(o))->p : &((rl_Rectangle *)(o))->v)


/* --- P2 views: read the Vector2/Vector3 payload through the view pointer.
 * `p == NULL` for owned objects (payload in `v`); `p != NULL` for views built
 * by rl_VectorN_view, where the payload lives in the owner's C struct. */
#define RL_V2(o) (((rl_Vector2 *)(o))->p ? ((rl_Vector2 *)(o))->p : &((rl_Vector2 *)(o))->v)
#define RL_V3(o) (((rl_Vector3 *)(o))->p ? ((rl_Vector3 *)(o))->p : &((rl_Vector3 *)(o))->v)
#define RL_V4(o) (((rl_Vector4 *)(o))->p ? ((rl_Vector4 *)(o))->p : &((rl_Vector4 *)(o))->v)


/* Mirror the raylib adapter's embedded-Vector2 wrapper. */
typedef struct rl_Vector2_s {
  sp_int cls_id;
  Vector2 *p;     /* NULL: owned (payload in v); non-NULL: a view */
  sp_RbVal owner;  /* view: GC-marked reference to the owner */
  Vector2 v;
} rl_Vector2;

/* physac_adapter.c — rl_ shims for Spinel AOT.
 *
 * PhysicsBody is an opaque pointer; bodies are created with Vector2 by value,
 * so those shims take raw floats. Field reads/writes go through accessors. */

void *rl_InitPhysics(void) { InitPhysics(); return NULL; }
void rl_UpdatePhysics1(void) { UpdatePhysics(); }
void rl_ResetPhysics(void) { ResetPhysics(); }
void rl_ClosePhysics(void) { ClosePhysics(); }
void rl_SetPhysicsGravity(float x, float y) { SetPhysicsGravity(x, y); }
void rl_SetPhysicsTimeStep(double delta) { SetPhysicsTimeStep(delta); }

void *rl_CreatePhysicsBodyCircle(float x, float y, float radius, float density) {
  return CreatePhysicsBodyCircle((Vector2){ x, y }, radius, density);
}
void *rl_CreatePhysicsBodyRectangle(float x, float y, float width, float height,
                                    float density) {
  return CreatePhysicsBodyRectangle((Vector2){ x, y }, width, height, density);
}
void *rl_CreatePhysicsBodyPolygon(float x, float y, float radius, int sides,
                                  float density) {
  return CreatePhysicsBodyPolygon((Vector2){ x, y }, radius, sides, density);
}
void rl_DestroyPhysicsBody(void *body) { DestroyPhysicsBody((PhysicsBody)body); }
void rl_PhysicsAddForce(void *body, float x, float y) {
  PhysicsAddForce((PhysicsBody)body, (Vector2){ x, y });
}
void rl_PhysicsAddTorque(void *body, float amount) {
  PhysicsAddTorque((PhysicsBody)body, amount);
}
void *rl_GetPhysicsBody(int index) { return GetPhysicsBody(index); }
int rl_GetPhysicsBodiesCount(void) { return GetPhysicsBodiesCount(); }
int rl_GetPhysicsShapeType(int index) { return GetPhysicsShapeType(index); }
int rl_GetPhysicsShapeVerticesCount(int index) {
  return GetPhysicsShapeVerticesCount(index);
}
void rl_GetPhysicsShapeVertex(void *body, int vertex, void *out) {
  *RL_V2(out) = GetPhysicsShapeVertex((PhysicsBody)body, vertex);
}
void rl_PhysicsBodySetEnabled(void *body, int enabled) {
  ((PhysicsBody)body)->enabled = enabled != 0;
}
int rl_PhysicsBodyGetEnabled(void *body) {
  return ((PhysicsBody)body)->enabled ? 1 : 0;
}
float rl_PhysicsBodyGetPosY(void *body) { return ((PhysicsBody)body)->position.y; }
float rl_PhysicsBodyGetPosX(void *body) { return ((PhysicsBody)body)->position.x; }

/* ================================================================
 * Generated shims (tools/gen_physac.py). Same conventions as the
 * hand-written shims above; keep in sync by re-running the generator.
 * ================================================================ */


/* ---- generated shims ---- */
/** PhysicsShatter(params: void * body, void * position, float force -> void) */
void rl_PhysicsShatter(void * body, void * position, float force) {
  PhysicsShatter(*(PhysicsBody *)body, *RL_V2(position), force);
}
/** SetPhysicsBodyRotation(params: void * body, float radians -> void) */
void rl_SetPhysicsBodyRotation(void * body, float radians) {
  SetPhysicsBodyRotation(*(PhysicsBody *)body, radians);
}
