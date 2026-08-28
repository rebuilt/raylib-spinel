# raylib_ruby.rb — MRI/CRuby FFI layer using raylib-bindings gem
# Provides PascalCase API matching Spinel's raylib_adapter.o
# Loaded conditionally in main.rb via $PROGRAM_NAME check
#
# With method_naming: :original, the gem defines PascalCase methods
# (BeginDrawing, ClearBackground, etc.) that match our adapter's signatures.
# We only add custom helpers here.

# Load the gem by its full path. Must not `require "raylib"` by name here: that
# would resolve back to this package's raylib.rb (already on the load path and
# already mid-load), so the gem's own raylib.rb would never run.
gem_root = Gem::Specification.find_by_name("raylib-bindings").full_gem_path
require File.join(gem_root, "lib", "raylib")

module Raylib
  shared_lib_path = Gem::Specification.find_by_name("raylib-bindings").full_gem_path + "/lib/"

  case RUBY_PLATFORM
  when /mswin|msys|mingw|cygwin/
    Raylib.load_lib(shared_lib_path + "libraylib.dll",
      raygui_libpath: shared_lib_path + "raygui.dll",
      physac_libpath: shared_lib_path + "physac.dll",
      method_naming: :original)
  when /darwin/
    arch = RUBY_PLATFORM.split("-")[0]
    Raylib.load_lib(shared_lib_path + "libraylib.#{arch}.dylib",
      raygui_libpath: shared_lib_path + "raygui.#{arch}.dylib",
      physac_libpath: shared_lib_path + "physac.#{arch}.dylib",
      method_naming: :original)
  when /linux/
    arch = RUBY_PLATFORM.split("-")[0]
    Raylib.load_lib(shared_lib_path + "libraylib.#{arch}.so",
      raygui_libpath: shared_lib_path + "raygui.#{arch}.so",
      physac_libpath: shared_lib_path + "physac.#{arch}.so",
      method_naming: :original)
  else
    raise "Unknown OS: #{RUBY_PLATFORM}"
  end

  # TODO: declare a struct in the spinel ffi bindings and then remove these functions
  # ---- Vector2 helpers (not in gem) ----
  def self.Vector2Create(x, y)
    Raylib::Vector2.create(x, y)
  end

  def self.Vector2GetX(vec)
    vec.x
  end

  def self.Vector2GetY(vec)
    vec.y
  end

  def self.Vector2SetX(vec, val)
    vec.x = val.to_f
  end

  def self.Vector2SetY(vec, val)
    vec.y = val.to_f
  end

  # ---- Color helper ----
  class Color
    def self.free(color)
      # no-op under MRI — gem's Color objects are GC-managed
    end
  end
end
