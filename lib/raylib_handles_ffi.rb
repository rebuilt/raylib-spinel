# frozen_string_literal: true

# raylib_handles_ffi.rb — the handle classes (Image/Texture2D/Font/...) as
# native view objects, plus the field shims.
#
# The C side lives in lib/rl_handle_views.h (layout + RL_<X> macros) and the
# implementation section of raylib_adapter.c (ctors, scans, rl_m_* accessors);
# lib/raylib_handles.rb adds the gem-shaped Ruby methods.
#
# View ctors take the pointer boxed ([:any]): Spinel boxes ffi_func :ptr
# returns, and rl_h_unbox accepts a boxed foreign pointer, an object or an
# Integer address.
module Raylib
  ffi_lib "raylib"

  # pointer <-> address (the gem's `ptr + index * Struct.size` idiom; Spinel
  # boxes poly arithmetic, so the address travels as an Integer)
  ffi_func :rl_ptr_addr, [:ptr], :long
  ffi_func :rl_PtrWriteFloat, [:long, :long, :float], :void
  ffi_func :rl_PtrReadFloat, [:long, :long], :float
  ffi_func :rl_PtrWriteInt16, [:long, :long, :int], :void

  # Interior pointers into the payload of a handle (for sub-struct views).
  # ffi_funcs (not native_methods): only ffi :ptr returns feed an [:any] ctor.
  ffi_func :rl_Font_texture_ptr, [:ptr], :ptr
  ffi_func :rl_Vector2_payload, [:ptr], :long
  ffi_func :rl_Vector3_payload, [:ptr], :long
  ffi_func :rl_Color_payload, [:ptr], :long
  ffi_func :rl_Rectangle_payload, [:ptr], :long
  ffi_func :rl_Font_recs_addr, [:ptr], :long
  ffi_func :rl_Font_glyphs_addr, [:ptr], :long
  ffi_func :rl_GlyphInfo_image_ptr, [:ptr], :ptr
  ffi_func :rl_RenderTexture_texture_ptr, [:ptr], :ptr
  ffi_func :rl_RenderTexture_depth_ptr, [:ptr], :ptr
  ffi_func :rl_FontTexture_ptr, [:ptr], :ptr

  # ------------------------------------------------------------------ Image
  native_struct "Image", "rl_Image"
  native_new [], "rl_Image_new"
  native_new [:any, :any], "rl_Image_view"
  native_method :width, [], :int, "rl_m_Image_width"
  native_method :width=, [:int], :int, "rl_m_Image_set_width"
  native_method :height, [], :int, "rl_m_Image_height"
  native_method :height=, [:int], :int, "rl_m_Image_set_height"
  native_method :mipmaps, [], :int, "rl_m_Image_mipmaps"
  native_method :mipmaps=, [:int], :int, "rl_m_Image_set_mipmaps"
  native_method :format, [], :int, "rl_m_Image_format"
  native_method :format=, [:int], :int, "rl_m_Image_set_format"
  ffi_func :rl_m_Image_data, [:ptr], :long
  native_method :data=, [:any], :void, "rl_m_Image_set_data"

  # -------------------------------------------------------------- Texture2D
  native_struct "Texture2D", "rl_Texture2D"
  native_new [], "rl_Texture2D_new"
  native_new [:any, :any], "rl_Texture2D_view"
  native_method :id, [], :int, "rl_m_Texture2D_id"
  native_method :id=, [:int], :int, "rl_m_Texture2D_set_id"
  native_method :width, [], :int, "rl_m_Texture2D_width"
  native_method :width=, [:int], :int, "rl_m_Texture2D_set_width"
  native_method :height, [], :int, "rl_m_Texture2D_height"
  native_method :height=, [:int], :int, "rl_m_Texture2D_set_height"
  native_method :mipmaps, [], :int, "rl_m_Texture2D_mipmaps"
  native_method :mipmaps=, [:int], :int, "rl_m_Texture2D_set_mipmaps"
  native_method :format, [], :int, "rl_m_Texture2D_format"
  native_method :format=, [:int], :int, "rl_m_Texture2D_set_format"

  # ------------------------------------------------------------------- Font
  native_struct "Font", "rl_Font"
  native_new [], "rl_Font_new"
  native_new [:any, :any], "rl_Font_view"
  native_method :baseSize, [], :int, "rl_m_Font_baseSize"
  native_method :baseSize=, [:int], :int, "rl_m_Font_set_baseSize"
  native_method :glyphCount, [], :int, "rl_m_Font_glyphCount"
  native_method :glyphCount=, [:int], :int, "rl_m_Font_set_glyphCount"
  native_method :glyphPadding, [], :int, "rl_m_Font_glyphPadding"
  native_method :glyphPadding=, [:int], :int, "rl_m_Font_set_glyphPadding"
  native_method :glyphs=, [:any], :void, "rl_m_Font_set_glyphs"
  native_method :recs=, [:any], :void, "rl_m_Font_set_recs"
  native_method :texture=, [:any], :void, "rl_m_Font_set_texture"
  native_method :texture_ptr, [], :ptr, "rl_Font_texture_ptr"
  # View accessors next to the class declaration: a polymorphic send (a Struct
  # field or an Array element) only finds the native-class arm when the
  # definition sits here rather than in raylib_handles.rb. The ffi_funcs they
  # read through are declared at the top of this file.
  class Font
    def texture = Texture2D.new(Raylib.rl_Font_texture_ptr(self), self)
    def recs = Ptr.new(Raylib.rl_Font_recs_addr(self))
    def glyphs = Ptr.new(Raylib.rl_Font_glyphs_addr(self))
  end

  # -------------------------------------------------------------- GlyphInfo
  native_struct "GlyphInfo", "rl_GlyphInfo"
  native_new [], "rl_GlyphInfo_new"
  native_new [:any, :any], "rl_GlyphInfo_view"
  native_new [:any], "rl_GlyphInfo_view_addr"
  native_method :value, [], :int, "rl_m_GlyphInfo_value"
  native_method :value=, [:int], :int, "rl_m_GlyphInfo_set_value"
  native_method :offsetX, [], :int, "rl_m_GlyphInfo_offsetX"
  native_method :offsetX=, [:int], :int, "rl_m_GlyphInfo_set_offsetX"
  native_method :offsetY, [], :int, "rl_m_GlyphInfo_offsetY"
  native_method :offsetY=, [:int], :int, "rl_m_GlyphInfo_set_offsetY"
  native_method :advanceX, [], :int, "rl_m_GlyphInfo_advanceX"
  native_method :advanceX=, [:int], :int, "rl_m_GlyphInfo_set_advanceX"
  class GlyphInfo
    def image = Image.new(Raylib.rl_GlyphInfo_image_ptr(self), self)
  end

  # --------------------------------------------------------- RenderTexture
  native_struct "RenderTexture", "rl_RenderTexture"
  native_new [], "rl_RenderTexture_new"
  native_new [:any, :any], "rl_RenderTexture_view"
  native_method :texture_ptr, [], :ptr, "rl_RenderTexture_texture_ptr"
  native_method :depth_ptr, [], :ptr, "rl_RenderTexture_depth_ptr"
  class RenderTexture
    def texture = Texture2D.new(Raylib.rl_RenderTexture_texture_ptr(self), self)
    def depth = Texture2D.new(Raylib.rl_RenderTexture_depth_ptr(self), self)
  end
