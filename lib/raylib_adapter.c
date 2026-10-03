#include <raylib.h>
#include <raymath.h>        /* raymath funcs (RL_* guards swallow duplicated types) */
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

/* sp_Vector2 — GC-embedded Vector2 (see raylib_ffi.rb). Declared early so the
 * generated shims below (and the raw Vector2 helpers) read the embedded `v`
 * instead of mistaking the cls_id header for the coordinates. */
typedef struct sp_Vector2_s {
  sp_int cls_id;
  Vector2 v;
} sp_Vector2;

/* Vector2 helper — heap allocates a native-shaped sp_Vector2 and returns a
 * pointer (matches the ffi_func Vector2Create(:ptr) declaration). Freed is
 * unnecessary: these are small fixed-size vectors. The struct carries the same
 * header + embedded Vector2 layout the shims now read via ->v. */
void *Vector2Create(float x, float y) {
  sp_Vector2 *v = (sp_Vector2 *)malloc(sizeof(sp_Vector2));
  v->cls_id = 0;
  v->v = (Vector2){ x, y };
  return v;
}
float Vector2GetX(void *v) { return ((sp_Vector2 *)v)->v.x; }
float Vector2GetY(void *v) { return ((sp_Vector2 *)v)->v.y; }
void Vector2SetX(void *v, float x) { ((sp_Vector2 *)v)->v.x = x; }
void Vector2SetY(void *v, float y) { ((sp_Vector2 *)v)->v.y = y; }

/* sp_Camera — GC-embedded Camera3D (see raylib_ffi.rb). Declared early so
 * sp_Camera3DCreate returns the same header+embedded layout the
 * sp_BeginMode3D / sp_UpdateCamera / sp_GetWorldToScreen shims read via ->c. */
