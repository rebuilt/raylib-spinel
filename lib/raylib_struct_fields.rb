# frozen_string_literal: true

# Field accessors for the small structs whose writers the generator does not
# emit (it covers scalars only) plus the gem's names where ours differed
# (BoneInfo#parent vs our parent_bone_index). Hand-written, so regenerating
# raylib_ffi.rb cannot drop them.
module Raylib
  native_struct "Ray", "rl_Ray"
  ffi_func :rl_Ray_position, [:ptr, :ptr], :void
  native_method :position=, [:ptr], :void, "rl_Ray_set_position"
  ffi_func :rl_Ray_direction, [:ptr, :ptr], :void
  native_method :direction=, [:ptr], :void, "rl_Ray_set_direction"

  native_struct "RayCollision", "rl_RayCollision"
  native_method :hit, [], :bool, "rl_m_RayCollision_hit"
  native_method :hit=, [:bool], :bool, "rl_m_RayCollision_set_hit"
  ffi_func :rl_RayCollision_point, [:ptr, :ptr], :void
  native_method :point=, [:ptr], :void, "rl_RayCollision_set_point"
  ffi_func :rl_RayCollision_normal, [:ptr, :ptr], :void
  native_method :normal=, [:ptr], :void, "rl_RayCollision_set_normal"

  native_struct "BoneInfo", "rl_BoneInfo"
  ffi_func :rl_BoneInfo_name, [:ptr], :str
  ffi_func :rl_BoneInfo_set_name, [:ptr, :str], :void
  native_method :parent, [], :int, "rl_m_BoneInfo_parent"
  native_method :parent=, [:int], :int, "rl_m_BoneInfo_set_parent"

  native_struct "RenderTexture", "rl_RenderTexture"
  native_method :id, [], :int, "rl_m_RenderTexture_id"
  native_method :id=, [:int], :int, "rl_m_RenderTexture_set_id"
  native_method :texture=, [:ptr], :void, "rl_RenderTexture_set_texture"
  native_method :depth=, [:ptr], :void, "rl_RenderTexture_set_depth"
end