end

# ------------------------------------------------------------------ batch 2
module Raylib
  # interior/helper shims for the batch-2 classes (the renamed scene-facing
  # shims -- rl_Model_material_ptr, rl_Model_mesh_ptr, rl_ModelAnimationAt_ptr,
  # rl_LoadShaderFS_ptr -- stay declared next to their peers in raylib_ffi.rb)
  ffi_func :rl_Material_shader_ptr, [:ptr], :ptr

  native_struct "Model", "rl_Model"
  native_new [], "rl_Model_new"
  native_new [:any, :any], "rl_Model_view"
  native_new [:any], "rl_Model_view_addr"
  native_method :meshCount, [], :int, "rl_m_Model_meshCount"
  native_method :meshCount=, [:int], :int, "rl_m_Model_set_meshCount"
  native_method :materialCount, [], :int, "rl_m_Model_materialCount"
  # payload accessors the AOT must see next to the class declaration, so a
  # polymorphic send (an Array element) finds the native-class arm
  class Model
    def material(index = 0) = Material.new(Raylib.rl_Model_material_ptr(self, index), self)
    def mesh(index = 0) = Mesh.new(Raylib.rl_Model_mesh_ptr(self, index), self)
  end
  native_method :materialCount=, [:int], :int, "rl_m_Model_set_materialCount"
  native_method :boneCount, [], :int, "rl_m_Model_boneCount"
  native_method :boneCount=, [:int], :int, "rl_m_Model_set_boneCount"
  ffi_func :rl_m_Model_meshes, [:ptr], :long
  ffi_func :rl_Model_set_meshes_ptr, [:ptr, :ptr], :void
  ffi_func :rl_m_Model_materials, [:ptr], :long
  ffi_func :rl_Model_set_materials_ptr, [:ptr, :ptr], :void
  ffi_func :rl_m_Model_meshMaterial, [:ptr], :long
  ffi_func :rl_Model_set_meshMaterial_ptr, [:ptr, :ptr], :void
  ffi_func :rl_m_Model_currentPose, [:ptr], :long
  ffi_func :rl_Model_set_currentPose_ptr, [:ptr, :ptr], :void
  ffi_func :rl_m_Model_boneMatrices, [:ptr], :long
  ffi_func :rl_Model_set_boneMatrices_ptr, [:ptr, :ptr], :void
  ffi_func :rl_Model_set_transform, [:ptr, :ptr], :void
