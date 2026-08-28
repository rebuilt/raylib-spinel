#include <raylib.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

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
 * structs by value (Color, Vector2, Rectangle, Texture2D, Font,
 * Music, Sound), so entry points that would take or return one
 * take pointers instead, under sp_/renamed symbols. Structs are
 * heap-allocated and passed as void*.
 *
 * Bool-returning functions are also shimmed: the x86-64 ABI
 * returns _Bool in AL with unspecified upper bits, and spinel's
 * int-typed externs would read that garbage. Calling through the
 * raylib.h prototypes here makes the compiler extract AL cleanly.
 * ================================================================ */

/* ---- Color passed as pointer ---- */
void sp_ColorFree(void *color) {
  if (color) free(color);
}
void sp_ClearBackground(void *color) {
  ClearBackground(*(Color *)color);
}
void sp_DrawText(const char *text, int x, int y, int size, void *color) {
  DrawText(text, x, y, size, *(Color *)color);
}
void sp_DrawCircle(int x, int y, float radius, void *color) {
  DrawCircle(x, y, radius, *(Color *)color);
}
void sp_DrawRectangle(int x, int y, int w, int h, void *color) {
  DrawRectangle(x, y, w, h, *(Color *)color);
}
void sp_DrawCircleV(void *center, float radius, void *color) {
  DrawCircleV(*(Vector2 *)center, radius, *(Color *)color);
}

/* ---- Texture lifetime: Texture2D held on the heap behind a ptr ---- */
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
int sp_GetTextureWidth(void *tex) { return ((Texture2D *)tex)->width; }
int sp_GetTextureHeight(void *tex) { return ((Texture2D *)tex)->height; }

/* ---- Rectangle passed as pointer; ALSO source of truth for
 *      spinel-side Rectangle struct layout (16 bytes: 4 floats) ---- */
void *RectangleNew(void) {
  Rectangle *r = (Rectangle *)calloc(1, sizeof(Rectangle));
  return r;
}
void RectangleFree(void *r) { if (r) free(r); }
float RectangleGetX(void *r) { return ((Rectangle *)r)->x; }
float RectangleGetY(void *r) { return ((Rectangle *)r)->y; }
float RectangleGetWidth(void *r) { return ((Rectangle *)r)->width; }
float RectangleGetHeight(void *r) { return ((Rectangle *)r)->height; }
void RectangleSetX(void *r, float v) { ((Rectangle *)r)->x = v; }
void RectangleSetY(void *r, float v) { ((Rectangle *)r)->y = v; }
void RectangleSetWidth(void *r, float v) { ((Rectangle *)r)->width = v; }
void RectangleSetHeight(void *r, float v) { ((Rectangle *)r)->height = v; }

/* ---- Vector2 helpers (custom — not raylib functions) ---- */
void *Vector2Create(float x, float y) {
  fprintf(stderr, "[Vector2Create] x=%f y=%f\n", x, y);
  Vector2 *v = (Vector2 *)malloc(sizeof(Vector2));
  v->x = x;
  v->y = y;
  return v;
}
void Vector2Free(void *p) { if (p) free(p); }
void Vector2SetX(void *p, float v) { ((Vector2 *)p)->x = v; }
void Vector2SetY(void *p, float v) { ((Vector2 *)p)->y = v; }
float Vector2GetX(void *p) { return ((Vector2 *)p)->x; }
float Vector2GetY(void *p) { return ((Vector2 *)p)->y; }

/* ---- Texture + rect drawing ---- */
void sp_DrawTexturePro(void *tex, void *src, void *dst, void *origin,
                       float rotation, void *color) {
  DrawTexturePro(*(Texture2D *)tex, *(Rectangle *)src, *(Rectangle *)dst,
                 *(Vector2 *)origin, rotation, *(Color *)color);
}
void sp_DrawTextureEx(void *tex, float x, float y, float rotation,
                      float scale, void *color) {
  DrawTextureEx(*(Texture2D *)tex, (Vector2){x, y}, rotation, scale,
                *(Color *)color);
}
void sp_DrawTexture(void *tex, int x, int y, void *color) {
  DrawTexture(*(Texture2D *)tex, x, y, *(Color *)color);
}

