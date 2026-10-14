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

  # TextFormat — the gem's printf-style helper. The gem passes FFI varargs as
  # (type, value) pairs; Spinel cannot call C varargs, so the pairs are
  # stripped here and Kernel#format does the work.
  def self.TextFormat(fmt, *args)
    vals = []
    i = 0
    while i < args.size
      vals << args[i + 1]
      i += 2
    end
    format(fmt, *vals)
  end

  # UnloadFileText — LoadFileText returns a Ruby String copy under Spinel
  # (see raylib_ffi.rb), so there is no C buffer to free. The raw-pointer pair
  # rl_LoadFileTextPtr/rl_UnloadFileTextPtr keeps the free for pointer users.
  def self.UnloadFileText(text)
    nil
  end
end

class String
  # The gem's TextFormat/LoadFileText return FFI pointers that callers read
  # with read_string; ours are already Ruby Strings, so the call is identity.
  def read_string = self
end