ffi_func :rl_Model_skeleton_ptr, [:ptr], :ptr
  ffi_func :rl_Model_set_skeleton, [:ptr, :ptr], :void

  native_struct "ModelSkeleton", "rl_ModelSkeleton"
  native_new [], "rl_ModelSkeleton_new"
  native_new [:any, :any], "rl_ModelSkeleton_view_any"
  native_method :boneCount, [], :int, "rl_m_ModelSkeleton_boneCount"
  native_method :boneCount=, [:int], :int, "rl_m_ModelSkeleton_set_boneCount"
  ffi_func :rl_m_ModelSkeleton_bones, [:ptr], :long
  ffi_func :rl_ModelSkeleton_set_bones_ptr, [:ptr, :ptr], :void
  ffi_func :rl_m_ModelSkeleton_bindPose, [:ptr], :long
  ffi_func :rl_ModelSkeleton_set_bindPose_ptr, [:ptr, :ptr], :void
native_struct "MaterialMap", "rl_MaterialMap"
  native_new [], "rl_MaterialMap_new"
  native_new [:any, :any], "rl_MaterialMap_view_any"
  ffi_func :rl_MaterialMap_texture_ptr, [:ptr], :ptr
  native_method :texture=, [:any], :void, "rl_MaterialMap_set_texture"
  ffi_func :rl_MaterialMap_color, [:ptr, :ptr], :void
  native_method :color=, [:any], :void, "rl_MaterialMap_set_color"
  native_method :value, [], :float, "rl_m_MaterialMap_value"
  native_method :value=, [:float], :float, "rl_m_MaterialMap_set_value"
  ffi_func :rl_m_Material_maps, [:ptr], :long
  ffi_func :rl_Material_set_maps_ptr, [:ptr, :ptr], :void
  ffi_func :rl_m_Material_params, [:ptr], :long
  ffi_func :rl_Material_set_params_ptr, [:ptr, :ptr], :void
  ffi_func :rl_m_Model_meshCount_v, [:ptr], :int
  ffi_func :rl_m_Model_materialCount_v, [:ptr], :int
  ffi_func :rl_m_Model_boneCount_v, [:ptr], :int

  native_struct "Material", "rl_Material"
  native_method :shader=, [:any], :void, "rl_Material_set_shader_any"
  native_new [], "rl_Material_new"
  native_new [:any, :any], "rl_Material_view"
  native_new [:any], "rl_Material_view_addr"

  native_struct "Mesh", "rl_Mesh"
  native_new [], "rl_Mesh_new"
  native_new [:any, :any], "rl_Mesh_view"
  native_new [:any], "rl_Mesh_view_addr"
  native_method :vertexCount, [], :int, "rl_m_Mesh_vertexCount"
  native_method :vertexCount=, [:int], :int, "rl_m_Mesh_set_vertexCount"
  native_method :triangleCount, [], :int, "rl_m_Mesh_triangleCount"
  ffi_func :rl_m_Mesh_vertices, [:ptr], :long
  native_method :vertices=, [:any], :void, "rl_m_Mesh_set_vertices"
  ffi_func :rl_m_Mesh_texcoords, [:ptr], :long
  native_method :texcoords=, [:any], :void, "rl_m_Mesh_set_texcoords"
  ffi_func :rl_m_Mesh_texcoords2, [:ptr], :long
  native_method :texcoords2=, [:any], :void, "rl_m_Mesh_set_texcoords2"
  ffi_func :rl_m_Mesh_normals, [:ptr], :long
  native_method :normals=, [:any], :void, "rl_m_Mesh_set_normals"
  ffi_func :rl_m_Mesh_tangents, [:ptr], :long
  native_method :tangents=, [:any], :void, "rl_m_Mesh_set_tangents"
  ffi_func :rl_m_Mesh_colors, [:ptr], :long
  native_method :colors=, [:any], :void, "rl_m_Mesh_set_colors"
  ffi_func :rl_m_Mesh_indices, [:ptr], :long
  native_method :indices=, [:any], :void, "rl_m_Mesh_set_indices"
  native_method :triangleCount=, [:int], :int, "rl_m_Mesh_set_triangleCount"

  native_struct "Shader", "rl_Shader"
  native_new [], "rl_Shader_new"
  native_new [:any, :any], "rl_Shader_view"
  native_new [:any], "rl_Shader_view_addr"
  native_method :id, [], :int, "rl_m_Shader_id"
  native_method :id=, [:int], :int, "rl_m_Shader_set_id"

  ffi_func :rl_Model_bone_ptr, [:ptr, :int], :ptr
  ffi_func :rl_Model_bind_pose_ptr, [:ptr, :int], :ptr
  ffi_func :rl_ModelAnimation_frame_pose_bone_ptr, [:ptr, :int, :int], :ptr

  native_struct "BoneInfo", "rl_BoneInfo"
  native_new [], "rl_BoneInfo_new"
  native_new [:any, :any], "rl_BoneInfo_view"
  native_new [:any], "rl_BoneInfo_view_addr"
  native_method :parent_bone_index, [], :int, "rl_m_BoneInfo_parent_bone_index"
  native_method :parent_bone_index=, [:int], :int, "rl_m_BoneInfo_set_parent_bone_index"

  native_struct "Transform", "rl_Transform"
  native_new [], "rl_Transform_new"
  native_new [:any, :any], "rl_Transform_view_any"
  native_new [:any], "rl_Transform_view_addr"
  native_method :translation=, [:any], :void, "rl_Transform_set_translation"
  native_method :rotation=, [:any], :void, "rl_Transform_set_rotation"
  native_method :scale=, [:any], :void, "rl_Transform_set_scale"

  native_struct "ModelAnimation", "rl_ModelAnimation"
  native_new [], "rl_ModelAnimation_new"
  native_new [:any, :any], "rl_ModelAnimation_view"
  native_new [:any], "rl_ModelAnimation_view_addr"
  native_method :keyframeCount, [], :int, "rl_m_ModelAnimation_keyframeCount"
  native_method :keyframeCount=, [:int], :int, "rl_m_ModelAnimation_set_keyframeCount"
  native_method :boneCount, [], :int, "rl_m_ModelAnimation_boneCount"
  native_method :boneCount=, [:int], :int, "rl_m_ModelAnimation_set_boneCount"
end
