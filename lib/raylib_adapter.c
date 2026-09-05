#include <raylib.h>
#include <stdio.h>
#include <stdlib.h>
#include "spinel/runtime.h"

/* ================================================================
 * raylib_adapter.c — sp_ shims for Spinel AOT
 *
 * Linked directly against libraylib (-lraylib); raylib.h is the
 * single source of signature truth. Functions whose signatures
 * match raylib exactly need no wrapper: spinel generates externs
 * from the ffi_func declarations in lib/raylib_ffi.rb and the
 * linker resolves them straight to libraylib.so.
 *
 * Only shims live here. Spinel's FFI cannot pass or return C
 * structs by value (Color, Vector2, Texture2D), so entry points
 * that would take one take pointers instead, under sp_/renamed
 * symbols. Color structs are heap-allocated via ffi_struct (see
 * raylib_ffi.rb) and passed as void*.
 *
 * Bool-returning functions are also shimmed: the x86-64 ABI
 * returns _Bool in AL with unspecified upper bits, and spinel's
 * int-typed externs would read that garbage. Calling through the
 * raylib.h prototypes here makes the compiler extract AL cleanly.
 * ================================================================ */


/* ================================================================
 * sp_Color — native, GC-managed Color (see native_struct in
 * raylib_ffi.rb).
 *
 * Embeds the raylib Color struct directly so the entire object lives in
 * spinel's GC heap. When the last reference (e.g. a Bunny) is collected,
 * the GC reclaims the whole sp_Color automatically — nothing extra to
 * free, no leak, and no manual Color.free needed. cls_id is the object
 * header, stamped by the compiler-passed constructor argument.
 *
 * Spinel cannot pass a native object to an ffi_func :ptr/:any argument
 * (only as a native_method receiver), so every color-consuming draw call
 * is a method on the Color itself, with the color as the receiver.
 * ================================================================ */
typedef struct sp_Color_s {
  sp_int cls_id;   /* object header: runtime class id, compiler-stamped */
  Color c;         /* raylib Color: { unsigned char r,g,b,a; } */
} sp_Color;

static void sp_Color_scan(void *p) { (void)p; }

sp_Color *sp_Color_new(sp_int cls_id, sp_int r, sp_int g, sp_int b, sp_int a) {
  sp_Color *self = (sp_Color *)sp_gc_alloc(sizeof(sp_Color), NULL, sp_Color_scan);
  self->cls_id = cls_id;
  self->c = (Color){ (unsigned char)r, (unsigned char)g, (unsigned char)b, (unsigned char)a };
  return self;
}

void sp_ClearBackground(void *color) {
  ClearBackground(((sp_Color *)color)->c);
}
void sp_DrawText(const char *text, int x, int y, int size, void *color) {
  DrawText(text, x, y, size, ((sp_Color *)color)->c);
}
void sp_DrawTextInt(const char *prefix, int value, int x, int y, int size,
                    void *color) {
  char buf[256];
  snprintf(buf, sizeof(buf), "%s%d", prefix, value);
  DrawText(buf, x, y, size, ((sp_Color *)color)->c);
}
void sp_DrawTexture(void *tex, int x, int y, void *color) {
  DrawTexture(*(Texture2D *)tex, x, y, ((sp_Color *)color)->c);
}
void sp_DrawTextureEx(void *tex, float x, float y, float rotation,
                      float scale, void *color) {
  DrawTextureEx(*(Texture2D *)tex, (Vector2){x, y}, rotation, scale,
                ((sp_Color *)color)->c);
}

/* ---- Texture lifetime: Texture2D held on the heap behind a ptr ----
 * raylib returns Texture2D by value; spinel FFI can't receive it. */
void *sp_LoadTexture(const char *path) {
  Texture2D *t = (Texture2D *)malloc(sizeof(Texture2D));
  *t = LoadTexture(path);
  return t;
}
void sp_UnloadTexture(void *tex) {
  if (tex) {
    UnloadTexture(*(Texture2D *)tex);
    free(tex);
  }
}

/* ---- Shape shims: Vector2 and Color passed as pointers ---- */
void sp_DrawCircleV(void *center, float radius, void *color) {
  DrawCircleV(*(Vector2 *)center, radius, ((sp_Color *)color)->c);
}
void sp_DrawTriangle(void *v1, void *v2, void *v3, void *color) {
  DrawTriangle(*(Vector2 *)v1, *(Vector2 *)v2, *(Vector2 *)v3,
               ((sp_Color *)color)->c);
}


/* ---- Bool-returning raylib functions ----
 * See header comment: int-typed FFI externs must not read the
 * unspecified upper bits of a _Bool return. These wrappers are
 * compiled against raylib.h, so the bool->int conversion happens
 * at the call site where the compiler knows the real type. */
int sp_WindowShouldClose(void) { return WindowShouldClose(); }
int sp_IsKeyDown(int key) { return IsKeyDown(key); }
int sp_IsKeyPressed(int key) { return IsKeyPressed(key); }
int sp_IsGamepadButtonDown(int gamepad, int button) {
  return IsGamepadButtonDown(gamepad, button);
}


