#include <raylib.h>
#include "physac.h"
#include <stdlib.h>
#include "spinel/runtime.h"

/* Mirror the raylib adapter's embedded-Vector2 wrapper. */
typedef struct rl_Vector2_s {
  sp_int cls_id;
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
  ((rl_Vector2 *)out)->v = GetPhysicsShapeVertex((PhysicsBody)body, vertex);
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
  PhysicsShatter(*(PhysicsBody *)body, ((rl_Vector2*)position)->v, force);
}
/** SetPhysicsBodyRotation(params: void * body, float radians -> void) */
void rl_SetPhysicsBodyRotation(void * body, float radians) {
  SetPhysicsBodyRotation(*(PhysicsBody *)body, radians);
}
