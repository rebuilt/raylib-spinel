# frozen_string_literal: true

# Opt-in rlgl loader for Spinel AOT.
#
# `require "raylib-spinel/rlgl"` splices in lib/rlgl_ffi.rb, whose Rlgl module
# declares the immediate-mode rl* functions (resolved against libraylib) plus
# the sp_* matrix/renderbatch shims. Under CRuby the raylib-bindings gem already
# exposes rlgl via its Rlgl module.
if $PROGRAM_NAME.end_with?(".rb")
  # no-op under CRuby
else
  require_relative "../lib/rlgl_ffi"
end
