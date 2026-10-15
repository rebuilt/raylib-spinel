#include <raylib.h>
#include <rlgl.h>           /* immediate-mode batch for rl_DrawPixelsPacked */
#include <raymath.h>        /* raymath funcs (RL_* guards swallow duplicated types) */
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


/* ================================================================
 * raylib_adapter.c — rl_ shims for Spinel AOT
 *
 * Linked directly against libraylib (-lraylib); raylib.h is the
 * single source of signature truth. Functions whose signatures
 * match raylib exactly need no wrapper: spinel generates externs
 * from the ffi_func declarations in lib/raylib_ffi.rb and the
 * linker resolves them straight to libraylib.so.
 *
 * Only shims live here. Spinel's FFI cannot pass or return C
 * structs by value (Color, Vector2, Texture2D), so entry points
 * that would take one take pointers instead, under rl_/renamed
 * symbols. Color structs are heap-allocated via ffi_struct (see
 * raylib_ffi.rb) and passed as void*.
 *
 * Bool-returning functions are also shimmed: the x86-64 ABI
 * returns _Bool in AL with unspecified upper bits, and spinel's
 * int-typed externs would read that garbage. Calling through the
 * raylib.h prototypes here makes the compiler extract AL cleanly.
 * ================================================================ */


/* ================================================================
 * rl_Color — native, GC-managed Color (see native_struct in
 * raylib_ffi.rb).
 *
 * Embeds the raylib Color struct directly so the entire object lives in
 * spinel's GC heap. When the last reference (e.g. a Bunny) is collected,
 * the GC reclaims the whole rl_Color automatically — nothing extra to
 * free, no leak, and no manual Color.free needed. cls_id is the object
 * header, stamped by the compiler-passed constructor argument.
 *
 * Spinel cannot pass a native object to an ffi_func :ptr/:any argument
 * (only as a native_method receiver), so every color-consuming draw call
 * is a method on the Color itself, with the color as the receiver.
 * ================================================================ */
typedef struct rl_Color_s {
  sp_int cls_id;   /* object header: runtime class id, compiler-stamped */
  Color c;         /* raylib Color: { unsigned char r,g,b,a; } */
} rl_Color;

static void rl_Color_scan(void *p) { (void)p; }

rl_Color *rl_Color_new(sp_int cls_id, sp_int r, sp_int g, sp_int b, sp_int a) {
  rl_Color *self = (rl_Color *)sp_gc_alloc(sizeof(rl_Color), NULL, rl_Color_scan);
  self->cls_id = cls_id;
  self->c = (Color){ (unsigned char)r, (unsigned char)g, (unsigned char)b, (unsigned char)a };
  return self;
}
sp_int rl_Color_set_r(rl_Color *self, sp_int r) { self->c.r = (unsigned char)r; return r; }
sp_int rl_Color_set_g(rl_Color *self, sp_int g) { self->c.g = (unsigned char)g; return g; }
sp_int rl_Color_set_b(rl_Color *self, sp_int b) { self->c.b = (unsigned char)b; return b; }
sp_int rl_Color_set_a(rl_Color *self, sp_int a) { self->c.a = (unsigned char)a; return a; }

/* rl_Vector2 — GC-embedded Vector2 (see raylib_ffi.rb). Declared early so the
 * generated shims below (and the raw Vector2 helpers) read the embedded `v`
 * instead of mistaking the cls_id header for the coordinates. */
typedef struct rl_Vector2_s {
  sp_int cls_id;
  Vector2 *p;     /* NULL: owned (payload in v); non-NULL: a view */
  sp_RbVal owner;  /* view: GC-marked reference to the owner */
  Vector2 v;
} rl_Vector2;

/* Vector2 helper — heap allocates a native-shaped rl_Vector2 and returns a
 * pointer (matches the ffi_func Vector2Create(:ptr) declaration). Freed is
 * unnecessary: these are small fixed-size vectors. The struct carries the same
 * header + embedded Vector2 layout the shims now read via ->v. */
void *Vector2Create(float x, float y) {
  rl_Vector2 *v = (rl_Vector2 *)malloc(sizeof(rl_Vector2));
  v->cls_id = 0;
  v->p = NULL;
  v->v = (Vector2){ x, y };
  return v;
}
float Vector2GetX(void *v) { return RL_V2(v)->x; }
float Vector2GetY(void *v) { return RL_V2(v)->y; }
void Vector2SetX(void *v, float x) { RL_V2(v)->x = x; }
void Vector2SetY(void *v, float y) { RL_V2(v)->y = y; }

/* rl_Camera — GC-embedded Camera3D (see raylib_ffi.rb). Declared early so
 * rl_Camera3DCreate returns the same header+embedded layout the
 * rl_BeginMode3D / rl_UpdateCamera / rl_GetWorldToScreen shims read via ->c. */
typedef struct rl_Camera_s {
  sp_int cls_id;
  Camera3D c;
} rl_Camera;

void rl_ClearBackground(void *color) {
  ClearBackground(((rl_Color *)color)->c);
}
void rl_DrawText(const char *text, int x, int y, int size, void *color) {
  DrawText(text, x, y, size, ((rl_Color *)color)->c);
}
void rl_DrawTextInt(const char *prefix, int value, int x, int y, int size,
                    void *color) {
  char buf[256];
  snprintf(buf, sizeof(buf), "%s%d", prefix, value);
  DrawText(buf, x, y, size, ((rl_Color *)color)->c);
}
float rl_FontBaseSize(void *font) { return (float)(RL_FONT(font))->baseSize; }
int rl_TextureWidth(void *texture) { return (int)(RL_TEX(texture))->width; }
int rl_TextureHeight(void *texture) { return (int)(RL_TEX(texture))->height; }
void rl_DrawTextureRec4(void *texture, float x, float y, float w, float h,
                        void *position, void *tint) {
  Rectangle src = { x, y, w, h };
  DrawTextureRec(*RL_TEX(texture), src, *RL_V2(position),
                 ((rl_Color *)tint)->c);
}
void rl_BeginMode2DF(float target_x, float target_y, float offset_x,
                     float offset_y, float rotation, float zoom) {
  Camera2D cam = { 0 };
  cam.target.x = target_x;
  cam.target.y = target_y;
  cam.offset.x = offset_x;
  cam.offset.y = offset_y;
  cam.rotation = rotation;
  cam.zoom = zoom;
  BeginMode2D(cam);
}
void rl_DrawRectangleRecF(float x, float y, float w, float h, void *color) {
  DrawRectangleRec((Rectangle){ x, y, w, h }, ((rl_Color *)color)->c);
}
void *rl_Camera3DCreate(float px, float py, float pz, float tx, float ty,
                        float tz, float ux, float uy, float uz, float fovy,
                        int projection) {
  /* Native-shaped so the rl_BeginMode3D / rl_UpdateCamera / GetWorldToScreen
   * shims (which read ((rl_Camera*)p)->c) see the camera, not the cls_id. */
  rl_Camera *cam = (rl_Camera *)malloc(sizeof(rl_Camera));
  cam->cls_id = 0;
  cam->c.position = (Vector3){ px, py, pz };
  cam->c.target = (Vector3){ tx, ty, tz };
  cam->c.up = (Vector3){ ux, uy, uz };
  cam->c.fovy = fovy;
  cam->c.projection = projection;
  return cam;
}
void rl_EndMode3D(void) { EndMode3D(); }
void rl_DrawGrid(int slices, float spacing) { DrawGrid(slices, spacing); }
void rl_DrawRenderTexture(void *target, void *tint) {
  RenderTexture2D *rt = RL_RT(target);
  Rectangle src = { 0, 0, (float)rt->texture.width, (float)-rt->texture.height };
  DrawTextureRec(rt->texture, src, (Vector2){ 0, 0 }, ((rl_Color *)tint)->c);
}
void rl_DrawRenderTextureAt(void *target, int x, int y, void *tint) {
  RenderTexture2D *rt = RL_RT(target);
  Rectangle src = { 0, 0, (float)rt->texture.width, (float)-rt->texture.height };
  DrawTextureRec(rt->texture, src, (Vector2){ (float)x, (float)y }, ((rl_Color *)tint)->c);
}
void rl_DrawRenderTexturePro(void *target, float rotation, void *tint) {
  RenderTexture2D *rt = RL_RT(target);
  DrawTexturePro(rt->texture,
                 (Rectangle){ 0, 0, (float)rt->texture.width, (float)-rt->texture.height },
                 (Rectangle){ GetScreenWidth()/2.0f, GetScreenHeight()/2.0f,
                              (float)rt->texture.width, (float)rt->texture.height },
                 (Vector2){ rt->texture.width/2.0f, rt->texture.height/2.0f },
                 rotation, ((rl_Color *)tint)->c);
}
void *rl_RenderTexture_texture_ptr(void *target) {
  return &(RL_RT(target))->texture;
}
void *rl_LoadImageFromRenderTexture(void *target) {
  RenderTexture2D *rt = RL_RT(target);
  Image *r = (Image *)malloc(sizeof(Image));
  *r = LoadImageFromTexture(rt->texture);
  return r;
}
void rl_DrawTexture(void *tex, int x, int y, void *color) {
  DrawTexture(*RL_TEX(tex), x, y, ((rl_Color *)color)->c);
}
/* Data-oriented draw: the tint is a packed 0xRRGGBBAA integer, so callers
 * that keep colors in a flat int array need no rl_Color object per sprite. */
void rl_DrawTexturePacked(void *tex, int x, int y, int rgba) {
  unsigned int u = (unsigned int)rgba;
  DrawTexture(*RL_TEX(tex), x, y,
              (Color){ (unsigned char)(u >> 24), (unsigned char)(u >> 16),
                       (unsigned char)(u >> 8), (unsigned char)u });
}
void rl_DrawTextureEx(void *tex, float x, float y, float rotation,
                      float scale, void *color) {
  DrawTextureEx(*RL_TEX(tex), (Vector2){x, y}, rotation, scale,
                ((rl_Color *)color)->c);
}

/* ---- Texture lifetime: Texture2D held on the heap behind a ptr ----
 * raylib returns Texture2D by value; spinel FFI can't receive it. */
void *rl_LoadTexture(const char *path) {
  Texture2D *t = (Texture2D *)malloc(sizeof(Texture2D));
  *t = LoadTexture(path);
  return t;
}

void rl_UnloadTexture(void *tex) {
  if (tex) {
    Texture2D *self = RL_TEX(tex);   /* the view points at the heap copy */
    UnloadTexture(*self);
    free(self);
  }
}

/* ---- Shape shims: Vector2 and Color passed as pointers ---- */
void rl_DrawCircleV(void *center, float radius, void *color) {
  DrawCircleV(*RL_V2(center), radius, ((rl_Color *)color)->c);
}
void rl_DrawPixel(int x, int y, void *color) {
  DrawPixel(x, y, ((rl_Color *)color)->c);
}
/* Data-oriented draw: the color is a packed 0xRRGGBBAA integer, so callers
 * that keep colors in a flat int array need no rl_Color object per pixel. */
void rl_DrawPixelPacked(int x, int y, int rgba) {
  unsigned int u = (unsigned int)rgba;
  DrawPixel(x, y,
            (Color){ (unsigned char)(u >> 24), (unsigned char)(u >> 16),
                     (unsigned char)(u >> 8), (unsigned char)u });
}
/* Batch-draw `count` 1x1 pixels from parallel packed pools in ONE immediate-mode
 * batch. raylib's DrawPixel opens/colors/emits/closes a batch per pixel, so
 * 120k particles meant ~700k Ruby->C calls + a batch flush per pixel; this does
 * one call and one rlBegin..rlEnd for the whole pool. The FFI passes the flat
 * data pointers (rl_*Array_ffi_data), so no per-element access on the Ruby side.
 * Coordinates arrive as doubles (sp_FloatArray stores doubles). */
void rl_DrawPixelsPacked(const double *xs, const double *ys,
                         const int64_t *colors, int count) {
  /* Mirror raylib's DrawPixelV: bind the 1x1 shapes texture for the whole
   * batch (without it the quads do not draw), then emit every pixel between a
   * single rlBegin/rlEnd. */
  Texture2D tex = GetShapesTexture();
  Rectangle sr = GetShapesTextureRectangle();
  float u0 = sr.x / (float)tex.width;
  float v0 = sr.y / (float)tex.height;
  float u1 = (sr.x + sr.width) / (float)tex.width;
  float v1 = (sr.y + sr.height) / (float)tex.height;

  rlSetTexture(tex.id);
  rlBegin(RL_QUADS);
  for (int i = 0; i < count; i++) {
    unsigned int u = (unsigned int)colors[i];
    rlNormal3f(0.0f, 0.0f, 1.0f);
    rlColor4ub((unsigned char)(u >> 24), (unsigned char)(u >> 16),
               (unsigned char)(u >> 8), (unsigned char)u);
    float x = (float)xs[i];
    float y = (float)ys[i];
    rlTexCoord2f(u0, v0); rlVertex2f(x, y);
    rlTexCoord2f(u0, v1); rlVertex2f(x, y + 1.0f);
    rlTexCoord2f(u1, v1); rlVertex2f(x + 1.0f, y + 1.0f);
    rlTexCoord2f(u1, v0); rlVertex2f(x + 1.0f, y);
  }
  rlEnd();
  rlSetTexture(0);
}
void rl_DrawTriangle(void *v1, void *v2, void *v3, void *color) {
  DrawTriangle(*RL_V2(v1), *RL_V2(v2), *RL_V2(v3),
               ((rl_Color *)color)->c);
}


/* ================================================================
 * Vector3 — native, GC-managed 3D vector (mirrors rl_Color).
 * Embeds raylib's Vector3 { float x, y, z; }. Used by the 3D
 * columns example: stored in arrays, field-read with .x/.y/.z,
 * and passed (as its pointer) to the rl_Draw* shims below.
 * ================================================================ */
typedef struct rl_Vector3_s {
  sp_int cls_id;   /* object header */
  Vector3 *p;     /* NULL: owned (payload in v); non-NULL: a view */
  sp_RbVal owner;  /* view: GC-marked reference to the owner */
  Vector3 v;       /* raylib Vector3 */
} rl_Vector3;

static void rl_Vector3_scan(void *p) {
  rl_Vector3 *s = (rl_Vector3 *)p;
  if (s->p) sp_mark_rbval(s->owner);
}

rl_Vector3 *rl_Vector3_new(sp_int cls_id, double x, double y, double z) {
  rl_Vector3 *self = (rl_Vector3 *)sp_gc_alloc(sizeof(rl_Vector3), NULL, rl_Vector3_scan);
  self->cls_id = cls_id;
  self->p = NULL;
  self->v = (Vector3){ (float)x, (float)y, (float)z };
  return self;
}

Vector3 *rl_Vector3_view(sp_int cls_id, void *p, sp_RbVal owner) {
  rl_Vector3 *self = (rl_Vector3 *)sp_gc_alloc(sizeof(rl_Vector3), NULL, rl_Vector3_scan);
  self->cls_id = cls_id;
  self->p = NULL;
  self->p = (Vector3 *)p;
  self->owner = owner;
  return self;
}
double rl_Vector3_x(rl_Vector3 *self) { return RL_V3(self)->x; }
double rl_Vector3_y(rl_Vector3 *self) { return RL_V3(self)->y; }
double rl_Vector3_z(rl_Vector3 *self) { return RL_V3(self)->z; }
double rl_Vector3_set_x(rl_Vector3 *self, double x) { RL_V3(self)->x = (float)x; return x; }
double rl_Vector3_set_y(rl_Vector3 *self, double y) { RL_V3(self)->y = (float)y; return y; }
double rl_Vector3_set_z(rl_Vector3 *self, double z) { RL_V3(self)->z = (float)z; return z; }
void *rl_Vector3_ptr(rl_Vector3 *self) { return self; }


/* ================================================================
 * Camera — native, GC-managed Camera3D (mirrors rl_Color/rl_Vector3).
 * Embeds raylib's Camera3D. Built with the with_* chain, mutated in
 * place by UpdateCamera (via rl_UpdateCamera), and handed to
 * BeginMode3D (via rl_BeginMode3D). Both take this object's pointer.
 * (struct declared near the top, shared with rl_Camera3DCreate.)
 * ================================================================ */
static void rl_Camera_scan(void *p) { (void)p; }

rl_Camera *rl_Camera_new(sp_int cls_id) {
  rl_Camera *self = (rl_Camera *)sp_gc_alloc(sizeof(rl_Camera), NULL, rl_Camera_scan);
  self->cls_id = cls_id;
  self->c = (Camera3D){ 0 };
  return self;
}
rl_Camera *rl_Camera_with_position(rl_Camera *self, double x, double y, double z) {
  self->c.position = (Vector3){ (float)x, (float)y, (float)z };
  return self;
}
rl_Camera *rl_Camera_with_target(rl_Camera *self, double x, double y, double z) {
  self->c.target = (Vector3){ (float)x, (float)y, (float)z };
  return self;
}
rl_Camera *rl_Camera_with_up(rl_Camera *self, double x, double y, double z) {
  self->c.up = (Vector3){ (float)x, (float)y, (float)z };
  return self;
}
rl_Camera *rl_Camera_with_fovy(rl_Camera *self, double fovy) {
  self->c.fovy = (float)fovy;
  return self;
}
rl_Camera *rl_Camera_with_projection(rl_Camera *self, int projection) {
  self->c.projection = projection;
  return self;
}
void *rl_Camera_ptr(rl_Camera *self) { return self; }

/* Sub-struct views (P2): interior pointers into the embedded Camera3D; the
 * Ruby layer wraps them with Vector3.new(ptr, self) so writes reach the
 * camera and the view keeps it alive (owner is GC-marked by the view's scan). */
void *rl_Camera_position_ptr(rl_Camera *self) { return (void *)&self->c.position; }
void *rl_Camera_target_ptr(rl_Camera *self) { return (void *)&self->c.target; }
void *rl_Camera_up_ptr(rl_Camera *self) { return (void *)&self->c.up; }
double rl_Camera_fovy(rl_Camera *self) { return (double)self->c.fovy; }
double rl_Camera_set_fovy(rl_Camera *self, double v) { self->c.fovy = (float)v; return v; }
sp_int rl_Camera_projection(rl_Camera *self) { return (sp_int)self->c.projection; }
sp_int rl_Camera_set_projection(rl_Camera *self, sp_int p) { self->c.projection = (int)p; return p; }


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
void rl_BeginMode3D(void *camera) {
  BeginMode3D(((rl_Camera *)camera)->c);
}
void rl_UpdateCamera(void *camera, int mode) {
  UpdateCamera(&((rl_Camera *)camera)->c, mode);
}
void rl_DrawPlane(void *pos, void *size, void *color) {
  DrawPlane(*RL_V3(pos), *RL_V2(size), ((rl_Color *)color)->c);
}
void rl_DrawCube(void *pos, float w, float h, float l, void *color) {
  DrawCube(*RL_V3(pos), w, h, l, ((rl_Color *)color)->c);
}
void rl_DrawCubeWires(void *pos, float w, float h, float l, void *color) {
  DrawCubeWires(*RL_V3(pos), w, h, l, ((rl_Color *)color)->c);
}
void rl_DrawRectangle(int x, int y, int w, int h, void *color) {
  DrawRectangle(x, y, w, h, ((rl_Color *)color)->c);
}
void rl_DrawRectangleLines(int x, int y, int w, int h, void *color) {
  DrawRectangleLines(x, y, w, h, ((rl_Color *)color)->c);
}

/* ================================================================
 * Generated shims (tools/gen_raylib_ffi.py). Same conventions as the
 * hand-written shims above; keep in sync by re-running the generator.
 * ================================================================ */


/* rl_Vector4 — GC-embedded Vector4 (see raylib_ffi.rb) */typedef struct rl_Vector4_s {
  sp_int cls_id;
  Vector4 *p;     /* NULL: owned (payload in v); non-NULL: a view */
  sp_RbVal owner;  /* view: GC-marked reference to the owner */
  Vector4 v;
} rl_Vector4;
static void rl_Vector4_scan(void *p) {
  rl_Vector4 *s = (rl_Vector4 *)p;
  if (s->p) sp_mark_rbval(s->owner);
}
rl_Vector4 *rl_Vector4_new(sp_int cls_id) {
  rl_Vector4 *self = (rl_Vector4 *)sp_gc_alloc(sizeof(rl_Vector4), NULL, rl_Vector4_scan);
  self->cls_id = cls_id;
  self->p = NULL;
  self->v = (Vector4){ 0 };
  return self;
}

Vector4 *rl_Vector4_view(sp_int cls_id, void *p, sp_RbVal owner) {
  rl_Vector4 *self = (rl_Vector4 *)sp_gc_alloc(sizeof(rl_Vector4), NULL, rl_Vector4_scan);
  self->cls_id = cls_id;
  self->p = NULL;
  self->p = (Vector4 *)p;
  self->owner = owner;
  return self;
}
double rl_Vector4_x(rl_Vector4 *self) {
  return (double)RL_V4(self)->x;
}
double rl_Vector4_set_x(rl_Vector4 *self, double x) {
  RL_V4(self)->x = (float)x;
  return x;
}
double rl_Vector4_y(rl_Vector4 *self) {
  return (double)RL_V4(self)->y;
}
double rl_Vector4_set_y(rl_Vector4 *self, double y) {
  RL_V4(self)->y = (float)y;
  return y;
}
double rl_Vector4_z(rl_Vector4 *self) {
  return (double)RL_V4(self)->z;
}
double rl_Vector4_set_z(rl_Vector4 *self, double z) {
  RL_V4(self)->z = (float)z;
  return z;
}
double rl_Vector4_w(rl_Vector4 *self) {
  return (double)RL_V4(self)->w;
}
double rl_Vector4_set_w(rl_Vector4 *self, double w) {
  RL_V4(self)->w = (float)w;
  return w;
}

