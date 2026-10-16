# frozen_string_literal: true

# raylib.rb — MRI-compatible entry point for `require "raylib"`.
#
# raylib-bindings projects start with `require "raylib"`. This file is the
# raylib-spinel package's entry under that name, so unmodified gem code builds
# with `spin`:
#
#   MRI:    raylib-spinel.rb is a no-op (the gem provides the API); loading it
#           is all that is needed.
#   Spinel: load the full gem-shaped surface — all six libraries, the bundled
#           ffi package, and the include-able instance methods from
#           lib/raylib_include.rb — so `include Raylib` and bare calls work.
#
# The `$PROGRAM_NAME` discriminator mirrors the rest of the package; both
# branches are parsed, only the active one runs.
if $PROGRAM_NAME.end_with?(".rb")
  require_relative "raylib-spinel"
else
  require "ffi"
  require_relative "raylib-spinel"
  require_relative "raylib-spinel/raymath"
  require_relative "raylib-spinel/rcamera"
  require_relative "raylib-spinel/rlgl"
  require_relative "raylib-spinel/raygui"
  require_relative "raylib-spinel/physac"
  require_relative "lib/raylib_include"
  require_relative "lib/raylib_compat"
  require_relative "lib/raylib_structs"
  require_relative "lib/raylib_pointer_fields"
  require_relative "lib/raygui_compat"
end
