# gem compatibility audit

Baseline: installed raylib-bindings gem + generator JSONs (raylib 6.1). Tool: `tools/gem_compat_audit.py`.

## Functions

| lib | total | ok | shim-only | arity-gap | missing |
| --- | --- | --- | --- | --- | --- |
| raylib | 619 | 612 | 0 | 5 | 2 |
| raymath | 146 | 146 | 0 | 0 | 0 |
| rlgl | 163 | 163 | 0 | 0 | 0 |
| physac | 19 | 18 | 1 | 0 | 0 |
| rcamera | 12 | 12 | 0 | 0 | 0 |
| raygui | 61 | 61 | 0 | 0 | 0 |

### Arity/signature gaps

`raylib:DrawTextureEx`, `raylib:LoadRenderTexture`, `raylib:LoadShader`, `raylib:LoadShaderFromMemory`, `raylib:LoadTextureCubemap`


### Missing functions

`raylib:TextFormat`, `raylib:internalDrawModelEx`


## Structs

Missing classes (21): `AudioStream`, `BoneInfo`, `Camera3D`, `Font`, `GlyphInfo`, `Image`, `Material`, `MaterialMap`, `Mesh`, `Model`, `ModelAnimation`, `ModelSkeleton`, `Music`, `RenderTexture`, `RenderTexture2D`, `Shader`, `Sound`, `Texture`, `Texture2D`, `TextureCubemap`, `Wave`

Field gaps (12):

- AutomationEvent: params
- AutomationEventList: events
- BoundingBox: max, min
- Camera: position, target, up
- Camera2D: offset, target
- FilePathList: paths
- NPatchInfo: source
- Ray: direction, position
- RayCollision: normal, point
- Transform: rotation, scale, translation
- VrDeviceInfo: chromaAbCorrection, lensDistortionValues
- VrStereoConfig: leftLensCenter, leftScreenCenter, projection, rightLensCenter, rightScreenCenter, scale, scaleIn, viewOffset

## Helpers

Missing helper methods (58):

- instance:BoneInfo.parent_bone_index
- class:BoundingBox.create
- instance:BoundingBox.with_max
- instance:BoundingBox.with_min
- instance:Camera2D.with_offset
- instance:Camera2D.with_rotation
- instance:Camera2D.with_target
- instance:Camera2D.with_zoom
- instance:Camera3D.with_fovy
- instance:Camera3D.with_position
- instance:Camera3D.with_projection
- instance:Camera3D.with_target
- instance:Camera3D.with_up
- instance:Color.copy
- class:Color.set
- instance:Color.set
- instance:Model.bind_pose_transform
- instance:Model.bone_count
- instance:Model.bone_info
- instance:Model.material
- instance:Model.material_count
- instance:ModelAnimations.anim
- instance:ModelAnimations.anims_count
- instance:ModelAnimations.bone_info
- instance:ModelAnimations.bone_transform
- instance:ModelAnimations.bone_transform_of_frame_pose
- instance:ModelAnimations.cleanup
- instance:ModelAnimations.frame_count
- instance:ModelAnimations.frame_pose
- instance:ModelAnimations.initialize
- instance:ModelAnimations.setup
- class:Quaternion.copy_from
- class:Quaternion.create
- instance:Quaternion.set
- instance:Quaternion.to_a
- module:Raylib.LoadAndAllocateModelAnimations
- module:Raylib.MatrixToFloat
- module:Raylib.UnloadAndFreeModelAnimations
- module:Raylib.Vector3ToFloat
- class:Rectangle.create
- instance:Rectangle.set
- instance:Transform.r
- instance:Transform.s
- instance:Transform.t
- instance:Vector2.add
- instance:Vector2.add_vector
- class:Vector2.copy_from
- class:Vector2.create
- instance:Vector2.set
- instance:Vector2.to_a
- class:Vector3.copy_from
- class:Vector3.create
- instance:Vector3.set
- instance:Vector3.to_a
- class:Vector4.copy_from
- class:Vector4.create
- instance:Vector4.set
- instance:Vector4.to_a

## Constants

Missing constants (1): `RAYLIB_VERSION`