/* rl_Rectangle — GC-embedded Rectangle (see raylib_ffi.rb) */typedef struct rl_Rectangle_s {
  sp_int cls_id;
  Rectangle *p;     /* NULL: owned (payload in v); non-NULL: a view */
  sp_RbVal owner;  /* view: GC-marked reference to the owner */
  Rectangle v;
} rl_Rectangle;
static void rl_Rectangle_scan(void *p) {
  rl_Rectangle *s = (rl_Rectangle *)p;
  if (s->p) sp_mark_rbval(s->owner);
}
rl_Rectangle *rl_Rectangle_new(sp_int cls_id) {
  rl_Rectangle *self = (rl_Rectangle *)sp_gc_alloc(sizeof(rl_Rectangle), NULL, rl_Rectangle_scan);
  self->cls_id = cls_id;
  self->p = NULL;
  self->v = (Rectangle){ 0 };
  return self;
}

Rectangle *rl_Rectangle_view(sp_int cls_id, void *p, sp_RbVal owner) {
  rl_Rectangle *self = (rl_Rectangle *)sp_gc_alloc(sizeof(rl_Rectangle), NULL, rl_Rectangle_scan);
  self->cls_id = cls_id;
  self->p = (Rectangle *)p;
  self->owner = owner;
  return self;
}
double rl_Rectangle_x(rl_Rectangle *self) {
  return (double)RL_RECT(self)->x;
}
double rl_Rectangle_set_x(rl_Rectangle *self, double x) {
  RL_RECT(self)->x = (float)x;
  return x;
}
double rl_Rectangle_y(rl_Rectangle *self) {
  return (double)RL_RECT(self)->y;
}
double rl_Rectangle_set_y(rl_Rectangle *self, double y) {
  RL_RECT(self)->y = (float)y;
  return y;
}
double rl_Rectangle_width(rl_Rectangle *self) {
  return (double)RL_RECT(self)->width;
}
double rl_Rectangle_set_width(rl_Rectangle *self, double width) {
  RL_RECT(self)->width = (float)width;
  return width;
}
double rl_Rectangle_height(rl_Rectangle *self) {
  return (double)RL_RECT(self)->height;
}
double rl_Rectangle_set_height(rl_Rectangle *self, double height) {
  RL_RECT(self)->height = (float)height;
  return height;
}

/* rl_Camera2D — GC-embedded Camera2D (see raylib_ffi.rb) */typedef struct rl_Camera2D_s {
  sp_int cls_id;
  Camera2D v;
} rl_Camera2D;
static void rl_Camera2D_scan(void *p) { (void)p; }
rl_Camera2D *rl_Camera2D_new(sp_int cls_id) {
  rl_Camera2D *self = (rl_Camera2D *)sp_gc_alloc(sizeof(rl_Camera2D), NULL, rl_Camera2D_scan);
  self->cls_id = cls_id;
  self->v = (Camera2D){ 0 };
  return self;
}
double rl_Camera2D_rotation(rl_Camera2D *self) {
  return (double)self->v.rotation;
}
/* Sub-struct views (P2): offset/target point into the embedded Camera2D. */
void *rl_Camera2D_offset_ptr(rl_Camera2D *self) { return (void *)&self->v.offset; }
void *rl_Camera2D_target_ptr(rl_Camera2D *self) { return (void *)&self->v.target; }
double rl_Camera2D_set_rotation(rl_Camera2D *self, double rotation) {
  self->v.rotation = (float)rotation;
  return rotation;
}
double rl_Camera2D_zoom(rl_Camera2D *self) {
  return (double)self->v.zoom;
}
double rl_Camera2D_set_zoom(rl_Camera2D *self, double zoom) {
  self->v.zoom = (float)zoom;
  return zoom;
}

/* rl_BoundingBox — GC-embedded BoundingBox (see raylib_ffi.rb) */typedef struct rl_BoundingBox_s {
  sp_int cls_id;
  BoundingBox v;
} rl_BoundingBox;
static void rl_BoundingBox_scan(void *p) { (void)p; }
rl_BoundingBox *rl_BoundingBox_new(sp_int cls_id) {
  rl_BoundingBox *self = (rl_BoundingBox *)sp_gc_alloc(sizeof(rl_BoundingBox), NULL, rl_BoundingBox_scan);
  self->cls_id = cls_id;
  self->v = (BoundingBox){ 0 };
  return self;
}
rl_BoundingBox *rl_BoundingBox_with_min(rl_BoundingBox *self, double x, double y, double z) {
  self->v.min = (Vector3){ (float)x, (float)y, (float)z };
  return self;
}
rl_BoundingBox *rl_BoundingBox_with_max(rl_BoundingBox *self, double x, double y, double z) {
  self->v.max = (Vector3){ (float)x, (float)y, (float)z };
  return self;
}
/* Sub-struct views (P2): min/max point into the embedded BoundingBox. */
void *rl_BoundingBox_min_ptr(rl_BoundingBox *self) { return (void *)&self->v.min; }
void *rl_BoundingBox_max_ptr(rl_BoundingBox *self) { return (void *)&self->v.max; }

/* rl_Transform - GC-embedded Transform (translation/rotation/scale); t/r/s are views. */
typedef struct rl_Transform_s {
  sp_int cls_id;
  Transform v;
} rl_Transform;
static void rl_Transform_scan(void *p) { (void)p; }
rl_Transform *rl_Transform_new(sp_int cls_id) {
  rl_Transform *self = (rl_Transform *)sp_gc_alloc(sizeof(rl_Transform), NULL, rl_Transform_scan);
  self->cls_id = cls_id;
  self->v = (Transform){ 0 };
  return self;
}
void *rl_Transform_t_ptr(rl_Transform *self) { return (void *)&self->v.translation; }
void *rl_Transform_r_ptr(rl_Transform *self) { return (void *)&self->v.rotation; }
void *rl_Transform_s_ptr(rl_Transform *self) { return (void *)&self->v.scale; }

/* rl_Ray — GC-embedded Ray (see raylib_ffi.rb) */typedef struct rl_Ray_s {
  sp_int cls_id;
  Ray v;
} rl_Ray;
static void rl_Ray_scan(void *p) { (void)p; }
rl_Ray *rl_Ray_new(sp_int cls_id) {
  rl_Ray *self = (rl_Ray *)sp_gc_alloc(sizeof(rl_Ray), NULL, rl_Ray_scan);
  self->cls_id = cls_id;
  self->v = (Ray){ 0 };
  return self;
}

/* rl_RayCollision — GC-embedded RayCollision (see raylib_ffi.rb) */typedef struct rl_RayCollision_s {
  sp_int cls_id;
  RayCollision v;
} rl_RayCollision;
static void rl_RayCollision_scan(void *p) { (void)p; }
rl_RayCollision *rl_RayCollision_new(sp_int cls_id) {
  rl_RayCollision *self = (rl_RayCollision *)sp_gc_alloc(sizeof(rl_RayCollision), NULL, rl_RayCollision_scan);
  self->cls_id = cls_id;
  self->v = (RayCollision){ 0 };
  return self;
}
int rl_RayCollision_hit(rl_RayCollision *self) {
  return self->v.hit ? 1 : 0;
}
int rl_RayCollision_set_hit(rl_RayCollision *self, int hit) {
  self->v.hit = hit != 0;
  return hit;
}
double rl_RayCollision_distance(rl_RayCollision *self) {
  return (double)self->v.distance;
}
double rl_RayCollision_set_distance(rl_RayCollision *self, double distance) {
  self->v.distance = (float)distance;
  return distance;
}

/* rl_Matrix — GC-embedded Matrix (see raylib_ffi.rb) */typedef struct rl_Matrix_s {
  sp_int cls_id;
  Matrix v;
} rl_Matrix;
static void rl_Matrix_scan(void *p) { (void)p; }
rl_Matrix *rl_Matrix_new(sp_int cls_id) {
  rl_Matrix *self = (rl_Matrix *)sp_gc_alloc(sizeof(rl_Matrix), NULL, rl_Matrix_scan);
  self->cls_id = cls_id;
  self->v = (Matrix){ 0 };
  return self;
}
double rl_Matrix_m0(rl_Matrix *self) {
  return (double)self->v.m0;
}
double rl_Matrix_set_m0(rl_Matrix *self, double m0) {
  self->v.m0 = (float)m0;
  return m0;
}
double rl_Matrix_m4(rl_Matrix *self) {
  return (double)self->v.m4;
}
double rl_Matrix_set_m4(rl_Matrix *self, double m4) {
  self->v.m4 = (float)m4;
  return m4;
}
double rl_Matrix_m8(rl_Matrix *self) {
  return (double)self->v.m8;
}
double rl_Matrix_set_m8(rl_Matrix *self, double m8) {
  self->v.m8 = (float)m8;
  return m8;
}
double rl_Matrix_m12(rl_Matrix *self) {
  return (double)self->v.m12;
}
double rl_Matrix_set_m12(rl_Matrix *self, double m12) {
  self->v.m12 = (float)m12;
  return m12;
}
double rl_Matrix_m1(rl_Matrix *self) {
  return (double)self->v.m1;
}
double rl_Matrix_set_m1(rl_Matrix *self, double m1) {
  self->v.m1 = (float)m1;
  return m1;
}
double rl_Matrix_m5(rl_Matrix *self) {
  return (double)self->v.m5;
}
double rl_Matrix_set_m5(rl_Matrix *self, double m5) {
  self->v.m5 = (float)m5;
  return m5;
}
double rl_Matrix_m9(rl_Matrix *self) {
  return (double)self->v.m9;
}
double rl_Matrix_set_m9(rl_Matrix *self, double m9) {
  self->v.m9 = (float)m9;
  return m9;
}
double rl_Matrix_m13(rl_Matrix *self) {
  return (double)self->v.m13;
}
double rl_Matrix_set_m13(rl_Matrix *self, double m13) {
  self->v.m13 = (float)m13;
  return m13;
}
double rl_Matrix_m2(rl_Matrix *self) {
  return (double)self->v.m2;
}
double rl_Matrix_set_m2(rl_Matrix *self, double m2) {
  self->v.m2 = (float)m2;
  return m2;
}
double rl_Matrix_m6(rl_Matrix *self) {
  return (double)self->v.m6;
}
double rl_Matrix_set_m6(rl_Matrix *self, double m6) {
  self->v.m6 = (float)m6;
  return m6;
}
double rl_Matrix_m10(rl_Matrix *self) {
  return (double)self->v.m10;
}
double rl_Matrix_set_m10(rl_Matrix *self, double m10) {
  self->v.m10 = (float)m10;
  return m10;
}
double rl_Matrix_m14(rl_Matrix *self) {
  return (double)self->v.m14;
}
double rl_Matrix_set_m14(rl_Matrix *self, double m14) {
  self->v.m14 = (float)m14;
  return m14;
}
double rl_Matrix_m3(rl_Matrix *self) {
  return (double)self->v.m3;
}
double rl_Matrix_set_m3(rl_Matrix *self, double m3) {
  self->v.m3 = (float)m3;
  return m3;
}
double rl_Matrix_m7(rl_Matrix *self) {
  return (double)self->v.m7;
}
double rl_Matrix_set_m7(rl_Matrix *self, double m7) {
  self->v.m7 = (float)m7;
  return m7;
}
double rl_Matrix_m11(rl_Matrix *self) {
  return (double)self->v.m11;
}
double rl_Matrix_set_m11(rl_Matrix *self, double m11) {
  self->v.m11 = (float)m11;
  return m11;
}
double rl_Matrix_m15(rl_Matrix *self) {
  return (double)self->v.m15;
}
double rl_Matrix_set_m15(rl_Matrix *self, double m15) {
  self->v.m15 = (float)m15;
  return m15;
}

/* rl_NPatchInfo — GC-embedded NPatchInfo (see raylib_ffi.rb) */typedef struct rl_NPatchInfo_s {
  sp_int cls_id;
  NPatchInfo v;
} rl_NPatchInfo;
static void rl_NPatchInfo_scan(void *p) { (void)p; }
rl_NPatchInfo *rl_NPatchInfo_new(sp_int cls_id) {
  rl_NPatchInfo *self = (rl_NPatchInfo *)sp_gc_alloc(sizeof(rl_NPatchInfo), NULL, rl_NPatchInfo_scan);
  self->cls_id = cls_id;
  self->v = (NPatchInfo){ 0 };
  return self;
}
int rl_NPatchInfo_left(rl_NPatchInfo *self) {
  return self->v.left;
}
int rl_NPatchInfo_set_left(rl_NPatchInfo *self, int left) {
  self->v.left = left;
  return left;
}
int rl_NPatchInfo_top(rl_NPatchInfo *self) {
  return self->v.top;
}
int rl_NPatchInfo_set_top(rl_NPatchInfo *self, int top) {
  self->v.top = top;
  return top;
}
int rl_NPatchInfo_right(rl_NPatchInfo *self) {
  return self->v.right;
}
int rl_NPatchInfo_set_right(rl_NPatchInfo *self, int right) {
  self->v.right = right;
  return right;
}
int rl_NPatchInfo_bottom(rl_NPatchInfo *self) {
  return self->v.bottom;
}
int rl_NPatchInfo_set_bottom(rl_NPatchInfo *self, int bottom) {
  self->v.bottom = bottom;
  return bottom;
}
int rl_NPatchInfo_layout(rl_NPatchInfo *self) {
  return self->v.layout;
}
int rl_NPatchInfo_set_layout(rl_NPatchInfo *self, int layout) {
  self->v.layout = layout;
  return layout;
}

/* rl_VrDeviceInfo — GC-embedded VrDeviceInfo (see raylib_ffi.rb) */typedef struct rl_VrDeviceInfo_s {
  sp_int cls_id;
  VrDeviceInfo v;
} rl_VrDeviceInfo;
static void rl_VrDeviceInfo_scan(void *p) { (void)p; }
rl_VrDeviceInfo *rl_VrDeviceInfo_new(sp_int cls_id) {
  rl_VrDeviceInfo *self = (rl_VrDeviceInfo *)sp_gc_alloc(sizeof(rl_VrDeviceInfo), NULL, rl_VrDeviceInfo_scan);
  self->cls_id = cls_id;
  self->v = (VrDeviceInfo){ 0 };
  return self;
}
int rl_VrDeviceInfo_hResolution(rl_VrDeviceInfo *self) {
  return self->v.hResolution;
}
int rl_VrDeviceInfo_set_hResolution(rl_VrDeviceInfo *self, int hResolution) {
  self->v.hResolution = hResolution;
  return hResolution;
}
int rl_VrDeviceInfo_vResolution(rl_VrDeviceInfo *self) {
  return self->v.vResolution;
}
int rl_VrDeviceInfo_set_vResolution(rl_VrDeviceInfo *self, int vResolution) {
  self->v.vResolution = vResolution;
  return vResolution;
}
double rl_VrDeviceInfo_hScreenSize(rl_VrDeviceInfo *self) {
  return (double)self->v.hScreenSize;
}
double rl_VrDeviceInfo_set_hScreenSize(rl_VrDeviceInfo *self, double hScreenSize) {
  self->v.hScreenSize = (float)hScreenSize;
  return hScreenSize;
}
double rl_VrDeviceInfo_vScreenSize(rl_VrDeviceInfo *self) {
  return (double)self->v.vScreenSize;
}
double rl_VrDeviceInfo_set_vScreenSize(rl_VrDeviceInfo *self, double vScreenSize) {
  self->v.vScreenSize = (float)vScreenSize;
  return vScreenSize;
}
double rl_VrDeviceInfo_eyeToScreenDistance(rl_VrDeviceInfo *self) {
  return (double)self->v.eyeToScreenDistance;
}
double rl_VrDeviceInfo_set_eyeToScreenDistance(rl_VrDeviceInfo *self, double eyeToScreenDistance) {
  self->v.eyeToScreenDistance = (float)eyeToScreenDistance;
  return eyeToScreenDistance;
}
double rl_VrDeviceInfo_lensSeparationDistance(rl_VrDeviceInfo *self) {
  return (double)self->v.lensSeparationDistance;
}
double rl_VrDeviceInfo_set_lensSeparationDistance(rl_VrDeviceInfo *self, double lensSeparationDistance) {
  self->v.lensSeparationDistance = (float)lensSeparationDistance;
  return lensSeparationDistance;
}
double rl_VrDeviceInfo_interpupillaryDistance(rl_VrDeviceInfo *self) {
  return (double)self->v.interpupillaryDistance;
}
double rl_VrDeviceInfo_set_interpupillaryDistance(rl_VrDeviceInfo *self, double interpupillaryDistance) {
  self->v.interpupillaryDistance = (float)interpupillaryDistance;
  return interpupillaryDistance;
}

/* rl_VrStereoConfig — GC-embedded VrStereoConfig (see raylib_ffi.rb) */typedef struct rl_VrStereoConfig_s {
  sp_int cls_id;
  VrStereoConfig v;
} rl_VrStereoConfig;
static void rl_VrStereoConfig_scan(void *p) { (void)p; }
rl_VrStereoConfig *rl_VrStereoConfig_new(sp_int cls_id) {
  rl_VrStereoConfig *self = (rl_VrStereoConfig *)sp_gc_alloc(sizeof(rl_VrStereoConfig), NULL, rl_VrStereoConfig_scan);
  self->cls_id = cls_id;
  self->v = (VrStereoConfig){ 0 };
  return self;
}

/* rl_FilePathList — GC-embedded FilePathList (see raylib_ffi.rb) */typedef struct rl_FilePathList_s {
  sp_int cls_id;
  FilePathList v;
} rl_FilePathList;
static void rl_FilePathList_scan(void *p) { (void)p; }
rl_FilePathList *rl_FilePathList_new(sp_int cls_id) {
  rl_FilePathList *self = (rl_FilePathList *)sp_gc_alloc(sizeof(rl_FilePathList), NULL, rl_FilePathList_scan);
  self->cls_id = cls_id;
  self->v = (FilePathList){ 0 };
  return self;
}
int rl_FilePathList_count(rl_FilePathList *self) {
  return self->v.count;
}
int rl_FilePathList_set_count(rl_FilePathList *self, int count) {
  self->v.count = count;
  return count;
}
const char *rl_FilePathList_path(rl_FilePathList *self, int index) {
  if (index < 0 || index >= self->v.count) return "";
  return self->v.paths[index];
}

/* rl_AutomationEvent — GC-embedded AutomationEvent (see raylib_ffi.rb) */typedef struct rl_AutomationEvent_s {
  sp_int cls_id;
  AutomationEvent v;
} rl_AutomationEvent;
static void rl_AutomationEvent_scan(void *p) { (void)p; }
rl_AutomationEvent *rl_AutomationEvent_new(sp_int cls_id) {
  rl_AutomationEvent *self = (rl_AutomationEvent *)sp_gc_alloc(sizeof(rl_AutomationEvent), NULL, rl_AutomationEvent_scan);
  self->cls_id = cls_id;
  self->v = (AutomationEvent){ 0 };
  return self;
}
int rl_AutomationEvent_frame(rl_AutomationEvent *self) {
  return self->v.frame;
}
int rl_AutomationEvent_set_frame(rl_AutomationEvent *self, int frame) {
  self->v.frame = frame;
  return frame;
}
int rl_AutomationEvent_type(rl_AutomationEvent *self) {
  return self->v.type;
}
int rl_AutomationEvent_set_type(rl_AutomationEvent *self, int type) {
  self->v.type = type;
  return type;
}

/* rl_AutomationEventList — GC-embedded AutomationEventList (see raylib_ffi.rb) */typedef struct rl_AutomationEventList_s {
  sp_int cls_id;
  AutomationEventList v;
} rl_AutomationEventList;
static void rl_AutomationEventList_scan(void *p) { (void)p; }
rl_AutomationEventList *rl_AutomationEventList_new(sp_int cls_id) {
  rl_AutomationEventList *self = (rl_AutomationEventList *)sp_gc_alloc(sizeof(rl_AutomationEventList), NULL, rl_AutomationEventList_scan);
  self->cls_id = cls_id;
  self->v = (AutomationEventList){ 0 };
  return self;
}
int rl_AutomationEventList_capacity(rl_AutomationEventList *self) {
  return self->v.capacity;
}
int rl_AutomationEventList_set_capacity(rl_AutomationEventList *self, int capacity) {
  self->v.capacity = capacity;
  return capacity;
}
int rl_AutomationEventList_count(rl_AutomationEventList *self) {
  return self->v.count;
}
int rl_AutomationEventList_set_count(rl_AutomationEventList *self, int count) {
  self->v.count = count;
  return count;
}

/* rl_Vector2 runtime methods (struct declared near the top) */
static void rl_Vector2_scan(void *p) {
  rl_Vector2 *s = (rl_Vector2 *)p;
  if (s->p) sp_mark_rbval(s->owner);
}
rl_Vector2 *rl_Vector2_new(sp_int cls_id) {
  rl_Vector2 *self = (rl_Vector2 *)sp_gc_alloc(sizeof(rl_Vector2), NULL, rl_Vector2_scan);
  self->cls_id = cls_id;
  self->p = NULL;
  self->v = (Vector2){ 0 };
  return self;
}

