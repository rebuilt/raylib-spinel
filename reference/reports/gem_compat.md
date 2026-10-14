# gem compatibility audit

Baseline: installed raylib-bindings gem + generator JSONs (raylib 6.1). Tool: `tools/gem_compat_audit.py`.

## Functions

| lib | total | ok | shim-only | arity-gap | missing |
| --- | --- | --- | --- | --- | --- |
| raylib | 619 | 611 | 0 | 5 | 3 |
| raymath | 146 | 146 | 0 | 0 | 0 |
| rlgl | 163 | 163 | 0 | 0 | 0 |
| physac | 19 | 14 | 0 | 5 | 0 |
| rcamera | 12 | 12 | 0 | 0 | 0 |
| raygui | 61 | 25 | 0 | 36 | 0 |

### Arity/signature gaps

`raylib:DrawTextureEx`, `raylib:LoadRenderTexture`, `raylib:LoadShader`, `raylib:LoadShaderFromMemory`, `raylib:LoadTextureCubemap`, `physac:CreatePhysicsBodyCircle`, `physac:CreatePhysicsBodyPolygon`, `physac:CreatePhysicsBodyRectangle`, `physac:GetPhysicsShapeVertex`, `physac:PhysicsAddForce`, `raygui:GuiButton`, `raygui:GuiCheckBox`, `raygui:GuiColorBarAlpha`, `raygui:GuiColorBarHue`, `raygui:GuiColorPanel`, `raygui:GuiColorPanelHSV`, `raygui:GuiColorPicker`, `raygui:GuiColorPickerHSV`, `raygui:GuiComboBox`, `raygui:GuiDropdownBox`, `raygui:GuiDummyRec`, `raygui:GuiGrid`, `raygui:GuiGroupBox`, `raygui:GuiLabel`, `raygui:GuiLabelButton`, `raygui:GuiLine`, `raygui:GuiListView`, `raygui:GuiListViewEx`, `raygui:GuiMessageBox`, `raygui:GuiPanel`, `raygui:GuiProgressBar`, `raygui:GuiScrollPanel`, `raygui:GuiSlider`, `raygui:GuiSliderBar`, `raygui:GuiSpinner`, `raygui:GuiStatusBar`, `raygui:GuiTabBar`, `raygui:GuiTabBarEx`, `raygui:GuiTextBox`, `raygui:GuiTextInputBox`, `raygui:GuiToggle`, `raygui:GuiToggleGroup`, `raygui:GuiToggleSlider`, `raygui:GuiValueBox`, `raygui:GuiValueBoxFloat`, `raygui:GuiWindowBox`


### Missing functions

`raylib:TextFormat`, `raylib:TraceLog`, `raylib:internalDrawModelEx`


## Structs

Missing classes (22): `AudioStream`, `BoneInfo`, `Camera3D`, `Font`, `GlyphInfo`, `Image`, `Material`, `MaterialMap`, `Mesh`, `Model`, `ModelAnimation`, `ModelSkeleton`, `Music`, `RenderTexture`, `RenderTexture2D`, `Shader`, `Sound`, `Texture`, `Texture2D`, `TextureCubemap`, `Transform`, `Wave`

Field gaps (11):

- AutomationEvent: params
- AutomationEventList: events
- BoundingBox: max, min
- Camera: fovy, position, projection, target, up
- Camera2D: offset, target
- FilePathList: paths
- NPatchInfo: source
- Ray: direction, position
- RayCollision: normal, point
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

Missing constants (322): `ARROWS_SIZE`, `ARROWS_VISIBLE`, `ARROW_PADDING`, `BASEPROP16`, `BASE_COLOR_DISABLED`, `BORDER_COLOR_DISABLED`, `CHECK_PADDING`, `COLOR_SELECTOR_SIZE`, `COMBO_BUTTON_SPACING`, `COMBO_BUTTON_WIDTH`, `DROPDOWN_ARROW_HIDDEN`, `DROPDOWN_ITEMS_SPACING`, `DROPDOWN_ROLL_UP`, `EXTPROP08`, `GROUP_PADDING`, `GROUP_WIDTH_FULL`, `HUEBAR_PADDING`, `HUEBAR_SELECTOR_HEIGHT`, `HUEBAR_SELECTOR_OVERFLOW`, `HUEBAR_WIDTH`, `ICON_1UP`, `ICON_ALARM`, `ICON_ALPHA_CLEAR`, `ICON_ALPHA_MULTIPLY`, `ICON_ARROW_DOWN`, `ICON_ARROW_DOWN_FILL`, `ICON_ARROW_LEFT`, `ICON_ARROW_LEFT_FILL`, `ICON_ARROW_RIGHT`, `ICON_ARROW_RIGHT_FILL`, `ICON_ARROW_UP`, `ICON_ARROW_UP_FILL`, `ICON_AUDIO`, `ICON_BIN`, `ICON_BOX`, `ICON_BOX_BOTTOM`, `ICON_BOX_BOTTOM_LEFT`, `ICON_BOX_BOTTOM_RIGHT`, `ICON_BOX_CENTER`, `ICON_BOX_CIRCLE_MASK`, `ICON_BOX_CONCENTRIC`, `ICON_BOX_CORNERS_BIG`, `ICON_BOX_CORNERS_SMALL`, `ICON_BOX_DOTS_BIG`, `ICON_BOX_DOTS_SMALL`, `ICON_BOX_GRID`, `ICON_BOX_GRID_BIG`, `ICON_BOX_LEFT`, `ICON_BOX_MINUS`, `ICON_BOX_MINUS_FILL`, `ICON_BOX_MORE`, `ICON_BOX_MORE_FILL`, `ICON_BOX_MULTISIZE`, `ICON_BOX_RIGHT`, `ICON_BOX_TOP`, `ICON_BOX_TOP_LEFT`, `ICON_BOX_TOP_RIGHT`, `ICON_BREAKPOINT_OFF`, `ICON_BREAKPOINT_ON`, `ICON_BRUSH_CLASSIC`, `ICON_BRUSH_PAINTER`, `ICON_BURGER_MENU`, `ICON_CAMERA`, `ICON_CAPSULE`, `ICON_CASE_SENSITIVE`, `ICON_CIRCLE_ADD`, `ICON_CIRCLE_ADD_FILL`, `ICON_CIRCLE_WARNING`, `ICON_CIRCLE_WARNING_FILL`, `ICON_CLOCK`, `ICON_COIN`, `ICON_COLLISION`, `ICON_COLOR_BUCKET`, `ICON_COLOR_PICKER`, `ICON_CONE`, `ICON_CORNER`, `ICON_CPU`, `ICON_CRACK`, `ICON_CRACK_POINTS`, `ICON_CROP` …
