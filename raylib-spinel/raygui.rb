# frozen_string_literal: true

# Opt-in raygui loader for Spinel AOT.
#
# `require "raylib-spinel/raygui"` splices in lib/raygui_ffi.rb; raygui itself
# is compiled into lib/raygui_adapter.o (linked into the gui scenes). Under
# CRuby the raylib-bindings gem already binds raygui.
if $PROGRAM_NAME.end_with?(".rb")
  # no-op under CRuby
else
  require_relative "../lib/raygui_ffi"
end