Vector2 *rl_Vector2_view(sp_int cls_id, void *p, sp_RbVal owner) {
  rl_Vector2 *self = (rl_Vector2 *)sp_gc_alloc(sizeof(rl_Vector2), NULL, rl_Vector2_scan);
  self->cls_id = cls_id;
  self->p = NULL;
  self->p = (Vector2 *)p;
  self->owner = owner;
  return self;
}
double rl_Vector2_x(rl_Vector2 *self) {
  return (double)RL_V2(self)->x;
}
double rl_Vector2_set_x(rl_Vector2 *self, double x) {
  RL_V2(self)->x = (float)x;
  return x;
}
double rl_Vector2_y(rl_Vector2 *self) {
  return (double)RL_V2(self)->y;
}
double rl_Vector2_set_y(rl_Vector2 *self, double y) {
  RL_V2(self)->y = (float)y;
  return y;
}

/* ---- generated shims ---- */
/** SetWindowIcon(params: void * image -> void) */
void rl_SetWindowIcon(void * image) {
  SetWindowIcon(*RL_IMG(image));
}
/** GetMonitorPosition(params: int monitor, void * _out -> void) */
void rl_GetMonitorPosition(int monitor, void * _out) {
  *RL_V2(_out) = GetMonitorPosition(monitor);
}
/** GetWindowPosition(params: void * _out -> void) */
void rl_GetWindowPosition(void * _out) {
  *RL_V2(_out) = GetWindowPosition();
}
/** GetWindowScaleDPI(params: void * _out -> void) */
void rl_GetWindowScaleDPI(void * _out) {
  *RL_V2(_out) = GetWindowScaleDPI();
}
/** GetClipboardImage(params: void -> void *) */
void * rl_GetClipboardImage(void) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GetClipboardImage();
  return r;
}
/** BeginMode2D(params: void * camera -> void) */
void rl_BeginMode2D(void * camera) {
  BeginMode2D(((rl_Camera2D*)camera)->v);
}
/** BeginTextureMode(params: void * target -> void) */
void rl_BeginTextureMode(void * target) {
  BeginTextureMode(*RL_RT(target));
}
/** BeginShaderMode(params: void * shader -> void) */
void rl_BeginShaderMode(void * shader) {
  BeginShaderMode(*(Shader *)shader);
}
/** BeginVrStereoMode(params: void * config -> void) */
void rl_BeginVrStereoMode(void * config) {
  BeginVrStereoMode(((rl_VrStereoConfig*)config)->v);
}
/** LoadVrStereoConfig(params: void * device, void * _out -> void) */
void rl_LoadVrStereoConfig(void * device, void * _out) {
  ((rl_VrStereoConfig*)_out)->v = LoadVrStereoConfig(((rl_VrDeviceInfo*)device)->v);
}
/** UnloadVrStereoConfig(params: void * config -> void) */
void rl_UnloadVrStereoConfig(void * config) {
  UnloadVrStereoConfig(((rl_VrStereoConfig*)config)->v);
}
/** LoadShader(params: const char * vsFileName, const char * fsFileName -> void *) */
void * rl_LoadShader(const char * vsFileName, const char * fsFileName) {
  Shader *r = (Shader *)malloc(sizeof(Shader));
  *r = LoadShader(vsFileName, fsFileName);
  return r;
}
/** LoadShaderFromMemory(params: const char * vsCode, const char * fsCode -> void *) */
void * rl_LoadShaderFromMemory(const char * vsCode, const char * fsCode) {
  Shader *r = (Shader *)malloc(sizeof(Shader));
  *r = LoadShaderFromMemory(vsCode, fsCode);
  return r;
}
/** IsShaderValid(params: void * shader -> _Bool) */
_Bool rl_IsShaderValid(void * shader) {
  return IsShaderValid(*(Shader *)shader);
}
/** GetShaderLocation(params: void * shader, const char * uniformName -> int) */
int rl_GetShaderLocation(void * shader, const char * uniformName) {
  return GetShaderLocation(*(Shader *)shader, uniformName);
}
/** GetShaderLocationAttrib(params: void * shader, const char * attribName -> int) */
int rl_GetShaderLocationAttrib(void * shader, const char * attribName) {
  return GetShaderLocationAttrib(*(Shader *)shader, attribName);
}
/** SetShaderValue(params: void * shader, int locIndex, void * value, int uniformType -> void) */
void rl_SetShaderValue(void * shader, int locIndex, void * value, int uniformType) {
  SetShaderValue(*(Shader *)shader, locIndex, value, uniformType);
}
/** SetShaderValueV(params: void * shader, int locIndex, void * value, int uniformType, int count -> void) */
void rl_SetShaderValueV(void * shader, int locIndex, void * value, int uniformType, int count) {
  SetShaderValueV(*(Shader *)shader, locIndex, value, uniformType, count);
}
/** SetShaderValueMatrix(params: void * shader, int locIndex, void * mat -> void) */
void rl_SetShaderValueMatrix(void * shader, int locIndex, void * mat) {
  SetShaderValueMatrix(*(Shader *)shader, locIndex, ((rl_Matrix*)mat)->v);
}
/** SetShaderValueTexture(params: void * shader, int locIndex, void * texture -> void) */
void rl_SetShaderValueTexture(void * shader, int locIndex, void * texture) {
  SetShaderValueTexture(*(Shader *)shader, locIndex, *RL_TEX(texture));
}
/** UnloadShader(params: void * shader -> void) */
void rl_UnloadShader(void * shader) {
  Shader *self = (Shader *)shader;
  UnloadShader(*self);
  free(self);
}
/** GetScreenToWorldRay(params: void * position, void * camera, void * _out -> void) */
void rl_GetScreenToWorldRay(void * position, void * camera, void * _out) {
  ((rl_Ray*)_out)->v = GetScreenToWorldRay(*RL_V2(position), ((rl_Camera*)camera)->c);
}
/** GetScreenToWorldRayEx(params: void * position, void * camera, int width, int height, void * _out -> void) */
void rl_GetScreenToWorldRayEx(void * position, void * camera, int width, int height, void * _out) {
  ((rl_Ray*)_out)->v = GetScreenToWorldRayEx(*RL_V2(position), ((rl_Camera*)camera)->c, width, height);
}
/** GetWorldToScreen(params: void * position, void * camera, void * _out -> void) */
void rl_GetWorldToScreen(void * position, void * camera, void * _out) {
  *RL_V2(_out) = GetWorldToScreen(*RL_V3(position), ((rl_Camera*)camera)->c);
}
/** GetWorldToScreenEx(params: void * position, void * camera, int width, int height, void * _out -> void) */
void rl_GetWorldToScreenEx(void * position, void * camera, int width, int height, void * _out) {
  *RL_V2(_out) = GetWorldToScreenEx(*RL_V3(position), ((rl_Camera*)camera)->c, width, height);
}
/** GetWorldToScreen2D(params: void * position, void * camera, void * _out -> void) */
void rl_GetWorldToScreen2D(void * position, void * camera, void * _out) {
  *RL_V2(_out) = GetWorldToScreen2D(*RL_V2(position), ((rl_Camera2D*)camera)->v);
}
/** GetScreenToWorld2D(params: void * position, void * camera, void * _out -> void) */
void rl_GetScreenToWorld2D(void * position, void * camera, void * _out) {
  *RL_V2(_out) = GetScreenToWorld2D(*RL_V2(position), ((rl_Camera2D*)camera)->v);
}
/** GetCameraMatrix(params: void * camera, void * _out -> void) */
void rl_GetCameraMatrix(void * camera, void * _out) {
  ((rl_Matrix*)_out)->v = GetCameraMatrix(((rl_Camera*)camera)->c);
}
/** GetCameraMatrix2D(params: void * camera, void * _out -> void) */
void rl_GetCameraMatrix2D(void * camera, void * _out) {
  ((rl_Matrix*)_out)->v = GetCameraMatrix2D(((rl_Camera2D*)camera)->v);
}
/** SetTraceLogCallback(params: void * callback -> void) */
void rl_SetTraceLogCallback(void * callback) {
  SetTraceLogCallback((TraceLogCallback)callback);
}
/** SetLoadFileDataCallback(params: void * callback -> void) */
void rl_SetLoadFileDataCallback(void * callback) {
  SetLoadFileDataCallback((LoadFileDataCallback)callback);
}
/** SetSaveFileDataCallback(params: void * callback -> void) */
void rl_SetSaveFileDataCallback(void * callback) {
  SetSaveFileDataCallback((SaveFileDataCallback)callback);
}
/** SetLoadFileTextCallback(params: void * callback -> void) */
void rl_SetLoadFileTextCallback(void * callback) {
  SetLoadFileTextCallback((LoadFileTextCallback)callback);
}
/** SetSaveFileTextCallback(params: void * callback -> void) */
void rl_SetSaveFileTextCallback(void * callback) {
  SetSaveFileTextCallback((SaveFileTextCallback)callback);
}
/** LoadDirectoryFiles(params: const char * dirPath, void * _out -> void) */
void rl_LoadDirectoryFiles(const char * dirPath, void * _out) {
  ((rl_FilePathList*)_out)->v = LoadDirectoryFiles(dirPath);
}
/** LoadDirectoryFilesEx(params: const char * basePath, const char * filter, _Bool scanSubdirs, void * _out -> void) */
void rl_LoadDirectoryFilesEx(const char * basePath, const char * filter, _Bool scanSubdirs, void * _out) {
  ((rl_FilePathList*)_out)->v = LoadDirectoryFilesEx(basePath, filter, scanSubdirs);
}
/** UnloadDirectoryFiles(params: void * files -> void) */
void rl_UnloadDirectoryFiles(void * files) {
  UnloadDirectoryFiles(((rl_FilePathList*)files)->v);
}
/** LoadDroppedFiles(params: void * _out -> void) */
void rl_LoadDroppedFiles(void * _out) {
  ((rl_FilePathList*)_out)->v = LoadDroppedFiles();
}
/** UnloadDroppedFiles(params: void * files -> void) */
void rl_UnloadDroppedFiles(void * files) {
  UnloadDroppedFiles(((rl_FilePathList*)files)->v);
}
/** LoadAutomationEventList(params: const char * fileName, void * _out -> void) */
void rl_LoadAutomationEventList(const char * fileName, void * _out) {
  ((rl_AutomationEventList*)_out)->v = LoadAutomationEventList(fileName);
}
/** UnloadAutomationEventList(params: void * list -> void) */
void rl_UnloadAutomationEventList(void * list) {
  UnloadAutomationEventList(((rl_AutomationEventList*)list)->v);
}
/** ExportAutomationEventList(params: void * list, const char * fileName -> _Bool) */
_Bool rl_ExportAutomationEventList(void * list, const char * fileName) {
  return ExportAutomationEventList(((rl_AutomationEventList*)list)->v, fileName);
}
/** SetAutomationEventList(params: void * list -> void) */
void rl_SetAutomationEventList(void * list) {
  SetAutomationEventList(&((rl_AutomationEventList*)list)->v);
}
/** PlayAutomationEvent(params: void * event -> void) */
void rl_PlayAutomationEvent(void * event) {
  PlayAutomationEvent(((rl_AutomationEvent*)event)->v);
}
/** GetMousePosition(params: void * _out -> void) */
void rl_GetMousePosition(void * _out) {
  *RL_V2(_out) = GetMousePosition();
}
/** GetMouseDelta(params: void * _out -> void) */
void rl_GetMouseDelta(void * _out) {
  *RL_V2(_out) = GetMouseDelta();
}
/** GetMouseWheelMoveV(params: void * _out -> void) */
void rl_GetMouseWheelMoveV(void * _out) {
  *RL_V2(_out) = GetMouseWheelMoveV();
}
/** GetTouchPosition(params: int index, void * _out -> void) */
void rl_GetTouchPosition(int index, void * _out) {
  *RL_V2(_out) = GetTouchPosition(index);
}
/** GetGestureDragVector(params: void * _out -> void) */
void rl_GetGestureDragVector(void * _out) {
  *RL_V2(_out) = GetGestureDragVector();
}
/** GetGesturePinchVector(params: void * _out -> void) */
void rl_GetGesturePinchVector(void * _out) {
  *RL_V2(_out) = GetGesturePinchVector();
}
/** UpdateCameraPro(params: void * camera, void * movement, void * rotation, float zoom -> void) */
void rl_UpdateCameraPro(void * camera, void * movement, void * rotation, float zoom) {
  UpdateCameraPro(&((rl_Camera*)camera)->c, *RL_V3(movement), *RL_V3(rotation), zoom);
}
/** SetShapesTexture(params: void * texture, void * rec -> void) */
void rl_SetShapesTexture(void * texture, void * rec) {
  SetShapesTexture(*RL_TEX(texture), *RL_RECT(rec));
}
/** GetShapesTexture(params: void -> void *) */
void * rl_GetShapesTexture(void) {
  Texture2D *r = (Texture2D *)malloc(sizeof(Texture2D));
  *r = GetShapesTexture();
  return r;
}
/** GetShapesTextureRectangle(params: void * _out -> void) */
void rl_GetShapesTextureRectangle(void * _out) {
  *RL_RECT(_out) = GetShapesTextureRectangle();
}
/** DrawPixelV(params: void * position, void * color -> void) */
void rl_DrawPixelV(void * position, void * color) {
  DrawPixelV(*RL_V2(position), ((rl_Color*)color)->c);
}
/** DrawLine(params: int startPosX, int startPosY, int endPosX, int endPosY, void * color -> void) */
void rl_DrawLine(int startPosX, int startPosY, int endPosX, int endPosY, void * color) {
  DrawLine(startPosX, startPosY, endPosX, endPosY, ((rl_Color*)color)->c);
}
/** DrawLineV(params: void * startPos, void * endPos, void * color -> void) */
void rl_DrawLineV(void * startPos, void * endPos, void * color) {
  DrawLineV(*RL_V2(startPos), *RL_V2(endPos), ((rl_Color*)color)->c);
}
/** DrawLineEx(params: void * startPos, void * endPos, float thick, void * color -> void) */
void rl_DrawLineEx(void * startPos, void * endPos, float thick, void * color) {
  DrawLineEx(*RL_V2(startPos), *RL_V2(endPos), thick, ((rl_Color*)color)->c);
}
/** DrawLineStrip(params: void * points, int pointCount, void * color -> void) */
void rl_DrawLineStrip(void * points, int pointCount, void * color) {
  DrawLineStrip(points, pointCount, ((rl_Color*)color)->c);
}
/** DrawLineBezier(params: void * startPos, void * endPos, float thick, void * color -> void) */
void rl_DrawLineBezier(void * startPos, void * endPos, float thick, void * color) {
  DrawLineBezier(*RL_V2(startPos), *RL_V2(endPos), thick, ((rl_Color*)color)->c);
}
/** DrawLineDashed(params: void * startPos, void * endPos, int dashSize, int spaceSize, void * color -> void) */
void rl_DrawLineDashed(void * startPos, void * endPos, int dashSize, int spaceSize, void * color) {
  DrawLineDashed(*RL_V2(startPos), *RL_V2(endPos), dashSize, spaceSize, ((rl_Color*)color)->c);
}
/** DrawTriangleGradient(params: void * v1, void * v2, void * v3, void * c1, void * c2, void * c3 -> void) */
void rl_DrawTriangleGradient(void * v1, void * v2, void * v3, void * c1, void * c2, void * c3) {
  DrawTriangleGradient(*RL_V2(v1), *RL_V2(v2), *RL_V2(v3), ((rl_Color*)c1)->c, ((rl_Color*)c2)->c, ((rl_Color*)c3)->c);
}
/** DrawTriangleLines(params: void * v1, void * v2, void * v3, void * color -> void) */
void rl_DrawTriangleLines(void * v1, void * v2, void * v3, void * color) {
  DrawTriangleLines(*RL_V2(v1), *RL_V2(v2), *RL_V2(v3), ((rl_Color*)color)->c);
}
/** DrawTriangleLinesEx(params: void * v1, void * v2, void * v3, float thick, void * color -> void) */
void rl_DrawTriangleLinesEx(void * v1, void * v2, void * v3, float thick, void * color) {
  DrawTriangleLinesEx(*RL_V2(v1), *RL_V2(v2), *RL_V2(v3), thick, ((rl_Color*)color)->c);
}
/** DrawTriangleFan(params: void * points, int pointCount, void * color -> void) */
void rl_DrawTriangleFan(void * points, int pointCount, void * color) {
  DrawTriangleFan(points, pointCount, ((rl_Color*)color)->c);
}
/** DrawTriangleStrip(params: void * points, int pointCount, void * color -> void) */
void rl_DrawTriangleStrip(void * points, int pointCount, void * color) {
  DrawTriangleStrip(points, pointCount, ((rl_Color*)color)->c);
}
/** DrawRectangleV(params: void * position, void * size, void * color -> void) */
void rl_DrawRectangleV(void * position, void * size, void * color) {
  DrawRectangleV(*RL_V2(position), *RL_V2(size), ((rl_Color*)color)->c);
}
/** DrawRectangleRec(params: void * rec, void * color -> void) */
void rl_DrawRectangleRec(void * rec, void * color) {
  DrawRectangleRec(*RL_RECT(rec), ((rl_Color*)color)->c);
}
/** DrawRectanglePro(params: void * rec, void * origin, float rotation, void * color -> void) */
void rl_DrawRectanglePro(void * rec, void * origin, float rotation, void * color) {
  DrawRectanglePro(*RL_RECT(rec), *RL_V2(origin), rotation, ((rl_Color*)color)->c);
}
/** DrawRectangleGradientV(params: int posX, int posY, int width, int height, void * top, void * bottom -> void) */
void rl_DrawRectangleGradientV(int posX, int posY, int width, int height, void * top, void * bottom) {
  DrawRectangleGradientV(posX, posY, width, height, ((rl_Color*)top)->c, ((rl_Color*)bottom)->c);
}
/** DrawRectangleGradientH(params: int posX, int posY, int width, int height, void * left, void * right -> void) */
void rl_DrawRectangleGradientH(int posX, int posY, int width, int height, void * left, void * right) {
  DrawRectangleGradientH(posX, posY, width, height, ((rl_Color*)left)->c, ((rl_Color*)right)->c);
}
/** DrawRectangleGradientEx(params: void * rec, void * col1, void * col2, void * col3, void * col4 -> void) */
void rl_DrawRectangleGradientEx(void * rec, void * col1, void * col2, void * col3, void * col4) {
  DrawRectangleGradientEx(*RL_RECT(rec), ((rl_Color*)col1)->c, ((rl_Color*)col2)->c, ((rl_Color*)col3)->c, ((rl_Color*)col4)->c);
}
/** DrawRectangleLinesEx(params: void * rec, float thick, void * color -> void) */
void rl_DrawRectangleLinesEx(void * rec, float thick, void * color) {
  DrawRectangleLinesEx(*RL_RECT(rec), thick, ((rl_Color*)color)->c);
}
/** DrawRectangleRounded(params: void * rec, float roundness, int segments, void * color -> void) */
void rl_DrawRectangleRounded(void * rec, float roundness, int segments, void * color) {
  DrawRectangleRounded(*RL_RECT(rec), roundness, segments, ((rl_Color*)color)->c);
}
/** DrawRectangleRoundedLines(params: void * rec, float roundness, int segments, void * color -> void) */
void rl_DrawRectangleRoundedLines(void * rec, float roundness, int segments, void * color) {
  DrawRectangleRoundedLines(*RL_RECT(rec), roundness, segments, ((rl_Color*)color)->c);
}
/** DrawRectangleRoundedLinesEx(params: void * rec, float roundness, int segments, float thick, void * color -> void) */
void rl_DrawRectangleRoundedLinesEx(void * rec, float roundness, int segments, float thick, void * color) {
  DrawRectangleRoundedLinesEx(*RL_RECT(rec), roundness, segments, thick, ((rl_Color*)color)->c);
}
/** DrawPoly(params: void * center, int sides, float radius, float rotation, void * color -> void) */
void rl_DrawPoly(void * center, int sides, float radius, float rotation, void * color) {
  DrawPoly(*RL_V2(center), sides, radius, rotation, ((rl_Color*)color)->c);
}
/** DrawPolyLines(params: void * center, int sides, float radius, float rotation, void * color -> void) */
void rl_DrawPolyLines(void * center, int sides, float radius, float rotation, void * color) {
  DrawPolyLines(*RL_V2(center), sides, radius, rotation, ((rl_Color*)color)->c);
}
/** DrawPolyLinesEx(params: void * center, int sides, float radius, float rotation, float thick, void * color -> void) */
void rl_DrawPolyLinesEx(void * center, int sides, float radius, float rotation, float thick, void * color) {
  DrawPolyLinesEx(*RL_V2(center), sides, radius, rotation, thick, ((rl_Color*)color)->c);
}
/** DrawCircle(params: int centerX, int centerY, float radius, void * color -> void) */
void rl_DrawCircle(int centerX, int centerY, float radius, void * color) {
  DrawCircle(centerX, centerY, radius, ((rl_Color*)color)->c);
}
/** DrawCircleGradient(params: void * center, float radius, void * inner, void * outer -> void) */
void rl_DrawCircleGradient(void * center, float radius, void * inner, void * outer) {
  DrawCircleGradient(*RL_V2(center), radius, ((rl_Color*)inner)->c, ((rl_Color*)outer)->c);
}
/** DrawCircleSector(params: void * center, float radius, float startAngle, float endAngle, int segments, void * color -> void) */
void rl_DrawCircleSector(void * center, float radius, float startAngle, float endAngle, int segments, void * color) {
  DrawCircleSector(*RL_V2(center), radius, startAngle, endAngle, segments, ((rl_Color*)color)->c);
}
/** DrawCircleSectorLines(params: void * center, float radius, float startAngle, float endAngle, int segments, void * color -> void) */
void rl_DrawCircleSectorLines(void * center, float radius, float startAngle, float endAngle, int segments, void * color) {
  DrawCircleSectorLines(*RL_V2(center), radius, startAngle, endAngle, segments, ((rl_Color*)color)->c);
}
/** DrawCircleSectorLinesEx(params: void * center, float radius, float startAngle, float endAngle, int segments, float thick, void * color -> void) */
void rl_DrawCircleSectorLinesEx(void * center, float radius, float startAngle, float endAngle, int segments, float thick, void * color) {
  DrawCircleSectorLinesEx(*RL_V2(center), radius, startAngle, endAngle, segments, thick, ((rl_Color*)color)->c);
}
/** DrawCircleLines(params: int centerX, int centerY, float radius, void * color -> void) */
void rl_DrawCircleLines(int centerX, int centerY, float radius, void * color) {
  DrawCircleLines(centerX, centerY, radius, ((rl_Color*)color)->c);
}
/** DrawCircleLinesV(params: void * center, float radius, void * color -> void) */
void rl_DrawCircleLinesV(void * center, float radius, void * color) {
  DrawCircleLinesV(*RL_V2(center), radius, ((rl_Color*)color)->c);
}
/** DrawCircleLinesEx(params: void * center, float radius, float thick, void * color -> void) */
void rl_DrawCircleLinesEx(void * center, float radius, float thick, void * color) {
  DrawCircleLinesEx(*RL_V2(center), radius, thick, ((rl_Color*)color)->c);
}
/** DrawEllipse(params: int centerX, int centerY, float radiusH, float radiusV, void * color -> void) */
void rl_DrawEllipse(int centerX, int centerY, float radiusH, float radiusV, void * color) {
  DrawEllipse(centerX, centerY, radiusH, radiusV, ((rl_Color*)color)->c);
}
/** DrawEllipseV(params: void * center, float radiusH, float radiusV, void * color -> void) */
void rl_DrawEllipseV(void * center, float radiusH, float radiusV, void * color) {
  DrawEllipseV(*RL_V2(center), radiusH, radiusV, ((rl_Color*)color)->c);
}
/** DrawEllipseLines(params: int centerX, int centerY, float radiusH, float radiusV, void * color -> void) */
void rl_DrawEllipseLines(int centerX, int centerY, float radiusH, float radiusV, void * color) {
  DrawEllipseLines(centerX, centerY, radiusH, radiusV, ((rl_Color*)color)->c);
}
/** DrawEllipseLinesV(params: void * center, float radiusH, float radiusV, void * color -> void) */
void rl_DrawEllipseLinesV(void * center, float radiusH, float radiusV, void * color) {
  DrawEllipseLinesV(*RL_V2(center), radiusH, radiusV, ((rl_Color*)color)->c);
}
/** DrawEllipseLinesEx(params: void * center, float radiusH, float radiusV, float thick, void * color -> void) */
void rl_DrawEllipseLinesEx(void * center, float radiusH, float radiusV, float thick, void * color) {
  DrawEllipseLinesEx(*RL_V2(center), radiusH, radiusV, thick, ((rl_Color*)color)->c);
}
/** DrawRing(params: void * center, float innerRadius, float outerRadius, float startAngle, float endAngle, int segments, void * color -> void) */
void rl_DrawRing(void * center, float innerRadius, float outerRadius, float startAngle, float endAngle, int segments, void * color) {
  DrawRing(*RL_V2(center), innerRadius, outerRadius, startAngle, endAngle, segments, ((rl_Color*)color)->c);
}
/** DrawRingLines(params: void * center, float innerRadius, float outerRadius, float startAngle, float endAngle, int segments, void * color -> void) */
void rl_DrawRingLines(void * center, float innerRadius, float outerRadius, float startAngle, float endAngle, int segments, void * color) {
  DrawRingLines(*RL_V2(center), innerRadius, outerRadius, startAngle, endAngle, segments, ((rl_Color*)color)->c);
}
/** DrawRingLinesEx(params: void * center, float innerRadius, float outerRadius, float startAngle, float endAngle, int segments, float thick, void * color -> void) */
void rl_DrawRingLinesEx(void * center, float innerRadius, float outerRadius, float startAngle, float endAngle, int segments, float thick, void * color) {
  DrawRingLinesEx(*RL_V2(center), innerRadius, outerRadius, startAngle, endAngle, segments, thick, ((rl_Color*)color)->c);
}
/** DrawSplineLinear(params: void * points, int pointCount, float thick, void * color -> void) */
void rl_DrawSplineLinear(void * points, int pointCount, float thick, void * color) {
  DrawSplineLinear(points, pointCount, thick, ((rl_Color*)color)->c);
}
/** DrawSplineBasis(params: void * points, int pointCount, float thick, void * color -> void) */
void rl_DrawSplineBasis(void * points, int pointCount, float thick, void * color) {
  DrawSplineBasis(points, pointCount, thick, ((rl_Color*)color)->c);
}
/** DrawSplineCatmullRom(params: void * points, int pointCount, float thick, void * color -> void) */
void rl_DrawSplineCatmullRom(void * points, int pointCount, float thick, void * color) {
  DrawSplineCatmullRom(points, pointCount, thick, ((rl_Color*)color)->c);
}
/** DrawSplineBezierQuadratic(params: void * points, int pointCount, float thick, void * color -> void) */
void rl_DrawSplineBezierQuadratic(void * points, int pointCount, float thick, void * color) {
  DrawSplineBezierQuadratic(points, pointCount, thick, ((rl_Color*)color)->c);
}
/** DrawSplineBezierCubic(params: void * points, int pointCount, float thick, void * color -> void) */
void rl_DrawSplineBezierCubic(void * points, int pointCount, float thick, void * color) {
  DrawSplineBezierCubic(points, pointCount, thick, ((rl_Color*)color)->c);
}
/** DrawSplineSegmentLinear(params: void * p1, void * p2, float thick, void * color -> void) */
void rl_DrawSplineSegmentLinear(void * p1, void * p2, float thick, void * color) {
  DrawSplineSegmentLinear(*RL_V2(p1), *RL_V2(p2), thick, ((rl_Color*)color)->c);
}
/** DrawSplineSegmentBasis(params: void * p1, void * p2, void * p3, void * p4, float thick, void * color -> void) */
void rl_DrawSplineSegmentBasis(void * p1, void * p2, void * p3, void * p4, float thick, void * color) {
  DrawSplineSegmentBasis(*RL_V2(p1), *RL_V2(p2), *RL_V2(p3), *RL_V2(p4), thick, ((rl_Color*)color)->c);
}
/** DrawSplineSegmentCatmullRom(params: void * p1, void * p2, void * p3, void * p4, float thick, void * color -> void) */
void rl_DrawSplineSegmentCatmullRom(void * p1, void * p2, void * p3, void * p4, float thick, void * color) {
  DrawSplineSegmentCatmullRom(*RL_V2(p1), *RL_V2(p2), *RL_V2(p3), *RL_V2(p4), thick, ((rl_Color*)color)->c);
}
/** DrawSplineSegmentBezierQuadratic(params: void * p1, void * c2, void * p3, float thick, void * color -> void) */
void rl_DrawSplineSegmentBezierQuadratic(void * p1, void * c2, void * p3, float thick, void * color) {
  DrawSplineSegmentBezierQuadratic(*RL_V2(p1), *RL_V2(c2), *RL_V2(p3), thick, ((rl_Color*)color)->c);
}
/** DrawSplineSegmentBezierCubic(params: void * p1, void * c2, void * c3, void * p4, float thick, void * color -> void) */
void rl_DrawSplineSegmentBezierCubic(void * p1, void * c2, void * c3, void * p4, float thick, void * color) {
  DrawSplineSegmentBezierCubic(*RL_V2(p1), *RL_V2(c2), *RL_V2(c3), *RL_V2(p4), thick, ((rl_Color*)color)->c);
}
/** GetSplinePointLinear(params: void * startPos, void * endPos, float t, void * _out -> void) */
void rl_GetSplinePointLinear(void * startPos, void * endPos, float t, void * _out) {
  *RL_V2(_out) = GetSplinePointLinear(*RL_V2(startPos), *RL_V2(endPos), t);
}
/** GetSplinePointBasis(params: void * p1, void * p2, void * p3, void * p4, float t, void * _out -> void) */
void rl_GetSplinePointBasis(void * p1, void * p2, void * p3, void * p4, float t, void * _out) {
  *RL_V2(_out) = GetSplinePointBasis(*RL_V2(p1), *RL_V2(p2), *RL_V2(p3), *RL_V2(p4), t);
}
/** GetSplinePointCatmullRom(params: void * p1, void * p2, void * p3, void * p4, float t, void * _out -> void) */
void rl_GetSplinePointCatmullRom(void * p1, void * p2, void * p3, void * p4, float t, void * _out) {
  *RL_V2(_out) = GetSplinePointCatmullRom(*RL_V2(p1), *RL_V2(p2), *RL_V2(p3), *RL_V2(p4), t);
}
/** GetSplinePointBezierQuadratic(params: void * p1, void * c2, void * p3, float t, void * _out -> void) */
void rl_GetSplinePointBezierQuadratic(void * p1, void * c2, void * p3, float t, void * _out) {
  *RL_V2(_out) = GetSplinePointBezierQuadratic(*RL_V2(p1), *RL_V2(c2), *RL_V2(p3), t);
}
/** GetSplinePointBezierCubic(params: void * p1, void * c2, void * c3, void * p4, float t, void * _out -> void) */
void rl_GetSplinePointBezierCubic(void * p1, void * c2, void * c3, void * p4, float t, void * _out) {
  *RL_V2(_out) = GetSplinePointBezierCubic(*RL_V2(p1), *RL_V2(c2), *RL_V2(c3), *RL_V2(p4), t);
}
/** CheckCollisionRecs(params: void * rec1, void * rec2 -> _Bool) */
_Bool rl_CheckCollisionRecs(void * rec1, void * rec2) {
  return CheckCollisionRecs(*RL_RECT(rec1), *RL_RECT(rec2));
}
/** CheckCollisionCircles(params: void * center1, float radius1, void * center2, float radius2 -> _Bool) */
_Bool rl_CheckCollisionCircles(void * center1, float radius1, void * center2, float radius2) {
  return CheckCollisionCircles(*RL_V2(center1), radius1, *RL_V2(center2), radius2);
}
/** CheckCollisionCircleRec(params: void * center, float radius, void * rec -> _Bool) */
_Bool rl_CheckCollisionCircleRec(void * center, float radius, void * rec) {
  return CheckCollisionCircleRec(*RL_V2(center), radius, *RL_RECT(rec));
}
/** CheckCollisionCircleLine(params: void * center, float radius, void * p1, void * p2 -> _Bool) */
_Bool rl_CheckCollisionCircleLine(void * center, float radius, void * p1, void * p2) {
  return CheckCollisionCircleLine(*RL_V2(center), radius, *RL_V2(p1), *RL_V2(p2));
}
/** CheckCollisionPointRec(params: void * point, void * rec -> _Bool) */
_Bool rl_CheckCollisionPointRec(void * point, void * rec) {
  return CheckCollisionPointRec(*RL_V2(point), *RL_RECT(rec));
}
/** CheckCollisionPointCircle(params: void * point, void * center, float radius -> _Bool) */
_Bool rl_CheckCollisionPointCircle(void * point, void * center, float radius) {
  return CheckCollisionPointCircle(*RL_V2(point), *RL_V2(center), radius);
}
/** CheckCollisionPointTriangle(params: void * point, void * p1, void * p2, void * p3 -> _Bool) */
_Bool rl_CheckCollisionPointTriangle(void * point, void * p1, void * p2, void * p3) {
  return CheckCollisionPointTriangle(*RL_V2(point), *RL_V2(p1), *RL_V2(p2), *RL_V2(p3));
}
/** CheckCollisionPointLine(params: void * point, void * p1, void * p2, int threshold -> _Bool) */
_Bool rl_CheckCollisionPointLine(void * point, void * p1, void * p2, int threshold) {
  return CheckCollisionPointLine(*RL_V2(point), *RL_V2(p1), *RL_V2(p2), threshold);
}
/** CheckCollisionPointPoly(params: void * point, void * points, int pointCount -> _Bool) */
_Bool rl_CheckCollisionPointPoly(void * point, void * points, int pointCount) {
  return CheckCollisionPointPoly(*RL_V2(point), points, pointCount);
}
/** CheckCollisionLines(params: void * startPos1, void * endPos1, void * startPos2, void * endPos2, void * collisionPoint -> _Bool) */
_Bool rl_CheckCollisionLines(void * startPos1, void * endPos1, void * startPos2, void * endPos2, void * collisionPoint) {
  return CheckCollisionLines(*RL_V2(startPos1), *RL_V2(endPos1), *RL_V2(startPos2), *RL_V2(endPos2), collisionPoint);
}
/** GetCollisionRec(params: void * rec1, void * rec2, void * _out -> void) */
void rl_GetCollisionRec(void * rec1, void * rec2, void * _out) {
  *RL_RECT(_out) = GetCollisionRec(*RL_RECT(rec1), *RL_RECT(rec2));
}
/** LoadImage(params: const char * fileName -> void *) */
void * rl_LoadImage(const char * fileName) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = LoadImage(fileName);
  return r;
}
/** LoadImageRaw(params: const char * fileName, int width, int height, int format, int headerSize -> void *) */
void * rl_LoadImageRaw(const char * fileName, int width, int height, int format, int headerSize) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = LoadImageRaw(fileName, width, height, format, headerSize);
  return r;
}
/** LoadImageAnim(params: const char * fileName, void * frames -> void *) */
void * rl_LoadImageAnim(const char * fileName, void * frames) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = LoadImageAnim(fileName, frames);
  return r;
}
/** LoadImageAnimFromMemory(params: const char * fileType, void * fileData, int dataSize, void * frames -> void *) */
void * rl_LoadImageAnimFromMemory(const char * fileType, void * fileData, int dataSize, void * frames) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = LoadImageAnimFromMemory(fileType, fileData, dataSize, frames);
  return r;
}
/** LoadImageFromMemory(params: const char * fileType, void * fileData, int dataSize -> void *) */
void * rl_LoadImageFromMemory(const char * fileType, void * fileData, int dataSize) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = LoadImageFromMemory(fileType, fileData, dataSize);
  return r;
}
/** LoadImageFromTexture(params: void * texture -> void *) */
void * rl_LoadImageFromTexture(void * texture) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = LoadImageFromTexture(*RL_TEX(texture));
  return r;
}
/** LoadImageFromScreen(params: void -> void *) */
void * rl_LoadImageFromScreen(void) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = LoadImageFromScreen();
  return r;
}
/** IsImageValid(params: void * image -> _Bool) */
_Bool rl_IsImageValid(void * image) {
  return IsImageValid(*RL_IMG(image));
}
/** UnloadImage(params: void * image -> void) */
void rl_UnloadImage(void * image) {
  Image *self = RL_IMG(image);
  UnloadImage(*self);
  free(self);
}
/** ExportImage(params: void * image, const char * fileName -> _Bool) */
_Bool rl_ExportImage(void * image, const char * fileName) {
  return ExportImage(*RL_IMG(image), fileName);
}
/** ExportImageToMemory(params: void * image, const char * fileType, void * fileSize -> void *) */
void * rl_ExportImageToMemory(void * image, const char * fileType, void * fileSize) {
  return ExportImageToMemory(*RL_IMG(image), fileType, fileSize);
}
/** ExportImageAsCode(params: void * image, const char * fileName -> _Bool) */
_Bool rl_ExportImageAsCode(void * image, const char * fileName) {
  return ExportImageAsCode(*RL_IMG(image), fileName);
}
/** GenImageColor(params: int width, int height, void * color -> void *) */
void * rl_GenImageColor(int width, int height, void * color) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GenImageColor(width, height, ((rl_Color*)color)->c);
  return r;
}
/** GenImageGradientLinear(params: int width, int height, int direction, void * start, void * end -> void *) */
void * rl_GenImageGradientLinear(int width, int height, int direction, void * start, void * end) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GenImageGradientLinear(width, height, direction, ((rl_Color*)start)->c, ((rl_Color*)end)->c);
  return r;
}
/** GenImageGradientRadial(params: int width, int height, float density, void * inner, void * outer -> void *) */
void * rl_GenImageGradientRadial(int width, int height, float density, void * inner, void * outer) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GenImageGradientRadial(width, height, density, ((rl_Color*)inner)->c, ((rl_Color*)outer)->c);
  return r;
}
/** GenImageGradientSquare(params: int width, int height, float density, void * inner, void * outer -> void *) */
void * rl_GenImageGradientSquare(int width, int height, float density, void * inner, void * outer) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GenImageGradientSquare(width, height, density, ((rl_Color*)inner)->c, ((rl_Color*)outer)->c);
  return r;
}
/** GenImageChecked(params: int width, int height, int checksX, int checksY, void * col1, void * col2 -> void *) */
void * rl_GenImageChecked(int width, int height, int checksX, int checksY, void * col1, void * col2) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GenImageChecked(width, height, checksX, checksY, ((rl_Color*)col1)->c, ((rl_Color*)col2)->c);
  return r;
}
/** GenImageWhiteNoise(params: int width, int height, float factor -> void *) */
void * rl_GenImageWhiteNoise(int width, int height, float factor) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GenImageWhiteNoise(width, height, factor);
  return r;
}
/** GenImagePerlinNoise(params: int width, int height, int offsetX, int offsetY, float scale -> void *) */
void * rl_GenImagePerlinNoise(int width, int height, int offsetX, int offsetY, float scale) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GenImagePerlinNoise(width, height, offsetX, offsetY, scale);
  return r;
}
/** GenImageCellular(params: int width, int height, int tileSize -> void *) */
void * rl_GenImageCellular(int width, int height, int tileSize) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GenImageCellular(width, height, tileSize);
  return r;
}
/** GenImageText(params: int width, int height, const char * text -> void *) */
void * rl_GenImageText(int width, int height, const char * text) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GenImageText(width, height, text);
  return r;
}
/** ImageCopy(params: void * image -> void *) */
void * rl_ImageCopy(void * image) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = ImageCopy(*RL_IMG(image));
  return r;
}
/** ImageFromImage(params: void * image, void * rec -> void *) */
void * rl_ImageFromImage(void * image, void * rec) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = ImageFromImage(*RL_IMG(image), *RL_RECT(rec));
  return r;
}
/** ImageFromChannel(params: void * image, int selectedChannel -> void *) */
void * rl_ImageFromChannel(void * image, int selectedChannel) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = ImageFromChannel(*RL_IMG(image), selectedChannel);
  return r;
}
/** ImageText(params: const char * text, int fontSize, void * color -> void *) */
void * rl_ImageText(const char * text, int fontSize, void * color) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = ImageText(text, fontSize, ((rl_Color*)color)->c);
  return r;
}
/** ImageTextEx(params: void * font, const char * text, float fontSize, float spacing, void * tint -> void *) */
void * rl_ImageTextEx(void * font, const char * text, float fontSize, float spacing, void * tint) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = ImageTextEx(*RL_FONT(font), text, fontSize, spacing, ((rl_Color*)tint)->c);
  return r;
}
/** ImageToPOT(params: void * image, void * fill -> void) */
void rl_ImageToPOT(void * image, void * fill) {
  ImageToPOT(image, ((rl_Color*)fill)->c);
}
/** ImageCrop(params: void * image, void * crop -> void) */
void rl_ImageCrop(void * image, void * crop) {
  ImageCrop(image, *RL_RECT(crop));
}
/** ImageAlphaClear(params: void * image, void * color, float threshold -> void) */
void rl_ImageAlphaClear(void * image, void * color, float threshold) {
  ImageAlphaClear(image, ((rl_Color*)color)->c, threshold);
}
/** ImageAlphaMask(params: void * image, void * alphaMask -> void) */
void rl_ImageAlphaMask(void * image, void * alphaMask) {
  ImageAlphaMask(image, *RL_IMG(alphaMask));
}
/** ImageResizeCanvas(params: void * image, int newWidth, int newHeight, int offsetX, int offsetY, void * fill -> void) */
void rl_ImageResizeCanvas(void * image, int newWidth, int newHeight, int offsetX, int offsetY, void * fill) {
  ImageResizeCanvas(image, newWidth, newHeight, offsetX, offsetY, ((rl_Color*)fill)->c);
}
/** ImageColorTint(params: void * image, void * color -> void) */
void rl_ImageColorTint(void * image, void * color) {
  ImageColorTint(image, ((rl_Color*)color)->c);
}
/** ImageColorReplace(params: void * image, void * color, void * replace -> void) */
void rl_ImageColorReplace(void * image, void * color, void * replace) {
  ImageColorReplace(image, ((rl_Color*)color)->c, ((rl_Color*)replace)->c);
}
/** LoadImageColors(params: void * image -> void *) */
void * rl_LoadImageColors(void * image) {
  return LoadImageColors(*RL_IMG(image));
}
/** LoadFileText as a raw char* handle so the pointer returned can be freed
 *  with rl_UnloadFileTextPtr. The flat `:str` binding copies the text into a
 *  Ruby String and loses the original pointer; UnloadFileText then frees a
 *  string literal/GC buffer and aborts. */
