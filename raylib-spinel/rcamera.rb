# Opt-in rcamera loader.
#
# `require "raylib-spinel/rcamera"` exposes the rcamera camera helpers under
# Raylib (GetCameraForward, CameraYaw, ...) on both backends.
#   - MRI: the raylib-bindings gem already binds every rcamera function onto
#     Raylib, so there is nothing to do.
#   - Spinel: the literal require_relative below is spliced at compile time and
#     drags in lib/rcamera_ffi.rb, whose module Raylib block declares the same
#     PascalCase surface (the rl_* pointer shims live in rcamera_adapter.c;
#     link it with --link lib/rcamera_adapter.o).
if $PROGRAM_NAME.end_with?(".rb")
  # no-op under CRuby
else
  require_relative "../lib/rcamera_ffi"
end
