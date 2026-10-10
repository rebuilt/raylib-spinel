# Opt-in raymath loader.
#
# `require "raylib-spinel/raymath"` exposes the raymath math functions under
# Raylib (Vector2Add, Vector2Scale, ...) on both backends.
#   - MRI: the raylib-bindings gem already binds every raymath function onto
#     Raylib, so there is nothing to do; the gem's raymath.rb is loaded as
#     part of `require "raylib-spinel"`.
#   - Spinel: the literal require_relative below is spliced at compile time and
#     drags in lib/raymath_ffi.rb, whose module Raylib blocks declare the same
#     PascalCase surface (the sp_* pointer shims live in raylib_adapter.c).
if $PROGRAM_NAME.end_with?(".rb")
  # no-op under CRuby
else
  require_relative "../lib/raymath_ffi"
end