void * rl_LoadFileTextPtr(const char * fileName) {
  return LoadFileText(fileName);
}
/** UnloadFileText(params: void * text -> void) */
void rl_UnloadFileTextPtr(void * text) {
  UnloadFileText((char *)text);
}
/** Copy a NUL-terminated C string into a Ruby String (the pointer stays
 *  owned by raylib until rl_UnloadFileTextPtr). */
const char * rl_PtrToString(void * ptr) {
  return (const char *)ptr;
}
/** LoadImagePalette(params: void * image, int maxPaletteSize, void * colorCount -> void *) */
void * rl_LoadImagePalette(void * image, int maxPaletteSize, void * colorCount) {
  return LoadImagePalette(*RL_IMG(image), maxPaletteSize, colorCount);
}
/** UnloadImageColors(params: void * colors -> void) */
void rl_UnloadImageColors(void * colors) {
  /* LoadImageColors returns a raw Color* array (see rl_LoadImageColors and
   * rl_ImageColorR), not an rl_Color object. Passing the interior field
   * address here made free() abort with "invalid pointer". */
  UnloadImageColors((Color *)colors);
}
/** UnloadImagePalette(params: void * colors -> void) */
void rl_UnloadImagePalette(void * colors) {
  UnloadImagePalette((Color *)colors);
}
/** GetImageAlphaBorder(params: void * image, float threshold, void * _out -> void) */
void rl_GetImageAlphaBorder(void * image, float threshold, void * _out) {
  *RL_RECT(_out) = GetImageAlphaBorder(*RL_IMG(image), threshold);
}
/** GetImageColor(params: void * image, int x, int y, void * _out -> void) */
void rl_GetImageColor(void * image, int x, int y, void * _out) {
  ((rl_Color*)_out)->c = GetImageColor(*RL_IMG(image), x, y);
}
/** ImageClearBackground(params: void * dst, void * color -> void) */
void rl_ImageClearBackground(void * dst, void * color) {
  ImageClearBackground(dst, ((rl_Color*)color)->c);
}
/** ImageDrawPixel(params: void * dst, int posX, int posY, void * color -> void) */
void rl_ImageDrawPixel(void * dst, int posX, int posY, void * color) {
  ImageDrawPixel(dst, posX, posY, ((rl_Color*)color)->c);
}
/** ImageDrawPixelV(params: void * dst, void * position, void * color -> void) */
void rl_ImageDrawPixelV(void * dst, void * position, void * color) {
  ImageDrawPixelV(dst, *RL_V2(position), ((rl_Color*)color)->c);
}
/** ImageDrawLine(params: void * dst, int startPosX, int startPosY, int endPosX, int endPosY, void * color -> void) */
void rl_ImageDrawLine(void * dst, int startPosX, int startPosY, int endPosX, int endPosY, void * color) {
  ImageDrawLine(dst, startPosX, startPosY, endPosX, endPosY, ((rl_Color*)color)->c);
}
/** ImageDrawLineV(params: void * dst, void * start, void * end, void * color -> void) */
void rl_ImageDrawLineV(void * dst, void * start, void * end, void * color) {
  ImageDrawLineV(dst, *RL_V2(start), *RL_V2(end), ((rl_Color*)color)->c);
}
/** ImageDrawLineEx(params: void * dst, void * start, void * end, int thick, void * color -> void) */
void rl_ImageDrawLineEx(void * dst, void * start, void * end, int thick, void * color) {
  ImageDrawLineEx(dst, *RL_V2(start), *RL_V2(end), thick, ((rl_Color*)color)->c);
}
/** ImageDrawLineStrip(params: void * dst, void * points, int pointCount, void * color -> void) */
void rl_ImageDrawLineStrip(void * dst, void * points, int pointCount, void * color) {
  ImageDrawLineStrip(dst, points, pointCount, ((rl_Color*)color)->c);
}
/** ImageDrawTriangle(params: void * dst, void * v1, void * v2, void * v3, void * color -> void) */
void rl_ImageDrawTriangle(void * dst, void * v1, void * v2, void * v3, void * color) {
  ImageDrawTriangle(dst, *RL_V2(v1), *RL_V2(v2), *RL_V2(v3), ((rl_Color*)color)->c);
}
/** ImageDrawTriangleGradient(params: void * dst, void * v1, void * v2, void * v3, void * c1, void * c2, void * c3 -> void) */
void rl_ImageDrawTriangleGradient(void * dst, void * v1, void * v2, void * v3, void * c1, void * c2, void * c3) {
  ImageDrawTriangleGradient(dst, *RL_V2(v1), *RL_V2(v2), *RL_V2(v3), ((rl_Color*)c1)->c, ((rl_Color*)c2)->c, ((rl_Color*)c3)->c);
}
/** ImageDrawTriangleLines(params: void * dst, void * v1, void * v2, void * v3, void * color -> void) */
void rl_ImageDrawTriangleLines(void * dst, void * v1, void * v2, void * v3, void * color) {
  ImageDrawTriangleLines(dst, *RL_V2(v1), *RL_V2(v2), *RL_V2(v3), ((rl_Color*)color)->c);
}
/** ImageDrawTriangleFan(params: void * dst, void * points, int pointCount, void * color -> void) */
void rl_ImageDrawTriangleFan(void * dst, void * points, int pointCount, void * color) {
  ImageDrawTriangleFan(dst, points, pointCount, ((rl_Color*)color)->c);
}
/** ImageDrawTriangleStrip(params: void * dst, void * points, int pointCount, void * color -> void) */
void rl_ImageDrawTriangleStrip(void * dst, void * points, int pointCount, void * color) {
  ImageDrawTriangleStrip(dst, points, pointCount, ((rl_Color*)color)->c);
}
/** ImageDrawRectangle(params: void * dst, int posX, int posY, int width, int height, void * color -> void) */
void rl_ImageDrawRectangle(void * dst, int posX, int posY, int width, int height, void * color) {
  ImageDrawRectangle(dst, posX, posY, width, height, ((rl_Color*)color)->c);
}
/** ImageDrawRectangleV(params: void * dst, void * position, void * size, void * color -> void) */
void rl_ImageDrawRectangleV(void * dst, void * position, void * size, void * color) {
  ImageDrawRectangleV(dst, *RL_V2(position), *RL_V2(size), ((rl_Color*)color)->c);
}
/** ImageDrawRectangleRec(params: void * dst, void * rec, void * color -> void) */
void rl_ImageDrawRectangleRec(void * dst, void * rec, void * color) {
  ImageDrawRectangleRec(dst, *RL_RECT(rec), ((rl_Color*)color)->c);
}
/** ImageDrawRectanglePro(params: void * dst, void * rec, void * origin, float rotation, void * color -> void) */
void rl_ImageDrawRectanglePro(void * dst, void * rec, void * origin, float rotation, void * color) {
  ImageDrawRectanglePro(dst, *RL_RECT(rec), *RL_V2(origin), rotation, ((rl_Color*)color)->c);
}
/** ImageDrawRectangleLines(params: void * dst, int posX, int posY, int width, int height, void * color -> void) */
void rl_ImageDrawRectangleLines(void * dst, int posX, int posY, int width, int height, void * color) {
  ImageDrawRectangleLines(dst, posX, posY, width, height, ((rl_Color*)color)->c);
}
/** ImageDrawRectangleLinesEx(params: void * dst, void * rec, int thick, void * color -> void) */
void rl_ImageDrawRectangleLinesEx(void * dst, void * rec, int thick, void * color) {
  ImageDrawRectangleLinesEx(dst, *RL_RECT(rec), thick, ((rl_Color*)color)->c);
}
/** ImageDrawRectangleGradientEx(params: void * dst, void * rec, void * col1, void * col2, void * col3, void * col4 -> void) */
void rl_ImageDrawRectangleGradientEx(void * dst, void * rec, void * col1, void * col2, void * col3, void * col4) {
  ImageDrawRectangleGradientEx(dst, *RL_RECT(rec), ((rl_Color*)col1)->c, ((rl_Color*)col2)->c, ((rl_Color*)col3)->c, ((rl_Color*)col4)->c);
}
/** ImageDrawCircle(params: void * dst, int centerX, int centerY, int radius, void * color -> void) */
void rl_ImageDrawCircle(void * dst, int centerX, int centerY, int radius, void * color) {
  ImageDrawCircle(dst, centerX, centerY, radius, ((rl_Color*)color)->c);
}
/** ImageDrawCircleV(params: void * dst, void * center, int radius, void * color -> void) */
void rl_ImageDrawCircleV(void * dst, void * center, int radius, void * color) {
  ImageDrawCircleV(dst, *RL_V2(center), radius, ((rl_Color*)color)->c);
}
/** ImageDrawCircleLines(params: void * dst, int centerX, int centerY, int radius, void * color -> void) */
void rl_ImageDrawCircleLines(void * dst, int centerX, int centerY, int radius, void * color) {
  ImageDrawCircleLines(dst, centerX, centerY, radius, ((rl_Color*)color)->c);
}
/** ImageDrawCircleLinesV(params: void * dst, void * center, int radius, void * color -> void) */
void rl_ImageDrawCircleLinesV(void * dst, void * center, int radius, void * color) {
  ImageDrawCircleLinesV(dst, *RL_V2(center), radius, ((rl_Color*)color)->c);
}
/** ImageDrawCircleGradient(params: void * dst, void * center, float radius, void * inner, void * outer -> void) */
void rl_ImageDrawCircleGradient(void * dst, void * center, float radius, void * inner, void * outer) {
  ImageDrawCircleGradient(dst, *RL_V2(center), radius, ((rl_Color*)inner)->c, ((rl_Color*)outer)->c);
}
/** ImageDrawImage(params: void * dst, void * src, int posX, int posY, void * tint -> void) */
void rl_ImageDrawImage(void * dst, void * src, int posX, int posY, void * tint) {
  ImageDrawImage(dst, *RL_IMG(src), posX, posY, ((rl_Color*)tint)->c);
}
/** ImageDrawImageEx(params: void * dst, void * src, void * position, float rotation, float scale, void * tint -> void) */
void rl_ImageDrawImageEx(void * dst, void * src, void * position, float rotation, float scale, void * tint) {
  ImageDrawImageEx(dst, *RL_IMG(src), *RL_V2(position), rotation, scale, ((rl_Color*)tint)->c);
}
/** ImageDrawImageRec(params: void * dst, void * src, void * srcRec, void * position, void * tint -> void) */
void rl_ImageDrawImageRec(void * dst, void * src, void * srcRec, void * position, void * tint) {
  ImageDrawImageRec(dst, *RL_IMG(src), *RL_RECT(srcRec), *RL_V2(position), ((rl_Color*)tint)->c);
}
/** ImageDrawImagePro(params: void * dst, void * src, void * srcRec, void * dstRec, void * origin, float rotation, void * tint -> void) */
void rl_ImageDrawImagePro(void * dst, void * src, void * srcRec, void * dstRec, void * origin, float rotation, void * tint) {
  ImageDrawImagePro(dst, *RL_IMG(src), *RL_RECT(srcRec), *RL_RECT(dstRec), *RL_V2(origin), rotation, ((rl_Color*)tint)->c);
}
/** ImageDrawText(params: void * dst, const char * text, int posX, int posY, int fontSize, void * color -> void) */
void rl_ImageDrawText(void * dst, const char * text, int posX, int posY, int fontSize, void * color) {
  ImageDrawText(dst, text, posX, posY, fontSize, ((rl_Color*)color)->c);
}
/** ImageDrawTextEx(params: void * dst, void * font, const char * text, void * position, float fontSize, float spacing, void * tint -> void) */
void rl_ImageDrawTextEx(void * dst, void * font, const char * text, void * position, float fontSize, float spacing, void * tint) {
  ImageDrawTextEx(dst, *RL_FONT(font), text, *RL_V2(position), fontSize, spacing, ((rl_Color*)tint)->c);
}
/** ImageDrawTextPro(params: void * dst, void * font, const char * text, void * position, void * origin, float rotation, float fontSize, float spacing, void * tint -> void) */
void rl_ImageDrawTextPro(void * dst, void * font, const char * text, void * position, void * origin, float rotation, float fontSize, float spacing, void * tint) {
  ImageDrawTextPro(dst, *RL_FONT(font), text, *RL_V2(position), *RL_V2(origin), rotation, fontSize, spacing, ((rl_Color*)tint)->c);
}
/** LoadTextureFromImage(params: void * image -> void *) */
void * rl_LoadTextureFromImage(void * image) {
  Texture2D *r = (Texture2D *)malloc(sizeof(Texture2D));
  *r = LoadTextureFromImage(*RL_IMG(image));
  return r;
}
/** LoadTextureCubemap(params: void * image, int layout -> void *) */
void * rl_LoadTextureCubemap(void * image, int layout) {
  TextureCubemap *r = (TextureCubemap *)malloc(sizeof(TextureCubemap));
  *r = LoadTextureCubemap(*RL_IMG(image), layout);
  return r;
}
/** LoadRenderTexture(params: int width, int height -> void *) */
void * rl_LoadRenderTexture(int width, int height) {
  RenderTexture2D *r = (RenderTexture2D *)malloc(sizeof(RenderTexture2D));
  *r = LoadRenderTexture(width, height);
  return r;
}
/** LoadRenderTextureEx(params: int width, int height, int format -> void *) */
void * rl_LoadRenderTextureEx(int width, int height, int format) {
  RenderTexture2D *r = (RenderTexture2D *)malloc(sizeof(RenderTexture2D));
  *r = LoadRenderTextureEx(width, height, format);
  return r;
}
/** IsTextureValid(params: void * texture -> _Bool) */
_Bool rl_IsTextureValid(void * texture) {
  return IsTextureValid(*RL_TEX(texture));
}
/** IsRenderTextureValid(params: void * target -> _Bool) */
_Bool rl_IsRenderTextureValid(void * target) {
  return IsRenderTextureValid(*RL_RT(target));
}
/** UnloadRenderTexture(params: void * target -> void) */
void rl_UnloadRenderTexture(void * target) {
  UnloadRenderTexture(*RL_RT(target));
}
/** UpdateTexture(params: void * texture, void * pixels -> void) */
void rl_UpdateTexture(void * texture, void * pixels) {
  UpdateTexture(*RL_TEX(texture), pixels);
}
/** UpdateTextureRec(params: void * texture, void * rec, void * pixels -> void) */
void rl_UpdateTextureRec(void * texture, void * rec, void * pixels) {
  UpdateTextureRec(*RL_TEX(texture), *RL_RECT(rec), pixels);
}
/** SetTextureFilter(params: void * texture, int filter -> void) */
void rl_SetTextureFilter(void * texture, int filter) {
  SetTextureFilter(*RL_TEX(texture), filter);
}
/** SetTextureWrap(params: void * texture, int wrap -> void) */
void rl_SetTextureWrap(void * texture, int wrap) {
  SetTextureWrap(*RL_TEX(texture), wrap);
}
/** DrawTextureV(params: void * texture, void * position, void * tint -> void) */
void rl_DrawTextureV(void * texture, void * position, void * tint) {
  DrawTextureV(*RL_TEX(texture), *RL_V2(position), ((rl_Color*)tint)->c);
}
/** DrawTextureRec(params: void * texture, void * rec, void * position, void * tint -> void) */
void rl_DrawTextureRec(void * texture, void * rec, void * position, void * tint) {
  DrawTextureRec(*RL_TEX(texture), *RL_RECT(rec), *RL_V2(position), ((rl_Color*)tint)->c);
}
/** DrawTexturePro(params: void * texture, void * srcrec, void * dstrec, void * origin, float rotation, void * tint -> void) */
void rl_DrawTexturePro(void * texture, void * srcrec, void * dstrec, void * origin, float rotation, void * tint) {
  DrawTexturePro(*RL_TEX(texture), *RL_RECT(srcrec), *RL_RECT(dstrec), *RL_V2(origin), rotation, ((rl_Color*)tint)->c);
}
/** DrawTextureNPatch(params: void * texture, void * nPatchInfo, void * dstrec, void * origin, float rotation, void * tint -> void) */
void rl_DrawTextureNPatch(void * texture, void * nPatchInfo, void * dstrec, void * origin, float rotation, void * tint) {
  DrawTextureNPatch(*RL_TEX(texture), ((rl_NPatchInfo*)nPatchInfo)->v, *RL_RECT(dstrec), *RL_V2(origin), rotation, ((rl_Color*)tint)->c);
}
/** ColorIsEqual(params: void * col1, void * col2 -> _Bool) */
_Bool rl_ColorIsEqual(void * col1, void * col2) {
  return ColorIsEqual(((rl_Color*)col1)->c, ((rl_Color*)col2)->c);
}
/** Fade(params: void * color, float alpha, void * _out -> void) */
void rl_Fade(void * color, float alpha, void * _out) {
  ((rl_Color*)_out)->c = Fade(((rl_Color*)color)->c, alpha);
}
/** ColorToInt(params: void * color -> int) */
int rl_ColorToInt(void * color) {
  return ColorToInt(((rl_Color*)color)->c);
}
/** ColorNormalize(params: void * color, void * _out -> void) */
void rl_ColorNormalize(void * color, void * _out) {
  *RL_V4(_out) = ColorNormalize(((rl_Color*)color)->c);
}
/** ColorFromNormalized(params: void * normalized, void * _out -> void) */
void rl_ColorFromNormalized(void * normalized, void * _out) {
  ((rl_Color*)_out)->c = ColorFromNormalized(*RL_V4(normalized));
}
/** ColorToHSV(params: void * color, void * _out -> void) */
void rl_ColorToHSV(void * color, void * _out) {
  *RL_V3(_out) = ColorToHSV(((rl_Color*)color)->c);
}
/** ColorFromHSV(params: float hue, float saturation, float value, void * _out -> void) */
void rl_ColorFromHSV(float hue, float saturation, float value, void * _out) {
  ((rl_Color*)_out)->c = ColorFromHSV(hue, saturation, value);
}
/** ColorTint(params: void * color, void * tint, void * _out -> void) */
void rl_ColorTint(void * color, void * tint, void * _out) {
  ((rl_Color*)_out)->c = ColorTint(((rl_Color*)color)->c, ((rl_Color*)tint)->c);
}
/** ColorBrightness(params: void * color, float factor, void * _out -> void) */
void rl_ColorBrightness(void * color, float factor, void * _out) {
  ((rl_Color*)_out)->c = ColorBrightness(((rl_Color*)color)->c, factor);
}
/** ColorContrast(params: void * color, float contrast, void * _out -> void) */
void rl_ColorContrast(void * color, float contrast, void * _out) {
  ((rl_Color*)_out)->c = ColorContrast(((rl_Color*)color)->c, contrast);
}
/** ColorAlpha(params: void * color, float alpha, void * _out -> void) */
void rl_ColorAlpha(void * color, float alpha, void * _out) {
  ((rl_Color*)_out)->c = ColorAlpha(((rl_Color*)color)->c, alpha);
}
/** ColorAlphaBlend(params: void * dst, void * src, void * tint, void * _out -> void) */
void rl_ColorAlphaBlend(void * dst, void * src, void * tint, void * _out) {
  ((rl_Color*)_out)->c = ColorAlphaBlend(((rl_Color*)dst)->c, ((rl_Color*)src)->c, ((rl_Color*)tint)->c);
}
/** ColorLerp(params: void * color1, void * color2, float factor, void * _out -> void) */
void rl_ColorLerp(void * color1, void * color2, float factor, void * _out) {
  ((rl_Color*)_out)->c = ColorLerp(((rl_Color*)color1)->c, ((rl_Color*)color2)->c, factor);
}
/** GetColor(params: uint32_t hexValue, void * _out -> void) */
void rl_GetColor(uint32_t hexValue, void * _out) {
  ((rl_Color*)_out)->c = GetColor(hexValue);
}
/** GetPixelColor(params: void * srcPtr, int format, void * _out -> void) */
void rl_GetPixelColor(void * srcPtr, int format, void * _out) {
  ((rl_Color*)_out)->c = GetPixelColor(srcPtr, format);
}
/** SetPixelColor(params: void * dstPtr, void * color, int format -> void) */
void rl_SetPixelColor(void * dstPtr, void * color, int format) {
  SetPixelColor(dstPtr, ((rl_Color*)color)->c, format);
}
/** GetFontDefault(params: void -> void *) */
void * rl_GetFontDefault(void) {
  Font *r = (Font *)malloc(sizeof(Font));
  *r = GetFontDefault();
  return r;
}
/** LoadFont(params: const char * fileName -> void *) */
void * rl_LoadFont(const char * fileName) {
  Font *r = (Font *)malloc(sizeof(Font));
  *r = LoadFont(fileName);
  return r;
}
/** LoadFontEx(params: const char * fileName, int fontSize, void * codepoints, int codepointCount -> void *) */
void * rl_LoadFontEx(const char * fileName, int fontSize, void * codepoints, int codepointCount) {
  Font *r = (Font *)malloc(sizeof(Font));
  *r = LoadFontEx(fileName, fontSize, codepoints, codepointCount);
  return r;
}
/** LoadFontFromImage(params: void * image, void * key, int firstChar -> void *) */
void * rl_LoadFontFromImage(void * image, void * key, int firstChar) {
  Font *r = (Font *)malloc(sizeof(Font));
  *r = LoadFontFromImage(*RL_IMG(image), ((rl_Color*)key)->c, firstChar);
  return r;
}
/** LoadFontFromMemory(params: const char * fileType, void * fileData, int dataSize, int fontSize, void * codepoints, int codepointCount -> void *) */
void * rl_LoadFontFromMemory(const char * fileType, void * fileData, int dataSize, int fontSize, void * codepoints, int codepointCount) {
  Font *r = (Font *)malloc(sizeof(Font));
  *r = LoadFontFromMemory(fileType, fileData, dataSize, fontSize, codepoints, codepointCount);
  return r;
}
/** IsFontValid(params: void * font -> _Bool) */
_Bool rl_IsFontValid(void * font) {
  return IsFontValid(*RL_FONT(font));
}
/** GenImageFontAtlas(params: void * glyphs, void * glyphRecs, int glyphCount, int fontSize, int padding, int packMethod -> void *) */
void * rl_GenImageFontAtlas(void * glyphs, void * glyphRecs, int glyphCount, int fontSize, int padding, int packMethod) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GenImageFontAtlas(glyphs, glyphRecs, glyphCount, fontSize, padding, packMethod);
  return r;
}
/** UnloadFont(params: void * font -> void) */
void rl_UnloadFont(void * font) {
  Font *self = RL_FONT(font);
  UnloadFont(*self);
  free(self);
}
/** ExportFontAsCode(params: void * font, const char * fileName -> _Bool) */
_Bool rl_ExportFontAsCode(void * font, const char * fileName) {
  return ExportFontAsCode(*RL_FONT(font), fileName);
}
/** DrawTextEx(params: void * font, const char * text, void * position, float fontSize, float spacing, void * tint -> void) */
void rl_DrawTextEx(void * font, const char * text, void * position, float fontSize, float spacing, void * tint) {
  DrawTextEx(*RL_FONT(font), text, *RL_V2(position), fontSize, spacing, ((rl_Color*)tint)->c);
}
/** DrawTextPro(params: void * font, const char * text, void * position, void * origin, float rotation, float fontSize, float spacing, void * tint -> void) */
void rl_DrawTextPro(void * font, const char * text, void * position, void * origin, float rotation, float fontSize, float spacing, void * tint) {
  DrawTextPro(*RL_FONT(font), text, *RL_V2(position), *RL_V2(origin), rotation, fontSize, spacing, ((rl_Color*)tint)->c);
}
/** DrawTextCodepoint(params: void * font, int codepoint, void * position, float fontSize, void * tint -> void) */
void rl_DrawTextCodepoint(void * font, int codepoint, void * position, float fontSize, void * tint) {
  DrawTextCodepoint(*RL_FONT(font), codepoint, *RL_V2(position), fontSize, ((rl_Color*)tint)->c);
}
/** DrawTextCodepoints(params: void * font, void * codepoints, int codepointCount, void * position, float fontSize, float spacing, void * tint -> void) */
void rl_DrawTextCodepoints(void * font, void * codepoints, int codepointCount, void * position, float fontSize, float spacing, void * tint) {
  DrawTextCodepoints(*RL_FONT(font), codepoints, codepointCount, *RL_V2(position), fontSize, spacing, ((rl_Color*)tint)->c);
}
/** MeasureTextEx(params: void * font, const char * text, float fontSize, float spacing, void * _out -> void) */
void rl_MeasureTextEx(void * font, const char * text, float fontSize, float spacing, void * _out) {
  *RL_V2(_out) = MeasureTextEx(*RL_FONT(font), text, fontSize, spacing);
}
/** MeasureTextCodepoints(params: void * font, void * codepoints, int length, float fontSize, float spacing, void * _out -> void) */
void rl_MeasureTextCodepoints(void * font, void * codepoints, int length, float fontSize, float spacing, void * _out) {
  *RL_V2(_out) = MeasureTextCodepoints(*RL_FONT(font), codepoints, length, fontSize, spacing);
}
/** GetGlyphIndex(params: void * font, int codepoint -> int) */
int rl_GetGlyphIndex(void * font, int codepoint) {
  return GetGlyphIndex(*RL_FONT(font), codepoint);
}
/** GetGlyphInfo(params: void * font, int codepoint -> void *) */
void * rl_GetGlyphInfo(void * font, int codepoint) {
  GlyphInfo *r = (GlyphInfo *)malloc(sizeof(GlyphInfo));
  *r = GetGlyphInfo(*RL_FONT(font), codepoint);
  return r;
}
/** GetGlyphAtlasRec(params: void * font, int codepoint, void * _out -> void) */
void rl_GetGlyphAtlasRec(void * font, int codepoint, void * _out) {
  *RL_RECT(_out) = GetGlyphAtlasRec(*RL_FONT(font), codepoint);
}
/** DrawLine3D(params: void * startPos, void * endPos, void * color -> void) */
void rl_DrawLine3D(void * startPos, void * endPos, void * color) {
  DrawLine3D(*RL_V3(startPos), *RL_V3(endPos), ((rl_Color*)color)->c);
}
/** DrawPoint3D(params: void * position, void * color -> void) */
void rl_DrawPoint3D(void * position, void * color) {
  DrawPoint3D(*RL_V3(position), ((rl_Color*)color)->c);
}
/** DrawCircle3D(params: void * center, float radius, void * rotationAxis, float rotationAngle, void * color -> void) */
void rl_DrawCircle3D(void * center, float radius, void * rotationAxis, float rotationAngle, void * color) {
  DrawCircle3D(*RL_V3(center), radius, *RL_V3(rotationAxis), rotationAngle, ((rl_Color*)color)->c);
}
/** DrawTriangle3D(params: void * v1, void * v2, void * v3, void * color -> void) */
void rl_DrawTriangle3D(void * v1, void * v2, void * v3, void * color) {
  DrawTriangle3D(*RL_V3(v1), *RL_V3(v2), *RL_V3(v3), ((rl_Color*)color)->c);
}
/** DrawTriangleStrip3D(params: void * points, int pointCount, void * color -> void) */
void rl_DrawTriangleStrip3D(void * points, int pointCount, void * color) {
  DrawTriangleStrip3D(points, pointCount, ((rl_Color*)color)->c);
}
/** DrawCubeV(params: void * position, void * size, void * color -> void) */
void rl_DrawCubeV(void * position, void * size, void * color) {
  DrawCubeV(*RL_V3(position), *RL_V3(size), ((rl_Color*)color)->c);
}
/** DrawCubeWiresV(params: void * position, void * size, void * color -> void) */
void rl_DrawCubeWiresV(void * position, void * size, void * color) {
  DrawCubeWiresV(*RL_V3(position), *RL_V3(size), ((rl_Color*)color)->c);
}
/** DrawSphere(params: void * centerPos, float radius, void * color -> void) */
void rl_DrawSphere(void * centerPos, float radius, void * color) {
  DrawSphere(*RL_V3(centerPos), radius, ((rl_Color*)color)->c);
}
/** DrawSphereEx(params: void * centerPos, float radius, int rings, int slices, void * color -> void) */
void rl_DrawSphereEx(void * centerPos, float radius, int rings, int slices, void * color) {
  DrawSphereEx(*RL_V3(centerPos), radius, rings, slices, ((rl_Color*)color)->c);
}
/** DrawSphereWires(params: void * centerPos, float radius, int rings, int slices, void * color -> void) */
void rl_DrawSphereWires(void * centerPos, float radius, int rings, int slices, void * color) {
  DrawSphereWires(*RL_V3(centerPos), radius, rings, slices, ((rl_Color*)color)->c);
}
/** DrawCylinder(params: void * position, float radiusTop, float radiusBottom, float height, int sides, void * color -> void) */
void rl_DrawCylinder(void * position, float radiusTop, float radiusBottom, float height, int sides, void * color) {
  DrawCylinder(*RL_V3(position), radiusTop, radiusBottom, height, sides, ((rl_Color*)color)->c);
}
/** DrawCylinderEx(params: void * startPos, void * endPos, float startRadius, float endRadius, int sides, void * color -> void) */
void rl_DrawCylinderEx(void * startPos, void * endPos, float startRadius, float endRadius, int sides, void * color) {
  DrawCylinderEx(*RL_V3(startPos), *RL_V3(endPos), startRadius, endRadius, sides, ((rl_Color*)color)->c);
}
/** DrawCylinderWires(params: void * position, float radiusTop, float radiusBottom, float height, int sides, void * color -> void) */
void rl_DrawCylinderWires(void * position, float radiusTop, float radiusBottom, float height, int sides, void * color) {
  DrawCylinderWires(*RL_V3(position), radiusTop, radiusBottom, height, sides, ((rl_Color*)color)->c);
}
/** DrawCylinderWiresEx(params: void * startPos, void * endPos, float startRadius, float endRadius, int sides, void * color -> void) */
void rl_DrawCylinderWiresEx(void * startPos, void * endPos, float startRadius, float endRadius, int sides, void * color) {
  DrawCylinderWiresEx(*RL_V3(startPos), *RL_V3(endPos), startRadius, endRadius, sides, ((rl_Color*)color)->c);
}
/** DrawCapsule(params: void * startPos, void * endPos, float radius, int rings, int slices, void * color -> void) */
void rl_DrawCapsule(void * startPos, void * endPos, float radius, int rings, int slices, void * color) {
  DrawCapsule(*RL_V3(startPos), *RL_V3(endPos), radius, rings, slices, ((rl_Color*)color)->c);
}
/** DrawCapsuleWires(params: void * startPos, void * endPos, float radius, int rings, int slices, void * color -> void) */
void rl_DrawCapsuleWires(void * startPos, void * endPos, float radius, int rings, int slices, void * color) {
  DrawCapsuleWires(*RL_V3(startPos), *RL_V3(endPos), radius, rings, slices, ((rl_Color*)color)->c);
}
/** DrawRay(params: void * ray, void * color -> void) */
void rl_DrawRay(void * ray, void * color) {
  DrawRay(((rl_Ray*)ray)->v, ((rl_Color*)color)->c);
}
/** LoadModel(params: const char * fileName -> void *) */
void * rl_LoadModel(const char * fileName) {
  Model *r = (Model *)malloc(sizeof(Model));
  *r = LoadModel(fileName);
  return r;
}
/** LoadModelFromMesh(params: void * mesh -> void *) */
void * rl_LoadModelFromMesh(void * mesh) {
  Model *r = (Model *)malloc(sizeof(Model));
  *r = LoadModelFromMesh(*(Mesh *)mesh);
  return r;
}
/** IsModelValid(params: void * model -> _Bool) */
_Bool rl_IsModelValid(void * model) {
  return IsModelValid(*(Model *)model);
}
/** UnloadModel(params: void * model -> void) */
void rl_UnloadModel(void * model) {
  Model *self = (Model *)model;
  UnloadModel(*self);
  free(self);
}
/** GetModelBoundingBox(params: void * model, void * _out -> void) */
void rl_GetModelBoundingBox(void * model, void * _out) {
  ((rl_BoundingBox*)_out)->v = GetModelBoundingBox(*(Model *)model);
}
/** DrawModel(params: void * model, void * position, float scale, void * tint -> void) */
void rl_DrawModel(void * model, void * position, float scale, void * tint) {
  DrawModel(*(Model *)model, *RL_V3(position), scale, ((rl_Color*)tint)->c);
}
/** DrawModelEx(params: void * model, void * position, void * rotationAxis, float rotationAngle, void * scale, void * tint -> void) */
void rl_DrawModelEx(void * model, void * position, void * rotationAxis, float rotationAngle, void * scale, void * tint) {
  DrawModelEx(*(Model *)model, *RL_V3(position), *RL_V3(rotationAxis), rotationAngle, *RL_V3(scale), ((rl_Color*)tint)->c);
}
/** DrawModelWires(params: void * model, void * position, float scale, void * tint -> void) */
void rl_DrawModelWires(void * model, void * position, float scale, void * tint) {
  DrawModelWires(*(Model *)model, *RL_V3(position), scale, ((rl_Color*)tint)->c);
}
/** DrawModelWiresEx(params: void * model, void * position, void * rotationAxis, float rotationAngle, void * scale, void * tint -> void) */
void rl_DrawModelWiresEx(void * model, void * position, void * rotationAxis, float rotationAngle, void * scale, void * tint) {
  DrawModelWiresEx(*(Model *)model, *RL_V3(position), *RL_V3(rotationAxis), rotationAngle, *RL_V3(scale), ((rl_Color*)tint)->c);
}
/** DrawBoundingBox(params: void * box, void * color -> void) */
void rl_DrawBoundingBox(void * box, void * color) {
  DrawBoundingBox(((rl_BoundingBox*)box)->v, ((rl_Color*)color)->c);
}
/** DrawBillboard(params: void * camera, void * texture, void * position, float scale, void * tint -> void) */
void rl_DrawBillboard(void * camera, void * texture, void * position, float scale, void * tint) {
  DrawBillboard(((rl_Camera*)camera)->c, *RL_TEX(texture), *RL_V3(position), scale, ((rl_Color*)tint)->c);
}
/** DrawBillboardRec(params: void * camera, void * texture, void * rec, void * position, void * size, void * tint -> void) */
void rl_DrawBillboardRec(void * camera, void * texture, void * rec, void * position, void * size, void * tint) {
  DrawBillboardRec(((rl_Camera*)camera)->c, *RL_TEX(texture), *RL_RECT(rec), *RL_V3(position), *RL_V2(size), ((rl_Color*)tint)->c);
}
/** DrawBillboardPro(params: void * camera, void * texture, void * rec, void * position, void * up, void * size, void * origin, float rotation, void * tint -> void) */
void rl_DrawBillboardPro(void * camera, void * texture, void * rec, void * position, void * up, void * size, void * origin, float rotation, void * tint) {
  DrawBillboardPro(((rl_Camera*)camera)->c, *RL_TEX(texture), *RL_RECT(rec), *RL_V3(position), *RL_V3(up), *RL_V2(size), *RL_V2(origin), rotation, ((rl_Color*)tint)->c);
}
/** UpdateMeshBuffer(params: void * mesh, int index, void * data, int dataSize, int offset -> void) */
void rl_UpdateMeshBuffer(void * mesh, int index, void * data, int dataSize, int offset) {
  UpdateMeshBuffer(*(Mesh *)mesh, index, data, dataSize, offset);
}
/** UnloadMesh(params: void * mesh -> void) */
void rl_UnloadMesh(void * mesh) {
  Mesh *self = (Mesh *)mesh;
  UnloadMesh(*self);
  free(self);
}
/** DrawMesh(params: void * mesh, void * material, void * transform -> void) */
void rl_DrawMesh(void * mesh, void * material, void * transform) {
  DrawMesh(*(Mesh *)mesh, *(Material *)material, ((rl_Matrix*)transform)->v);
}
/** DrawMeshInstanced(params: void * mesh, void * material, void * transforms, int instances -> void) */
void rl_DrawMeshInstanced(void * mesh, void * material, void * transforms, int instances) {
  DrawMeshInstanced(*(Mesh *)mesh, *(Material *)material, transforms, instances);
}
/** GetMeshBoundingBox(params: void * mesh, void * _out -> void) */
void rl_GetMeshBoundingBox(void * mesh, void * _out) {
  ((rl_BoundingBox*)_out)->v = GetMeshBoundingBox(*(Mesh *)mesh);
}
/** ExportMesh(params: void * mesh, const char * fileName -> _Bool) */
_Bool rl_ExportMesh(void * mesh, const char * fileName) {
  return ExportMesh(*(Mesh *)mesh, fileName);
}
/** ExportMeshAsCode(params: void * mesh, const char * fileName -> _Bool) */
_Bool rl_ExportMeshAsCode(void * mesh, const char * fileName) {
  return ExportMeshAsCode(*(Mesh *)mesh, fileName);
}
/** GenMeshPoly(params: int sides, float radius -> void *) */
void * rl_GenMeshPoly(int sides, float radius) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshPoly(sides, radius);
  return r;
}
/** GenMeshPlane(params: float width, float length, int resX, int resZ -> void *) */
void * rl_GenMeshPlane(float width, float length, int resX, int resZ) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshPlane(width, length, resX, resZ);
  return r;
}
/** GenMeshCube(params: float width, float height, float length -> void *) */
void * rl_GenMeshCube(float width, float height, float length) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshCube(width, height, length);
  return r;
}
/** GenMeshSphere(params: float radius, int rings, int slices -> void *) */
void * rl_GenMeshSphere(float radius, int rings, int slices) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshSphere(radius, rings, slices);
  return r;
}
/** GenMeshHemiSphere(params: float radius, int rings, int slices -> void *) */
void * rl_GenMeshHemiSphere(float radius, int rings, int slices) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshHemiSphere(radius, rings, slices);
  return r;
}
/** GenMeshCylinder(params: float radius, float height, int slices -> void *) */
void * rl_GenMeshCylinder(float radius, float height, int slices) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshCylinder(radius, height, slices);
  return r;
}
/** GenMeshCone(params: float radius, float height, int slices -> void *) */
void * rl_GenMeshCone(float radius, float height, int slices) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshCone(radius, height, slices);
  return r;
}
/** GenMeshTorus(params: float radius, float size, int radSeg, int sides -> void *) */
void * rl_GenMeshTorus(float radius, float size, int radSeg, int sides) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshTorus(radius, size, radSeg, sides);
  return r;
}
/** GenMeshKnot(params: float radius, float size, int radSeg, int sides -> void *) */
void * rl_GenMeshKnot(float radius, float size, int radSeg, int sides) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshKnot(radius, size, radSeg, sides);
  return r;
}
/** GenMeshHeightmap(params: void * heightmap, void * size -> void *) */
void * rl_GenMeshHeightmap(void * heightmap, void * size) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshHeightmap(*RL_IMG(heightmap), *RL_V3(size));
  return r;
}
/** GenMeshCubicmap(params: void * cubicmap, void * cubeSize -> void *) */
void * rl_GenMeshCubicmap(void * cubicmap, void * cubeSize) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshCubicmap(*RL_IMG(cubicmap), *RL_V3(cubeSize));
  return r;
}
/** LoadMaterialDefault(params: void -> void *) */
void * rl_LoadMaterialDefault(void) {
  Material *r = (Material *)malloc(sizeof(Material));
  *r = LoadMaterialDefault();
  return r;
}
/** IsMaterialValid(params: void * material -> _Bool) */
_Bool rl_IsMaterialValid(void * material) {
  return IsMaterialValid(*(Material *)material);
}
/** UnloadMaterial(params: void * material -> void) */
void rl_UnloadMaterial(void * material) {
  Material *self = (Material *)material;
  UnloadMaterial(*self);
  free(self);
}
/** SetMaterialTexture(params: void * material, int mapType, void * texture -> void) */
void rl_SetMaterialTexture(void * material, int mapType, void * texture) {
  SetMaterialTexture(material, mapType, *RL_TEX(texture));
}
/** UpdateModelAnimation(params: void * model, void * anim, float frame -> void) */
void rl_UpdateModelAnimation(void * model, void * anim, float frame) {
  UpdateModelAnimation(*(Model *)model, *(ModelAnimation *)anim, frame);
}
/** UpdateModelAnimationEx(params: void * model, void * animA, float frameA, void * animB, float frameB, float blend -> void) */
void rl_UpdateModelAnimationEx(void * model, void * animA, float frameA, void * animB, float frameB, float blend) {
  UpdateModelAnimationEx(*(Model *)model, *(ModelAnimation *)animA, frameA, *(ModelAnimation *)animB, frameB, blend);
}
/** IsModelAnimationValid(params: void * model, void * anim -> _Bool) */
_Bool rl_IsModelAnimationValid(void * model, void * anim) {
  return IsModelAnimationValid(*(Model *)model, *(ModelAnimation *)anim);
}
/** CheckCollisionSpheres(params: void * center1, float radius1, void * center2, float radius2 -> _Bool) */
_Bool rl_CheckCollisionSpheres(void * center1, float radius1, void * center2, float radius2) {
  return CheckCollisionSpheres(*RL_V3(center1), radius1, *RL_V3(center2), radius2);
}
/** CheckCollisionBoxes(params: void * box1, void * box2 -> _Bool) */
_Bool rl_CheckCollisionBoxes(void * box1, void * box2) {
  return CheckCollisionBoxes(((rl_BoundingBox*)box1)->v, ((rl_BoundingBox*)box2)->v);
}
/** CheckCollisionBoxSphere(params: void * box, void * center, float radius -> _Bool) */
_Bool rl_CheckCollisionBoxSphere(void * box, void * center, float radius) {
  return CheckCollisionBoxSphere(((rl_BoundingBox*)box)->v, *RL_V3(center), radius);
}
/** GetRayCollisionSphere(params: void * ray, void * center, float radius, void * _out -> void) */
void rl_GetRayCollisionSphere(void * ray, void * center, float radius, void * _out) {
  ((rl_RayCollision*)_out)->v = GetRayCollisionSphere(((rl_Ray*)ray)->v, *RL_V3(center), radius);
}
/** GetRayCollisionBox(params: void * ray, void * box, void * _out -> void) */
void rl_GetRayCollisionBox(void * ray, void * box, void * _out) {
  ((rl_RayCollision*)_out)->v = GetRayCollisionBox(((rl_Ray*)ray)->v, ((rl_BoundingBox*)box)->v);
}
/** GetRayCollisionMesh(params: void * ray, void * mesh, void * transform, void * _out -> void) */
void rl_GetRayCollisionMesh(void * ray, void * mesh, void * transform, void * _out) {
  ((rl_RayCollision*)_out)->v = GetRayCollisionMesh(((rl_Ray*)ray)->v, *(Mesh *)mesh, ((rl_Matrix*)transform)->v);
}
/** GetRayCollisionTriangle(params: void * ray, void * p1, void * p2, void * p3, void * _out -> void) */
void rl_GetRayCollisionTriangle(void * ray, void * p1, void * p2, void * p3, void * _out) {
  ((rl_RayCollision*)_out)->v = GetRayCollisionTriangle(((rl_Ray*)ray)->v, *RL_V3(p1), *RL_V3(p2), *RL_V3(p3));
}
/** GetRayCollisionQuad(params: void * ray, void * p1, void * p2, void * p3, void * p4, void * _out -> void) */
void rl_GetRayCollisionQuad(void * ray, void * p1, void * p2, void * p3, void * p4, void * _out) {
  ((rl_RayCollision*)_out)->v = GetRayCollisionQuad(((rl_Ray*)ray)->v, *RL_V3(p1), *RL_V3(p2), *RL_V3(p3), *RL_V3(p4));
}
/** LoadWave(params: const char * fileName -> void *) */
void * rl_LoadWave(const char * fileName) {
  Wave *r = (Wave *)malloc(sizeof(Wave));
  *r = LoadWave(fileName);
  return r;
}
/** LoadWaveFromMemory(params: const char * fileType, void * fileData, int dataSize -> void *) */
void * rl_LoadWaveFromMemory(const char * fileType, void * fileData, int dataSize) {
  Wave *r = (Wave *)malloc(sizeof(Wave));
  *r = LoadWaveFromMemory(fileType, fileData, dataSize);
  return r;
}
/** IsWaveValid(params: void * wave -> _Bool) */
_Bool rl_IsWaveValid(void * wave) {
  return IsWaveValid(*(Wave *)wave);
}
/** LoadSound(params: const char * fileName -> void *) */
void * rl_LoadSound(const char * fileName) {
  Sound *r = (Sound *)malloc(sizeof(Sound));
  *r = LoadSound(fileName);
  return r;
}
/** LoadSoundFromWave(params: void * wave -> void *) */
void * rl_LoadSoundFromWave(void * wave) {
  Sound *r = (Sound *)malloc(sizeof(Sound));
  *r = LoadSoundFromWave(*(Wave *)wave);
  return r;
}
/** LoadSoundAlias(params: void * source -> void *) */
void * rl_LoadSoundAlias(void * source) {
  Sound *r = (Sound *)malloc(sizeof(Sound));
  *r = LoadSoundAlias(*(Sound *)source);
  return r;
}
/** IsSoundValid(params: void * sound -> _Bool) */
_Bool rl_IsSoundValid(void * sound) {
  return IsSoundValid(*(Sound *)sound);
}
/** UpdateSound(params: void * sound, void * data, int frameCount -> void) */
void rl_UpdateSound(void * sound, void * data, int frameCount) {
  UpdateSound(*(Sound *)sound, data, frameCount);
}
/** UnloadWave(params: void * wave -> void) */
void rl_UnloadWave(void * wave) {
  Wave *self = (Wave *)wave;
  UnloadWave(*self);
  free(self);
}
/** UnloadSound(params: void * sound -> void) */
void rl_UnloadSound(void * sound) {
  Sound *self = (Sound *)sound;
  UnloadSound(*self);
  free(self);
}
/** UnloadSoundAlias(params: void * alias -> void) */
void rl_UnloadSoundAlias(void * alias) {
  UnloadSoundAlias(*(Sound *)alias);
}
/** ExportWave(params: void * wave, const char * fileName -> _Bool) */
_Bool rl_ExportWave(void * wave, const char * fileName) {
  return ExportWave(*(Wave *)wave, fileName);
}
/** ExportWaveAsCode(params: void * wave, const char * fileName -> _Bool) */
_Bool rl_ExportWaveAsCode(void * wave, const char * fileName) {
  return ExportWaveAsCode(*(Wave *)wave, fileName);
}
/** PlaySound(params: void * sound -> void) */
void rl_PlaySound(void * sound) {
  PlaySound(*(Sound *)sound);
}
/** StopSound(params: void * sound -> void) */
void rl_StopSound(void * sound) {
  StopSound(*(Sound *)sound);
}
/** PauseSound(params: void * sound -> void) */
void rl_PauseSound(void * sound) {
  PauseSound(*(Sound *)sound);
}
/** ResumeSound(params: void * sound -> void) */
void rl_ResumeSound(void * sound) {
  ResumeSound(*(Sound *)sound);
}
/** IsSoundPlaying(params: void * sound -> _Bool) */
_Bool rl_IsSoundPlaying(void * sound) {
  return IsSoundPlaying(*(Sound *)sound);
}
/** SetSoundVolume(params: void * sound, float volume -> void) */
void rl_SetSoundVolume(void * sound, float volume) {
  SetSoundVolume(*(Sound *)sound, volume);
}
/** SetSoundPitch(params: void * sound, float pitch -> void) */
void rl_SetSoundPitch(void * sound, float pitch) {
  SetSoundPitch(*(Sound *)sound, pitch);
}
/** SetSoundPan(params: void * sound, float pan -> void) */
void rl_SetSoundPan(void * sound, float pan) {
  SetSoundPan(*(Sound *)sound, pan);
}
/** WaveCopy(params: void * wave -> void *) */
void * rl_WaveCopy(void * wave) {
  Wave *r = (Wave *)malloc(sizeof(Wave));
  *r = WaveCopy(*(Wave *)wave);
  return r;
}
/** LoadWaveSamples(params: void * wave -> void *) */
void * rl_LoadWaveSamples(void * wave) {
  return LoadWaveSamples(*(Wave *)wave);
}
/** LoadMusicStream(params: const char * fileName -> void *) */
void * rl_LoadMusicStream(const char * fileName) {
  Music *r = (Music *)malloc(sizeof(Music));
  *r = LoadMusicStream(fileName);
  return r;
}
/** LoadMusicStreamFromMemory(params: const char * fileType, void * data, int dataSize -> void *) */
void * rl_LoadMusicStreamFromMemory(const char * fileType, void * data, int dataSize) {
  Music *r = (Music *)malloc(sizeof(Music));
  *r = LoadMusicStreamFromMemory(fileType, data, dataSize);
  return r;
}
/** IsMusicValid(params: void * music -> _Bool) */
_Bool rl_IsMusicValid(void * music) {
  return IsMusicValid(*(Music *)music);
}
/** UnloadMusicStream(params: void * music -> void) */
void rl_UnloadMusicStream(void * music) {
  UnloadMusicStream(*(Music *)music);
}
/** PlayMusicStream(params: void * music -> void) */
void rl_PlayMusicStream(void * music) {
  PlayMusicStream(*(Music *)music);
}
/** IsMusicStreamPlaying(params: void * music -> _Bool) */
_Bool rl_IsMusicStreamPlaying(void * music) {
  return IsMusicStreamPlaying(*(Music *)music);
}
/** UpdateMusicStream(params: void * music -> void) */
void rl_UpdateMusicStream(void * music) {
  UpdateMusicStream(*(Music *)music);
}
/** StopMusicStream(params: void * music -> void) */
void rl_StopMusicStream(void * music) {
  StopMusicStream(*(Music *)music);
}
/** PauseMusicStream(params: void * music -> void) */
void rl_PauseMusicStream(void * music) {
  PauseMusicStream(*(Music *)music);
}
/** ResumeMusicStream(params: void * music -> void) */
void rl_ResumeMusicStream(void * music) {
  ResumeMusicStream(*(Music *)music);
}
/** SeekMusicStream(params: void * music, float position -> void) */
void rl_SeekMusicStream(void * music, float position) {
  SeekMusicStream(*(Music *)music, position);
}
/** SetMusicVolume(params: void * music, float volume -> void) */
void rl_SetMusicVolume(void * music, float volume) {
  SetMusicVolume(*(Music *)music, volume);
}
/** SetMusicPitch(params: void * music, float pitch -> void) */
void rl_SetMusicPitch(void * music, float pitch) {
  SetMusicPitch(*(Music *)music, pitch);
}
/** SetMusicPan(params: void * music, float pan -> void) */
void rl_SetMusicPan(void * music, float pan) {
  SetMusicPan(*(Music *)music, pan);
}
/** GetMusicTimeLength(params: void * music -> float) */
float rl_GetMusicTimeLength(void * music) {
  return GetMusicTimeLength(*(Music *)music);
}
/** GetMusicTimePlayed(params: void * music -> float) */
float rl_GetMusicTimePlayed(void * music) {
  return GetMusicTimePlayed(*(Music *)music);
}
/** LoadAudioStream(params: uint32_t sampleRate, uint32_t sampleSize, uint32_t channels -> void *) */
void * rl_LoadAudioStream(uint32_t sampleRate, uint32_t sampleSize, uint32_t channels) {
  AudioStream *r = (AudioStream *)malloc(sizeof(AudioStream));
  *r = LoadAudioStream(sampleRate, sampleSize, channels);
  return r;
}
/** IsAudioStreamValid(params: void * stream -> _Bool) */
_Bool rl_IsAudioStreamValid(void * stream) {
  return IsAudioStreamValid(*(AudioStream *)stream);
}
/** UnloadAudioStream(params: void * stream -> void) */
void rl_UnloadAudioStream(void * stream) {
  AudioStream *self = (AudioStream *)stream;
  UnloadAudioStream(*self);
  free(self);
}
/** UpdateAudioStream(params: void * stream, void * data, int frameCount -> void) */
void rl_UpdateAudioStream(void * stream, void * data, int frameCount) {
  UpdateAudioStream(*(AudioStream *)stream, data, frameCount);
}
/** IsAudioStreamProcessed(params: void * stream -> _Bool) */
_Bool rl_IsAudioStreamProcessed(void * stream) {
  return IsAudioStreamProcessed(*(AudioStream *)stream);
}
/** PlayAudioStream(params: void * stream -> void) */
void rl_PlayAudioStream(void * stream) {
  PlayAudioStream(*(AudioStream *)stream);
}
/** PauseAudioStream(params: void * stream -> void) */
void rl_PauseAudioStream(void * stream) {
  PauseAudioStream(*(AudioStream *)stream);
}
/** ResumeAudioStream(params: void * stream -> void) */
void rl_ResumeAudioStream(void * stream) {
  ResumeAudioStream(*(AudioStream *)stream);
}
/** IsAudioStreamPlaying(params: void * stream -> _Bool) */
_Bool rl_IsAudioStreamPlaying(void * stream) {
  return IsAudioStreamPlaying(*(AudioStream *)stream);
}
/** StopAudioStream(params: void * stream -> void) */
void rl_StopAudioStream(void * stream) {
  StopAudioStream(*(AudioStream *)stream);
}
/** SetAudioStreamVolume(params: void * stream, float volume -> void) */
void rl_SetAudioStreamVolume(void * stream, float volume) {
  SetAudioStreamVolume(*(AudioStream *)stream, volume);
}
/** SetAudioStreamPitch(params: void * stream, float pitch -> void) */
void rl_SetAudioStreamPitch(void * stream, float pitch) {
  SetAudioStreamPitch(*(AudioStream *)stream, pitch);
}
/** SetAudioStreamPan(params: void * stream, float pan -> void) */
void rl_SetAudioStreamPan(void * stream, float pan) {
  SetAudioStreamPan(*(AudioStream *)stream, pan);
}
/** SetAudioStreamCallback(params: void * stream, void * callback -> void) */
void rl_SetAudioStreamCallback(void * stream, void * callback) {
  SetAudioStreamCallback(*(AudioStream *)stream, (AudioCallback)callback);
}
/** AttachAudioStreamProcessor(params: void * stream, void * processor -> void) */
void rl_AttachAudioStreamProcessor(void * stream, void * processor) {
  AttachAudioStreamProcessor(*(AudioStream *)stream, (AudioCallback)processor);
}
/** DetachAudioStreamProcessor(params: void * stream, void * processor -> void) */
void rl_DetachAudioStreamProcessor(void * stream, void * processor) {
  DetachAudioStreamProcessor(*(AudioStream *)stream, (AudioCallback)processor);
}
/** AttachAudioMixedProcessor(params: void * processor -> void) */
void rl_AttachAudioMixedProcessor(void * processor) {
  AttachAudioMixedProcessor((AudioCallback)processor);
}
/** DetachAudioMixedProcessor(params: void * processor -> void) */
void rl_DetachAudioMixedProcessor(void * processor) {
  DetachAudioMixedProcessor((AudioCallback)processor);
}

