# frozen_string_literal: true

# Opt-in physac loader for Spinel AOT.
#
# `require "raylib-spinel/physac"` splices in lib/physac_ffi.rb; physac itself is
# compiled into lib/physac_adapter.o + lib/physac_impl.o (linked into the physics
# scene). Under CRuby the raylib-bindings gem already binds physac.
if RUBY_ENGINE == "spinel"
  require_relative "../lib/physac_ffi"
  require_relative "../lib/physac_compat"
else
  # no-op under CRuby
end
