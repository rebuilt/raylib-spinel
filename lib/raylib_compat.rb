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

# Gem::Specification — the preamble of every raylib-bindings example
# (examples/template.rb) locates the gem's bundled library before use:
#
#   shared_lib_path = Gem::Specification.find_by_name('raylib-bindings').full_gem_path + '/lib/'
#   Raylib.load_lib(shared_lib_path + "libraylib.so", raygui_libpath: ..., physac_libpath: ...)
#
# Under Spinel there is no RubyGems runtime to answer that: `Gem` exists as a
# module, `Gem::Specification` does not, and --require-gate refuses
# `require "rubygems"` (see tools/repro/upstream/issue-f-require-gate-builtin.md).
# The path it computes is only ever passed to Raylib.load_lib, which is a no-op
# here, so an answer that locates nothing keeps unmodified example code
# running. A stub rather than a shim: every name answers, where MRI raises
# Gem::LoadError for a gem that is not installed. Safe because this package
# reads the path back to nothing; a program that asks RubyGems something real
# (specs, activation) is asking for MRI, where this file is not loaded.
module Gem
  class Specification
    def self.find_by_name(name)
      new
    end

    def full_gem_path = ""

    def full_require_paths = [""]
  end
end