/* ================================================================
 * Generated shims (tools/gen_raylib_ffi.py). Same conventions as the
 * hand-written shims above; keep in sync by re-running the generator.
 * ================================================================ */


/* ---- generated shims ---- */

/* ================================================================
 * raymath demo bindings (hand-written; declared in lib/raymath_ffi.rb).
 * Same Ruby surface as the gem's raymath.rb (Raylib.Vector2Add & co).
 * The core native structs (rl_Vector2) are defined above, so these can
 * live in the raylib adapter object — no separate libraymath exists.
 * Follows the generator conventions: by-value structs via pointers.
 * ================================================================ */
void rl_Vector2Add(rl_Vector2 *a, rl_Vector2 *b, rl_Vector2 *out) {
  out->v = Vector2Add((*RL_V2(a)), b->v);
}
void rl_Vector2Scale(rl_Vector2 *v, double scale, rl_Vector2 *out) {
  out->v = Vector2Scale((*RL_V2(v)), (float)scale);
}
void rl_Vector2Rotate(rl_Vector2 *v, double angle, rl_Vector2 *out) {
  out->v = Vector2Rotate((*RL_V2(v)), (float)angle);
}
void rl_Vector2Normalize(rl_Vector2 *v, rl_Vector2 *out) {
  out->v = Vector2Normalize((*RL_V2(v)));
}
/* Return type must match the raymath_ffi.rb ffi_func decls (:float): these
 * hand-written shims win the link over the generator's static duplicates in
 * raymath_adapter.c, so a double return here misreads xmm0 as float garbage. */
