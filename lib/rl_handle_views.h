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
typedef struct rl_Model_s {
  sp_int cls_id;
  Model *p;            /* NULL: owned; non-NULL: view */
  sp_RbVal owner;    /* view: GC-marked owner (nil if none) */
  Model v;             /* owned payload */
} rl_Model;
#define RL_MODEL(o) (((rl_Model *)(o))->p ? ((rl_Model *)(o))->p : &((rl_Model *)(o))->v)
typedef struct rl_Material_s {
  sp_int cls_id;
  Material *p;            /* NULL: owned; non-NULL: view */
  sp_RbVal owner;    /* view: GC-marked owner (nil if none) */
  Material v;             /* owned payload */
} rl_Material;
#define RL_MAT(o) (((rl_Material *)(o))->p ? ((rl_Material *)(o))->p : &((rl_Material *)(o))->v)
typedef struct rl_Mesh_s {
  sp_int cls_id;
  Mesh *p;            /* NULL: owned; non-NULL: view */
  sp_RbVal owner;    /* view: GC-marked owner (nil if none) */
  Mesh v;             /* owned payload */
} rl_Mesh;
#define RL_MESH(o) (((rl_Mesh *)(o))->p ? ((rl_Mesh *)(o))->p : &((rl_Mesh *)(o))->v)
typedef struct rl_Shader_s {
  sp_int cls_id;
  Shader *p;            /* NULL: owned; non-NULL: view */
  sp_RbVal owner;    /* view: GC-marked owner (nil if none) */
  Shader v;             /* owned payload */
} rl_Shader;
#define RL_SHDR(o) (((rl_Shader *)(o))->p ? ((rl_Shader *)(o))->p : &((rl_Shader *)(o))->v)
typedef struct rl_ModelAnimation_s {
  sp_int cls_id;
  ModelAnimation *p;            /* NULL: owned; non-NULL: view */
  sp_RbVal owner;    /* view: GC-marked owner (nil if none) */
  ModelAnimation v;             /* owned payload */
} rl_ModelAnimation;
#define RL_ANIM(o) (((rl_ModelAnimation *)(o))->p ? ((rl_ModelAnimation *)(o))->p : &((rl_ModelAnimation *)(o))->v)
typedef struct rl_BoneInfo_s {
  sp_int cls_id;
  BoneInfo *p;            /* NULL: owned; non-NULL: view */
  sp_RbVal owner;    /* view: GC-marked owner (nil if none) */
  BoneInfo v;             /* owned payload */
} rl_BoneInfo;
#define RL_BONE(o) (((rl_BoneInfo *)(o))->p ? ((rl_BoneInfo *)(o))->p : &((rl_BoneInfo *)(o))->v)
/* ==== end handle-class views preamble ==== */
