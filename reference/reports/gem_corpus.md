# gem corpus results

Tool: `tools/run_gem_corpus.py`. Oracle: CRuby + raylib-bindings; Spinel: `spinel` with `spin flags`.

## Synthetic corpus (CRuby vs Spinel, same output)

| program | verdict | detail |
| --- | --- | --- |
| 01_structs.rb | same |  |
| 02_textformat.rb | same |  |
| 03_constants.rb | same |  |
| 04_raymath.rb | same |  |
| 05_raygui_state.rb | same |  |
| 06_files.rb | same |  |
| 07_window.rb | same |  |
| 08_shapes.rb | same |  |
| 09_textures.rb | same |  |
| 10_models.rb | same |  |
| 11_render_texture.rb | same |  |
| 12_field_index.rb | same |  |
| 13_pointer_fields.rb | same |  |
| 14_font_fields.rb | same |  |

14/14 run identically under both engines.

## raylib-bindings examples (loader line replaced, `spinel -c`)

| verdict | count |
| --- | --- |
| analyzed | 57 |
| bare-call | 1 |
| invalid | 7 |
| refusal | 5 |

70 examples total.


Invalid upstream (excluded from the target):

- models_animation_blending.gpu.rb — calls UpdateModelAnimationBonesLerp (not in raylib 6.1 or gem 0.8.4; NoMethodError under CRuby)
- models_animation_lowlevelapi.rb — calls UnloadModelAnimation (singular); the loaded gem binds only the plural UnloadModelAnimations
- rlgl_compute_shader.rb — calls rlLoadComputeShaderProgram/rlCompileShader; the loaded gem exposes rlLoadShaderProgramCompute instead and has no rlCompileShader
- shapes_basic_shapes.rb — calls DrawCircleGradient(x, y, radius, ...); the loaded gem binds the raylib-6 signature (Vector2 center, float radius, ...)
- text_font_sdf.rb — calls LoadFontData with 6 arguments; the loaded gem binds 7 (the last a glyphCount out-pointer), so both engines raise ArgumentError
- textures_background_scrolling.rb — calls unloadtexture (typo; NoMethodError under CRuby)
- textures_bunnymark_optimized.rb — calls Vector2#add! (not defined by the gem; NoMethodError under CRuby)
First bare-call blocker (same shape for all 1):

```
/tmp/tmp084mmvtj/textures_bunnymark_plain.rb:48: unsupported call operator write (unsupported receiver/attr): node 94283 (CallOperatorWriteNode)
```

## Examples run (asset-free subset, CRuby vs Spinel under Xvfb)

| example | verdict | detail |
| --- | --- | --- |
| gui_controls.rb | skipped | builds its list view with Array#pack('p*'); Spinel's pack('p*') emits a single pointer whatever the element count, so the char** is unusable (see tools/repro/upstream/issue-d). The program runs (the shim clamps the item count), but it renders differently from CRuby |
| snake_case_api.rb | skipped | uses Gem::Specification (RubyGems API), not the raylib surface |
| snake_case_rlgl.rb | skipped | uses Gem::Specification (RubyGems API), not the raylib surface |
| template.rb | skipped | uses Gem::Specification (RubyGems API), not the raylib surface |
| utf8_font.rb | skipped | reads ./jpfont/jpfont.txt relative to cwd (asset not present) |
| basic_loop.rb | ran | mri shot=3 0.2636 1280x1024 | spinel shot=3 0.2636 1280x1024 |
| bitmap_font.rb | ran | mri shot=5 0.0537 1280x1024 | spinel shot=5 0.0537 1280x1024 |
| core_2d_camera.rb | ran | mri shot=16 0.1658 1280x1024 | spinel shot=16 0.1642 1280x1024 |
| core_3d_camera_first_person.rb | ran | mri shot=9 0.1796 1280x1024 | spinel shot=11 0.1913 1280x1024 |
| core_3d_split_screen.rb | ran | mri shot=6 0.1595 1280x1024 | spinel shot=6 0.1595 1280x1024 |
| core_automation_events.rb | ran | mri shot=10 0.1779 1280x1024 | spinel shot=10 0.1779 1280x1024 |
| core_drop_files.rb | ran | mri shot=3 0.2632 1280x1024 | spinel shot=3 0.2632 1280x1024 |
| core_loading_thread.rb | ran | mri shot=3 0.2623 1280x1024 | spinel shot=3 0.2623 1280x1024 |
| core_world_screen.rb | ran | mri shot=7 0.2592 1280x1024 | spinel shot=7 0.2592 1280x1024 |
| flocking_optimized.rb | ran | mri shot=6 0.3040 1280x1024 | spinel shot=6 0.3040 1280x1024 |
| flocking_plain.rb | ran | mri shot=6 0.3039 1280x1024 | spinel shot=6 0.3042 1280x1024 |
| game_of_life_simple.rb | ran | mri shot=3 0.0135 1280x1024 | spinel shot=3 0.0135 1280x1024 |
| game_of_life_ui.rb | ran | mri shot=9 0.0727 1280x1024 | spinel shot=9 0.0727 1280x1024 |
| lissajous_curve.rb | ran | mri shot=5 0.2209 1280x1024 | spinel shot=5 0.2209 1280x1024 |
| models_box_collisions.rb | ran | mri shot=8 0.2520 1280x1024 | spinel shot=8 0.2520 1280x1024 |
| models_geometric_shapes.rb | ran | mri shot=15 0.2380 1280x1024 | spinel shot=15 0.2380 1280x1024 |
| models_mesh_generation.rb | spinel-error | spinel rc=1 undefined method 'material' for an instance of Raylib::Model |
| models_rlgl_solar_system.rb | ran | mri shot=7 0.2625 1280x1024 | spinel shot=7 0.2625 1280x1024 |
| models_waving_cubes.rb | ran | mri shot=25 0.2188 1280x1024 | spinel shot=25 0.2251 1280x1024 |
| particles_fireworks.rb | ran | mri shot=2 0.0019 1280x1024 | spinel shot=2 0.0019 1280x1024 |
| physics_demo.rb | ran | mri shot=7 0.0021 1280x1024 | spinel shot=7 0.0021 1280x1024 |
| procedural_texture.rb | ran | mri shot=715 0.0946 1280x1024 | spinel shot=715 0.0946 1280x1024 |
| shapes_basic_shapes.rb | mri-error | mri rc=1 	from /tmp/tmprzucjddf/shapes_basic_shapes.rb:17:in '<main>' |
| shapes_draw_circle_sector.rb | ran | mri shot=14 0.2500 1280x1024 | spinel shot=14 0.2500 1280x1024 |
| shapes_lines_bezier.rb | ran | mri shot=10 0.2619 1280x1024 | spinel shot=10 0.2619 1280x1024 |
| text_rectangle_bounds.rb | ran | mri shot=5 0.2415 1280x1024 | spinel shot=5 0.2415 1280x1024 |
| textures_image_generation.rb | ran | mri shot=459 0.1247 1280x1024 | spinel shot=459 0.1247 1280x1024 |
| textures_gif_player.rb | ran | mri shot=8 0.2600 1280x1024 | spinel shot=8 0.2598 1280x1024 |
| textures_mouse_painting.rb | ran | mri shot=23 0.2558 1280x1024 | spinel shot=23 0.2558 1280x1024 |
| toon_character_sprites.rb | ran | mri shot=5 0.5006 1280x1024 | spinel shot=5 0.5008 1280x1024 |

28/35 ran identically enough to render content under both engines (screenshots kept in /tmp/opencode/corpus_shots).