float rl_Vector2Length(rl_Vector2 *v) {
  return Vector2Length((*RL_V2(v)));
}
void rl_Vector2Lerp(rl_Vector2 *a, rl_Vector2 *b, double amount, rl_Vector2 *out) {
  out->v = Vector2Lerp((*RL_V2(a)), b->v, (float)amount);
}
float rl_Vector2Angle(rl_Vector2 *a, rl_Vector2 *b) {
  return Vector2Angle((*RL_V2(a)), b->v);
}

/* ---- positional construction fills (Raylib.Vector2/Vector4/Matrix) ----
 * Spinel inlines Klass.new(args) to the native ctor and its type analysis can
 * degrade the accessor writers (v.x = x) to generic ivar dispatch in programs
 * where other classes share x/y/m fields, so construction goes through these
 * explicit C helpers via ffi_func instead. */
/* NOTE: the ffi_func declarations type these as :float, so the generated
 * externs pass C float — the definitions must be float too (a double callee
 * reading a float arg sees zeroed upper bits and loses the value). */
void rl_Vector2Fill(rl_Vector2 *o, float x, float y) {
  (*RL_V2(o)) = (Vector2){ x, y };
}
void rl_Vector4Fill(rl_Vector4 *o, float x, float y, float z, float w) {
  (*RL_V4(o)) = (Vector4){ x, y, z, w };
}
void rl_MatrixFill(rl_Matrix *o, float m0, float m4, float m8, float m12,
                   float m1, float m5, float m9, float m13,
                   float m2, float m6, float m10, float m14,
                   float m3, float m7, float m11, float m15) {
  o->v = (Matrix){ m0, m4, m8, m12,
                   m1, m5, m9, m13,
                   m2, m6, m10, m14,
                   m3, m7, m11, m15 };
}

