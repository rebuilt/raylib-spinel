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

11/11 run identically under both engines.

## raylib-bindings examples (loader line replaced, `spinel -c`)

| verdict | count |
| --- | --- |
| analyzed | 59 |
| invalid | 6 |
| refusal | 5 |

70 examples total.


Invalid upstream (excluded from the target):

- models_animation_blending.gpu.rb — calls UpdateModelAnimationBonesLerp (not in raylib 6.1 or gem 0.8.4; NoMethodError under CRuby)
- models_animation_lowlevelapi.rb — calls UnloadModelAnimation (singular); the loaded gem binds only the plural UnloadModelAnimations
- rlgl_compute_shader.rb — calls rlLoadComputeShaderProgram/rlCompileShader; the loaded gem exposes rlLoadShaderProgramCompute instead and has no rlCompileShader
- shapes_basic_shapes.rb — calls DrawCircleGradient(x, y, radius, ...); the loaded gem binds the raylib-6 signature (Vector2 center, float radius, ...)
- textures_background_scrolling.rb — calls unloadtexture (typo; NoMethodError under CRuby)
- textures_bunnymark_optimized.rb — calls Vector2#add! (not defined by the gem; NoMethodError under CRuby)
## Examples run (asset-free subset, CRuby vs Spinel under Xvfb)

| example | verdict | detail |
| --- | --- | --- |
| basic_loop.rb | ran | mri shot=3 0.263621 1280x1024 | spinel shot=3 0.263621 1280x1024 |
| bitmap_font.rb | ran | mri shot=5 0.0537468 1280x1024 | spinel shot=5 0.0537468 1280x1024 |
| core_2d_camera.rb | ran | mri shot=18 0.161866 1280x1024 | spinel shot=16 0.164671 1280x1024 |
| core_3d_camera_first_person.rb | ran | mri shot=13 0.20611 1280x1024 | spinel shot=11 0.18117 1280x1024 |
| core_3d_split_screen.rb | ran | mri shot=6 0.159456 1280x1024 | spinel shot=6 0.159456 1280x1024 |
| core_automation_events.rb | ran | mri shot=10 0.177944 1280x1024 | spinel shot=10 0.177944 1280x1024 |
| core_drop_files.rb | ran | mri shot=3 0.263192 1280x1024 | spinel shot=3 0.263192 1280x1024 |
| core_loading_thread.rb | ran | mri shot=3 0.262302 1280x1024 | spinel shot=3 0.262302 1280x1024 |
| core_world_screen.rb | ran | mri shot=7 0.25922 1280x1024 | spinel shot=7 0.25922 1280x1024 |
| flocking_optimized.rb | ran | mri shot=6 0.304237 1280x1024 | spinel shot=6 0.304018 1280x1024 |
| flocking_plain.rb | ran | mri shot=6 0.304072 1280x1024 | spinel shot=6 0.304161 1280x1024 |
| game_of_life_simple.rb | ran | mri shot=3 0.0134672 1280x1024 | spinel shot=3 0.0134672 1280x1024 |
| game_of_life_ui.rb | spinel-error | compile: C compilation failed |
| gui_controls.rb | spinel-error | compile: C compilation failed |
| lissajous_curve.rb | ran | mri shot=5 0.220916 1280x1024 | spinel shot=5 0.220916 1280x1024 |
| models_box_collisions.rb | ran | mri shot=8 0.252021 1280x1024 | spinel shot=8 0.252021 1280x1024 |
| models_geometric_shapes.rb | ran | mri shot=15 0.237963 1280x1024 | spinel shot=15 0.237963 1280x1024 |
| models_mesh_generation.rb | spinel-error | spinel rc=1 undefined method 'triangleCount=' for an instance of Raylib: |
| models_rlgl_solar_system.rb | ran | mri shot=7 0.262474 1280x1024 | spinel shot=7 0.262474 1280x1024 |
| models_waving_cubes.rb | ran | mri shot=25 0.217051 1280x1024 | spinel shot=25 0.225764 1280x1024 |
| particles_fireworks.rb | ran | mri shot=2 0.00192638 1280x1024 | spinel shot=2 0.00192638 1280x1024 |
| physics_demo.rb | ran | mri shot=7 0.00206353 1280x1024 | spinel shot=7 0.00206353 1280x1024 |
| procedural_texture.rb | ran | mri shot=715 0.0945784 1280x1024 | spinel shot=715 0.0945784 1280x1024 |
| shapes_basic_shapes.rb | mri-error | mri rc=1 	from /tmp/tmpfw7wjfa8/shapes_basic_shapes.rb:17:in '<main>' |
| shapes_draw_circle_sector.rb | ran | mri shot=14 0.250008 1280x1024 | spinel shot=14 0.250008 1280x1024 |
| shapes_lines_bezier.rb | ran | mri shot=10 0.26191 1280x1024 | spinel shot=10 0.26191 1280x1024 |
| snake_case_api.rb | skipped | uses Gem::Specification (RubyGems API), not the raylib surface |
| snake_case_rlgl.rb | skipped | uses Gem::Specification (RubyGems API), not the raylib surface |
| template.rb | skipped | uses Gem::Specification (RubyGems API), not the raylib surface |
| text_rectangle_bounds.rb | ran | mri shot=5 0.241475 1280x1024 | spinel shot=5 0.241475 1280x1024 |
| textures_image_generation.rb | ran | mri shot=459 0.12471 1280x1024 | spinel shot=459 0.12471 1280x1024 |
| textures_mouse_painting.rb | ran | mri shot=23 0.255827 1280x1024 | spinel shot=23 0.255827 1280x1024 |
| toon_character_sprites.rb | ran | mri shot=5 0.500409 1280x1024 | spinel shot=5 0.500668 1280x1024 |
| utf8_font.rb | skipped | reads ./jpfont/jpfont.txt relative to cwd (asset not present) |

26/34 ran identically enough to render content under both engines (screenshots kept in /tmp/opencode/corpus_shots).
