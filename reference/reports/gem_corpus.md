# gem corpus results

Tool: `tools/run_gem_corpus.py`. Oracle: CRuby + raylib-bindings; Spinel: `spinel` with `spin flags`.

## Synthetic corpus (CRuby vs Spinel, same output)

| program | verdict | detail |
| --- | --- | --- |
| 01_structs.rb | compile-error | /home/nelson/workspace/ruby/spinel/raylib-spinel/reference/gem_corpus/01_structs.rb:5: undefined method 'create' for a Class: no class in the program defines a class method 'create' (NoMethodError) |
| 02_textformat.rb | compile-error | /home/nelson/workspace/ruby/spinel/raylib-spinel/reference/gem_corpus/02_textformat.rb:5: unsupported puts argument: node 18106 (CallNode `read_string`) recv=CallNode/ty0 argc=0 |
| 03_constants.rb | compile-error | /home/nelson/workspace/ruby/spinel/raylib-spinel/reference/gem_corpus/03_constants.rb:11: unsupported puts argument: node 18145 (CallNode `round`) recv=ConstantPathNode/ty0 argc=1 arg0ty3 |
| 04_raymath.rb | compile-error | /home/nelson/workspace/ruby/spinel/raylib-spinel/reference/gem_corpus/04_raymath.rb:5: undefined method 'create' for a Class: no class in the program defines a class method 'create' (NoMethodError) |
| 05_raygui_state.rb | compile-error | /home/nelson/workspace/ruby/spinel/raylib-spinel/reference/gem_corpus/05_raygui_state.rb:5: undefined method 'GuiIsLocked' for a Class: no class in the program defines a class method 'GuiIsLocked' (NoMethodError) |
| 06_files.rb | run-error | run-error: undefined method 'read_string' for an instance of String (NoMethodError) |
| 07_window.rb | same |  |
| 08_shapes.rb | compile-error | /home/nelson/workspace/ruby/spinel/raylib-spinel/reference/gem_corpus/08_shapes.rb:7: undefined method 'create' for a Class: no class in the program defines a class method 'create' (NoMethodError) |
| 09_textures.rb | compile-error | /home/nelson/workspace/ruby/spinel/raylib-spinel/reference/gem_corpus/09_textures.rb:9: undefined method 'create' for a Class: no class in the program defines a class method 'create' (NoMethodError) |
| 10_models.rb | run-error | run-error: undefined method 'meshCount' for an instance of  (NoMethodError) |

1/10 run identically under both engines.

## raylib-bindings examples (loader line replaced, `spinel -c`)

| verdict | count |
| --- | --- |
| analyzed | 10 |
| bare-call | 2 |
| refusal | 58 |

70 examples total.

First bare-call blocker (same shape for all 2):

```
/tmp/tmpmrs1y1yk/core_loading_thread.rb:1352: unsupported call: node 43304 (CallNode `TraceLog`) recv=-/ty-1 argc=2 arg0ty3
```