/* ================================================================
 * Hand-written extras (project additions)
 *
 * Opaque resource field accessors and small out-parameter helpers
 * used by the model/font/animation example scenes.
 * ================================================================ */

/* Font.texture -> Texture2D* (embedded in the Font struct). */
void *rl_FontTexture_ptr(void *font) {
  return &(RL_FONT(font))->texture;
}

/* Model.materials[index] -> Material* (embedded in the Model struct). */
void *rl_Model_material(void *model, int index) {
  Model *m = (Model *)model;
  if (index < 0 || index >= m->materialCount) return NULL;
  return &m->materials[index];
}

/* int out-parameter helpers (e.g. LoadImageAnim frame count). */
int *rl_IntAlloc(void) {
  int *p = (int *)malloc(sizeof(int));
  *p = 0;
  return p;
}
int rl_IntGet(int *p) { return *p; }
void rl_IntFree(int *p) { free(p); }

/* Image field accessors (Image is an opaque heap pointer). */
int rl_ImageWidth(void *image) { return (RL_IMG(image))->width; }
int rl_ImageHeight(void *image) { return (RL_IMG(image))->height; }
/* Pointer to the start of a single animation frame's pixel data. */
void *rl_ImageFrameData(void *image, int frameIndex) {
  Image *img = RL_IMG(image);
  int frameBytes = img->width * img->height * 4;
  return (unsigned char *)img->data + frameBytes * frameIndex;
}

/* ---- Model / animation / picking / camera extras ---- */

/* Model.transform accessors (Matrix is a native rl_Matrix). */
void rl_Model_transform(void *model, void *out) {
  ((rl_Matrix *)out)->v = ((Model *)model)->transform;
}
void rl_Model_set_transform(void *model, void *matrix) {
  ((Model *)model)->transform = ((rl_Matrix *)matrix)->v;
}

/* Model.meshes[index] -> Mesh* (embedded in the Model struct). */
void *rl_Model_mesh(void *model, int index) {
  Model *m = (Model *)model;
  if (index < 0 || index >= m->meshCount) return NULL;
  return &m->meshes[index];
}
int rl_Model_meshCount(void *model) { return ((Model *)model)->meshCount; }

/* ModelAnimation array element and frame count. */
void *rl_ModelAnimationAt(void *anims, int index) {
  return &((ModelAnimation *)anims)[index];
}
int rl_ModelAnimation_frameCount(void *anim) {
  return ((ModelAnimation *)anim)->keyframeCount;
}

/* RayCollision point/normal -> native Vector3 out-param. */
void rl_RayCollision_point(void *self, void *out) {
  *RL_V3(out) = ((rl_RayCollision *)self)->v.point;
}
void rl_RayCollision_normal(void *self, void *out) {
  *RL_V3(out) = ((rl_RayCollision *)self)->v.normal;
}

/* Camera3D position component reads (native Camera has no field accessors). */
void rl_Camera_position_from_bounds(void *self, void *box, float pad) {
  BoundingBox *b = (BoundingBox *)box;
  ((rl_Camera *)self)->c.position = (Vector3){ b->max.x + pad, b->max.y + pad,
                                              b->max.z + pad };
}
float rl_Camera_position_x(void *self) { return ((rl_Camera *)self)->c.position.x; }
float rl_Camera_position_y(void *self) { return ((rl_Camera *)self)->c.position.y; }
float rl_Camera_position_z(void *self) { return ((rl_Camera *)self)->c.position.z; }

/* LoadImageColors array element R channel. */
int rl_ImageColorR(void *colors, int index) {
  return ((Color *)colors)[index].r;
}

/* raymath MatrixRotateXYZ on the raylib adapter object (raymath adapter is not
 * linked into scenes). */
void rl_MatrixRotateXYZ(void *angle, void *out) {
  ((rl_Matrix *)out)->v = MatrixRotateXYZ(*RL_V3(angle));
}

/* Circle/rect collision from raw floats (avoids native Rectangle field writes
 * in the all-in-one TU). center is a native rl_Vector2. */
_Bool rl_CheckCollisionCircleRecF(void *center, float radius,
                                  float x, float y, float w, float h) {
  Rectangle rec = { x, y, w, h };
  return CheckCollisionCircleRec(*RL_V2(center), radius, rec);
}

/* ---- Shader value helpers (SetShaderValue takes a void* value) ---- */

/* Fragment-only shader (NULL vertex shader -> raylib default). */
void *rl_LoadShaderFS(const char *fsFileName) {
  Shader *s = (Shader *)malloc(sizeof(Shader));
  *s = LoadShader(NULL, fsFileName);
  return s;
}
void rl_SetShaderValueFloat(void *shader, int locIndex, float v, int type) {
  SetShaderValue(*(Shader *)shader, locIndex, &v, type);
}
void rl_SetShaderValueVec2(void *shader, int locIndex, float x, float y,
                           int type) {
  float v[2] = { x, y };
  SetShaderValue(*(Shader *)shader, locIndex, v, type);
}
void rl_SetShaderValueVec3(void *shader, int locIndex, float x, float y,
                           float z, int type) {
  float v[3] = { x, y, z };
  SetShaderValue(*(Shader *)shader, locIndex, v, type);
}

