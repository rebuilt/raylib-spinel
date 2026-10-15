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
| 10_models.rb | run-error | run-error: undefined method 'meshCount' for an instance of  (NoMethodError) |

9/10 run identically under both engines.
