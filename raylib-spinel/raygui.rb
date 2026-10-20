# frozen_string_literal: true

# Opt-in raygui loader for Spinel AOT.
#
# `require "raylib-spinel/raygui"` splices in lib/raygui_ffi.rb; raygui itself
# is compiled into lib/raygui_adapter.o (linked into the gui scenes). Under
# CRuby the raylib-bindings gem already binds raygui.
if RUBY_ENGINE == "spinel"
  require_relative "../lib/raygui_ffi"
  # Gem-shaped RGui* helpers (Rectangle bounds, value-first returns).
  require_relative "../lib/raygui_compat"
else
  # no-op under CRuby
end