typedef struct sp_Camera_s {
  sp_int cls_id;
  Camera3D c;
} sp_Camera;

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
float sp_FontBaseSize(void *font) { return (float)((Font *)font)->baseSize; }
int sp_TextureWidth(void *texture) { return (int)((Texture *)texture)->width; }
int sp_TextureHeight(void *texture) { return (int)((Texture *)texture)->height; }
void sp_DrawTextureRec4(void *texture, float x, float y, float w, float h,
                        void *position, void *tint) {
  Rectangle src = { x, y, w, h };
  DrawTextureRec(*(Texture2D *)texture, src, ((sp_Vector2 *)position)->v,
                 ((sp_Color *)tint)->c);
}
void sp_BeginMode2DF(float target_x, float target_y, float offset_x,
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
void sp_DrawRectangleRecF(float x, float y, float w, float h, void *color) {
  DrawRectangleRec((Rectangle){ x, y, w, h }, ((sp_Color *)color)->c);
}
void *sp_Camera3DCreate(float px, float py, float pz, float tx, float ty,
                        float tz, float ux, float uy, float uz, float fovy,
                        int projection) {
  /* Native-shaped so the sp_BeginMode3D / sp_UpdateCamera / GetWorldToScreen
   * shims (which read ((sp_Camera*)p)->c) see the camera, not the cls_id. */
  sp_Camera *cam = (sp_Camera *)malloc(sizeof(sp_Camera));
  cam->cls_id = 0;
  cam->c.position = (Vector3){ px, py, pz };
  cam->c.target = (Vector3){ tx, ty, tz };
  cam->c.up = (Vector3){ ux, uy, uz };
  cam->c.fovy = fovy;
  cam->c.projection = projection;
  return cam;
}
void sp_EndMode3D(void) { EndMode3D(); }
void sp_DrawGrid(int slices, float spacing) { DrawGrid(slices, spacing); }
void sp_DrawRenderTexture(void *target, void *tint) {
  RenderTexture2D *rt = (RenderTexture2D *)target;
  Rectangle src = { 0, 0, (float)rt->texture.width, (float)-rt->texture.height };
  DrawTextureRec(rt->texture, src, (Vector2){ 0, 0 }, ((sp_Color *)tint)->c);
}
void sp_DrawRenderTextureAt(void *target, int x, int y, void *tint) {
  RenderTexture2D *rt = (RenderTexture2D *)target;
  Rectangle src = { 0, 0, (float)rt->texture.width, (float)-rt->texture.height };
  DrawTextureRec(rt->texture, src, (Vector2){ (float)x, (float)y }, ((sp_Color *)tint)->c);
}
void sp_DrawRenderTexturePro(void *target, float rotation, void *tint) {
  RenderTexture2D *rt = (RenderTexture2D *)target;
  DrawTexturePro(rt->texture,
                 (Rectangle){ 0, 0, (float)rt->texture.width, (float)-rt->texture.height },
                 (Rectangle){ GetScreenWidth()/2.0f, GetScreenHeight()/2.0f,
                              (float)rt->texture.width, (float)rt->texture.height },
                 (Vector2){ rt->texture.width/2.0f, rt->texture.height/2.0f },
                 rotation, ((sp_Color *)tint)->c);
}
void *sp_RenderTexture_texture(void *target) {
  return &((RenderTexture2D *)target)->texture;
}
void *sp_LoadImageFromRenderTexture(void *target) {
  RenderTexture2D *rt = (RenderTexture2D *)target;
  Image *r = (Image *)malloc(sizeof(Image));
  *r = LoadImageFromTexture(rt->texture);
  return r;
}
void sp_DrawTexture(void *tex, int x, int y, void *color) {
  DrawTexture(*(Texture2D *)tex, x, y, ((sp_Color *)color)->c);
}
/* Data-oriented draw: the tint is a packed 0xRRGGBBAA integer, so callers
 * that keep colors in a flat int array need no sp_Color object per sprite. */
void sp_DrawTexturePacked(void *tex, int x, int y, int rgba) {
  unsigned int u = (unsigned int)rgba;
  DrawTexture(*(Texture2D *)tex, x, y,
              (Color){ (unsigned char)(u >> 24), (unsigned char)(u >> 16),
                       (unsigned char)(u >> 8), (unsigned char)u });
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
  DrawCircleV(((sp_Vector2 *)center)->v, radius, ((sp_Color *)color)->c);
}
void sp_DrawPixel(int x, int y, void *color) {
  DrawPixel(x, y, ((sp_Color *)color)->c);
}
void sp_DrawTriangle(void *v1, void *v2, void *v3, void *color) {
  DrawTriangle(((sp_Vector2 *)v1)->v, ((sp_Vector2 *)v2)->v, ((sp_Vector2 *)v3)->v,
               ((sp_Color *)color)->c);
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
 * (struct declared near the top, shared with sp_Camera3DCreate.)
 * ================================================================ */
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
  DrawPlane(((sp_Vector3 *)pos)->v, ((sp_Vector2 *)size)->v, ((sp_Color *)color)->c);
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

/* ================================================================
 * Generated shims (tools/gen_raylib_ffi.py). Same conventions as the
 * hand-written shims above; keep in sync by re-running the generator.
 * ================================================================ */


/* sp_Vector4 — GC-embedded Vector4 (see raylib_ffi.rb) */typedef struct sp_Vector4_s {
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
double sp_Vector4_x(sp_Vector4 *self) {
  return (double)self->v.x;
}
double sp_Vector4_set_x(sp_Vector4 *self, double x) {
  self->v.x = (float)x;
  return x;
}
double sp_Vector4_y(sp_Vector4 *self) {
  return (double)self->v.y;
}
double sp_Vector4_set_y(sp_Vector4 *self, double y) {
  self->v.y = (float)y;
  return y;
}
double sp_Vector4_z(sp_Vector4 *self) {
  return (double)self->v.z;
}
double sp_Vector4_set_z(sp_Vector4 *self, double z) {
  self->v.z = (float)z;
  return z;
}
double sp_Vector4_w(sp_Vector4 *self) {
  return (double)self->v.w;
}
double sp_Vector4_set_w(sp_Vector4 *self, double w) {
  self->v.w = (float)w;
  return w;
}

/* sp_Rectangle — GC-embedded Rectangle (see raylib_ffi.rb) */typedef struct sp_Rectangle_s {
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
double sp_Rectangle_x(sp_Rectangle *self) {
  return (double)self->v.x;
}
double sp_Rectangle_set_x(sp_Rectangle *self, double x) {
  self->v.x = (float)x;
  return x;
}
double sp_Rectangle_y(sp_Rectangle *self) {
  return (double)self->v.y;
}
double sp_Rectangle_set_y(sp_Rectangle *self, double y) {
  self->v.y = (float)y;
  return y;
}
double sp_Rectangle_width(sp_Rectangle *self) {
  return (double)self->v.width;
}
double sp_Rectangle_set_width(sp_Rectangle *self, double width) {
  self->v.width = (float)width;
  return width;
}
double sp_Rectangle_height(sp_Rectangle *self) {
  return (double)self->v.height;
}
double sp_Rectangle_set_height(sp_Rectangle *self, double height) {
  self->v.height = (float)height;
  return height;
}

/* sp_Camera2D — GC-embedded Camera2D (see raylib_ffi.rb) */typedef struct sp_Camera2D_s {
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
double sp_Camera2D_rotation(sp_Camera2D *self) {
  return (double)self->v.rotation;
}
double sp_Camera2D_set_rotation(sp_Camera2D *self, double rotation) {
  self->v.rotation = (float)rotation;
  return rotation;
}
double sp_Camera2D_zoom(sp_Camera2D *self) {
  return (double)self->v.zoom;
}
double sp_Camera2D_set_zoom(sp_Camera2D *self, double zoom) {
  self->v.zoom = (float)zoom;
  return zoom;
}

/* sp_BoundingBox — GC-embedded BoundingBox (see raylib_ffi.rb) */typedef struct sp_BoundingBox_s {
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
sp_BoundingBox *sp_BoundingBox_with_min(sp_BoundingBox *self, double x, double y, double z) {
  self->v.min = (Vector3){ (float)x, (float)y, (float)z };
  return self;
}
sp_BoundingBox *sp_BoundingBox_with_max(sp_BoundingBox *self, double x, double y, double z) {
  self->v.max = (Vector3){ (float)x, (float)y, (float)z };
  return self;
}

/* sp_Ray — GC-embedded Ray (see raylib_ffi.rb) */typedef struct sp_Ray_s {
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

/* sp_RayCollision — GC-embedded RayCollision (see raylib_ffi.rb) */typedef struct sp_RayCollision_s {
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
int sp_RayCollision_hit(sp_RayCollision *self) {
  return self->v.hit ? 1 : 0;
}
int sp_RayCollision_set_hit(sp_RayCollision *self, int hit) {
  self->v.hit = hit != 0;
  return hit;
}
double sp_RayCollision_distance(sp_RayCollision *self) {
  return (double)self->v.distance;
}
double sp_RayCollision_set_distance(sp_RayCollision *self, double distance) {
  self->v.distance = (float)distance;
  return distance;
}

/* sp_Matrix — GC-embedded Matrix (see raylib_ffi.rb) */typedef struct sp_Matrix_s {
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

/* sp_NPatchInfo — GC-embedded NPatchInfo (see raylib_ffi.rb) */typedef struct sp_NPatchInfo_s {
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
int sp_NPatchInfo_left(sp_NPatchInfo *self) {
  return self->v.left;
}
int sp_NPatchInfo_set_left(sp_NPatchInfo *self, int left) {
  self->v.left = left;
  return left;
}
int sp_NPatchInfo_top(sp_NPatchInfo *self) {
  return self->v.top;
}
int sp_NPatchInfo_set_top(sp_NPatchInfo *self, int top) {
  self->v.top = top;
  return top;
}
int sp_NPatchInfo_right(sp_NPatchInfo *self) {
  return self->v.right;
}
int sp_NPatchInfo_set_right(sp_NPatchInfo *self, int right) {
  self->v.right = right;
  return right;
}
int sp_NPatchInfo_bottom(sp_NPatchInfo *self) {
  return self->v.bottom;
}
int sp_NPatchInfo_set_bottom(sp_NPatchInfo *self, int bottom) {
  self->v.bottom = bottom;
  return bottom;
}
int sp_NPatchInfo_layout(sp_NPatchInfo *self) {
  return self->v.layout;
}
int sp_NPatchInfo_set_layout(sp_NPatchInfo *self, int layout) {
  self->v.layout = layout;
  return layout;
}

/* sp_VrDeviceInfo — GC-embedded VrDeviceInfo (see raylib_ffi.rb) */typedef struct sp_VrDeviceInfo_s {
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
int sp_VrDeviceInfo_hResolution(sp_VrDeviceInfo *self) {
  return self->v.hResolution;
}
int sp_VrDeviceInfo_set_hResolution(sp_VrDeviceInfo *self, int hResolution) {
  self->v.hResolution = hResolution;
  return hResolution;
}
int sp_VrDeviceInfo_vResolution(sp_VrDeviceInfo *self) {
  return self->v.vResolution;
}
int sp_VrDeviceInfo_set_vResolution(sp_VrDeviceInfo *self, int vResolution) {
  self->v.vResolution = vResolution;
  return vResolution;
}
double sp_VrDeviceInfo_hScreenSize(sp_VrDeviceInfo *self) {
  return (double)self->v.hScreenSize;
}
double sp_VrDeviceInfo_set_hScreenSize(sp_VrDeviceInfo *self, double hScreenSize) {
  self->v.hScreenSize = (float)hScreenSize;
  return hScreenSize;
}
double sp_VrDeviceInfo_vScreenSize(sp_VrDeviceInfo *self) {
  return (double)self->v.vScreenSize;
}
double sp_VrDeviceInfo_set_vScreenSize(sp_VrDeviceInfo *self, double vScreenSize) {
  self->v.vScreenSize = (float)vScreenSize;
  return vScreenSize;
}
double sp_VrDeviceInfo_eyeToScreenDistance(sp_VrDeviceInfo *self) {
  return (double)self->v.eyeToScreenDistance;
}
double sp_VrDeviceInfo_set_eyeToScreenDistance(sp_VrDeviceInfo *self, double eyeToScreenDistance) {
  self->v.eyeToScreenDistance = (float)eyeToScreenDistance;
  return eyeToScreenDistance;
}
double sp_VrDeviceInfo_lensSeparationDistance(sp_VrDeviceInfo *self) {
  return (double)self->v.lensSeparationDistance;
}
double sp_VrDeviceInfo_set_lensSeparationDistance(sp_VrDeviceInfo *self, double lensSeparationDistance) {
  self->v.lensSeparationDistance = (float)lensSeparationDistance;
  return lensSeparationDistance;
}
double sp_VrDeviceInfo_interpupillaryDistance(sp_VrDeviceInfo *self) {
  return (double)self->v.interpupillaryDistance;
}
double sp_VrDeviceInfo_set_interpupillaryDistance(sp_VrDeviceInfo *self, double interpupillaryDistance) {
  self->v.interpupillaryDistance = (float)interpupillaryDistance;
  return interpupillaryDistance;
}

/* sp_VrStereoConfig — GC-embedded VrStereoConfig (see raylib_ffi.rb) */typedef struct sp_VrStereoConfig_s {
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

/* sp_FilePathList — GC-embedded FilePathList (see raylib_ffi.rb) */typedef struct sp_FilePathList_s {
  sp_int cls_id;
  FilePathList v;
} sp_FilePathList;
static void sp_FilePathList_scan(void *p) { (void)p; }
sp_FilePathList *sp_FilePathList_new(sp_int cls_id) {
  sp_FilePathList *self = (sp_FilePathList *)sp_gc_alloc(sizeof(sp_FilePathList), NULL, sp_FilePathList_scan);
  self->cls_id = cls_id;
  self->v = (FilePathList){ 0 };
  return self;
}
int sp_FilePathList_count(sp_FilePathList *self) {
  return self->v.count;
}
int sp_FilePathList_set_count(sp_FilePathList *self, int count) {
  self->v.count = count;
  return count;
}
const char *sp_FilePathList_path(sp_FilePathList *self, int index) {
  if (index < 0 || index >= self->v.count) return "";
  return self->v.paths[index];
}

/* sp_AutomationEvent — GC-embedded AutomationEvent (see raylib_ffi.rb) */typedef struct sp_AutomationEvent_s {
  sp_int cls_id;
  AutomationEvent v;
} sp_AutomationEvent;
static void sp_AutomationEvent_scan(void *p) { (void)p; }
sp_AutomationEvent *sp_AutomationEvent_new(sp_int cls_id) {
  sp_AutomationEvent *self = (sp_AutomationEvent *)sp_gc_alloc(sizeof(sp_AutomationEvent), NULL, sp_AutomationEvent_scan);
  self->cls_id = cls_id;
  self->v = (AutomationEvent){ 0 };
  return self;
}
int sp_AutomationEvent_frame(sp_AutomationEvent *self) {
  return self->v.frame;
}
int sp_AutomationEvent_set_frame(sp_AutomationEvent *self, int frame) {
  self->v.frame = frame;
  return frame;
}
int sp_AutomationEvent_type(sp_AutomationEvent *self) {
  return self->v.type;
}
int sp_AutomationEvent_set_type(sp_AutomationEvent *self, int type) {
  self->v.type = type;
  return type;
}

/* sp_AutomationEventList — GC-embedded AutomationEventList (see raylib_ffi.rb) */typedef struct sp_AutomationEventList_s {
  sp_int cls_id;
  AutomationEventList v;
} sp_AutomationEventList;
static void sp_AutomationEventList_scan(void *p) { (void)p; }
sp_AutomationEventList *sp_AutomationEventList_new(sp_int cls_id) {
  sp_AutomationEventList *self = (sp_AutomationEventList *)sp_gc_alloc(sizeof(sp_AutomationEventList), NULL, sp_AutomationEventList_scan);
  self->cls_id = cls_id;
  self->v = (AutomationEventList){ 0 };
  return self;
}
int sp_AutomationEventList_capacity(sp_AutomationEventList *self) {
  return self->v.capacity;
}
int sp_AutomationEventList_set_capacity(sp_AutomationEventList *self, int capacity) {
  self->v.capacity = capacity;
  return capacity;
}
int sp_AutomationEventList_count(sp_AutomationEventList *self) {
  return self->v.count;
}
int sp_AutomationEventList_set_count(sp_AutomationEventList *self, int count) {
  self->v.count = count;
  return count;
}

/* sp_Vector2 runtime methods (struct declared near the top) */
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

/* ---- generated shims ---- */
/** SetWindowIcon(params: void * image -> void) */
void sp_SetWindowIcon(void * image) {
  SetWindowIcon(*(Image *)image);
}
/** GetMonitorPosition(params: int monitor, void * _out -> void) */
void sp_GetMonitorPosition(int monitor, void * _out) {
  ((sp_Vector2*)_out)->v = GetMonitorPosition(monitor);
}
/** GetWindowPosition(params: void * _out -> void) */
void sp_GetWindowPosition(void * _out) {
  ((sp_Vector2*)_out)->v = GetWindowPosition();
}
/** GetWindowScaleDPI(params: void * _out -> void) */
void sp_GetWindowScaleDPI(void * _out) {
  ((sp_Vector2*)_out)->v = GetWindowScaleDPI();
}
/** GetClipboardImage(params: void -> void *) */
void * sp_GetClipboardImage(void) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GetClipboardImage();
  return r;
}
/** BeginMode2D(params: void * camera -> void) */
void sp_BeginMode2D(void * camera) {
  BeginMode2D(((sp_Camera2D*)camera)->v);
}
/** BeginTextureMode(params: void * target -> void) */
void sp_BeginTextureMode(void * target) {
  BeginTextureMode(*(RenderTexture2D *)target);
}
/** BeginShaderMode(params: void * shader -> void) */
void sp_BeginShaderMode(void * shader) {
  BeginShaderMode(*(Shader *)shader);
}
/** BeginVrStereoMode(params: void * config -> void) */
void sp_BeginVrStereoMode(void * config) {
  BeginVrStereoMode(((sp_VrStereoConfig*)config)->v);
}
/** LoadVrStereoConfig(params: void * device, void * _out -> void) */
void sp_LoadVrStereoConfig(void * device, void * _out) {
  ((sp_VrStereoConfig*)_out)->v = LoadVrStereoConfig(((sp_VrDeviceInfo*)device)->v);
}
/** UnloadVrStereoConfig(params: void * config -> void) */
void sp_UnloadVrStereoConfig(void * config) {
  UnloadVrStereoConfig(((sp_VrStereoConfig*)config)->v);
}
/** LoadShader(params: const char * vsFileName, const char * fsFileName -> void *) */
void * sp_LoadShader(const char * vsFileName, const char * fsFileName) {
  Shader *r = (Shader *)malloc(sizeof(Shader));
  *r = LoadShader(vsFileName, fsFileName);
  return r;
}
/** LoadShaderFromMemory(params: const char * vsCode, const char * fsCode -> void *) */
void * sp_LoadShaderFromMemory(const char * vsCode, const char * fsCode) {
  Shader *r = (Shader *)malloc(sizeof(Shader));
  *r = LoadShaderFromMemory(vsCode, fsCode);
  return r;
}
/** IsShaderValid(params: void * shader -> _Bool) */
_Bool sp_IsShaderValid(void * shader) {
  return IsShaderValid(*(Shader *)shader);
}
/** GetShaderLocation(params: void * shader, const char * uniformName -> int) */
int sp_GetShaderLocation(void * shader, const char * uniformName) {
  return GetShaderLocation(*(Shader *)shader, uniformName);
}
/** GetShaderLocationAttrib(params: void * shader, const char * attribName -> int) */
int sp_GetShaderLocationAttrib(void * shader, const char * attribName) {
  return GetShaderLocationAttrib(*(Shader *)shader, attribName);
}
/** SetShaderValue(params: void * shader, int locIndex, void * value, int uniformType -> void) */
void sp_SetShaderValue(void * shader, int locIndex, void * value, int uniformType) {
  SetShaderValue(*(Shader *)shader, locIndex, value, uniformType);
}
/** SetShaderValueV(params: void * shader, int locIndex, void * value, int uniformType, int count -> void) */
void sp_SetShaderValueV(void * shader, int locIndex, void * value, int uniformType, int count) {
  SetShaderValueV(*(Shader *)shader, locIndex, value, uniformType, count);
}
/** SetShaderValueMatrix(params: void * shader, int locIndex, void * mat -> void) */
void sp_SetShaderValueMatrix(void * shader, int locIndex, void * mat) {
  SetShaderValueMatrix(*(Shader *)shader, locIndex, ((sp_Matrix*)mat)->v);
}
/** SetShaderValueTexture(params: void * shader, int locIndex, void * texture -> void) */
void sp_SetShaderValueTexture(void * shader, int locIndex, void * texture) {
  SetShaderValueTexture(*(Shader *)shader, locIndex, *(Texture2D *)texture);
}
/** UnloadShader(params: void * shader -> void) */
void sp_UnloadShader(void * shader) {
  Shader *self = (Shader *)shader;
  UnloadShader(*self);
  free(self);
}
/** GetScreenToWorldRay(params: void * position, void * camera, void * _out -> void) */
void sp_GetScreenToWorldRay(void * position, void * camera, void * _out) {
  ((sp_Ray*)_out)->v = GetScreenToWorldRay(((sp_Vector2 *)position)->v, ((sp_Camera*)camera)->c);
}
/** GetScreenToWorldRayEx(params: void * position, void * camera, int width, int height, void * _out -> void) */
void sp_GetScreenToWorldRayEx(void * position, void * camera, int width, int height, void * _out) {
  ((sp_Ray*)_out)->v = GetScreenToWorldRayEx(((sp_Vector2 *)position)->v, ((sp_Camera*)camera)->c, width, height);
}
/** GetWorldToScreen(params: void * position, void * camera, void * _out -> void) */
void sp_GetWorldToScreen(void * position, void * camera, void * _out) {
  ((sp_Vector2*)_out)->v = GetWorldToScreen(((sp_Vector3*)position)->v, ((sp_Camera*)camera)->c);
}
/** GetWorldToScreenEx(params: void * position, void * camera, int width, int height, void * _out -> void) */
void sp_GetWorldToScreenEx(void * position, void * camera, int width, int height, void * _out) {
  ((sp_Vector2*)_out)->v = GetWorldToScreenEx(((sp_Vector3*)position)->v, ((sp_Camera*)camera)->c, width, height);
}
/** GetWorldToScreen2D(params: void * position, void * camera, void * _out -> void) */
void sp_GetWorldToScreen2D(void * position, void * camera, void * _out) {
  ((sp_Vector2*)_out)->v = GetWorldToScreen2D(((sp_Vector2 *)position)->v, ((sp_Camera2D*)camera)->v);
}
/** GetScreenToWorld2D(params: void * position, void * camera, void * _out -> void) */
void sp_GetScreenToWorld2D(void * position, void * camera, void * _out) {
  ((sp_Vector2*)_out)->v = GetScreenToWorld2D(((sp_Vector2 *)position)->v, ((sp_Camera2D*)camera)->v);
}
/** GetCameraMatrix(params: void * camera, void * _out -> void) */
void sp_GetCameraMatrix(void * camera, void * _out) {
  ((sp_Matrix*)_out)->v = GetCameraMatrix(((sp_Camera*)camera)->c);
}
/** GetCameraMatrix2D(params: void * camera, void * _out -> void) */
void sp_GetCameraMatrix2D(void * camera, void * _out) {
  ((sp_Matrix*)_out)->v = GetCameraMatrix2D(((sp_Camera2D*)camera)->v);
}
/** SetTraceLogCallback(params: void * callback -> void) */
void sp_SetTraceLogCallback(void * callback) {
  SetTraceLogCallback((TraceLogCallback)callback);
}
/** SetLoadFileDataCallback(params: void * callback -> void) */
void sp_SetLoadFileDataCallback(void * callback) {
  SetLoadFileDataCallback((LoadFileDataCallback)callback);
}
/** SetSaveFileDataCallback(params: void * callback -> void) */
void sp_SetSaveFileDataCallback(void * callback) {
  SetSaveFileDataCallback((SaveFileDataCallback)callback);
}
/** SetLoadFileTextCallback(params: void * callback -> void) */
void sp_SetLoadFileTextCallback(void * callback) {
  SetLoadFileTextCallback((LoadFileTextCallback)callback);
}
/** SetSaveFileTextCallback(params: void * callback -> void) */
void sp_SetSaveFileTextCallback(void * callback) {
  SetSaveFileTextCallback((SaveFileTextCallback)callback);
}
/** LoadDirectoryFiles(params: const char * dirPath, void * _out -> void) */
void sp_LoadDirectoryFiles(const char * dirPath, void * _out) {
  ((sp_FilePathList*)_out)->v = LoadDirectoryFiles(dirPath);
}
/** LoadDirectoryFilesEx(params: const char * basePath, const char * filter, _Bool scanSubdirs, void * _out -> void) */
void sp_LoadDirectoryFilesEx(const char * basePath, const char * filter, _Bool scanSubdirs, void * _out) {
  ((sp_FilePathList*)_out)->v = LoadDirectoryFilesEx(basePath, filter, scanSubdirs);
}
/** UnloadDirectoryFiles(params: void * files -> void) */
void sp_UnloadDirectoryFiles(void * files) {
  UnloadDirectoryFiles(((sp_FilePathList*)files)->v);
}
/** LoadDroppedFiles(params: void * _out -> void) */
void sp_LoadDroppedFiles(void * _out) {
  ((sp_FilePathList*)_out)->v = LoadDroppedFiles();
}
/** UnloadDroppedFiles(params: void * files -> void) */
void sp_UnloadDroppedFiles(void * files) {
  UnloadDroppedFiles(((sp_FilePathList*)files)->v);
}
/** LoadAutomationEventList(params: const char * fileName, void * _out -> void) */
void sp_LoadAutomationEventList(const char * fileName, void * _out) {
  ((sp_AutomationEventList*)_out)->v = LoadAutomationEventList(fileName);
}
/** UnloadAutomationEventList(params: void * list -> void) */
void sp_UnloadAutomationEventList(void * list) {
  UnloadAutomationEventList(((sp_AutomationEventList*)list)->v);
}
/** ExportAutomationEventList(params: void * list, const char * fileName -> _Bool) */
_Bool sp_ExportAutomationEventList(void * list, const char * fileName) {
  return ExportAutomationEventList(((sp_AutomationEventList*)list)->v, fileName);
}
/** SetAutomationEventList(params: void * list -> void) */
void sp_SetAutomationEventList(void * list) {
  SetAutomationEventList(&((sp_AutomationEventList*)list)->v);
}
/** PlayAutomationEvent(params: void * event -> void) */
void sp_PlayAutomationEvent(void * event) {
  PlayAutomationEvent(((sp_AutomationEvent*)event)->v);
}
/** GetMousePosition(params: void * _out -> void) */
void sp_GetMousePosition(void * _out) {
  ((sp_Vector2*)_out)->v = GetMousePosition();
}
/** GetMouseDelta(params: void * _out -> void) */
void sp_GetMouseDelta(void * _out) {
  ((sp_Vector2*)_out)->v = GetMouseDelta();
}
/** GetMouseWheelMoveV(params: void * _out -> void) */
void sp_GetMouseWheelMoveV(void * _out) {
  ((sp_Vector2*)_out)->v = GetMouseWheelMoveV();
}
/** GetTouchPosition(params: int index, void * _out -> void) */
void sp_GetTouchPosition(int index, void * _out) {
  ((sp_Vector2*)_out)->v = GetTouchPosition(index);
}
/** GetGestureDragVector(params: void * _out -> void) */
void sp_GetGestureDragVector(void * _out) {
  ((sp_Vector2*)_out)->v = GetGestureDragVector();
}
/** GetGesturePinchVector(params: void * _out -> void) */
void sp_GetGesturePinchVector(void * _out) {
  ((sp_Vector2*)_out)->v = GetGesturePinchVector();
}
/** UpdateCameraPro(params: void * camera, void * movement, void * rotation, float zoom -> void) */
void sp_UpdateCameraPro(void * camera, void * movement, void * rotation, float zoom) {
  UpdateCameraPro(&((sp_Camera*)camera)->c, ((sp_Vector3*)movement)->v, ((sp_Vector3*)rotation)->v, zoom);
}
/** SetShapesTexture(params: void * texture, void * rec -> void) */
void sp_SetShapesTexture(void * texture, void * rec) {
  SetShapesTexture(*(Texture2D *)texture, ((sp_Rectangle*)rec)->v);
}
/** GetShapesTexture(params: void -> void *) */
void * sp_GetShapesTexture(void) {
  Texture2D *r = (Texture2D *)malloc(sizeof(Texture2D));
  *r = GetShapesTexture();
  return r;
}
/** GetShapesTextureRectangle(params: void * _out -> void) */
void sp_GetShapesTextureRectangle(void * _out) {
  ((sp_Rectangle*)_out)->v = GetShapesTextureRectangle();
}
/** DrawPixelV(params: void * position, void * color -> void) */
void sp_DrawPixelV(void * position, void * color) {
  DrawPixelV(((sp_Vector2 *)position)->v, ((sp_Color*)color)->c);
}
/** DrawLine(params: int startPosX, int startPosY, int endPosX, int endPosY, void * color -> void) */
void sp_DrawLine(int startPosX, int startPosY, int endPosX, int endPosY, void * color) {
  DrawLine(startPosX, startPosY, endPosX, endPosY, ((sp_Color*)color)->c);
}
/** DrawLineV(params: void * startPos, void * endPos, void * color -> void) */
void sp_DrawLineV(void * startPos, void * endPos, void * color) {
  DrawLineV(((sp_Vector2 *)startPos)->v, ((sp_Vector2 *)endPos)->v, ((sp_Color*)color)->c);
}
/** DrawLineEx(params: void * startPos, void * endPos, float thick, void * color -> void) */
void sp_DrawLineEx(void * startPos, void * endPos, float thick, void * color) {
  DrawLineEx(((sp_Vector2 *)startPos)->v, ((sp_Vector2 *)endPos)->v, thick, ((sp_Color*)color)->c);
}
/** DrawLineStrip(params: void * points, int pointCount, void * color -> void) */
void sp_DrawLineStrip(void * points, int pointCount, void * color) {
  DrawLineStrip(points, pointCount, ((sp_Color*)color)->c);
}
/** DrawLineBezier(params: void * startPos, void * endPos, float thick, void * color -> void) */
void sp_DrawLineBezier(void * startPos, void * endPos, float thick, void * color) {
  DrawLineBezier(((sp_Vector2 *)startPos)->v, ((sp_Vector2 *)endPos)->v, thick, ((sp_Color*)color)->c);
}
/** DrawLineDashed(params: void * startPos, void * endPos, int dashSize, int spaceSize, void * color -> void) */
void sp_DrawLineDashed(void * startPos, void * endPos, int dashSize, int spaceSize, void * color) {
  DrawLineDashed(((sp_Vector2 *)startPos)->v, ((sp_Vector2 *)endPos)->v, dashSize, spaceSize, ((sp_Color*)color)->c);
}
/** DrawTriangleGradient(params: void * v1, void * v2, void * v3, void * c1, void * c2, void * c3 -> void) */
void sp_DrawTriangleGradient(void * v1, void * v2, void * v3, void * c1, void * c2, void * c3) {
  DrawTriangleGradient(((sp_Vector2 *)v1)->v, ((sp_Vector2 *)v2)->v, ((sp_Vector2 *)v3)->v, ((sp_Color*)c1)->c, ((sp_Color*)c2)->c, ((sp_Color*)c3)->c);
}
/** DrawTriangleLines(params: void * v1, void * v2, void * v3, void * color -> void) */
void sp_DrawTriangleLines(void * v1, void * v2, void * v3, void * color) {
  DrawTriangleLines(((sp_Vector2 *)v1)->v, ((sp_Vector2 *)v2)->v, ((sp_Vector2 *)v3)->v, ((sp_Color*)color)->c);
}
/** DrawTriangleLinesEx(params: void * v1, void * v2, void * v3, float thick, void * color -> void) */
void sp_DrawTriangleLinesEx(void * v1, void * v2, void * v3, float thick, void * color) {
  DrawTriangleLinesEx(((sp_Vector2 *)v1)->v, ((sp_Vector2 *)v2)->v, ((sp_Vector2 *)v3)->v, thick, ((sp_Color*)color)->c);
}
/** DrawTriangleFan(params: void * points, int pointCount, void * color -> void) */
void sp_DrawTriangleFan(void * points, int pointCount, void * color) {
  DrawTriangleFan(points, pointCount, ((sp_Color*)color)->c);
}
/** DrawTriangleStrip(params: void * points, int pointCount, void * color -> void) */
void sp_DrawTriangleStrip(void * points, int pointCount, void * color) {
  DrawTriangleStrip(points, pointCount, ((sp_Color*)color)->c);
}
/** DrawRectangleV(params: void * position, void * size, void * color -> void) */
void sp_DrawRectangleV(void * position, void * size, void * color) {
  DrawRectangleV(((sp_Vector2 *)position)->v, ((sp_Vector2 *)size)->v, ((sp_Color*)color)->c);
}
/** DrawRectangleRec(params: void * rec, void * color -> void) */
void sp_DrawRectangleRec(void * rec, void * color) {
  DrawRectangleRec(((sp_Rectangle*)rec)->v, ((sp_Color*)color)->c);
}
/** DrawRectanglePro(params: void * rec, void * origin, float rotation, void * color -> void) */
void sp_DrawRectanglePro(void * rec, void * origin, float rotation, void * color) {
  DrawRectanglePro(((sp_Rectangle*)rec)->v, ((sp_Vector2 *)origin)->v, rotation, ((sp_Color*)color)->c);
}
/** DrawRectangleGradientV(params: int posX, int posY, int width, int height, void * top, void * bottom -> void) */
void sp_DrawRectangleGradientV(int posX, int posY, int width, int height, void * top, void * bottom) {
  DrawRectangleGradientV(posX, posY, width, height, ((sp_Color*)top)->c, ((sp_Color*)bottom)->c);
}
/** DrawRectangleGradientH(params: int posX, int posY, int width, int height, void * left, void * right -> void) */
void sp_DrawRectangleGradientH(int posX, int posY, int width, int height, void * left, void * right) {
  DrawRectangleGradientH(posX, posY, width, height, ((sp_Color*)left)->c, ((sp_Color*)right)->c);
}
/** DrawRectangleGradientEx(params: void * rec, void * col1, void * col2, void * col3, void * col4 -> void) */
void sp_DrawRectangleGradientEx(void * rec, void * col1, void * col2, void * col3, void * col4) {
  DrawRectangleGradientEx(((sp_Rectangle*)rec)->v, ((sp_Color*)col1)->c, ((sp_Color*)col2)->c, ((sp_Color*)col3)->c, ((sp_Color*)col4)->c);
}
/** DrawRectangleLinesEx(params: void * rec, float thick, void * color -> void) */
void sp_DrawRectangleLinesEx(void * rec, float thick, void * color) {
  DrawRectangleLinesEx(((sp_Rectangle*)rec)->v, thick, ((sp_Color*)color)->c);
}
/** DrawRectangleRounded(params: void * rec, float roundness, int segments, void * color -> void) */
void sp_DrawRectangleRounded(void * rec, float roundness, int segments, void * color) {
  DrawRectangleRounded(((sp_Rectangle*)rec)->v, roundness, segments, ((sp_Color*)color)->c);
}
/** DrawRectangleRoundedLines(params: void * rec, float roundness, int segments, void * color -> void) */
void sp_DrawRectangleRoundedLines(void * rec, float roundness, int segments, void * color) {
  DrawRectangleRoundedLines(((sp_Rectangle*)rec)->v, roundness, segments, ((sp_Color*)color)->c);
}
/** DrawRectangleRoundedLinesEx(params: void * rec, float roundness, int segments, float thick, void * color -> void) */
void sp_DrawRectangleRoundedLinesEx(void * rec, float roundness, int segments, float thick, void * color) {
  DrawRectangleRoundedLinesEx(((sp_Rectangle*)rec)->v, roundness, segments, thick, ((sp_Color*)color)->c);
}
/** DrawPoly(params: void * center, int sides, float radius, float rotation, void * color -> void) */
void sp_DrawPoly(void * center, int sides, float radius, float rotation, void * color) {
  DrawPoly(((sp_Vector2 *)center)->v, sides, radius, rotation, ((sp_Color*)color)->c);
}
/** DrawPolyLines(params: void * center, int sides, float radius, float rotation, void * color -> void) */
void sp_DrawPolyLines(void * center, int sides, float radius, float rotation, void * color) {
  DrawPolyLines(((sp_Vector2 *)center)->v, sides, radius, rotation, ((sp_Color*)color)->c);
}
/** DrawPolyLinesEx(params: void * center, int sides, float radius, float rotation, float thick, void * color -> void) */
void sp_DrawPolyLinesEx(void * center, int sides, float radius, float rotation, float thick, void * color) {
  DrawPolyLinesEx(((sp_Vector2 *)center)->v, sides, radius, rotation, thick, ((sp_Color*)color)->c);
}
/** DrawCircle(params: int centerX, int centerY, float radius, void * color -> void) */
void sp_DrawCircle(int centerX, int centerY, float radius, void * color) {
  DrawCircle(centerX, centerY, radius, ((sp_Color*)color)->c);
}
/** DrawCircleGradient(params: void * center, float radius, void * inner, void * outer -> void) */
void sp_DrawCircleGradient(void * center, float radius, void * inner, void * outer) {
  DrawCircleGradient(((sp_Vector2 *)center)->v, radius, ((sp_Color*)inner)->c, ((sp_Color*)outer)->c);
}
/** DrawCircleSector(params: void * center, float radius, float startAngle, float endAngle, int segments, void * color -> void) */
void sp_DrawCircleSector(void * center, float radius, float startAngle, float endAngle, int segments, void * color) {
  DrawCircleSector(((sp_Vector2 *)center)->v, radius, startAngle, endAngle, segments, ((sp_Color*)color)->c);
}
/** DrawCircleSectorLines(params: void * center, float radius, float startAngle, float endAngle, int segments, void * color -> void) */
void sp_DrawCircleSectorLines(void * center, float radius, float startAngle, float endAngle, int segments, void * color) {
  DrawCircleSectorLines(((sp_Vector2 *)center)->v, radius, startAngle, endAngle, segments, ((sp_Color*)color)->c);
}
/** DrawCircleSectorLinesEx(params: void * center, float radius, float startAngle, float endAngle, int segments, float thick, void * color -> void) */
void sp_DrawCircleSectorLinesEx(void * center, float radius, float startAngle, float endAngle, int segments, float thick, void * color) {
  DrawCircleSectorLinesEx(((sp_Vector2 *)center)->v, radius, startAngle, endAngle, segments, thick, ((sp_Color*)color)->c);
}
/** DrawCircleLines(params: int centerX, int centerY, float radius, void * color -> void) */
void sp_DrawCircleLines(int centerX, int centerY, float radius, void * color) {
  DrawCircleLines(centerX, centerY, radius, ((sp_Color*)color)->c);
}
/** DrawCircleLinesV(params: void * center, float radius, void * color -> void) */
void sp_DrawCircleLinesV(void * center, float radius, void * color) {
  DrawCircleLinesV(((sp_Vector2 *)center)->v, radius, ((sp_Color*)color)->c);
}
/** DrawCircleLinesEx(params: void * center, float radius, float thick, void * color -> void) */
void sp_DrawCircleLinesEx(void * center, float radius, float thick, void * color) {
  DrawCircleLinesEx(((sp_Vector2 *)center)->v, radius, thick, ((sp_Color*)color)->c);
}
/** DrawEllipse(params: int centerX, int centerY, float radiusH, float radiusV, void * color -> void) */
void sp_DrawEllipse(int centerX, int centerY, float radiusH, float radiusV, void * color) {
  DrawEllipse(centerX, centerY, radiusH, radiusV, ((sp_Color*)color)->c);
}
/** DrawEllipseV(params: void * center, float radiusH, float radiusV, void * color -> void) */
void sp_DrawEllipseV(void * center, float radiusH, float radiusV, void * color) {
  DrawEllipseV(((sp_Vector2 *)center)->v, radiusH, radiusV, ((sp_Color*)color)->c);
}
/** DrawEllipseLines(params: int centerX, int centerY, float radiusH, float radiusV, void * color -> void) */
void sp_DrawEllipseLines(int centerX, int centerY, float radiusH, float radiusV, void * color) {
  DrawEllipseLines(centerX, centerY, radiusH, radiusV, ((sp_Color*)color)->c);
}
/** DrawEllipseLinesV(params: void * center, float radiusH, float radiusV, void * color -> void) */
void sp_DrawEllipseLinesV(void * center, float radiusH, float radiusV, void * color) {
  DrawEllipseLinesV(((sp_Vector2 *)center)->v, radiusH, radiusV, ((sp_Color*)color)->c);
}
/** DrawEllipseLinesEx(params: void * center, float radiusH, float radiusV, float thick, void * color -> void) */
void sp_DrawEllipseLinesEx(void * center, float radiusH, float radiusV, float thick, void * color) {
  DrawEllipseLinesEx(((sp_Vector2 *)center)->v, radiusH, radiusV, thick, ((sp_Color*)color)->c);
}
/** DrawRing(params: void * center, float innerRadius, float outerRadius, float startAngle, float endAngle, int segments, void * color -> void) */
void sp_DrawRing(void * center, float innerRadius, float outerRadius, float startAngle, float endAngle, int segments, void * color) {
  DrawRing(((sp_Vector2 *)center)->v, innerRadius, outerRadius, startAngle, endAngle, segments, ((sp_Color*)color)->c);
}
/** DrawRingLines(params: void * center, float innerRadius, float outerRadius, float startAngle, float endAngle, int segments, void * color -> void) */
void sp_DrawRingLines(void * center, float innerRadius, float outerRadius, float startAngle, float endAngle, int segments, void * color) {
  DrawRingLines(((sp_Vector2 *)center)->v, innerRadius, outerRadius, startAngle, endAngle, segments, ((sp_Color*)color)->c);
}
/** DrawRingLinesEx(params: void * center, float innerRadius, float outerRadius, float startAngle, float endAngle, int segments, float thick, void * color -> void) */
void sp_DrawRingLinesEx(void * center, float innerRadius, float outerRadius, float startAngle, float endAngle, int segments, float thick, void * color) {
  DrawRingLinesEx(((sp_Vector2 *)center)->v, innerRadius, outerRadius, startAngle, endAngle, segments, thick, ((sp_Color*)color)->c);
}
/** DrawSplineLinear(params: void * points, int pointCount, float thick, void * color -> void) */
void sp_DrawSplineLinear(void * points, int pointCount, float thick, void * color) {
  DrawSplineLinear(points, pointCount, thick, ((sp_Color*)color)->c);
}
/** DrawSplineBasis(params: void * points, int pointCount, float thick, void * color -> void) */
void sp_DrawSplineBasis(void * points, int pointCount, float thick, void * color) {
  DrawSplineBasis(points, pointCount, thick, ((sp_Color*)color)->c);
}
/** DrawSplineCatmullRom(params: void * points, int pointCount, float thick, void * color -> void) */
void sp_DrawSplineCatmullRom(void * points, int pointCount, float thick, void * color) {
  DrawSplineCatmullRom(points, pointCount, thick, ((sp_Color*)color)->c);
}
/** DrawSplineBezierQuadratic(params: void * points, int pointCount, float thick, void * color -> void) */
void sp_DrawSplineBezierQuadratic(void * points, int pointCount, float thick, void * color) {
  DrawSplineBezierQuadratic(points, pointCount, thick, ((sp_Color*)color)->c);
}
/** DrawSplineBezierCubic(params: void * points, int pointCount, float thick, void * color -> void) */
void sp_DrawSplineBezierCubic(void * points, int pointCount, float thick, void * color) {
  DrawSplineBezierCubic(points, pointCount, thick, ((sp_Color*)color)->c);
}
/** DrawSplineSegmentLinear(params: void * p1, void * p2, float thick, void * color -> void) */
void sp_DrawSplineSegmentLinear(void * p1, void * p2, float thick, void * color) {
  DrawSplineSegmentLinear(((sp_Vector2 *)p1)->v, ((sp_Vector2 *)p2)->v, thick, ((sp_Color*)color)->c);
}
/** DrawSplineSegmentBasis(params: void * p1, void * p2, void * p3, void * p4, float thick, void * color -> void) */
void sp_DrawSplineSegmentBasis(void * p1, void * p2, void * p3, void * p4, float thick, void * color) {
  DrawSplineSegmentBasis(((sp_Vector2 *)p1)->v, ((sp_Vector2 *)p2)->v, ((sp_Vector2 *)p3)->v, ((sp_Vector2 *)p4)->v, thick, ((sp_Color*)color)->c);
}
/** DrawSplineSegmentCatmullRom(params: void * p1, void * p2, void * p3, void * p4, float thick, void * color -> void) */
void sp_DrawSplineSegmentCatmullRom(void * p1, void * p2, void * p3, void * p4, float thick, void * color) {
  DrawSplineSegmentCatmullRom(((sp_Vector2 *)p1)->v, ((sp_Vector2 *)p2)->v, ((sp_Vector2 *)p3)->v, ((sp_Vector2 *)p4)->v, thick, ((sp_Color*)color)->c);
}
/** DrawSplineSegmentBezierQuadratic(params: void * p1, void * c2, void * p3, float thick, void * color -> void) */
void sp_DrawSplineSegmentBezierQuadratic(void * p1, void * c2, void * p3, float thick, void * color) {
  DrawSplineSegmentBezierQuadratic(((sp_Vector2 *)p1)->v, ((sp_Vector2 *)c2)->v, ((sp_Vector2 *)p3)->v, thick, ((sp_Color*)color)->c);
}
/** DrawSplineSegmentBezierCubic(params: void * p1, void * c2, void * c3, void * p4, float thick, void * color -> void) */
void sp_DrawSplineSegmentBezierCubic(void * p1, void * c2, void * c3, void * p4, float thick, void * color) {
  DrawSplineSegmentBezierCubic(((sp_Vector2 *)p1)->v, ((sp_Vector2 *)c2)->v, ((sp_Vector2 *)c3)->v, ((sp_Vector2 *)p4)->v, thick, ((sp_Color*)color)->c);
}
/** GetSplinePointLinear(params: void * startPos, void * endPos, float t, void * _out -> void) */
void sp_GetSplinePointLinear(void * startPos, void * endPos, float t, void * _out) {
  ((sp_Vector2*)_out)->v = GetSplinePointLinear(((sp_Vector2 *)startPos)->v, ((sp_Vector2 *)endPos)->v, t);
}
/** GetSplinePointBasis(params: void * p1, void * p2, void * p3, void * p4, float t, void * _out -> void) */
void sp_GetSplinePointBasis(void * p1, void * p2, void * p3, void * p4, float t, void * _out) {
  ((sp_Vector2*)_out)->v = GetSplinePointBasis(((sp_Vector2 *)p1)->v, ((sp_Vector2 *)p2)->v, ((sp_Vector2 *)p3)->v, ((sp_Vector2 *)p4)->v, t);
}
/** GetSplinePointCatmullRom(params: void * p1, void * p2, void * p3, void * p4, float t, void * _out -> void) */
void sp_GetSplinePointCatmullRom(void * p1, void * p2, void * p3, void * p4, float t, void * _out) {
  ((sp_Vector2*)_out)->v = GetSplinePointCatmullRom(((sp_Vector2 *)p1)->v, ((sp_Vector2 *)p2)->v, ((sp_Vector2 *)p3)->v, ((sp_Vector2 *)p4)->v, t);
}
/** GetSplinePointBezierQuadratic(params: void * p1, void * c2, void * p3, float t, void * _out -> void) */
void sp_GetSplinePointBezierQuadratic(void * p1, void * c2, void * p3, float t, void * _out) {
  ((sp_Vector2*)_out)->v = GetSplinePointBezierQuadratic(((sp_Vector2 *)p1)->v, ((sp_Vector2 *)c2)->v, ((sp_Vector2 *)p3)->v, t);
}
/** GetSplinePointBezierCubic(params: void * p1, void * c2, void * c3, void * p4, float t, void * _out -> void) */
void sp_GetSplinePointBezierCubic(void * p1, void * c2, void * c3, void * p4, float t, void * _out) {
  ((sp_Vector2*)_out)->v = GetSplinePointBezierCubic(((sp_Vector2 *)p1)->v, ((sp_Vector2 *)c2)->v, ((sp_Vector2 *)c3)->v, ((sp_Vector2 *)p4)->v, t);
}
/** CheckCollisionRecs(params: void * rec1, void * rec2 -> _Bool) */
_Bool sp_CheckCollisionRecs(void * rec1, void * rec2) {
  return CheckCollisionRecs(((sp_Rectangle*)rec1)->v, ((sp_Rectangle*)rec2)->v);
}
/** CheckCollisionCircles(params: void * center1, float radius1, void * center2, float radius2 -> _Bool) */
_Bool sp_CheckCollisionCircles(void * center1, float radius1, void * center2, float radius2) {
  return CheckCollisionCircles(((sp_Vector2 *)center1)->v, radius1, ((sp_Vector2 *)center2)->v, radius2);
}
/** CheckCollisionCircleRec(params: void * center, float radius, void * rec -> _Bool) */
_Bool sp_CheckCollisionCircleRec(void * center, float radius, void * rec) {
  return CheckCollisionCircleRec(((sp_Vector2 *)center)->v, radius, ((sp_Rectangle*)rec)->v);
}
/** CheckCollisionCircleLine(params: void * center, float radius, void * p1, void * p2 -> _Bool) */
_Bool sp_CheckCollisionCircleLine(void * center, float radius, void * p1, void * p2) {
  return CheckCollisionCircleLine(((sp_Vector2 *)center)->v, radius, ((sp_Vector2 *)p1)->v, ((sp_Vector2 *)p2)->v);
}
/** CheckCollisionPointRec(params: void * point, void * rec -> _Bool) */
_Bool sp_CheckCollisionPointRec(void * point, void * rec) {
  return CheckCollisionPointRec(((sp_Vector2 *)point)->v, ((sp_Rectangle*)rec)->v);
}
/** CheckCollisionPointCircle(params: void * point, void * center, float radius -> _Bool) */
_Bool sp_CheckCollisionPointCircle(void * point, void * center, float radius) {
  return CheckCollisionPointCircle(((sp_Vector2 *)point)->v, ((sp_Vector2 *)center)->v, radius);
}
/** CheckCollisionPointTriangle(params: void * point, void * p1, void * p2, void * p3 -> _Bool) */
_Bool sp_CheckCollisionPointTriangle(void * point, void * p1, void * p2, void * p3) {
  return CheckCollisionPointTriangle(((sp_Vector2 *)point)->v, ((sp_Vector2 *)p1)->v, ((sp_Vector2 *)p2)->v, ((sp_Vector2 *)p3)->v);
}
/** CheckCollisionPointLine(params: void * point, void * p1, void * p2, int threshold -> _Bool) */
_Bool sp_CheckCollisionPointLine(void * point, void * p1, void * p2, int threshold) {
  return CheckCollisionPointLine(((sp_Vector2 *)point)->v, ((sp_Vector2 *)p1)->v, ((sp_Vector2 *)p2)->v, threshold);
}
/** CheckCollisionPointPoly(params: void * point, void * points, int pointCount -> _Bool) */
_Bool sp_CheckCollisionPointPoly(void * point, void * points, int pointCount) {
  return CheckCollisionPointPoly(((sp_Vector2 *)point)->v, points, pointCount);
}
/** CheckCollisionLines(params: void * startPos1, void * endPos1, void * startPos2, void * endPos2, void * collisionPoint -> _Bool) */
_Bool sp_CheckCollisionLines(void * startPos1, void * endPos1, void * startPos2, void * endPos2, void * collisionPoint) {
  return CheckCollisionLines(((sp_Vector2 *)startPos1)->v, ((sp_Vector2 *)endPos1)->v, ((sp_Vector2 *)startPos2)->v, ((sp_Vector2 *)endPos2)->v, collisionPoint);
}
/** GetCollisionRec(params: void * rec1, void * rec2, void * _out -> void) */
void sp_GetCollisionRec(void * rec1, void * rec2, void * _out) {
  ((sp_Rectangle*)_out)->v = GetCollisionRec(((sp_Rectangle*)rec1)->v, ((sp_Rectangle*)rec2)->v);
}
/** LoadImage(params: const char * fileName -> void *) */
void * sp_LoadImage(const char * fileName) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = LoadImage(fileName);
  return r;
}
/** LoadImageRaw(params: const char * fileName, int width, int height, int format, int headerSize -> void *) */
void * sp_LoadImageRaw(const char * fileName, int width, int height, int format, int headerSize) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = LoadImageRaw(fileName, width, height, format, headerSize);
  return r;
}
/** LoadImageAnim(params: const char * fileName, void * frames -> void *) */
void * sp_LoadImageAnim(const char * fileName, void * frames) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = LoadImageAnim(fileName, frames);
  return r;
}
/** LoadImageAnimFromMemory(params: const char * fileType, void * fileData, int dataSize, void * frames -> void *) */
void * sp_LoadImageAnimFromMemory(const char * fileType, void * fileData, int dataSize, void * frames) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = LoadImageAnimFromMemory(fileType, fileData, dataSize, frames);
  return r;
}
/** LoadImageFromMemory(params: const char * fileType, void * fileData, int dataSize -> void *) */
void * sp_LoadImageFromMemory(const char * fileType, void * fileData, int dataSize) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = LoadImageFromMemory(fileType, fileData, dataSize);
  return r;
}
/** LoadImageFromTexture(params: void * texture -> void *) */
void * sp_LoadImageFromTexture(void * texture) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = LoadImageFromTexture(*(Texture2D *)texture);
  return r;
}
/** LoadImageFromScreen(params: void -> void *) */
void * sp_LoadImageFromScreen(void) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = LoadImageFromScreen();
  return r;
}
/** IsImageValid(params: void * image -> _Bool) */
_Bool sp_IsImageValid(void * image) {
  return IsImageValid(*(Image *)image);
}
/** UnloadImage(params: void * image -> void) */
void sp_UnloadImage(void * image) {
  Image *self = (Image *)image;
  UnloadImage(*self);
  free(self);
}
/** ExportImage(params: void * image, const char * fileName -> _Bool) */
_Bool sp_ExportImage(void * image, const char * fileName) {
  return ExportImage(*(Image *)image, fileName);
}
/** ExportImageToMemory(params: void * image, const char * fileType, void * fileSize -> void *) */
void * sp_ExportImageToMemory(void * image, const char * fileType, void * fileSize) {
  return ExportImageToMemory(*(Image *)image, fileType, fileSize);
}
/** ExportImageAsCode(params: void * image, const char * fileName -> _Bool) */
_Bool sp_ExportImageAsCode(void * image, const char * fileName) {
  return ExportImageAsCode(*(Image *)image, fileName);
}
/** GenImageColor(params: int width, int height, void * color -> void *) */
void * sp_GenImageColor(int width, int height, void * color) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GenImageColor(width, height, ((sp_Color*)color)->c);
  return r;
}
/** GenImageGradientLinear(params: int width, int height, int direction, void * start, void * end -> void *) */
void * sp_GenImageGradientLinear(int width, int height, int direction, void * start, void * end) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GenImageGradientLinear(width, height, direction, ((sp_Color*)start)->c, ((sp_Color*)end)->c);
  return r;
}
/** GenImageGradientRadial(params: int width, int height, float density, void * inner, void * outer -> void *) */
void * sp_GenImageGradientRadial(int width, int height, float density, void * inner, void * outer) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GenImageGradientRadial(width, height, density, ((sp_Color*)inner)->c, ((sp_Color*)outer)->c);
  return r;
}
/** GenImageGradientSquare(params: int width, int height, float density, void * inner, void * outer -> void *) */
void * sp_GenImageGradientSquare(int width, int height, float density, void * inner, void * outer) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GenImageGradientSquare(width, height, density, ((sp_Color*)inner)->c, ((sp_Color*)outer)->c);
  return r;
}
/** GenImageChecked(params: int width, int height, int checksX, int checksY, void * col1, void * col2 -> void *) */
void * sp_GenImageChecked(int width, int height, int checksX, int checksY, void * col1, void * col2) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GenImageChecked(width, height, checksX, checksY, ((sp_Color*)col1)->c, ((sp_Color*)col2)->c);
  return r;
}
/** GenImageWhiteNoise(params: int width, int height, float factor -> void *) */
void * sp_GenImageWhiteNoise(int width, int height, float factor) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GenImageWhiteNoise(width, height, factor);
  return r;
}
/** GenImagePerlinNoise(params: int width, int height, int offsetX, int offsetY, float scale -> void *) */
void * sp_GenImagePerlinNoise(int width, int height, int offsetX, int offsetY, float scale) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GenImagePerlinNoise(width, height, offsetX, offsetY, scale);
  return r;
}
/** GenImageCellular(params: int width, int height, int tileSize -> void *) */
void * sp_GenImageCellular(int width, int height, int tileSize) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GenImageCellular(width, height, tileSize);
  return r;
}
/** GenImageText(params: int width, int height, const char * text -> void *) */
void * sp_GenImageText(int width, int height, const char * text) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GenImageText(width, height, text);
  return r;
}
/** ImageCopy(params: void * image -> void *) */
void * sp_ImageCopy(void * image) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = ImageCopy(*(Image *)image);
  return r;
}
/** ImageFromImage(params: void * image, void * rec -> void *) */
void * sp_ImageFromImage(void * image, void * rec) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = ImageFromImage(*(Image *)image, ((sp_Rectangle*)rec)->v);
  return r;
}
/** ImageFromChannel(params: void * image, int selectedChannel -> void *) */
void * sp_ImageFromChannel(void * image, int selectedChannel) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = ImageFromChannel(*(Image *)image, selectedChannel);
  return r;
}
/** ImageText(params: const char * text, int fontSize, void * color -> void *) */
void * sp_ImageText(const char * text, int fontSize, void * color) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = ImageText(text, fontSize, ((sp_Color*)color)->c);
  return r;
}
/** ImageTextEx(params: void * font, const char * text, float fontSize, float spacing, void * tint -> void *) */
void * sp_ImageTextEx(void * font, const char * text, float fontSize, float spacing, void * tint) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = ImageTextEx(*(Font *)font, text, fontSize, spacing, ((sp_Color*)tint)->c);
  return r;
}
/** ImageToPOT(params: void * image, void * fill -> void) */
void sp_ImageToPOT(void * image, void * fill) {
  ImageToPOT(image, ((sp_Color*)fill)->c);
}
/** ImageCrop(params: void * image, void * crop -> void) */
void sp_ImageCrop(void * image, void * crop) {
  ImageCrop(image, ((sp_Rectangle*)crop)->v);
}
/** ImageAlphaClear(params: void * image, void * color, float threshold -> void) */
void sp_ImageAlphaClear(void * image, void * color, float threshold) {
  ImageAlphaClear(image, ((sp_Color*)color)->c, threshold);
}
/** ImageAlphaMask(params: void * image, void * alphaMask -> void) */
void sp_ImageAlphaMask(void * image, void * alphaMask) {
  ImageAlphaMask(image, *(Image *)alphaMask);
}
/** ImageResizeCanvas(params: void * image, int newWidth, int newHeight, int offsetX, int offsetY, void * fill -> void) */
void sp_ImageResizeCanvas(void * image, int newWidth, int newHeight, int offsetX, int offsetY, void * fill) {
  ImageResizeCanvas(image, newWidth, newHeight, offsetX, offsetY, ((sp_Color*)fill)->c);
}
/** ImageColorTint(params: void * image, void * color -> void) */
void sp_ImageColorTint(void * image, void * color) {
  ImageColorTint(image, ((sp_Color*)color)->c);
}
/** ImageColorReplace(params: void * image, void * color, void * replace -> void) */
void sp_ImageColorReplace(void * image, void * color, void * replace) {
  ImageColorReplace(image, ((sp_Color*)color)->c, ((sp_Color*)replace)->c);
}
/** LoadImageColors(params: void * image -> void *) */
void * sp_LoadImageColors(void * image) {
  return LoadImageColors(*(Image *)image);
}
/** LoadFileText as a raw char* handle so the pointer returned can be freed
 *  with sp_UnloadFileTextPtr. The flat `:str` binding copies the text into a
 *  Ruby String and loses the original pointer; UnloadFileText then frees a
 *  string literal/GC buffer and aborts. */