/* ================================================================
 * Vector3 — native, GC-managed 3D vector (mirrors sp_Color).
 * Embeds raylib's Vector3 { float x, y, z; }. Used by the 3D
 * columns example: stored in arrays, field-read with .x/.y/.z,
 * and passed (as its pointer) to the sp_Draw* shims below.
 * ================================================================ */
typedef struct sp_Vector3_s {
  sp_int cls_id;   /* object header */
  Vector3 v;       /* raylib Vector3 */
} sp_Vector3;

static void sp_Vector3_scan(void *p) { (void)p; }

sp_Vector3 *sp_Vector3_new(sp_int cls_id, double x, double y, double z) {
  sp_Vector3 *self = (sp_Vector3 *)sp_gc_alloc(sizeof(sp_Vector3), NULL, sp_Vector3_scan);
  self->cls_id = cls_id;
  self->v = (Vector3){ (float)x, (float)y, (float)z };
  return self;
}
double sp_Vector3_x(sp_Vector3 *self) { return self->v.x; }
double sp_Vector3_y(sp_Vector3 *self) { return self->v.y; }
double sp_Vector3_z(sp_Vector3 *self) { return self->v.z; }
void *sp_Vector3_ptr(sp_Vector3 *self) { return self; }


/* ================================================================
 * Camera — native, GC-managed Camera3D (mirrors sp_Color/sp_Vector3).
 * Embeds raylib's Camera3D. Built with the with_* chain, mutated in
 * place by UpdateCamera (via sp_UpdateCamera), and handed to
 * BeginMode3D (via sp_BeginMode3D). Both take this object's pointer.
 * ================================================================ */
typedef struct sp_Camera_s {
  sp_int cls_id;
  Camera3D c;
} sp_Camera;

static void sp_Camera_scan(void *p) { (void)p; }

sp_Camera *sp_Camera_new(sp_int cls_id) {
  sp_Camera *self = (sp_Camera *)sp_gc_alloc(sizeof(sp_Camera), NULL, sp_Camera_scan);
  self->cls_id = cls_id;
  self->c = (Camera3D){ 0 };
  return self;
}
sp_Camera *sp_Camera_with_position(sp_Camera *self, double x, double y, double z) {
  self->c.position = (Vector3){ (float)x, (float)y, (float)z };
  return self;
}
sp_Camera *sp_Camera_with_target(sp_Camera *self, double x, double y, double z) {
  self->c.target = (Vector3){ (float)x, (float)y, (float)z };
  return self;
}
sp_Camera *sp_Camera_with_up(sp_Camera *self, double x, double y, double z) {
  self->c.up = (Vector3){ (float)x, (float)y, (float)z };
  return self;
}
sp_Camera *sp_Camera_with_fovy(sp_Camera *self, double fovy) {
  self->c.fovy = (float)fovy;
  return self;
}
sp_Camera *sp_Camera_with_projection(sp_Camera *self, int projection) {
  self->c.projection = projection;
  return self;
}
void *sp_Camera_ptr(sp_Camera *self) { return self; }


/* ================================================================
 * Vector2 helper — heap allocates a raylib Vector2 and returns a
 * pointer (matches the ffi_func Vector2Create(:ptr) declaration).
 * Freed is unnecessary: raylib hands out small fixed-size Vec2s.
 * ================================================================ */
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


/* ================================================================
 * 3D / extra drawing shims for the columns example.
 * Vector3, Vector2, Camera3D and Color are passed as pointers
 * (spinel cannot pass structs by value; see header).
 *
 * NOTE: these are ffi_func entries, so their :float parameters lower
 * to C `float` (unlike native_method/native_new args, which use the
 * double-typed sp_float). Mismatching them (e.g. declaring `double`)
 * corrupts the dims passed by the generated ABI. See raylib_ffi.rb.
 * ================================================================ */
void sp_BeginMode3D(void *camera) {
  BeginMode3D(((sp_Camera *)camera)->c);
}
void sp_UpdateCamera(void *camera, int mode) {
  UpdateCamera(&((sp_Camera *)camera)->c, mode);
}
void sp_DrawPlane(void *pos, void *size, void *color) {
  DrawPlane(((sp_Vector3 *)pos)->v, *(Vector2 *)size, ((sp_Color *)color)->c);
}
void sp_DrawCube(void *pos, float w, float h, float l, void *color) {
  DrawCube(((sp_Vector3 *)pos)->v, w, h, l, ((sp_Color *)color)->c);
}
void sp_DrawCubeWires(void *pos, float w, float h, float l, void *color) {
  DrawCubeWires(((sp_Vector3 *)pos)->v, w, h, l, ((sp_Color *)color)->c);
}
void sp_DrawRectangle(int x, int y, int w, int h, void *color) {
  DrawRectangle(x, y, w, h, ((sp_Color *)color)->c);
}
void sp_DrawRectangleLines(int x, int y, int w, int h, void *color) {
  DrawRectangleLines(x, y, w, h, ((sp_Color *)color)->c);
}
