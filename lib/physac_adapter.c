#include <raylib.h>
#include "physac.h"
#include <stdlib.h>
#include "spinel/runtime.h"

/* Mirror the raylib adapter's embedded-Vector2 wrapper. */
typedef struct sp_Vector2_s {
  sp_int cls_id;
  Vector2 v;
} sp_Vector2;

/* physac_adapter.c — sp_ shims for Spinel AOT.
 *
 * PhysicsBody is an opaque pointer; bodies are created with Vector2 by value,
 * so those shims take raw floats. Field reads/writes go through accessors. */

void *sp_InitPhysics(void) { InitPhysics(); return NULL; }
void sp_UpdatePhysics1(void) { UpdatePhysics(); }
void sp_ResetPhysics(void) { ResetPhysics(); }
void sp_ClosePhysics(void) { ClosePhysics(); }
void sp_SetPhysicsGravity(float x, float y) { SetPhysicsGravity(x, y); }
void sp_SetPhysicsTimeStep(double delta) { SetPhysicsTimeStep(delta); }

void *sp_CreatePhysicsBodyCircle(float x, float y, float radius, float density) {
  return CreatePhysicsBodyCircle((Vector2){ x, y }, radius, density);
}
void *sp_CreatePhysicsBodyRectangle(float x, float y, float width, float height,
                                    float density) {
  return CreatePhysicsBodyRectangle((Vector2){ x, y }, width, height, density);
}
void *sp_CreatePhysicsBodyPolygon(float x, float y, float radius, int sides,
                                  float density) {
  return CreatePhysicsBodyPolygon((Vector2){ x, y }, radius, sides, density);
}
void sp_DestroyPhysicsBody(void *body) { DestroyPhysicsBody((PhysicsBody)body); }
void sp_PhysicsAddForce(void *body, float x, float y) {
  PhysicsAddForce((PhysicsBody)body, (Vector2){ x, y });
}
void sp_PhysicsAddTorque(void *body, float amount) {
  PhysicsAddTorque((PhysicsBody)body, amount);
}
void *sp_GetPhysicsBody(int index) { return GetPhysicsBody(index); }
int sp_GetPhysicsBodiesCount(void) { return GetPhysicsBodiesCount(); }
int sp_GetPhysicsShapeType(int index) { return GetPhysicsShapeType(index); }
int sp_GetPhysicsShapeVerticesCount(int index) {
  return GetPhysicsShapeVerticesCount(index);
}
void sp_GetPhysicsShapeVertex(void *body, int vertex, void *out) {
  ((sp_Vector2 *)out)->v = GetPhysicsShapeVertex((PhysicsBody)body, vertex);
}
void sp_PhysicsBodySetEnabled(void *body, int enabled) {
  ((PhysicsBody)body)->enabled = enabled != 0;
}
int sp_PhysicsBodyGetEnabled(void *body) {
  return ((PhysicsBody)body)->enabled ? 1 : 0;
}
float sp_PhysicsBodyGetPosY(void *body) { return ((PhysicsBody)body)->position.y; }
float sp_PhysicsBodyGetPosX(void *body) { return ((PhysicsBody)body)->position.x; }