/* ---- Font lifetime ---- */
void *sp_LoadFont(const char *path) {
  Font *f = (Font *)malloc(sizeof(Font));
  *f = LoadFont(path);
  return f;
}
void sp_UnloadFont(void *font) {
  if (font) {
    UnloadFont(*(Font *)font);
    free(font);
  }
}
int sp_GetFontBaseSize(void *font) { return ((Font *)font)->baseSize; }
void sp_DrawTextEx(void *font, const char *text, void *pos, float size,
                   float spacing, void *color) {
  fprintf(stderr, "[sp_DrawTextEx] font=%p pos=%p color=%p size=%f spacing=%f text='%s'\n",
          font, pos, color, size, spacing, text ? text : "(null)");
  fprintf(stderr, "[f] base=%d glyphs=%d | [v] x=%f y=%f | [c] %d %d %d %d\n",
          font ? ((Font *)font)->baseSize : -1, font ? ((Font *)font)->glyphCount : -1,
          pos ? ((Vector2 *)pos)->x : -1, pos ? ((Vector2 *)pos)->y : -1,
          color ? ((Color *)color)->r : -1, color ? ((Color *)color)->g : -1,
          color ? ((Color *)color)->b : -1, color ? ((Color *)color)->a : -1);
  DrawTextEx(*(Font *)font, text, *(Vector2 *)pos, size, spacing,
             *(Color *)color);
}

/* ---- Audio device ---- */
/* InitAudioDevice/CloseAudioDevice have no struct args — direct externs. */

/* ---- Music ---- */
void *sp_LoadMusicStream(const char *path) {
  Music *m = (Music *)malloc(sizeof(Music));
  *m = LoadMusicStream(path);
  return m;
}
void sp_UnloadMusicStream(void *m) {
  if (m) {
    UnloadMusicStream(*(Music *)m);
    free(m);
  }
}
void sp_PlayMusicStream(void *m) { PlayMusicStream(*(Music *)m); }
void sp_StopMusicStream(void *m) { StopMusicStream(*(Music *)m); }
void sp_PauseMusicStream(void *m) { PauseMusicStream(*(Music *)m); }
void sp_ResumeMusicStream(void *m) { ResumeMusicStream(*(Music *)m); }
void sp_UpdateMusicStream(void *m) { UpdateMusicStream(*(Music *)m); }
void sp_SetMusicVolume(void *m, float volume) {
  SetMusicVolume(*(Music *)m, volume);
}
void sp_SetMusicLooping(void *m, int looping) { ((Music *)m)->looping = looping; }

/* ---- Sound ---- */
void *sp_LoadSound(const char *path) {
  Sound *s = (Sound *)malloc(sizeof(Sound));
  *s = LoadSound(path);
  return s;
}
void sp_UnloadSound(void *s) {
  if (s) {
    UnloadSound(*(Sound *)s);
    free(s);
  }
}
void sp_PlaySound(void *s) { PlaySound(*(Sound *)s); }

/* ---- Mouse ---- */
void *sp_GetMousePosition(void) {
  Vector2 *v = (Vector2 *)malloc(sizeof(Vector2));
  *v = GetMousePosition();
  return v;
}
void *sp_GetMouseDelta(void) {
  Vector2 *v = (Vector2 *)malloc(sizeof(Vector2));
  *v = GetMouseDelta();
  return v;
}

/* ---- Vector2/Color-taking functions ---- */
void sp_DrawTriangle(void *v1, void *v2, void *v3, void *color) {
  DrawTriangle(*(Vector2 *)v1, *(Vector2 *)v2, *(Vector2 *)v3,
               *(Color *)color);
}

/* ---- Bool-returning raylib functions ----
 * See header comment: int-typed FFI externs must not read the
 * unspecified upper bits of a _Bool return. */
int sp_WindowShouldClose(void) { return WindowShouldClose(); }
int sp_IsKeyDown(int key) { return IsKeyDown(key); }
int sp_IsKeyPressed(int key) { return IsKeyPressed(key); }
int sp_IsKeyReleased(int key) { return IsKeyReleased(key); }
int sp_IsMouseButtonPressed(int btn) { return IsMouseButtonPressed(btn); }
int sp_IsMouseButtonReleased(int btn) { return IsMouseButtonReleased(btn); }
int sp_IsGamepadAvailable(int gp) { return IsGamepadAvailable(gp); }
int sp_IsGamepadButtonDown(int gp, int btn) {
  return IsGamepadButtonDown(gp, btn);
}
int sp_IsGamepadButtonPressed(int gp, int btn) {
  return IsGamepadButtonPressed(gp, btn);
}
int sp_IsGamepadButtonReleased(int gp, int btn) {
  return IsGamepadButtonReleased(gp, btn);
}