void * sp_LoadFileTextPtr(const char * fileName) {
  return LoadFileText(fileName);
}
/** UnloadFileText(params: void * text -> void) */
void sp_UnloadFileTextPtr(void * text) {
  UnloadFileText((char *)text);
}
/** Copy a NUL-terminated C string into a Ruby String (the pointer stays
 *  owned by raylib until sp_UnloadFileTextPtr). */
const char * sp_PtrToString(void * ptr) {
  return (const char *)ptr;
}
/** LoadImagePalette(params: void * image, int maxPaletteSize, void * colorCount -> void *) */
void * sp_LoadImagePalette(void * image, int maxPaletteSize, void * colorCount) {
  return LoadImagePalette(*(Image *)image, maxPaletteSize, colorCount);
}
/** UnloadImageColors(params: void * colors -> void) */
void sp_UnloadImageColors(void * colors) {
  /* LoadImageColors returns a raw Color* array (see sp_LoadImageColors and
   * sp_ImageColorR), not an sp_Color object. Passing the interior field
   * address here made free() abort with "invalid pointer". */
  UnloadImageColors((Color *)colors);
}
/** UnloadImagePalette(params: void * colors -> void) */
void sp_UnloadImagePalette(void * colors) {
  UnloadImagePalette((Color *)colors);
}
/** GetImageAlphaBorder(params: void * image, float threshold, void * _out -> void) */
void sp_GetImageAlphaBorder(void * image, float threshold, void * _out) {
  ((sp_Rectangle*)_out)->v = GetImageAlphaBorder(*(Image *)image, threshold);
}
/** GetImageColor(params: void * image, int x, int y, void * _out -> void) */
void sp_GetImageColor(void * image, int x, int y, void * _out) {
  ((sp_Color*)_out)->c = GetImageColor(*(Image *)image, x, y);
}
/** ImageClearBackground(params: void * dst, void * color -> void) */
void sp_ImageClearBackground(void * dst, void * color) {
  ImageClearBackground(dst, ((sp_Color*)color)->c);
}
/** ImageDrawPixel(params: void * dst, int posX, int posY, void * color -> void) */
void sp_ImageDrawPixel(void * dst, int posX, int posY, void * color) {
  ImageDrawPixel(dst, posX, posY, ((sp_Color*)color)->c);
}
/** ImageDrawPixelV(params: void * dst, void * position, void * color -> void) */
void sp_ImageDrawPixelV(void * dst, void * position, void * color) {
  ImageDrawPixelV(dst, ((sp_Vector2 *)position)->v, ((sp_Color*)color)->c);
}
/** ImageDrawLine(params: void * dst, int startPosX, int startPosY, int endPosX, int endPosY, void * color -> void) */
void sp_ImageDrawLine(void * dst, int startPosX, int startPosY, int endPosX, int endPosY, void * color) {
  ImageDrawLine(dst, startPosX, startPosY, endPosX, endPosY, ((sp_Color*)color)->c);
}
/** ImageDrawLineV(params: void * dst, void * start, void * end, void * color -> void) */
void sp_ImageDrawLineV(void * dst, void * start, void * end, void * color) {
  ImageDrawLineV(dst, ((sp_Vector2 *)start)->v, ((sp_Vector2 *)end)->v, ((sp_Color*)color)->c);
}
/** ImageDrawLineEx(params: void * dst, void * start, void * end, int thick, void * color -> void) */
void sp_ImageDrawLineEx(void * dst, void * start, void * end, int thick, void * color) {
  ImageDrawLineEx(dst, ((sp_Vector2 *)start)->v, ((sp_Vector2 *)end)->v, thick, ((sp_Color*)color)->c);
}
/** ImageDrawLineStrip(params: void * dst, void * points, int pointCount, void * color -> void) */
void sp_ImageDrawLineStrip(void * dst, void * points, int pointCount, void * color) {
  ImageDrawLineStrip(dst, points, pointCount, ((sp_Color*)color)->c);
}
/** ImageDrawTriangle(params: void * dst, void * v1, void * v2, void * v3, void * color -> void) */
void sp_ImageDrawTriangle(void * dst, void * v1, void * v2, void * v3, void * color) {
  ImageDrawTriangle(dst, ((sp_Vector2 *)v1)->v, ((sp_Vector2 *)v2)->v, ((sp_Vector2 *)v3)->v, ((sp_Color*)color)->c);
}
/** ImageDrawTriangleGradient(params: void * dst, void * v1, void * v2, void * v3, void * c1, void * c2, void * c3 -> void) */
void sp_ImageDrawTriangleGradient(void * dst, void * v1, void * v2, void * v3, void * c1, void * c2, void * c3) {
  ImageDrawTriangleGradient(dst, ((sp_Vector2 *)v1)->v, ((sp_Vector2 *)v2)->v, ((sp_Vector2 *)v3)->v, ((sp_Color*)c1)->c, ((sp_Color*)c2)->c, ((sp_Color*)c3)->c);
}
/** ImageDrawTriangleLines(params: void * dst, void * v1, void * v2, void * v3, void * color -> void) */
void sp_ImageDrawTriangleLines(void * dst, void * v1, void * v2, void * v3, void * color) {
  ImageDrawTriangleLines(dst, ((sp_Vector2 *)v1)->v, ((sp_Vector2 *)v2)->v, ((sp_Vector2 *)v3)->v, ((sp_Color*)color)->c);
}
/** ImageDrawTriangleFan(params: void * dst, void * points, int pointCount, void * color -> void) */
void sp_ImageDrawTriangleFan(void * dst, void * points, int pointCount, void * color) {
  ImageDrawTriangleFan(dst, points, pointCount, ((sp_Color*)color)->c);
}
/** ImageDrawTriangleStrip(params: void * dst, void * points, int pointCount, void * color -> void) */
void sp_ImageDrawTriangleStrip(void * dst, void * points, int pointCount, void * color) {
  ImageDrawTriangleStrip(dst, points, pointCount, ((sp_Color*)color)->c);
}
/** ImageDrawRectangle(params: void * dst, int posX, int posY, int width, int height, void * color -> void) */
void sp_ImageDrawRectangle(void * dst, int posX, int posY, int width, int height, void * color) {
  ImageDrawRectangle(dst, posX, posY, width, height, ((sp_Color*)color)->c);
}
/** ImageDrawRectangleV(params: void * dst, void * position, void * size, void * color -> void) */
void sp_ImageDrawRectangleV(void * dst, void * position, void * size, void * color) {
  ImageDrawRectangleV(dst, ((sp_Vector2 *)position)->v, ((sp_Vector2 *)size)->v, ((sp_Color*)color)->c);
}
/** ImageDrawRectangleRec(params: void * dst, void * rec, void * color -> void) */
void sp_ImageDrawRectangleRec(void * dst, void * rec, void * color) {
  ImageDrawRectangleRec(dst, ((sp_Rectangle*)rec)->v, ((sp_Color*)color)->c);
}
/** ImageDrawRectanglePro(params: void * dst, void * rec, void * origin, float rotation, void * color -> void) */
void sp_ImageDrawRectanglePro(void * dst, void * rec, void * origin, float rotation, void * color) {
  ImageDrawRectanglePro(dst, ((sp_Rectangle*)rec)->v, ((sp_Vector2 *)origin)->v, rotation, ((sp_Color*)color)->c);
}
/** ImageDrawRectangleLines(params: void * dst, int posX, int posY, int width, int height, void * color -> void) */
void sp_ImageDrawRectangleLines(void * dst, int posX, int posY, int width, int height, void * color) {
  ImageDrawRectangleLines(dst, posX, posY, width, height, ((sp_Color*)color)->c);
}
/** ImageDrawRectangleLinesEx(params: void * dst, void * rec, int thick, void * color -> void) */
void sp_ImageDrawRectangleLinesEx(void * dst, void * rec, int thick, void * color) {
  ImageDrawRectangleLinesEx(dst, ((sp_Rectangle*)rec)->v, thick, ((sp_Color*)color)->c);
}
/** ImageDrawRectangleGradientEx(params: void * dst, void * rec, void * col1, void * col2, void * col3, void * col4 -> void) */
void sp_ImageDrawRectangleGradientEx(void * dst, void * rec, void * col1, void * col2, void * col3, void * col4) {
  ImageDrawRectangleGradientEx(dst, ((sp_Rectangle*)rec)->v, ((sp_Color*)col1)->c, ((sp_Color*)col2)->c, ((sp_Color*)col3)->c, ((sp_Color*)col4)->c);
}
/** ImageDrawCircle(params: void * dst, int centerX, int centerY, int radius, void * color -> void) */
void sp_ImageDrawCircle(void * dst, int centerX, int centerY, int radius, void * color) {
  ImageDrawCircle(dst, centerX, centerY, radius, ((sp_Color*)color)->c);
}
/** ImageDrawCircleV(params: void * dst, void * center, int radius, void * color -> void) */
void sp_ImageDrawCircleV(void * dst, void * center, int radius, void * color) {
  ImageDrawCircleV(dst, ((sp_Vector2 *)center)->v, radius, ((sp_Color*)color)->c);
}
/** ImageDrawCircleLines(params: void * dst, int centerX, int centerY, int radius, void * color -> void) */
void sp_ImageDrawCircleLines(void * dst, int centerX, int centerY, int radius, void * color) {
  ImageDrawCircleLines(dst, centerX, centerY, radius, ((sp_Color*)color)->c);
}
/** ImageDrawCircleLinesV(params: void * dst, void * center, int radius, void * color -> void) */
void sp_ImageDrawCircleLinesV(void * dst, void * center, int radius, void * color) {
  ImageDrawCircleLinesV(dst, ((sp_Vector2 *)center)->v, radius, ((sp_Color*)color)->c);
}
/** ImageDrawCircleGradient(params: void * dst, void * center, float radius, void * inner, void * outer -> void) */
void sp_ImageDrawCircleGradient(void * dst, void * center, float radius, void * inner, void * outer) {
  ImageDrawCircleGradient(dst, ((sp_Vector2 *)center)->v, radius, ((sp_Color*)inner)->c, ((sp_Color*)outer)->c);
}
/** ImageDrawImage(params: void * dst, void * src, int posX, int posY, void * tint -> void) */
void sp_ImageDrawImage(void * dst, void * src, int posX, int posY, void * tint) {
  ImageDrawImage(dst, *(Image *)src, posX, posY, ((sp_Color*)tint)->c);
}
/** ImageDrawImageEx(params: void * dst, void * src, void * position, float rotation, float scale, void * tint -> void) */
void sp_ImageDrawImageEx(void * dst, void * src, void * position, float rotation, float scale, void * tint) {
  ImageDrawImageEx(dst, *(Image *)src, ((sp_Vector2 *)position)->v, rotation, scale, ((sp_Color*)tint)->c);
}
/** ImageDrawImageRec(params: void * dst, void * src, void * srcRec, void * position, void * tint -> void) */
void sp_ImageDrawImageRec(void * dst, void * src, void * srcRec, void * position, void * tint) {
  ImageDrawImageRec(dst, *(Image *)src, ((sp_Rectangle*)srcRec)->v, ((sp_Vector2 *)position)->v, ((sp_Color*)tint)->c);
}
/** ImageDrawImagePro(params: void * dst, void * src, void * srcRec, void * dstRec, void * origin, float rotation, void * tint -> void) */
void sp_ImageDrawImagePro(void * dst, void * src, void * srcRec, void * dstRec, void * origin, float rotation, void * tint) {
  ImageDrawImagePro(dst, *(Image *)src, ((sp_Rectangle*)srcRec)->v, ((sp_Rectangle*)dstRec)->v, ((sp_Vector2 *)origin)->v, rotation, ((sp_Color*)tint)->c);
}
/** ImageDrawText(params: void * dst, const char * text, int posX, int posY, int fontSize, void * color -> void) */
void sp_ImageDrawText(void * dst, const char * text, int posX, int posY, int fontSize, void * color) {
  ImageDrawText(dst, text, posX, posY, fontSize, ((sp_Color*)color)->c);
}
/** ImageDrawTextEx(params: void * dst, void * font, const char * text, void * position, float fontSize, float spacing, void * tint -> void) */
void sp_ImageDrawTextEx(void * dst, void * font, const char * text, void * position, float fontSize, float spacing, void * tint) {
  ImageDrawTextEx(dst, *(Font *)font, text, ((sp_Vector2 *)position)->v, fontSize, spacing, ((sp_Color*)tint)->c);
}
/** ImageDrawTextPro(params: void * dst, void * font, const char * text, void * position, void * origin, float rotation, float fontSize, float spacing, void * tint -> void) */
void sp_ImageDrawTextPro(void * dst, void * font, const char * text, void * position, void * origin, float rotation, float fontSize, float spacing, void * tint) {
  ImageDrawTextPro(dst, *(Font *)font, text, ((sp_Vector2 *)position)->v, ((sp_Vector2 *)origin)->v, rotation, fontSize, spacing, ((sp_Color*)tint)->c);
}
/** LoadTextureFromImage(params: void * image -> void *) */
void * sp_LoadTextureFromImage(void * image) {
  Texture2D *r = (Texture2D *)malloc(sizeof(Texture2D));
  *r = LoadTextureFromImage(*(Image *)image);
  return r;
}
/** LoadTextureCubemap(params: void * image, int layout -> void *) */
void * sp_LoadTextureCubemap(void * image, int layout) {
  TextureCubemap *r = (TextureCubemap *)malloc(sizeof(TextureCubemap));
  *r = LoadTextureCubemap(*(Image *)image, layout);
  return r;
}
/** LoadRenderTexture(params: int width, int height -> void *) */
void * sp_LoadRenderTexture(int width, int height) {
  RenderTexture2D *r = (RenderTexture2D *)malloc(sizeof(RenderTexture2D));
  *r = LoadRenderTexture(width, height);
  return r;
}
/** LoadRenderTextureEx(params: int width, int height, int format -> void *) */
void * sp_LoadRenderTextureEx(int width, int height, int format) {
  RenderTexture2D *r = (RenderTexture2D *)malloc(sizeof(RenderTexture2D));
  *r = LoadRenderTextureEx(width, height, format);
  return r;
}
/** IsTextureValid(params: void * texture -> _Bool) */
_Bool sp_IsTextureValid(void * texture) {
  return IsTextureValid(*(Texture2D *)texture);
}
/** IsRenderTextureValid(params: void * target -> _Bool) */
_Bool sp_IsRenderTextureValid(void * target) {
  return IsRenderTextureValid(*(RenderTexture2D *)target);
}
/** UnloadRenderTexture(params: void * target -> void) */
void sp_UnloadRenderTexture(void * target) {
  UnloadRenderTexture(*(RenderTexture2D *)target);
}
/** UpdateTexture(params: void * texture, void * pixels -> void) */
void sp_UpdateTexture(void * texture, void * pixels) {
  UpdateTexture(*(Texture2D *)texture, pixels);
}
/** UpdateTextureRec(params: void * texture, void * rec, void * pixels -> void) */
void sp_UpdateTextureRec(void * texture, void * rec, void * pixels) {
  UpdateTextureRec(*(Texture2D *)texture, ((sp_Rectangle*)rec)->v, pixels);
}
/** SetTextureFilter(params: void * texture, int filter -> void) */
void sp_SetTextureFilter(void * texture, int filter) {
  SetTextureFilter(*(Texture2D *)texture, filter);
}
/** SetTextureWrap(params: void * texture, int wrap -> void) */
void sp_SetTextureWrap(void * texture, int wrap) {
  SetTextureWrap(*(Texture2D *)texture, wrap);
}
/** DrawTextureV(params: void * texture, void * position, void * tint -> void) */
void sp_DrawTextureV(void * texture, void * position, void * tint) {
  DrawTextureV(*(Texture2D *)texture, ((sp_Vector2 *)position)->v, ((sp_Color*)tint)->c);
}
/** DrawTextureRec(params: void * texture, void * rec, void * position, void * tint -> void) */
void sp_DrawTextureRec(void * texture, void * rec, void * position, void * tint) {
  DrawTextureRec(*(Texture2D *)texture, ((sp_Rectangle*)rec)->v, ((sp_Vector2 *)position)->v, ((sp_Color*)tint)->c);
}
/** DrawTexturePro(params: void * texture, void * srcrec, void * dstrec, void * origin, float rotation, void * tint -> void) */
void sp_DrawTexturePro(void * texture, void * srcrec, void * dstrec, void * origin, float rotation, void * tint) {
  DrawTexturePro(*(Texture2D *)texture, ((sp_Rectangle*)srcrec)->v, ((sp_Rectangle*)dstrec)->v, ((sp_Vector2 *)origin)->v, rotation, ((sp_Color*)tint)->c);
}
/** DrawTextureNPatch(params: void * texture, void * nPatchInfo, void * dstrec, void * origin, float rotation, void * tint -> void) */
void sp_DrawTextureNPatch(void * texture, void * nPatchInfo, void * dstrec, void * origin, float rotation, void * tint) {
  DrawTextureNPatch(*(Texture2D *)texture, ((sp_NPatchInfo*)nPatchInfo)->v, ((sp_Rectangle*)dstrec)->v, ((sp_Vector2 *)origin)->v, rotation, ((sp_Color*)tint)->c);
}
/** ColorIsEqual(params: void * col1, void * col2 -> _Bool) */
_Bool sp_ColorIsEqual(void * col1, void * col2) {
  return ColorIsEqual(((sp_Color*)col1)->c, ((sp_Color*)col2)->c);
}
/** Fade(params: void * color, float alpha, void * _out -> void) */
void sp_Fade(void * color, float alpha, void * _out) {
  ((sp_Color*)_out)->c = Fade(((sp_Color*)color)->c, alpha);
}
/** ColorToInt(params: void * color -> int) */
int sp_ColorToInt(void * color) {
  return ColorToInt(((sp_Color*)color)->c);
}
/** ColorNormalize(params: void * color, void * _out -> void) */
void sp_ColorNormalize(void * color, void * _out) {
  ((sp_Vector4*)_out)->v = ColorNormalize(((sp_Color*)color)->c);
}
/** ColorFromNormalized(params: void * normalized, void * _out -> void) */
void sp_ColorFromNormalized(void * normalized, void * _out) {
  ((sp_Color*)_out)->c = ColorFromNormalized(((sp_Vector4*)normalized)->v);
}
/** ColorToHSV(params: void * color, void * _out -> void) */
void sp_ColorToHSV(void * color, void * _out) {
  ((sp_Vector3*)_out)->v = ColorToHSV(((sp_Color*)color)->c);
}
/** ColorFromHSV(params: float hue, float saturation, float value, void * _out -> void) */
void sp_ColorFromHSV(float hue, float saturation, float value, void * _out) {
  ((sp_Color*)_out)->c = ColorFromHSV(hue, saturation, value);
}
/** ColorTint(params: void * color, void * tint, void * _out -> void) */
void sp_ColorTint(void * color, void * tint, void * _out) {
  ((sp_Color*)_out)->c = ColorTint(((sp_Color*)color)->c, ((sp_Color*)tint)->c);
}
/** ColorBrightness(params: void * color, float factor, void * _out -> void) */
void sp_ColorBrightness(void * color, float factor, void * _out) {
  ((sp_Color*)_out)->c = ColorBrightness(((sp_Color*)color)->c, factor);
}
/** ColorContrast(params: void * color, float contrast, void * _out -> void) */
void sp_ColorContrast(void * color, float contrast, void * _out) {
  ((sp_Color*)_out)->c = ColorContrast(((sp_Color*)color)->c, contrast);
}
/** ColorAlpha(params: void * color, float alpha, void * _out -> void) */
void sp_ColorAlpha(void * color, float alpha, void * _out) {
  ((sp_Color*)_out)->c = ColorAlpha(((sp_Color*)color)->c, alpha);
}
/** ColorAlphaBlend(params: void * dst, void * src, void * tint, void * _out -> void) */
void sp_ColorAlphaBlend(void * dst, void * src, void * tint, void * _out) {
  ((sp_Color*)_out)->c = ColorAlphaBlend(((sp_Color*)dst)->c, ((sp_Color*)src)->c, ((sp_Color*)tint)->c);
}
/** ColorLerp(params: void * color1, void * color2, float factor, void * _out -> void) */
void sp_ColorLerp(void * color1, void * color2, float factor, void * _out) {
  ((sp_Color*)_out)->c = ColorLerp(((sp_Color*)color1)->c, ((sp_Color*)color2)->c, factor);
}
/** GetColor(params: uint32_t hexValue, void * _out -> void) */
void sp_GetColor(uint32_t hexValue, void * _out) {
  ((sp_Color*)_out)->c = GetColor(hexValue);
}
/** GetPixelColor(params: void * srcPtr, int format, void * _out -> void) */
void sp_GetPixelColor(void * srcPtr, int format, void * _out) {
  ((sp_Color*)_out)->c = GetPixelColor(srcPtr, format);
}
/** SetPixelColor(params: void * dstPtr, void * color, int format -> void) */
void sp_SetPixelColor(void * dstPtr, void * color, int format) {
  SetPixelColor(dstPtr, ((sp_Color*)color)->c, format);
}
/** GetFontDefault(params: void -> void *) */
void * sp_GetFontDefault(void) {
  Font *r = (Font *)malloc(sizeof(Font));
  *r = GetFontDefault();
  return r;
}
/** LoadFont(params: const char * fileName -> void *) */
void * sp_LoadFont(const char * fileName) {
  Font *r = (Font *)malloc(sizeof(Font));
  *r = LoadFont(fileName);
  return r;
}
/** LoadFontEx(params: const char * fileName, int fontSize, void * codepoints, int codepointCount -> void *) */
void * sp_LoadFontEx(const char * fileName, int fontSize, void * codepoints, int codepointCount) {
  Font *r = (Font *)malloc(sizeof(Font));
  *r = LoadFontEx(fileName, fontSize, codepoints, codepointCount);
  return r;
}
/** LoadFontFromImage(params: void * image, void * key, int firstChar -> void *) */
void * sp_LoadFontFromImage(void * image, void * key, int firstChar) {
  Font *r = (Font *)malloc(sizeof(Font));
  *r = LoadFontFromImage(*(Image *)image, ((sp_Color*)key)->c, firstChar);
  return r;
}
/** LoadFontFromMemory(params: const char * fileType, void * fileData, int dataSize, int fontSize, void * codepoints, int codepointCount -> void *) */
void * sp_LoadFontFromMemory(const char * fileType, void * fileData, int dataSize, int fontSize, void * codepoints, int codepointCount) {
  Font *r = (Font *)malloc(sizeof(Font));
  *r = LoadFontFromMemory(fileType, fileData, dataSize, fontSize, codepoints, codepointCount);
  return r;
}
/** IsFontValid(params: void * font -> _Bool) */
_Bool sp_IsFontValid(void * font) {
  return IsFontValid(*(Font *)font);
}
/** GenImageFontAtlas(params: void * glyphs, void * glyphRecs, int glyphCount, int fontSize, int padding, int packMethod -> void *) */
void * sp_GenImageFontAtlas(void * glyphs, void * glyphRecs, int glyphCount, int fontSize, int padding, int packMethod) {
  Image *r = (Image *)malloc(sizeof(Image));
  *r = GenImageFontAtlas(glyphs, glyphRecs, glyphCount, fontSize, padding, packMethod);
  return r;
}
/** UnloadFont(params: void * font -> void) */
void sp_UnloadFont(void * font) {
  Font *self = (Font *)font;
  UnloadFont(*self);
  free(self);
}
/** ExportFontAsCode(params: void * font, const char * fileName -> _Bool) */
_Bool sp_ExportFontAsCode(void * font, const char * fileName) {
  return ExportFontAsCode(*(Font *)font, fileName);
}
/** DrawTextEx(params: void * font, const char * text, void * position, float fontSize, float spacing, void * tint -> void) */
void sp_DrawTextEx(void * font, const char * text, void * position, float fontSize, float spacing, void * tint) {
  DrawTextEx(*(Font *)font, text, ((sp_Vector2 *)position)->v, fontSize, spacing, ((sp_Color*)tint)->c);
}
/** DrawTextPro(params: void * font, const char * text, void * position, void * origin, float rotation, float fontSize, float spacing, void * tint -> void) */
void sp_DrawTextPro(void * font, const char * text, void * position, void * origin, float rotation, float fontSize, float spacing, void * tint) {
  DrawTextPro(*(Font *)font, text, ((sp_Vector2 *)position)->v, ((sp_Vector2 *)origin)->v, rotation, fontSize, spacing, ((sp_Color*)tint)->c);
}
/** DrawTextCodepoint(params: void * font, int codepoint, void * position, float fontSize, void * tint -> void) */
void sp_DrawTextCodepoint(void * font, int codepoint, void * position, float fontSize, void * tint) {
  DrawTextCodepoint(*(Font *)font, codepoint, ((sp_Vector2 *)position)->v, fontSize, ((sp_Color*)tint)->c);
}
/** DrawTextCodepoints(params: void * font, void * codepoints, int codepointCount, void * position, float fontSize, float spacing, void * tint -> void) */
void sp_DrawTextCodepoints(void * font, void * codepoints, int codepointCount, void * position, float fontSize, float spacing, void * tint) {
  DrawTextCodepoints(*(Font *)font, codepoints, codepointCount, ((sp_Vector2 *)position)->v, fontSize, spacing, ((sp_Color*)tint)->c);
}
/** MeasureTextEx(params: void * font, const char * text, float fontSize, float spacing, void * _out -> void) */
void sp_MeasureTextEx(void * font, const char * text, float fontSize, float spacing, void * _out) {
  ((sp_Vector2*)_out)->v = MeasureTextEx(*(Font *)font, text, fontSize, spacing);
}
/** MeasureTextCodepoints(params: void * font, void * codepoints, int length, float fontSize, float spacing, void * _out -> void) */
void sp_MeasureTextCodepoints(void * font, void * codepoints, int length, float fontSize, float spacing, void * _out) {
  ((sp_Vector2*)_out)->v = MeasureTextCodepoints(*(Font *)font, codepoints, length, fontSize, spacing);
}
/** GetGlyphIndex(params: void * font, int codepoint -> int) */
int sp_GetGlyphIndex(void * font, int codepoint) {
  return GetGlyphIndex(*(Font *)font, codepoint);
}
/** GetGlyphInfo(params: void * font, int codepoint -> void *) */
void * sp_GetGlyphInfo(void * font, int codepoint) {
  GlyphInfo *r = (GlyphInfo *)malloc(sizeof(GlyphInfo));
  *r = GetGlyphInfo(*(Font *)font, codepoint);
  return r;
}
/** GetGlyphAtlasRec(params: void * font, int codepoint, void * _out -> void) */
void sp_GetGlyphAtlasRec(void * font, int codepoint, void * _out) {
  ((sp_Rectangle*)_out)->v = GetGlyphAtlasRec(*(Font *)font, codepoint);
}
/** DrawLine3D(params: void * startPos, void * endPos, void * color -> void) */
void sp_DrawLine3D(void * startPos, void * endPos, void * color) {
  DrawLine3D(((sp_Vector3*)startPos)->v, ((sp_Vector3*)endPos)->v, ((sp_Color*)color)->c);
}
/** DrawPoint3D(params: void * position, void * color -> void) */
void sp_DrawPoint3D(void * position, void * color) {
  DrawPoint3D(((sp_Vector3*)position)->v, ((sp_Color*)color)->c);
}
/** DrawCircle3D(params: void * center, float radius, void * rotationAxis, float rotationAngle, void * color -> void) */
void sp_DrawCircle3D(void * center, float radius, void * rotationAxis, float rotationAngle, void * color) {
  DrawCircle3D(((sp_Vector3*)center)->v, radius, ((sp_Vector3*)rotationAxis)->v, rotationAngle, ((sp_Color*)color)->c);
}
/** DrawTriangle3D(params: void * v1, void * v2, void * v3, void * color -> void) */
void sp_DrawTriangle3D(void * v1, void * v2, void * v3, void * color) {
  DrawTriangle3D(((sp_Vector3*)v1)->v, ((sp_Vector3*)v2)->v, ((sp_Vector3*)v3)->v, ((sp_Color*)color)->c);
}
/** DrawTriangleStrip3D(params: void * points, int pointCount, void * color -> void) */
void sp_DrawTriangleStrip3D(void * points, int pointCount, void * color) {
  DrawTriangleStrip3D(points, pointCount, ((sp_Color*)color)->c);
}
/** DrawCubeV(params: void * position, void * size, void * color -> void) */
void sp_DrawCubeV(void * position, void * size, void * color) {
  DrawCubeV(((sp_Vector3*)position)->v, ((sp_Vector3*)size)->v, ((sp_Color*)color)->c);
}
/** DrawCubeWiresV(params: void * position, void * size, void * color -> void) */
void sp_DrawCubeWiresV(void * position, void * size, void * color) {
  DrawCubeWiresV(((sp_Vector3*)position)->v, ((sp_Vector3*)size)->v, ((sp_Color*)color)->c);
}
/** DrawSphere(params: void * centerPos, float radius, void * color -> void) */
void sp_DrawSphere(void * centerPos, float radius, void * color) {
  DrawSphere(((sp_Vector3*)centerPos)->v, radius, ((sp_Color*)color)->c);
}
/** DrawSphereEx(params: void * centerPos, float radius, int rings, int slices, void * color -> void) */
void sp_DrawSphereEx(void * centerPos, float radius, int rings, int slices, void * color) {
  DrawSphereEx(((sp_Vector3*)centerPos)->v, radius, rings, slices, ((sp_Color*)color)->c);
}
/** DrawSphereWires(params: void * centerPos, float radius, int rings, int slices, void * color -> void) */
void sp_DrawSphereWires(void * centerPos, float radius, int rings, int slices, void * color) {
  DrawSphereWires(((sp_Vector3*)centerPos)->v, radius, rings, slices, ((sp_Color*)color)->c);
}
/** DrawCylinder(params: void * position, float radiusTop, float radiusBottom, float height, int sides, void * color -> void) */
void sp_DrawCylinder(void * position, float radiusTop, float radiusBottom, float height, int sides, void * color) {
  DrawCylinder(((sp_Vector3*)position)->v, radiusTop, radiusBottom, height, sides, ((sp_Color*)color)->c);
}
/** DrawCylinderEx(params: void * startPos, void * endPos, float startRadius, float endRadius, int sides, void * color -> void) */
void sp_DrawCylinderEx(void * startPos, void * endPos, float startRadius, float endRadius, int sides, void * color) {
  DrawCylinderEx(((sp_Vector3*)startPos)->v, ((sp_Vector3*)endPos)->v, startRadius, endRadius, sides, ((sp_Color*)color)->c);
}
/** DrawCylinderWires(params: void * position, float radiusTop, float radiusBottom, float height, int sides, void * color -> void) */
void sp_DrawCylinderWires(void * position, float radiusTop, float radiusBottom, float height, int sides, void * color) {
  DrawCylinderWires(((sp_Vector3*)position)->v, radiusTop, radiusBottom, height, sides, ((sp_Color*)color)->c);
}
/** DrawCylinderWiresEx(params: void * startPos, void * endPos, float startRadius, float endRadius, int sides, void * color -> void) */
void sp_DrawCylinderWiresEx(void * startPos, void * endPos, float startRadius, float endRadius, int sides, void * color) {
  DrawCylinderWiresEx(((sp_Vector3*)startPos)->v, ((sp_Vector3*)endPos)->v, startRadius, endRadius, sides, ((sp_Color*)color)->c);
}
/** DrawCapsule(params: void * startPos, void * endPos, float radius, int rings, int slices, void * color -> void) */
void sp_DrawCapsule(void * startPos, void * endPos, float radius, int rings, int slices, void * color) {
  DrawCapsule(((sp_Vector3*)startPos)->v, ((sp_Vector3*)endPos)->v, radius, rings, slices, ((sp_Color*)color)->c);
}
/** DrawCapsuleWires(params: void * startPos, void * endPos, float radius, int rings, int slices, void * color -> void) */
void sp_DrawCapsuleWires(void * startPos, void * endPos, float radius, int rings, int slices, void * color) {
  DrawCapsuleWires(((sp_Vector3*)startPos)->v, ((sp_Vector3*)endPos)->v, radius, rings, slices, ((sp_Color*)color)->c);
}
/** DrawRay(params: void * ray, void * color -> void) */
void sp_DrawRay(void * ray, void * color) {
  DrawRay(((sp_Ray*)ray)->v, ((sp_Color*)color)->c);
}
/** LoadModel(params: const char * fileName -> void *) */
void * sp_LoadModel(const char * fileName) {
  Model *r = (Model *)malloc(sizeof(Model));
  *r = LoadModel(fileName);
  return r;
}
/** LoadModelFromMesh(params: void * mesh -> void *) */
void * sp_LoadModelFromMesh(void * mesh) {
  Model *r = (Model *)malloc(sizeof(Model));
  *r = LoadModelFromMesh(*(Mesh *)mesh);
  return r;
}
/** IsModelValid(params: void * model -> _Bool) */
_Bool sp_IsModelValid(void * model) {
  return IsModelValid(*(Model *)model);
}
/** UnloadModel(params: void * model -> void) */
void sp_UnloadModel(void * model) {
  Model *self = (Model *)model;
  UnloadModel(*self);
  free(self);
}
/** GetModelBoundingBox(params: void * model, void * _out -> void) */
void sp_GetModelBoundingBox(void * model, void * _out) {
  ((sp_BoundingBox*)_out)->v = GetModelBoundingBox(*(Model *)model);
}
/** DrawModel(params: void * model, void * position, float scale, void * tint -> void) */
void sp_DrawModel(void * model, void * position, float scale, void * tint) {
  DrawModel(*(Model *)model, ((sp_Vector3*)position)->v, scale, ((sp_Color*)tint)->c);
}
/** DrawModelEx(params: void * model, void * position, void * rotationAxis, float rotationAngle, void * scale, void * tint -> void) */
void sp_DrawModelEx(void * model, void * position, void * rotationAxis, float rotationAngle, void * scale, void * tint) {
  DrawModelEx(*(Model *)model, ((sp_Vector3*)position)->v, ((sp_Vector3*)rotationAxis)->v, rotationAngle, ((sp_Vector3*)scale)->v, ((sp_Color*)tint)->c);
}
/** DrawModelWires(params: void * model, void * position, float scale, void * tint -> void) */
void sp_DrawModelWires(void * model, void * position, float scale, void * tint) {
  DrawModelWires(*(Model *)model, ((sp_Vector3*)position)->v, scale, ((sp_Color*)tint)->c);
}
/** DrawModelWiresEx(params: void * model, void * position, void * rotationAxis, float rotationAngle, void * scale, void * tint -> void) */
void sp_DrawModelWiresEx(void * model, void * position, void * rotationAxis, float rotationAngle, void * scale, void * tint) {
  DrawModelWiresEx(*(Model *)model, ((sp_Vector3*)position)->v, ((sp_Vector3*)rotationAxis)->v, rotationAngle, ((sp_Vector3*)scale)->v, ((sp_Color*)tint)->c);
}
/** DrawBoundingBox(params: void * box, void * color -> void) */
void sp_DrawBoundingBox(void * box, void * color) {
  DrawBoundingBox(((sp_BoundingBox*)box)->v, ((sp_Color*)color)->c);
}
/** DrawBillboard(params: void * camera, void * texture, void * position, float scale, void * tint -> void) */
void sp_DrawBillboard(void * camera, void * texture, void * position, float scale, void * tint) {
  DrawBillboard(((sp_Camera*)camera)->c, *(Texture2D *)texture, ((sp_Vector3*)position)->v, scale, ((sp_Color*)tint)->c);
}
/** DrawBillboardRec(params: void * camera, void * texture, void * rec, void * position, void * size, void * tint -> void) */
void sp_DrawBillboardRec(void * camera, void * texture, void * rec, void * position, void * size, void * tint) {
  DrawBillboardRec(((sp_Camera*)camera)->c, *(Texture2D *)texture, ((sp_Rectangle*)rec)->v, ((sp_Vector3*)position)->v, ((sp_Vector2 *)size)->v, ((sp_Color*)tint)->c);
}
/** DrawBillboardPro(params: void * camera, void * texture, void * rec, void * position, void * up, void * size, void * origin, float rotation, void * tint -> void) */
void sp_DrawBillboardPro(void * camera, void * texture, void * rec, void * position, void * up, void * size, void * origin, float rotation, void * tint) {
  DrawBillboardPro(((sp_Camera*)camera)->c, *(Texture2D *)texture, ((sp_Rectangle*)rec)->v, ((sp_Vector3*)position)->v, ((sp_Vector3*)up)->v, ((sp_Vector2 *)size)->v, ((sp_Vector2 *)origin)->v, rotation, ((sp_Color*)tint)->c);
}
/** UpdateMeshBuffer(params: void * mesh, int index, void * data, int dataSize, int offset -> void) */
void sp_UpdateMeshBuffer(void * mesh, int index, void * data, int dataSize, int offset) {
  UpdateMeshBuffer(*(Mesh *)mesh, index, data, dataSize, offset);
}
/** UnloadMesh(params: void * mesh -> void) */
void sp_UnloadMesh(void * mesh) {
  Mesh *self = (Mesh *)mesh;
  UnloadMesh(*self);
  free(self);
}
/** DrawMesh(params: void * mesh, void * material, void * transform -> void) */
void sp_DrawMesh(void * mesh, void * material, void * transform) {
  DrawMesh(*(Mesh *)mesh, *(Material *)material, ((sp_Matrix*)transform)->v);
}
/** DrawMeshInstanced(params: void * mesh, void * material, void * transforms, int instances -> void) */
void sp_DrawMeshInstanced(void * mesh, void * material, void * transforms, int instances) {
  DrawMeshInstanced(*(Mesh *)mesh, *(Material *)material, transforms, instances);
}
/** GetMeshBoundingBox(params: void * mesh, void * _out -> void) */
void sp_GetMeshBoundingBox(void * mesh, void * _out) {
  ((sp_BoundingBox*)_out)->v = GetMeshBoundingBox(*(Mesh *)mesh);
}
/** ExportMesh(params: void * mesh, const char * fileName -> _Bool) */
_Bool sp_ExportMesh(void * mesh, const char * fileName) {
  return ExportMesh(*(Mesh *)mesh, fileName);
}
/** ExportMeshAsCode(params: void * mesh, const char * fileName -> _Bool) */
_Bool sp_ExportMeshAsCode(void * mesh, const char * fileName) {
  return ExportMeshAsCode(*(Mesh *)mesh, fileName);
}
/** GenMeshPoly(params: int sides, float radius -> void *) */
void * sp_GenMeshPoly(int sides, float radius) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshPoly(sides, radius);
  return r;
}
/** GenMeshPlane(params: float width, float length, int resX, int resZ -> void *) */
void * sp_GenMeshPlane(float width, float length, int resX, int resZ) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshPlane(width, length, resX, resZ);
  return r;
}
/** GenMeshCube(params: float width, float height, float length -> void *) */
void * sp_GenMeshCube(float width, float height, float length) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshCube(width, height, length);
  return r;
}
/** GenMeshSphere(params: float radius, int rings, int slices -> void *) */
void * sp_GenMeshSphere(float radius, int rings, int slices) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshSphere(radius, rings, slices);
  return r;
}
/** GenMeshHemiSphere(params: float radius, int rings, int slices -> void *) */
void * sp_GenMeshHemiSphere(float radius, int rings, int slices) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshHemiSphere(radius, rings, slices);
  return r;
}
/** GenMeshCylinder(params: float radius, float height, int slices -> void *) */
void * sp_GenMeshCylinder(float radius, float height, int slices) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshCylinder(radius, height, slices);
  return r;
}
/** GenMeshCone(params: float radius, float height, int slices -> void *) */
void * sp_GenMeshCone(float radius, float height, int slices) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshCone(radius, height, slices);
  return r;
}
/** GenMeshTorus(params: float radius, float size, int radSeg, int sides -> void *) */
void * sp_GenMeshTorus(float radius, float size, int radSeg, int sides) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshTorus(radius, size, radSeg, sides);
  return r;
}
/** GenMeshKnot(params: float radius, float size, int radSeg, int sides -> void *) */
void * sp_GenMeshKnot(float radius, float size, int radSeg, int sides) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshKnot(radius, size, radSeg, sides);
  return r;
}
/** GenMeshHeightmap(params: void * heightmap, void * size -> void *) */
void * sp_GenMeshHeightmap(void * heightmap, void * size) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshHeightmap(*(Image *)heightmap, ((sp_Vector3*)size)->v);
  return r;
}
/** GenMeshCubicmap(params: void * cubicmap, void * cubeSize -> void *) */
void * sp_GenMeshCubicmap(void * cubicmap, void * cubeSize) {
  Mesh *r = (Mesh *)malloc(sizeof(Mesh));
  *r = GenMeshCubicmap(*(Image *)cubicmap, ((sp_Vector3*)cubeSize)->v);
  return r;
}
/** LoadMaterialDefault(params: void -> void *) */
void * sp_LoadMaterialDefault(void) {
  Material *r = (Material *)malloc(sizeof(Material));
  *r = LoadMaterialDefault();
  return r;
}
/** IsMaterialValid(params: void * material -> _Bool) */
_Bool sp_IsMaterialValid(void * material) {
  return IsMaterialValid(*(Material *)material);
}
/** UnloadMaterial(params: void * material -> void) */
void sp_UnloadMaterial(void * material) {
  Material *self = (Material *)material;
  UnloadMaterial(*self);
  free(self);
}
/** SetMaterialTexture(params: void * material, int mapType, void * texture -> void) */
void sp_SetMaterialTexture(void * material, int mapType, void * texture) {
  SetMaterialTexture(material, mapType, *(Texture2D *)texture);
}
/** UpdateModelAnimation(params: void * model, void * anim, float frame -> void) */
void sp_UpdateModelAnimation(void * model, void * anim, float frame) {
  UpdateModelAnimation(*(Model *)model, *(ModelAnimation *)anim, frame);
}
/** UpdateModelAnimationEx(params: void * model, void * animA, float frameA, void * animB, float frameB, float blend -> void) */
void sp_UpdateModelAnimationEx(void * model, void * animA, float frameA, void * animB, float frameB, float blend) {
  UpdateModelAnimationEx(*(Model *)model, *(ModelAnimation *)animA, frameA, *(ModelAnimation *)animB, frameB, blend);
}
/** IsModelAnimationValid(params: void * model, void * anim -> _Bool) */
_Bool sp_IsModelAnimationValid(void * model, void * anim) {
  return IsModelAnimationValid(*(Model *)model, *(ModelAnimation *)anim);
}
/** CheckCollisionSpheres(params: void * center1, float radius1, void * center2, float radius2 -> _Bool) */
_Bool sp_CheckCollisionSpheres(void * center1, float radius1, void * center2, float radius2) {
  return CheckCollisionSpheres(((sp_Vector3*)center1)->v, radius1, ((sp_Vector3*)center2)->v, radius2);
}
/** CheckCollisionBoxes(params: void * box1, void * box2 -> _Bool) */
_Bool sp_CheckCollisionBoxes(void * box1, void * box2) {
  return CheckCollisionBoxes(((sp_BoundingBox*)box1)->v, ((sp_BoundingBox*)box2)->v);
}
/** CheckCollisionBoxSphere(params: void * box, void * center, float radius -> _Bool) */
_Bool sp_CheckCollisionBoxSphere(void * box, void * center, float radius) {
  return CheckCollisionBoxSphere(((sp_BoundingBox*)box)->v, ((sp_Vector3*)center)->v, radius);
}
/** GetRayCollisionSphere(params: void * ray, void * center, float radius, void * _out -> void) */
void sp_GetRayCollisionSphere(void * ray, void * center, float radius, void * _out) {
  ((sp_RayCollision*)_out)->v = GetRayCollisionSphere(((sp_Ray*)ray)->v, ((sp_Vector3*)center)->v, radius);
}
/** GetRayCollisionBox(params: void * ray, void * box, void * _out -> void) */
void sp_GetRayCollisionBox(void * ray, void * box, void * _out) {
  ((sp_RayCollision*)_out)->v = GetRayCollisionBox(((sp_Ray*)ray)->v, ((sp_BoundingBox*)box)->v);
}
/** GetRayCollisionMesh(params: void * ray, void * mesh, void * transform, void * _out -> void) */
void sp_GetRayCollisionMesh(void * ray, void * mesh, void * transform, void * _out) {
  ((sp_RayCollision*)_out)->v = GetRayCollisionMesh(((sp_Ray*)ray)->v, *(Mesh *)mesh, ((sp_Matrix*)transform)->v);
}
/** GetRayCollisionTriangle(params: void * ray, void * p1, void * p2, void * p3, void * _out -> void) */
void sp_GetRayCollisionTriangle(void * ray, void * p1, void * p2, void * p3, void * _out) {
  ((sp_RayCollision*)_out)->v = GetRayCollisionTriangle(((sp_Ray*)ray)->v, ((sp_Vector3*)p1)->v, ((sp_Vector3*)p2)->v, ((sp_Vector3*)p3)->v);
}
/** GetRayCollisionQuad(params: void * ray, void * p1, void * p2, void * p3, void * p4, void * _out -> void) */
void sp_GetRayCollisionQuad(void * ray, void * p1, void * p2, void * p3, void * p4, void * _out) {
  ((sp_RayCollision*)_out)->v = GetRayCollisionQuad(((sp_Ray*)ray)->v, ((sp_Vector3*)p1)->v, ((sp_Vector3*)p2)->v, ((sp_Vector3*)p3)->v, ((sp_Vector3*)p4)->v);
}
/** LoadWave(params: const char * fileName -> void *) */
void * sp_LoadWave(const char * fileName) {
  Wave *r = (Wave *)malloc(sizeof(Wave));
  *r = LoadWave(fileName);
  return r;
}
/** LoadWaveFromMemory(params: const char * fileType, void * fileData, int dataSize -> void *) */
void * sp_LoadWaveFromMemory(const char * fileType, void * fileData, int dataSize) {
  Wave *r = (Wave *)malloc(sizeof(Wave));
  *r = LoadWaveFromMemory(fileType, fileData, dataSize);
  return r;
}
/** IsWaveValid(params: void * wave -> _Bool) */
_Bool sp_IsWaveValid(void * wave) {
  return IsWaveValid(*(Wave *)wave);
}
/** LoadSound(params: const char * fileName -> void *) */
void * sp_LoadSound(const char * fileName) {
  Sound *r = (Sound *)malloc(sizeof(Sound));
  *r = LoadSound(fileName);
  return r;
}
/** LoadSoundFromWave(params: void * wave -> void *) */
void * sp_LoadSoundFromWave(void * wave) {
  Sound *r = (Sound *)malloc(sizeof(Sound));
  *r = LoadSoundFromWave(*(Wave *)wave);
  return r;
}
/** LoadSoundAlias(params: void * source -> void *) */
void * sp_LoadSoundAlias(void * source) {
  Sound *r = (Sound *)malloc(sizeof(Sound));
  *r = LoadSoundAlias(*(Sound *)source);
  return r;
}
/** IsSoundValid(params: void * sound -> _Bool) */
_Bool sp_IsSoundValid(void * sound) {
  return IsSoundValid(*(Sound *)sound);
}
/** UpdateSound(params: void * sound, void * data, int frameCount -> void) */
void sp_UpdateSound(void * sound, void * data, int frameCount) {
  UpdateSound(*(Sound *)sound, data, frameCount);
}
/** UnloadWave(params: void * wave -> void) */
void sp_UnloadWave(void * wave) {
  Wave *self = (Wave *)wave;
  UnloadWave(*self);
  free(self);
}
/** UnloadSound(params: void * sound -> void) */
void sp_UnloadSound(void * sound) {
  Sound *self = (Sound *)sound;
  UnloadSound(*self);
  free(self);
}
/** UnloadSoundAlias(params: void * alias -> void) */
void sp_UnloadSoundAlias(void * alias) {
  UnloadSoundAlias(*(Sound *)alias);
}
/** ExportWave(params: void * wave, const char * fileName -> _Bool) */
_Bool sp_ExportWave(void * wave, const char * fileName) {
  return ExportWave(*(Wave *)wave, fileName);
}
/** ExportWaveAsCode(params: void * wave, const char * fileName -> _Bool) */
_Bool sp_ExportWaveAsCode(void * wave, const char * fileName) {
  return ExportWaveAsCode(*(Wave *)wave, fileName);
}
/** PlaySound(params: void * sound -> void) */
void sp_PlaySound(void * sound) {
  PlaySound(*(Sound *)sound);
}
/** StopSound(params: void * sound -> void) */
void sp_StopSound(void * sound) {
  StopSound(*(Sound *)sound);
}
/** PauseSound(params: void * sound -> void) */
void sp_PauseSound(void * sound) {
  PauseSound(*(Sound *)sound);
}
/** ResumeSound(params: void * sound -> void) */
void sp_ResumeSound(void * sound) {
  ResumeSound(*(Sound *)sound);
}
/** IsSoundPlaying(params: void * sound -> _Bool) */
_Bool sp_IsSoundPlaying(void * sound) {
  return IsSoundPlaying(*(Sound *)sound);
}
/** SetSoundVolume(params: void * sound, float volume -> void) */
void sp_SetSoundVolume(void * sound, float volume) {
  SetSoundVolume(*(Sound *)sound, volume);
}
/** SetSoundPitch(params: void * sound, float pitch -> void) */
void sp_SetSoundPitch(void * sound, float pitch) {
  SetSoundPitch(*(Sound *)sound, pitch);
}
/** SetSoundPan(params: void * sound, float pan -> void) */
void sp_SetSoundPan(void * sound, float pan) {
  SetSoundPan(*(Sound *)sound, pan);
}
/** WaveCopy(params: void * wave -> void *) */
void * sp_WaveCopy(void * wave) {
  Wave *r = (Wave *)malloc(sizeof(Wave));
  *r = WaveCopy(*(Wave *)wave);
  return r;
}
/** LoadWaveSamples(params: void * wave -> void *) */
void * sp_LoadWaveSamples(void * wave) {
  return LoadWaveSamples(*(Wave *)wave);
}
/** LoadMusicStream(params: const char * fileName -> void *) */
void * sp_LoadMusicStream(const char * fileName) {
  Music *r = (Music *)malloc(sizeof(Music));
  *r = LoadMusicStream(fileName);
  return r;
}
/** LoadMusicStreamFromMemory(params: const char * fileType, void * data, int dataSize -> void *) */
void * sp_LoadMusicStreamFromMemory(const char * fileType, void * data, int dataSize) {
  Music *r = (Music *)malloc(sizeof(Music));
  *r = LoadMusicStreamFromMemory(fileType, data, dataSize);
  return r;
}
/** IsMusicValid(params: void * music -> _Bool) */
_Bool sp_IsMusicValid(void * music) {
  return IsMusicValid(*(Music *)music);
}
/** UnloadMusicStream(params: void * music -> void) */
void sp_UnloadMusicStream(void * music) {
  UnloadMusicStream(*(Music *)music);
}
/** PlayMusicStream(params: void * music -> void) */
void sp_PlayMusicStream(void * music) {
  PlayMusicStream(*(Music *)music);
}
/** IsMusicStreamPlaying(params: void * music -> _Bool) */
_Bool sp_IsMusicStreamPlaying(void * music) {
  return IsMusicStreamPlaying(*(Music *)music);
}
/** UpdateMusicStream(params: void * music -> void) */
void sp_UpdateMusicStream(void * music) {
  UpdateMusicStream(*(Music *)music);
}
/** StopMusicStream(params: void * music -> void) */
void sp_StopMusicStream(void * music) {
  StopMusicStream(*(Music *)music);
}
/** PauseMusicStream(params: void * music -> void) */
void sp_PauseMusicStream(void * music) {
  PauseMusicStream(*(Music *)music);
}
/** ResumeMusicStream(params: void * music -> void) */
void sp_ResumeMusicStream(void * music) {
  ResumeMusicStream(*(Music *)music);
}
/** SeekMusicStream(params: void * music, float position -> void) */
void sp_SeekMusicStream(void * music, float position) {
  SeekMusicStream(*(Music *)music, position);
}
/** SetMusicVolume(params: void * music, float volume -> void) */
void sp_SetMusicVolume(void * music, float volume) {
  SetMusicVolume(*(Music *)music, volume);
}
/** SetMusicPitch(params: void * music, float pitch -> void) */
void sp_SetMusicPitch(void * music, float pitch) {
  SetMusicPitch(*(Music *)music, pitch);
}
/** SetMusicPan(params: void * music, float pan -> void) */
void sp_SetMusicPan(void * music, float pan) {
  SetMusicPan(*(Music *)music, pan);
}
/** GetMusicTimeLength(params: void * music -> float) */
float sp_GetMusicTimeLength(void * music) {
  return GetMusicTimeLength(*(Music *)music);
}
/** GetMusicTimePlayed(params: void * music -> float) */
float sp_GetMusicTimePlayed(void * music) {
  return GetMusicTimePlayed(*(Music *)music);
}
/** LoadAudioStream(params: uint32_t sampleRate, uint32_t sampleSize, uint32_t channels -> void *) */
void * sp_LoadAudioStream(uint32_t sampleRate, uint32_t sampleSize, uint32_t channels) {
  AudioStream *r = (AudioStream *)malloc(sizeof(AudioStream));
  *r = LoadAudioStream(sampleRate, sampleSize, channels);
  return r;
}
/** IsAudioStreamValid(params: void * stream -> _Bool) */
_Bool sp_IsAudioStreamValid(void * stream) {
  return IsAudioStreamValid(*(AudioStream *)stream);
}
/** UnloadAudioStream(params: void * stream -> void) */
void sp_UnloadAudioStream(void * stream) {
  AudioStream *self = (AudioStream *)stream;
  UnloadAudioStream(*self);
  free(self);
}
/** UpdateAudioStream(params: void * stream, void * data, int frameCount -> void) */
void sp_UpdateAudioStream(void * stream, void * data, int frameCount) {
  UpdateAudioStream(*(AudioStream *)stream, data, frameCount);
}
/** IsAudioStreamProcessed(params: void * stream -> _Bool) */
_Bool sp_IsAudioStreamProcessed(void * stream) {
  return IsAudioStreamProcessed(*(AudioStream *)stream);
}
/** PlayAudioStream(params: void * stream -> void) */
void sp_PlayAudioStream(void * stream) {
  PlayAudioStream(*(AudioStream *)stream);
}
/** PauseAudioStream(params: void * stream -> void) */
void sp_PauseAudioStream(void * stream) {
  PauseAudioStream(*(AudioStream *)stream);
}
/** ResumeAudioStream(params: void * stream -> void) */
void sp_ResumeAudioStream(void * stream) {
  ResumeAudioStream(*(AudioStream *)stream);
}
/** IsAudioStreamPlaying(params: void * stream -> _Bool) */
_Bool sp_IsAudioStreamPlaying(void * stream) {
  return IsAudioStreamPlaying(*(AudioStream *)stream);
}
/** StopAudioStream(params: void * stream -> void) */
void sp_StopAudioStream(void * stream) {
  StopAudioStream(*(AudioStream *)stream);
}
/** SetAudioStreamVolume(params: void * stream, float volume -> void) */
void sp_SetAudioStreamVolume(void * stream, float volume) {
  SetAudioStreamVolume(*(AudioStream *)stream, volume);
}
/** SetAudioStreamPitch(params: void * stream, float pitch -> void) */
void sp_SetAudioStreamPitch(void * stream, float pitch) {
  SetAudioStreamPitch(*(AudioStream *)stream, pitch);
}
/** SetAudioStreamPan(params: void * stream, float pan -> void) */
void sp_SetAudioStreamPan(void * stream, float pan) {
  SetAudioStreamPan(*(AudioStream *)stream, pan);
}
/** SetAudioStreamCallback(params: void * stream, void * callback -> void) */
void sp_SetAudioStreamCallback(void * stream, void * callback) {
  SetAudioStreamCallback(*(AudioStream *)stream, (AudioCallback)callback);
}
/** AttachAudioStreamProcessor(params: void * stream, void * processor -> void) */
void sp_AttachAudioStreamProcessor(void * stream, void * processor) {
  AttachAudioStreamProcessor(*(AudioStream *)stream, (AudioCallback)processor);
}
/** DetachAudioStreamProcessor(params: void * stream, void * processor -> void) */
void sp_DetachAudioStreamProcessor(void * stream, void * processor) {
  DetachAudioStreamProcessor(*(AudioStream *)stream, (AudioCallback)processor);
}
/** AttachAudioMixedProcessor(params: void * processor -> void) */
void sp_AttachAudioMixedProcessor(void * processor) {
  AttachAudioMixedProcessor((AudioCallback)processor);
}
/** DetachAudioMixedProcessor(params: void * processor -> void) */
void sp_DetachAudioMixedProcessor(void * processor) {
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
 * The core native structs (sp_Vector2) are defined above, so these can
 * live in the raylib adapter object — no separate libraymath exists.
 * Follows the generator conventions: by-value structs via pointers.
 * ================================================================ */
void sp_Vector2Add(sp_Vector2 *a, sp_Vector2 *b, sp_Vector2 *out) {
  out->v = Vector2Add(a->v, b->v);
}
void sp_Vector2Scale(sp_Vector2 *v, double scale, sp_Vector2 *out) {
  out->v = Vector2Scale(v->v, (float)scale);
}
void sp_Vector2Rotate(sp_Vector2 *v, double angle, sp_Vector2 *out) {
  out->v = Vector2Rotate(v->v, (float)angle);
}
void sp_Vector2Normalize(sp_Vector2 *v, sp_Vector2 *out) {
  out->v = Vector2Normalize(v->v);
}
double sp_Vector2Length(sp_Vector2 *v) {
  return (double)Vector2Length(v->v);
}
void sp_Vector2Lerp(sp_Vector2 *a, sp_Vector2 *b, double amount, sp_Vector2 *out) {
  out->v = Vector2Lerp(a->v, b->v, (float)amount);
}
double sp_Vector2Angle(sp_Vector2 *a, sp_Vector2 *b) {
  return (double)Vector2Angle(a->v, b->v);
}

/* ---- positional construction fills (Raylib.Vector2/Vector4/Matrix) ----
 * Spinel inlines Klass.new(args) to the native ctor and its type analysis can
 * degrade the accessor writers (v.x = x) to generic ivar dispatch in programs
 * where other classes share x/y/m fields, so construction goes through these
 * explicit C helpers via ffi_func instead. */
/* NOTE: the ffi_func declarations type these as :float, so the generated
 * externs pass C float — the definitions must be float too (a double callee
 * reading a float arg sees zeroed upper bits and loses the value). */
void sp_Vector2Fill(sp_Vector2 *o, float x, float y) {
  o->v = (Vector2){ x, y };
}
void sp_Vector4Fill(sp_Vector4 *o, float x, float y, float z, float w) {
  o->v = (Vector4){ x, y, z, w };
}
void sp_MatrixFill(sp_Matrix *o, float m0, float m4, float m8, float m12,
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
void *sp_FontTexture(void *font) {
  return &((Font *)font)->texture;
}

/* Model.materials[index] -> Material* (embedded in the Model struct). */
void *sp_Model_material(void *model, int index) {
  Model *m = (Model *)model;
  if (index < 0 || index >= m->materialCount) return NULL;
  return &m->materials[index];
}

/* int out-parameter helpers (e.g. LoadImageAnim frame count). */
int *sp_IntAlloc(void) {
  int *p = (int *)malloc(sizeof(int));
  *p = 0;
  return p;
}
int sp_IntGet(int *p) { return *p; }
void sp_IntFree(int *p) { free(p); }

/* Image field accessors (Image is an opaque heap pointer). */
int sp_ImageWidth(void *image) { return ((Image *)image)->width; }
int sp_ImageHeight(void *image) { return ((Image *)image)->height; }
/* Pointer to the start of a single animation frame's pixel data. */
void *sp_ImageFrameData(void *image, int frameIndex) {
  Image *img = (Image *)image;
  int frameBytes = img->width * img->height * 4;
  return (unsigned char *)img->data + frameBytes * frameIndex;
}

/* ---- Model / animation / picking / camera extras ---- */

/* Model.transform accessors (Matrix is a native sp_Matrix). */
void sp_Model_transform(void *model, void *out) {
  ((sp_Matrix *)out)->v = ((Model *)model)->transform;
}
void sp_Model_set_transform(void *model, void *matrix) {
  ((Model *)model)->transform = ((sp_Matrix *)matrix)->v;
}

/* Model.meshes[index] -> Mesh* (embedded in the Model struct). */
void *sp_Model_mesh(void *model, int index) {
  Model *m = (Model *)model;
  if (index < 0 || index >= m->meshCount) return NULL;
  return &m->meshes[index];
}
int sp_Model_meshCount(void *model) { return ((Model *)model)->meshCount; }

/* ModelAnimation array element and frame count. */
void *sp_ModelAnimationAt(void *anims, int index) {
  return &((ModelAnimation *)anims)[index];
}
int sp_ModelAnimation_frameCount(void *anim) {
  return ((ModelAnimation *)anim)->keyframeCount;
}

/* RayCollision point/normal -> native Vector3 out-param. */
void sp_RayCollision_point(void *self, void *out) {
  ((sp_Vector3 *)out)->v = ((sp_RayCollision *)self)->v.point;
}
void sp_RayCollision_normal(void *self, void *out) {
  ((sp_Vector3 *)out)->v = ((sp_RayCollision *)self)->v.normal;
}

/* Camera3D position component reads (native Camera has no field accessors). */
void sp_Camera_position_from_bounds(void *self, void *box, float pad) {
  BoundingBox *b = (BoundingBox *)box;
  ((sp_Camera *)self)->c.position = (Vector3){ b->max.x + pad, b->max.y + pad,
                                              b->max.z + pad };
}
float sp_Camera_position_x(void *self) { return ((sp_Camera *)self)->c.position.x; }
float sp_Camera_position_y(void *self) { return ((sp_Camera *)self)->c.position.y; }
float sp_Camera_position_z(void *self) { return ((sp_Camera *)self)->c.position.z; }

/* LoadImageColors array element R channel. */
int sp_ImageColorR(void *colors, int index) {
  return ((Color *)colors)[index].r;
}

/* raymath MatrixRotateXYZ on the raylib adapter object (raymath adapter is not
 * linked into scenes). */
void sp_MatrixRotateXYZ(void *angle, void *out) {
  ((sp_Matrix *)out)->v = MatrixRotateXYZ(((sp_Vector3 *)angle)->v);
}

/* Circle/rect collision from raw floats (avoids native Rectangle field writes
 * in the all-in-one TU). center is a native sp_Vector2. */
_Bool sp_CheckCollisionCircleRecF(void *center, float radius,
                                  float x, float y, float w, float h) {
  Rectangle rec = { x, y, w, h };
  return CheckCollisionCircleRec(((sp_Vector2 *)center)->v, radius, rec);
}

/* ---- Shader value helpers (SetShaderValue takes a void* value) ---- */

/* Fragment-only shader (NULL vertex shader -> raylib default). */
void *sp_LoadShaderFS(const char *fsFileName) {
  Shader *s = (Shader *)malloc(sizeof(Shader));
  *s = LoadShader(NULL, fsFileName);
  return s;
}
void sp_SetShaderValueFloat(void *shader, int locIndex, float v, int type) {
  SetShaderValue(*(Shader *)shader, locIndex, &v, type);
}
void sp_SetShaderValueVec2(void *shader, int locIndex, float x, float y,
                           int type) {
  float v[2] = { x, y };
  SetShaderValue(*(Shader *)shader, locIndex, v, type);
}
void sp_SetShaderValueVec3(void *shader, int locIndex, float x, float y,
                           float z, int type) {
  float v[3] = { x, y, z };
  SetShaderValue(*(Shader *)shader, locIndex, v, type);
}

/* ---- Model skeleton / animation pose accessors ---- */
int sp_Model_boneCount(void *model) {
  return (int)((Model *)model)->skeleton.boneCount;
}
int sp_Model_boneParent(void *model, int index) {
  return ((Model *)model)->skeleton.bones[index].parent;
}
void sp_Model_bindPoseTranslation(void *model, int index, void *out) {
  ((sp_Vector3 *)out)->v =
    ((Model *)model)->skeleton.bindPose[index].translation;
}
void sp_ModelAnimation_framePoseTranslation(void *anim, int frame, int bone,
                                            void *out) {
  ((sp_Vector3 *)out)->v =
    ((ModelAnimation *)anim)->keyframePoses[frame][bone].translation;
}

/* Camera3D target component reads (for shader uniforms). */
float sp_Camera_target_x(void *self) { return ((sp_Camera *)self)->c.target.x; }
float sp_Camera_target_y(void *self) { return ((sp_Camera *)self)->c.target.y; }
float sp_Camera_target_z(void *self) { return ((sp_Camera *)self)->c.target.z; }

/* ---- Shader location slot / material shader assignment ---- */
void sp_Shader_setLoc(void *shader, int index, int value) {
  ((Shader *)shader)->locs[index] = value;
}
void sp_Material_set_shader(void *material, void *shader) {
  ((Material *)material)->shader = *(Shader *)shader;
}
void sp_SetShaderValueInt(void *shader, int locIndex, int v, int type) {
  SetShaderValue(*(Shader *)shader, locIndex, &v, type);
}
void sp_SetShaderValueVec4(void *shader, int locIndex, float x, float y,
                           float z, float w, int type) {
  float v[4] = { x, y, z, w };
  SetShaderValue(*(Shader *)shader, locIndex, v, type);
}
void sp_SetShaderValueColor(void *shader, int locIndex, void *color, int type) {
  sp_Color *c = (sp_Color *)color;
  float v[4] = { c->c.r / 255.0f, c->c.g / 255.0f, c->c.b / 255.0f,
                 c->c.a / 255.0f };
  SetShaderValue(*(Shader *)shader, locIndex, v, type);
}

/* ---- Font glyph internals + float-arg rectangle helpers ---- */
int sp_FontGlyphAdvanceX(void *font, int index) {
  return ((Font *)font)->glyphs[index].advanceX;
}
float sp_FontGlyphRecWidth(void *font, int index) {
  return ((Font *)font)->recs[index].width;
}
void sp_DrawRectangleLinesExF(float x, float y, float w, float h, float thick,
                              void *color) {
  DrawRectangleLinesEx((Rectangle){ x, y, w, h }, thick, ((sp_Color *)color)->c);
}
_Bool sp_CheckCollisionPointRecF(void *point, float x, float y, float w,
                                 float h) {
  return CheckCollisionPointRec(((sp_Vector2 *)point)->v,
                                (Rectangle){ x, y, w, h });
}

/* Build a Font from a TTF file's data via LoadFontData + GenImageFontAtlas
 * (used by the SDF font example). loadGlyphCount 0 lets raylib use defaults. */
void *sp_LoadFontAtlas(const char *path, int fontSize, int loadGlyphCount,
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
int sp_Color_r(sp_Color *self) { return self->c.r; }
int sp_Color_g(sp_Color *self) { return self->c.g; }
int sp_Color_b(sp_Color *self) { return self->c.b; }
int sp_Color_a(sp_Color *self) { return self->c.a; }

/* No-arg Vector3 allocator for out-param results (raymath wrappers). */
sp_Vector3 *sp_Vector3_new0(sp_int cls_id) {
  sp_Vector3 *self = (sp_Vector3 *)sp_gc_alloc(sizeof(sp_Vector3), NULL, sp_Vector3_scan);
  self->cls_id = cls_id;
  self->v = (Vector3){ 0 };
  return self;
}


/* Pure float/int shims added to bypass Spinel single-TU Rectangle struct-id collision */
void *sp_ImageFromImageF(void *image, float x, float y, float w, float h) {
  Image *img = (Image *)image;
  Image *result = (Image *)malloc(sizeof(Image));
  *result = ImageFromImage(*img, (Rectangle){ x, y, w, h });
  return result;
}

void sp_DrawRectangleProF(float x, float y, float w, float h,
                          float ox, float oy, float rotation, void *color) {
  DrawRectanglePro((Rectangle){ x, y, w, h },
                   (Vector2){ ox, oy },
                   rotation,
                   ((sp_Color *)color)->c);
}

void sp_DrawRectangleRoundedF(float x, float y, float w, float h,
                              float roundness, int segments, void *color) {
  DrawRectangleRounded((Rectangle){ x, y, w, h },
                       roundness, segments,
                       ((sp_Color *)color)->c);
}

void sp_DrawRectangleRoundedLinesExF(float x, float y, float w, float h,
                                    float roundness, int segments, float thick, void *color) {
  DrawRectangleRoundedLinesEx((Rectangle){ x, y, w, h },
                              roundness, segments, thick,
                              ((sp_Color *)color)->c);
}

void sp_DrawTextureRecF(void *texture, float sx, float sy, float sw, float sh,
                        float px, float py, void *tint) {
  DrawTextureRec(*(Texture2D *)texture,
                 (Rectangle){ sx, sy, sw, sh },
                 (Vector2){ px, py },
                 ((sp_Color *)tint)->c);
}

/* DrawTexturePro with raw float src/dest/origin (avoids native Rectangle/
 * Vector2 field writes in the all-in-one TU). */
void sp_DrawTextureProF(void *texture, float sx, float sy, float sw, float sh,
                        float dx, float dy, float dw, float dh,
                        float ox, float oy, float rotation, void *tint) {
  DrawTexturePro(*(Texture2D *)texture,
                 (Rectangle){ sx, sy, sw, sh },
                 (Rectangle){ dx, dy, dw, dh },
                 (Vector2){ ox, oy }, rotation, ((sp_Color *)tint)->c);
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

int sp_DirListCount(void *list) {
  if (!list) return 0;
  return ((sp_FilePathList *)list)->v.count;
}
const char *sp_DirListName(void *list, int index) {
  if (!list) return "";
  sp_FilePathList *fl = (sp_FilePathList *)list;
  if (index < 0 || index >= fl->v.count) return "";
  return fl->v.paths[index];
}

static double sp_sine_time = 0.0;

void sp_AudioStreamSineReset(void) { sp_sine_time = 0.0; }
void sp_UpdateAudioStreamSine(void *stream, int frames, float gain,
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
