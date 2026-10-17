# frozen_string_literal: true

# Field accessors for the small structs whose writers the generator does not
# emit (it covers scalars only) plus the gem's names where ours differed
# (BoneInfo#parent vs our parent_bone_index). Hand-written, so regenerating
# raylib_ffi.rb cannot drop them.
module Raylib
  native_struct "Ray", "rl_Ray"
  ffi_func :rl_Ray_position, [:ptr, :ptr], :void
  native_method :position=, [:any], :void, "rl_Ray_set_position"
  ffi_func :rl_Ray_direction, [:ptr, :ptr], :void
  native_method :direction=, [:any], :void, "rl_Ray_set_direction"

  native_struct "RayCollision", "rl_RayCollision"
  native_method :hit, [], :bool, "rl_m_RayCollision_hit"
  native_method :hit=, [:bool], :bool, "rl_m_RayCollision_set_hit"
  ffi_func :rl_RayCollision_point, [:ptr, :ptr], :void
  native_method :point=, [:any], :void, "rl_RayCollision_set_point"
  ffi_func :rl_RayCollision_normal, [:ptr, :ptr], :void
  native_method :normal=, [:any], :void, "rl_RayCollision_set_normal"

  native_struct "BoneInfo", "rl_BoneInfo"
  ffi_func :rl_BoneInfo_name, [:ptr], :str
  ffi_func :rl_BoneInfo_set_name, [:ptr, :str], :void
  native_method :parent, [], :int, "rl_m_BoneInfo_parent"
  native_method :parent=, [:int], :int, "rl_m_BoneInfo_set_parent"

  native_struct "RenderTexture", "rl_RenderTexture"
  native_method :id, [], :int, "rl_m_RenderTexture_id"
  native_method :id=, [:int], :int, "rl_m_RenderTexture_set_id"
  native_method :texture=, [:any], :void, "rl_RenderTexture_set_texture"
  native_method :depth=, [:any], :void, "rl_RenderTexture_set_depth"
  native_struct "Mesh", "rl_Mesh"
  ffi_func :rl_m_Mesh_animVertices, [:ptr], :long
  native_method :animVertices=, [:any], :void, "rl_Mesh_set_animVertices"
  ffi_func :rl_m_Mesh_animNormals, [:ptr], :long
  native_method :animNormals=, [:any], :void, "rl_Mesh_set_animNormals"
  ffi_func :rl_m_Mesh_boneIndices, [:ptr], :long
  native_method :boneIndices=, [:any], :void, "rl_Mesh_set_boneIndices"
  ffi_func :rl_m_Mesh_boneWeights, [:ptr], :long
  native_method :boneWeights=, [:any], :void, "rl_Mesh_set_boneWeights"
  native_method :boneCount, [], :int, "rl_m_Mesh_boneCount"
  native_method :boneCount=, [:int], :int, "rl_m_Mesh_set_boneCount"
  native_method :vaoId, [], :int, "rl_m_Mesh_vaoId"
  native_method :vaoId=, [:int], :int, "rl_m_Mesh_set_vaoId"
  ffi_func :rl_m_Mesh_vboId, [:ptr], :long
  native_method :vboId=, [:any], :void, "rl_Mesh_set_vboId"

  native_struct "ModelAnimation", "rl_ModelAnimation"
  ffi_func :rl_ModelAnimation_name, [:ptr], :str
  ffi_func :rl_ModelAnimation_set_name, [:ptr, :str], :void
  ffi_func :rl_m_ModelAnimation_keyframePoses, [:ptr], :long
  native_method :keyframePoses=, [:any], :void, "rl_ModelAnimation_set_keyframePoses"
  native_struct "Shader", "rl_Shader"
  ffi_func :rl_m_Shader_locs, [:ptr], :long
  native_method :locs=, [:any], :void, "rl_Shader_set_locs"

  native_struct "BoundingBox", "rl_BoundingBox"
  native_method :min=, [:any], :void, "rl_BoundingBox_set_min"
  native_method :max=, [:any], :void, "rl_BoundingBox_set_max"

  native_struct "NPatchInfo", "rl_NPatchInfo"
  ffi_func :rl_NPatchInfo_source, [:ptr, :ptr], :void
  native_method :source=, [:any], :void, "rl_NPatchInfo_set_source"

  native_struct "FilePathList", "rl_FilePathList"
  ffi_func :rl_m_FilePathList_paths, [:ptr], :long
  native_method :paths=, [:any], :void, "rl_FilePathList_set_paths"
  native_struct "VrDeviceInfo", "rl_VrDeviceInfo"
  ffi_func :rl_m_VrDeviceInfo_lensDistortionValues, [:ptr], :long
  native_method :lensDistortionValues=, [:any], :void, "rl_VrDeviceInfo_set_lensDistortionValues"
  ffi_func :rl_m_VrDeviceInfo_chromaAbCorrection, [:ptr], :long
  native_method :chromaAbCorrection=, [:any], :void, "rl_VrDeviceInfo_set_chromaAbCorrection"

  native_struct "VrStereoConfig", "rl_VrStereoConfig"
  ffi_func :rl_m_VrStereoConfig_projection, [:ptr], :long
  native_method :projection=, [:any], :void, "rl_VrStereoConfig_set_projection"
  ffi_func :rl_m_VrStereoConfig_viewOffset, [:ptr], :long
  native_method :viewOffset=, [:any], :void, "rl_VrStereoConfig_set_viewOffset"
  ffi_func :rl_m_VrStereoConfig_leftLensCenter, [:ptr], :long
  native_method :leftLensCenter=, [:any], :void, "rl_VrStereoConfig_set_leftLensCenter"
  ffi_func :rl_m_VrStereoConfig_rightLensCenter, [:ptr], :long
  native_method :rightLensCenter=, [:any], :void, "rl_VrStereoConfig_set_rightLensCenter"
  ffi_func :rl_m_VrStereoConfig_leftScreenCenter, [:ptr], :long
  native_method :leftScreenCenter=, [:any], :void, "rl_VrStereoConfig_set_leftScreenCenter"
  ffi_func :rl_m_VrStereoConfig_rightScreenCenter, [:ptr], :long
  native_method :rightScreenCenter=, [:any], :void, "rl_VrStereoConfig_set_rightScreenCenter"
  ffi_func :rl_m_VrStereoConfig_scale, [:ptr], :long
  native_method :scale=, [:any], :void, "rl_VrStereoConfig_set_scale"
  ffi_func :rl_m_VrStereoConfig_scaleIn, [:ptr], :long
  native_method :scaleIn=, [:any], :void, "rl_VrStereoConfig_set_scaleIn"

  native_struct "AutomationEvent", "rl_AutomationEvent"
  ffi_func :rl_m_AutomationEvent_params, [:ptr], :long
  native_method :params=, [:any], :void, "rl_AutomationEvent_set_params"

  native_struct "GlyphInfo", "rl_GlyphInfo"
  native_method :image=, [:any], :void, "rl_GlyphInfo_set_image"

  native_struct "AutomationEventList", "rl_AutomationEventList"
  native_method :events=, [:any], :void, "rl_AutomationEventList_set_events"
end
