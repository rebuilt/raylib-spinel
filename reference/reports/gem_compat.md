# gem compatibility audit

Baseline: installed raylib-bindings gem + generator JSONs (raylib 6.1). Tool: `tools/gem_compat_audit.rb`.

## Functions

| lib | total | ok | shim-only | arity-gap | missing |
| --- | --- | --- | --- | --- | --- |
| raylib | 619 | 613 | 0 | 4 | 2 |
| raymath | 146 | 146 | 0 | 0 | 0 |
| rlgl | 163 | 163 | 0 | 0 | 0 |
| physac | 19 | 18 | 1 | 0 | 0 |
| rcamera | 12 | 12 | 0 | 0 | 0 |
| raygui | 61 | 61 | 0 | 0 | 0 |

### Arity/signature gaps

`raylib:LoadRenderTexture`, `raylib:LoadShader`, `raylib:LoadShaderFromMemory`, `raylib:LoadTextureCubemap`


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

Missing helper methods (37):

- instance:BoneInfo.parent_bone_index
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
- instance:Model.material
- instance:Model.material_count
- instance:ModelAnimations.anim
- instance:ModelAnimations.anims_count
- instance:ModelAnimations.bone_transform
- instance:ModelAnimations.bone_transform_of_frame_pose
- instance:ModelAnimations.cleanup
- instance:ModelAnimations.frame_count
- instance:ModelAnimations.frame_pose
- instance:ModelAnimations.initialize
- instance:ModelAnimations.setup
- class:Quaternion.copy_from
- instance:Quaternion.to_a
- module:Raylib.LoadAndAllocateModelAnimations
- module:Raylib.MatrixToFloat
- module:Raylib.UnloadAndFreeModelAnimations
- module:Raylib.Vector3ToFloat
- instance:Vector2.add
- instance:Vector2.add_vector
- class:Vector2.copy_from
- instance:Vector2.to_a
- class:Vector3.copy_from
- instance:Vector3.to_a
- class:Vector4.copy_from
- instance:Vector4.to_a

## Constants

Missing constants (1): `RAYLIB_VERSION`
