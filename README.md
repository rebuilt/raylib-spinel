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