/* ---- Model skeleton / animation pose accessors ---- */
int rl_Model_boneCount(void *model) {
  return (int)((Model *)model)->skeleton.boneCount;
}
int rl_Model_boneParent(void *model, int index) {
  return ((Model *)model)->skeleton.bones[index].parent;
}
void rl_Model_bindPoseTranslation(void *model, int index, void *out) {
  *RL_V3(out) =
    ((Model *)model)->skeleton.bindPose[index].translation;
}
void rl_ModelAnimation_framePoseTranslation(void *anim, int frame, int bone,
                                            void *out) {
  *RL_V3(out) =
    ((ModelAnimation *)anim)->keyframePoses[frame][bone].translation;
}

/* Camera3D target component reads (for shader uniforms). */
float rl_Camera_target_x(void *self) { return ((rl_Camera *)self)->c.target.x; }
float rl_Camera_target_y(void *self) { return ((rl_Camera *)self)->c.target.y; }
float rl_Camera_target_z(void *self) { return ((rl_Camera *)self)->c.target.z; }

/* ---- Shader location slot / material shader assignment ---- */
void rl_Shader_setLoc(void *shader, int index, int value) {
  ((Shader *)shader)->locs[index] = value;
}
void rl_Material_set_shader(void *material, void *shader) {
  ((Material *)material)->shader = *(Shader *)shader;
}
void rl_SetShaderValueInt(void *shader, int locIndex, int v, int type) {
  SetShaderValue(*(Shader *)shader, locIndex, &v, type);
}
void rl_SetShaderValueVec4(void *shader, int locIndex, float x, float y,
                           float z, float w, int type) {
  float v[4] = { x, y, z, w };
  SetShaderValue(*(Shader *)shader, locIndex, v, type);
}
void rl_SetShaderValueColor(void *shader, int locIndex, void *color, int type) {
  rl_Color *c = (rl_Color *)color;
  float v[4] = { c->c.r / 255.0f, c->c.g / 255.0f, c->c.b / 255.0f,
                 c->c.a / 255.0f };
  SetShaderValue(*(Shader *)shader, locIndex, v, type);
}

/* ---- Font glyph internals + float-arg rectangle helpers ---- */
int rl_FontGlyphAdvanceX(void *font, int index) {
  return (RL_FONT(font))->glyphs[index].advanceX;
}
float rl_FontGlyphRecWidth(void *font, int index) {
  return (RL_FONT(font))->recs[index].width;
}
void rl_DrawRectangleLinesExF(float x, float y, float w, float h, float thick,
                              void *color) {
  DrawRectangleLinesEx((Rectangle){ x, y, w, h }, thick, ((rl_Color *)color)->c);
}
_Bool rl_CheckCollisionPointRecF(void *point, float x, float y, float w,
                                 float h) {
  return CheckCollisionPointRec(*RL_V2(point),
                                (Rectangle){ x, y, w, h });
}

/* Build a Font from a TTF file's data via LoadFontData + GenImageFontAtlas
 * (used by the SDF font example). loadGlyphCount 0 lets raylib use defaults. */
void *rl_LoadFontAtlas_ptr(const char *path, int fontSize, int loadGlyphCount,
                       int atlasGlyphCount, int padding, int packMethod,
                       int fontType) {
  int dataSize = 0;
  unsigned char *data = LoadFileData(path, &dataSize);
  int loadedCount = 0;
  GlyphInfo *glyphs = LoadFontData(data, dataSize, fontSize, NULL,
                                   loadGlyphCount, fontType, &loadedCount);
  Rectangle *recs = NULL;
  Image atlas = GenImageFontAtlas(glyphs, &recs, atlasGlyphCount, fontSize,
                                  padding, packMethod);
  Font *font = (Font *)malloc(sizeof(Font));
  font->baseSize = fontSize;
  font->glyphCount = atlasGlyphCount;
  font->glyphPadding = padding;
  font->texture = LoadTextureFromImage(atlas);
  font->recs = recs;
  font->glyphs = glyphs;
  UnloadImage(atlas);
  UnloadFileData(data);
  return font;
}

/* ---- Color component reads (for rlColor4ub etc.) ---- */
int rl_Color_r(rl_Color *self) { return self->c.r; }
int rl_Color_g(rl_Color *self) { return self->c.g; }
int rl_Color_b(rl_Color *self) { return self->c.b; }
int rl_Color_a(rl_Color *self) { return self->c.a; }

/* No-arg Vector3 allocator for out-param results (raymath wrappers). */
rl_Vector3 *rl_Vector3_new0(sp_int cls_id) {
  rl_Vector3 *self = (rl_Vector3 *)sp_gc_alloc(sizeof(rl_Vector3), NULL, rl_Vector3_scan);
  self->cls_id = cls_id;
  self->p = NULL;
  self->v = (Vector3){ 0 };
  return self;
}


/* Pure float/int shims added to bypass Spinel single-TU Rectangle struct-id collision */
void *rl_ImageFromImageF_ptr(void *image, float x, float y, float w, float h) {
  Image *img = RL_IMG(image);
  Image *result = (Image *)malloc(sizeof(Image));
  *result = ImageFromImage(*img, (Rectangle){ x, y, w, h });
  return result;
}

void rl_DrawRectangleProF(float x, float y, float w, float h,
                          float ox, float oy, float rotation, void *color) {
  DrawRectanglePro((Rectangle){ x, y, w, h },
                   (Vector2){ ox, oy },
                   rotation,
                   ((rl_Color *)color)->c);
}

void rl_DrawRectangleRoundedF(float x, float y, float w, float h,
                              float roundness, int segments, void *color) {
  DrawRectangleRounded((Rectangle){ x, y, w, h },
                       roundness, segments,
                       ((rl_Color *)color)->c);
}

void rl_DrawRectangleRoundedLinesExF(float x, float y, float w, float h,
                                    float roundness, int segments, float thick, void *color) {
  DrawRectangleRoundedLinesEx((Rectangle){ x, y, w, h },
                              roundness, segments, thick,
                              ((rl_Color *)color)->c);
}

void rl_DrawTextureRecF(void *texture, float sx, float sy, float sw, float sh,
                        float px, float py, void *tint) {
  DrawTextureRec(*RL_TEX(texture),
                 (Rectangle){ sx, sy, sw, sh },
                 (Vector2){ px, py },
                 ((rl_Color *)tint)->c);
}

/* DrawTexturePro with raw float src/dest/origin (avoids native Rectangle/
 * Vector2 field writes in the all-in-one TU). */
void rl_DrawTextureProF(void *texture, float sx, float sy, float sw, float sh,
                        float dx, float dy, float dw, float dh,
                        float ox, float oy, float rotation, void *tint) {
  DrawTexturePro(*RL_TEX(texture),
                 (Rectangle){ sx, sy, sw, sh },
                 (Rectangle){ dx, dy, dw, dh },
                 (Vector2){ ox, oy }, rotation, ((rl_Color *)tint)->c);
}

/* ================================================================
 * Shims added for the second Tier-1 example batch.
 *
 * - DirList accessors: LoadDirectoryFiles hands back an opaque
 *   FilePathList, and Spinel cannot read a C struct field, so the
 *   count / name accessors are re-exported over the handle.
 * - AudioStreamSine: UpdateAudioStream takes a float* buffer, so the
 *   440 Hz test tone is generated on the C side from the gain the
 *   Ruby side (the ADSR envelope) asks for.
 * ================================================================ */

int rl_DirListCount(void *list) {
  if (!list) return 0;
  return ((rl_FilePathList *)list)->v.count;
}
const char *rl_DirListName(void *list, int index) {
  if (!list) return "";
  rl_FilePathList *fl = (rl_FilePathList *)list;
  if (index < 0 || index >= fl->v.count) return "";
  return fl->v.paths[index];
}

static double sp_sine_time = 0.0;

void rl_AudioStreamSineReset(void) { sp_sine_time = 0.0; }
void rl_UpdateAudioStreamSine(void *stream, int frames, float gain,
                              float frequency, int sampleRate) {
  static float buffer[4096];
  if (frames > 4096) frames = 4096;
  if (frames < 0) frames = 0;
  for (int i = 0; i < frames; i++) {
    buffer[i] = gain * (float)sinf(2.0f * (float)PI * frequency * sp_sine_time);
    sp_sine_time += 1.0 / (double)sampleRate;
  }
  if (frames > 0) UpdateAudioStream(*(AudioStream *)stream, buffer, frames);
}

/* ================================================================
 * Shims added for the Raylib-Examples port batch.
 *
 * Both exist for the same reason as every other `*F` shim here:
 * Spinel's single-TU codegen assigns a local `cls_id` to a native
 * struct literal, so a Ruby-side `Raylib::BoundingBox` /
 * `Raylib::Vector3` compound literal can reach C with a mismatched id
 * (the historical `rl_BoundingBox_with_min` "expected double but
 * argument is of type sp_RbVal" failure). Passing raw floats and
 * assembling the struct here keeps the Ruby side scalar-only.
 * ================================================================ */

/* CheckCollisionBoxes from 12 raw floats.
 *
 * BoundingBox is { Vector3 min, max }, so the caller supplies
 * (minX,minY,minZ,maxX,maxY,maxZ) twice. Unused dims may be 0; the
 * test is a strict per-axis interval overlap. */
_Bool rl_CheckCollisionBoxesF(float min1_x, float min1_y, float min1_z,
                              float max1_x, float max1_y, float max1_z,
                              float min2_x, float min2_y, float min2_z,
                              float max2_x, float max2_y, float max2_z) {
  BoundingBox b1;
  BoundingBox b2;
  b1.min = (Vector3){ min1_x, min1_y, min1_z };
  b1.max = (Vector3){ max1_x, max1_y, max1_z };
  b2.min = (Vector3){ min2_x, min2_y, min2_z };
  b2.max = (Vector3){ max2_x, max2_y, max2_z };
  return CheckCollisionBoxes(b1, b2);
}

/* Assign a texture to a material's MAP_DIFFUSE slot.
 *
 * Material.maps[] is embedded in the Material struct, so Ruby cannot
 * reach `maps[MAP_DIFFUSE].texture` without a shim. Returns 1 on
 * success, 0 if either handle is NULL -- callers that ignore the
 * result would otherwise draw an untextured model with no signal. */
int rl_Material_set_diffuse(void *material, void *texture) {
  if (!material || !texture) return 0;
  /* MATERIAL_MAP_DIFFUSE is a #define alias of MATERIAL_MAP_ALBEDO in raylib
   * 5.5+, so this spelling works across both. Going through the public
   * SetMaterialTexture also keeps the material's maps[] consistent instead of
   * writing the slot behind raylib's back. */
  SetMaterialTexture((Material *)material, MATERIAL_MAP_DIFFUSE,
                     *RL_TEX(texture));
  return 1;
}

/* rl_Material_set_diffuse over a model's materialIndex, for the
 * "GenImageChecked -> LoadTextureFromImage -> poke the model's
 * material" pattern that the raylib 3D cube demos use. */
int rl_ModelSetDiffuseTexture(void *model, int materialIndex,
                              void *texture) {
  Model *m = (Model *)model;
  if (!m || materialIndex < 0 || materialIndex >= m->materialCount) return 0;
  return rl_Material_set_diffuse(&m->materials[materialIndex], texture);
}

/* ==== handle-class views: implementation (gen_handle_class_c.py) ==== */
/* Handles are normally views: the producers return a raw pointer to
 * a heap copy (or an interior pointer), and the Ruby layer wraps it
 * with <Class>.new(ptr, owner). The owned ctor exists for symmetry. */
static void *rl_h_unbox(sp_RbVal v) {
  if (v.tag == SP_TAG_INT) return (void *)(intptr_t)v.v.i;
  if (v.tag == SP_TAG_OBJ) return v.v.p;
  return NULL;
}

static void rl_Image_scan(void *p) {
  rl_Image *s = (rl_Image *)p;
  if (s->p) sp_mark_rbval(s->owner);
}
rl_Image *rl_Image_new(sp_int cls_id) {
  rl_Image *s = (rl_Image *)sp_gc_alloc(sizeof(rl_Image), NULL, rl_Image_scan);
  memset(s, 0, sizeof *s);
  s->cls_id = cls_id;
  return s;
}
rl_Image *rl_Image_view(sp_int cls_id, sp_RbVal pv, sp_RbVal owner) {
  rl_Image *s = (rl_Image *)sp_gc_alloc(sizeof(rl_Image), NULL, rl_Image_scan);
  s->cls_id = cls_id;
  s->p = (Image *)rl_h_unbox(pv);
  s->owner = owner;
  return s;
}
sp_int rl_m_Image_width(rl_Image *self) { return (sp_int)RL_IMG(self)->width; }
sp_int rl_m_Image_height(rl_Image *self) { return (sp_int)RL_IMG(self)->height; }
sp_int rl_m_Image_mipmaps(rl_Image *self) { return (sp_int)RL_IMG(self)->mipmaps; }
sp_int rl_m_Image_format(rl_Image *self) { return (sp_int)RL_IMG(self)->format; }
rl_Image *rl_Image_view_addr(sp_int cls_id, sp_RbVal addr) {
  rl_Image *s = (rl_Image *)sp_gc_alloc(sizeof(rl_Image), NULL, rl_Image_scan);
  s->cls_id = cls_id;
  s->p = (Image *)rl_h_unbox(addr);
  s->owner = sp_box_nil();
  return s;
}

static void rl_Texture2D_scan(void *p) {
  rl_Texture2D *s = (rl_Texture2D *)p;
  if (s->p) sp_mark_rbval(s->owner);
}
rl_Texture2D *rl_Texture2D_new(sp_int cls_id) {
  rl_Texture2D *s = (rl_Texture2D *)sp_gc_alloc(sizeof(rl_Texture2D), NULL, rl_Texture2D_scan);
  memset(s, 0, sizeof *s);
  s->cls_id = cls_id;
  return s;
}
rl_Texture2D *rl_Texture2D_view(sp_int cls_id, sp_RbVal pv, sp_RbVal owner) {
  rl_Texture2D *s = (rl_Texture2D *)sp_gc_alloc(sizeof(rl_Texture2D), NULL, rl_Texture2D_scan);
  s->cls_id = cls_id;
  s->p = (Texture2D *)rl_h_unbox(pv);
  s->owner = owner;
  return s;
}
sp_int rl_m_Texture2D_id(rl_Texture2D *self) { return (sp_int)RL_TEX(self)->id; }
sp_int rl_m_Texture2D_width(rl_Texture2D *self) { return (sp_int)RL_TEX(self)->width; }
sp_int rl_m_Texture2D_height(rl_Texture2D *self) { return (sp_int)RL_TEX(self)->height; }
sp_int rl_m_Texture2D_mipmaps(rl_Texture2D *self) { return (sp_int)RL_TEX(self)->mipmaps; }
sp_int rl_m_Texture2D_format(rl_Texture2D *self) { return (sp_int)RL_TEX(self)->format; }
rl_Texture2D *rl_Texture2D_view_addr(sp_int cls_id, sp_RbVal addr) {
  rl_Texture2D *s = (rl_Texture2D *)sp_gc_alloc(sizeof(rl_Texture2D), NULL, rl_Texture2D_scan);
  s->cls_id = cls_id;
  s->p = (Texture2D *)rl_h_unbox(addr);
  s->owner = sp_box_nil();
  return s;
}

static void rl_Font_scan(void *p) {
  rl_Font *s = (rl_Font *)p;
  if (s->p) sp_mark_rbval(s->owner);
}
rl_Font *rl_Font_new(sp_int cls_id) {
  rl_Font *s = (rl_Font *)sp_gc_alloc(sizeof(rl_Font), NULL, rl_Font_scan);
  memset(s, 0, sizeof *s);
  s->cls_id = cls_id;
  return s;
}
rl_Font *rl_Font_view(sp_int cls_id, sp_RbVal pv, sp_RbVal owner) {
  rl_Font *s = (rl_Font *)sp_gc_alloc(sizeof(rl_Font), NULL, rl_Font_scan);
  s->cls_id = cls_id;
  s->p = (Font *)rl_h_unbox(pv);
  s->owner = owner;
  return s;
}
sp_int rl_m_Font_baseSize(rl_Font *self) { return (sp_int)RL_FONT(self)->baseSize; }
sp_int rl_m_Font_glyphCount(rl_Font *self) { return (sp_int)RL_FONT(self)->glyphCount; }
sp_int rl_m_Font_glyphPadding(rl_Font *self) { return (sp_int)RL_FONT(self)->glyphPadding; }
rl_Font *rl_Font_view_addr(sp_int cls_id, sp_RbVal addr) {
  rl_Font *s = (rl_Font *)sp_gc_alloc(sizeof(rl_Font), NULL, rl_Font_scan);
  s->cls_id = cls_id;
  s->p = (Font *)rl_h_unbox(addr);
  s->owner = sp_box_nil();
  return s;
}

static void rl_GlyphInfo_scan(void *p) {
  rl_GlyphInfo *s = (rl_GlyphInfo *)p;
  if (s->p) sp_mark_rbval(s->owner);
}
rl_GlyphInfo *rl_GlyphInfo_new(sp_int cls_id) {
  rl_GlyphInfo *s = (rl_GlyphInfo *)sp_gc_alloc(sizeof(rl_GlyphInfo), NULL, rl_GlyphInfo_scan);
  memset(s, 0, sizeof *s);
  s->cls_id = cls_id;
  return s;
}
rl_GlyphInfo *rl_GlyphInfo_view(sp_int cls_id, sp_RbVal pv, sp_RbVal owner) {
  rl_GlyphInfo *s = (rl_GlyphInfo *)sp_gc_alloc(sizeof(rl_GlyphInfo), NULL, rl_GlyphInfo_scan);
  s->cls_id = cls_id;
  s->p = (GlyphInfo *)rl_h_unbox(pv);
  s->owner = owner;
  return s;
}
sp_int rl_m_GlyphInfo_value(rl_GlyphInfo *self) { return (sp_int)RL_GLYPH(self)->value; }
sp_int rl_m_GlyphInfo_offsetX(rl_GlyphInfo *self) { return (sp_int)RL_GLYPH(self)->offsetX; }
sp_int rl_m_GlyphInfo_offsetY(rl_GlyphInfo *self) { return (sp_int)RL_GLYPH(self)->offsetY; }
sp_int rl_m_GlyphInfo_advanceX(rl_GlyphInfo *self) { return (sp_int)RL_GLYPH(self)->advanceX; }
rl_GlyphInfo *rl_GlyphInfo_view_addr(sp_int cls_id, sp_RbVal addr) {
  rl_GlyphInfo *s = (rl_GlyphInfo *)sp_gc_alloc(sizeof(rl_GlyphInfo), NULL, rl_GlyphInfo_scan);
  s->cls_id = cls_id;
  s->p = (GlyphInfo *)rl_h_unbox(addr);
  s->owner = sp_box_nil();
  return s;
}

static void rl_RenderTexture_scan(void *p) {
  rl_RenderTexture *s = (rl_RenderTexture *)p;
  if (s->p) sp_mark_rbval(s->owner);
}
rl_RenderTexture *rl_RenderTexture_new(sp_int cls_id) {
  rl_RenderTexture *s = (rl_RenderTexture *)sp_gc_alloc(sizeof(rl_RenderTexture), NULL, rl_RenderTexture_scan);
  memset(s, 0, sizeof *s);
  s->cls_id = cls_id;
  return s;
}
rl_RenderTexture *rl_RenderTexture_view(sp_int cls_id, sp_RbVal pv, sp_RbVal owner) {
  rl_RenderTexture *s = (rl_RenderTexture *)sp_gc_alloc(sizeof(rl_RenderTexture), NULL, rl_RenderTexture_scan);
  s->cls_id = cls_id;
  s->p = (RenderTexture *)rl_h_unbox(pv);
  s->owner = owner;
  return s;
}
rl_RenderTexture *rl_RenderTexture_view_addr(sp_int cls_id, sp_RbVal addr) {
  rl_RenderTexture *s = (rl_RenderTexture *)sp_gc_alloc(sizeof(rl_RenderTexture), NULL, rl_RenderTexture_scan);
  s->cls_id = cls_id;
  s->p = (RenderTexture *)rl_h_unbox(addr);
  s->owner = sp_box_nil();
  return s;
}

/* Rectangle view from an address Integer (the gem idiom
 * `Rectangle.new(font.recs + i * Rectangle.size)`; the argument is a
 * boxed Integer because Spinel boxes poly arithmetic). */
Rectangle *rl_Rectangle_view_addr(sp_int cls_id, sp_RbVal addr) {
  Rectangle *payload = (Rectangle *)(intptr_t)(addr.tag == SP_TAG_INT ? addr.v.i : 0);
  rl_Rectangle *s = (rl_Rectangle *)sp_gc_alloc(sizeof(rl_Rectangle), NULL, rl_Rectangle_scan);
  s->cls_id = cls_id;
  s->p = payload;
  s->owner = sp_box_nil();
  return s;
}
/* ==== end handle-class views implementation ==== */

/* ==== handle helpers (gen_handle_class_c.py companions) ==== */
void *rl_Font_texture_ptr(void *font) { return (void *)&RL_FONT(font)->texture; }
long rl_Font_recs_addr(void *font) { return (long)(intptr_t)RL_FONT(font)->recs; }
long rl_Font_glyphs_addr(void *font) { return (long)(intptr_t)RL_FONT(font)->glyphs; }
void *rl_GlyphInfo_image_ptr(void *g) { return (void *)&RL_GLYPH(g)->image; }
long rl_ptr_addr(void *p) { return (long)(intptr_t)p; }
