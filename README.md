# Setup
## Create a new spinel app


```bash
# git clone this repo
spin new myapp        # scaffold: spin.toml, bin/myapp.rb, test/, .gitignore
cd myapp
spin add raylib --path ../raylib-spinel

spin run              # compile bin/myapp.rb and run it
```

## Existing raylib-bindings projects

Projects written against the MRI `raylib-bindings` gem need no source changes:
point spin at this package and keep `require "raylib"`. That entry loads the
full gem surface (raylib, raymath, rlgl, rcamera, raygui, physac), the bundled
`ffi` package, and the include-able instance methods, and the gem's
`Raylib.load_lib` / `Raylib.setup_symbols` calls are accepted as no-ops.

```bash
cd my_existing_game
spin add raylib --path ../raylib-spinel
spin run bin/my_game.rb   # `require "raylib"` resolves to this package
```


Create a gemfile

```
source "https://rubygems.org"

gem "raylib-bindings"
gem "debug"


```
Create your game.  Here is an example

```ruby

require "raylib-spinel"

include Raylib

Raylib.InitWindow(1280, 720, "raylib [text] example - Hello World")
Raylib.EnableCursor()
WHITE_TEXT_COLOR = Color.from_u8(255, 255, 255, 255)
BLACK_TEXT_COLOR = Color.from_u8(0, 0, 0, 255)
until Raylib.WindowShouldClose == 1
  Raylib.BeginDrawing
    Raylib.ClearBackground(BLACK_TEXT_COLOR)
    Raylib.DrawFPS(10, 90)

    Raylib.DrawText("Hello World", 10, 10, 20, WHITE_TEXT_COLOR)
  Raylib.EndDrawing

  # Break instead of CloseWindow here: closing mid-frame leaves update/draw
  # running against a dead GL context; teardown happens after the loop.
  is_q_down = Raylib.IsKeyDown(Raylib::KEY_Q)
  break if is_q_down
end

Raylib.CloseWindow()


```

Add a gemfile with raylib-bindings

## Development: generators, audits, corpus

The Spinel surface is generated from the gem's API JSON; the generators keep
the shim layer honest:

```bash
python3 tools/gen_raylib_ffi.py          # ffi_func/wrapper surface + rl_* shims
python3 tools/gen_handle_class_c.py      # handle-class views + Class.size (sizeof)
python3 tools/gen_raylib_include.py      # include-able instance delegators
python3 tools/wrap_handle_producers.py   # wrap Load*/Gen* into view objects
```

Handle classes are GC views (`rl_<X>`: cls_id / payload pointer / owner). Every
shim parameter naming a handle class, by value or by pointer, must unwrap it
(`*RL_TEX(t)`, `RL_IMG(i)`); only flat buffers stay raw. Two audits enforce
that and are safe to run any time:

```bash
python3 tools/check_shim_unwraps.py                # shims + direct decls + undefined symbols
python3 tools/fix_pointer_handle_shims.py --check  # single-struct pointer params unwrapped
ruby tools/check_duplicate_methods.rb              # one definition per module function
```

Verification: `spin test` (headless, MRI-differential expectations) and
`python3 tools/run_gem_corpus.py` (synthetic programs run under CRuby +
raylib-bindings and under Spinel, then diffed; the raylib-bindings examples
with the loader line replaced are compiled to record coverage). The runner
links the gem's libraylib under its SONAME: the system build creates incomplete
FBOs, which shows up as all-zero render-texture readbacks.
