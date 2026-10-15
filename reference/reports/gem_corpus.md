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

10/10 run identically under both engines.

## raylib-bindings examples (loader line replaced, `spinel -c`)

| verdict | count |
| --- | --- |
| analyzed | 56 |
| bare-call | 1 |
| invalid | 3 |
| refusal | 10 |

70 examples total.


Invalid upstream (excluded from the target):

- models_animation_blending.gpu.rb — calls UpdateModelAnimationBonesLerp (not in raylib 6.1 or gem 0.8.4; NoMethodError under CRuby)
- textures_background_scrolling.rb — calls unloadtexture (typo; NoMethodError under CRuby)
- textures_bunnymark_optimized.rb — calls Vector2#add! (not defined by the gem; NoMethodError under CRuby)
First bare-call blocker (same shape for all 1):

```
/tmp/tmpajzl32gf/shaders_basic_pbr.rb:356: unsupported call: node 97912 (CallNode `size`) recv=ConstantReadNode/ty49 argc=0
```
