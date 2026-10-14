# frozen_string_literal: true

# raylib_compat.rb — Spinel-side no-ops for the gem's runtime entry idioms.
#
# Unmodified raylib-bindings projects sometimes call Raylib.load_lib /
# Raylib.setup_symbols to point the gem at a shared library before use. Under
# Spinel the adapters are linked into the binary, so these are accepted and
# ignored; the signatures mirror the gem's (raylib-bindings lib/raylib.rb).
# Loaded by raylib.rb on the Spinel path only.
module Raylib
  def self.load_lib(libpath, raygui_libpath: nil, physac_libpath: nil,
                    method_naming: :original)
    nil
  end

  def self.setup_symbols(method_naming: :original)
    nil
  end
end
