/* ==== handle-class views: preamble (gen_handle_class_c.py) ==== */
/* Handle classes use the same owned/view layout as the vectors:
 * payload in `v`, or a view over someone else's memory via `p`
 * (raw heap copies from the shims, interior pointers like
 * Font.texture). */
typedef struct rl_Image_s {
  sp_int cls_id;
  Image *p;            /* NULL: owned; non-NULL: view */
  sp_RbVal owner;    /* view: GC-marked owner (nil if none) */
  Image v;             /* owned payload */
} rl_Image;
#define RL_IMG(o) (((rl_Image *)(o))->p ? ((rl_Image *)(o))->p : &((rl_Image *)(o))->v)
typedef struct rl_Texture2D_s {
  sp_int cls_id;
  Texture2D *p;            /* NULL: owned; non-NULL: view */
  sp_RbVal owner;    /* view: GC-marked owner (nil if none) */
  Texture2D v;             /* owned payload */
} rl_Texture2D;
#define RL_TEX(o) (((rl_Texture2D *)(o))->p ? ((rl_Texture2D *)(o))->p : &((rl_Texture2D *)(o))->v)
typedef struct rl_Font_s {
  sp_int cls_id;
  Font *p;            /* NULL: owned; non-NULL: view */
  sp_RbVal owner;    /* view: GC-marked owner (nil if none) */
  Font v;             /* owned payload */
} rl_Font;
#define RL_FONT(o) (((rl_Font *)(o))->p ? ((rl_Font *)(o))->p : &((rl_Font *)(o))->v)
typedef struct rl_GlyphInfo_s {
  sp_int cls_id;
  GlyphInfo *p;            /* NULL: owned; non-NULL: view */
  sp_RbVal owner;    /* view: GC-marked owner (nil if none) */
  GlyphInfo v;             /* owned payload */
} rl_GlyphInfo;
#define RL_GLYPH(o) (((rl_GlyphInfo *)(o))->p ? ((rl_GlyphInfo *)(o))->p : &((rl_GlyphInfo *)(o))->v)
typedef struct rl_RenderTexture_s {
  sp_int cls_id;
  RenderTexture *p;            /* NULL: owned; non-NULL: view */
  sp_RbVal owner;    /* view: GC-marked owner (nil if none) */
  RenderTexture v;             /* owned payload */
} rl_RenderTexture;
#define RL_RT(o) (((rl_RenderTexture *)(o))->p ? ((rl_RenderTexture *)(o))->p : &((rl_RenderTexture *)(o))->v)
/* ==== end handle-class views preamble ==== */
