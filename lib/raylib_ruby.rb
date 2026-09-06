# raylib_ruby.rb — MRI/CRuby FFI layer using raylib-bindings gem
# Provides PascalCase API matching Spinel's raylib_adapter.o
# Loaded conditionally in main.rb via $PROGRAM_NAME check
#
# With method_naming: :original, the gem defines PascalCase methods
# (BeginDrawing, ClearBackground, etc.) that match our adapter's signatures.
# We only add custom helpers here.

# --- Live reloading (MRI only) ---
# If the main program set $live_reload_game_lib / $live_reload_game_modules
# before requiring raylib-spinel, start a file watcher that loads changed
# game files and signals the main loop to reinitialize.
if $live_reload_game_lib
  require "listen"

  $reload_requested = false
  $reload_mutex = Mutex.new

  listener = Listen.to($live_reload_game_lib) do |modified, added, removed|
    (modified + added).each do |file|
      next unless $live_reload_game_modules.key?(file)

      mod_name = $live_reload_game_modules[file]
      begin
        load(file)
        $reload_mutex.synchronize do
          $reload_mod = mod_name
          $reload_requested = true
        end
        puts "[live-reload] reloaded #{mod_name} from #{File.basename(file)}"
      rescue => e
        $stderr.puts "[live-reload] error reloading #{file}: #{e}"
      end
    end
  end

  listener.start
end

module Raylib
  # Require the raylib-bindings gem's raylib.rb by absolute path. A plain
  # `require "raylib"` is ambiguous: RubyGems resolves it to the gem literally
  # named "raylib" (if installed) instead of this gem, whose only entry point
  # is also lib/raylib.rb. Requiring by full path sidesteps gem-name resolution
  # so `ruby --yjit main.rb` works without bundle exec.
  raylib_bindings_root = Gem::Specification.find_by_name("raylib-bindings").full_gem_path
  require File.join(raylib_bindings_root, "lib", "raylib")

  shared_lib_path = raylib_bindings_root + "/lib/"

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


  # ---- DrawTextInt (custom — adapter has sp_DrawTextInt, gem doesn't) ----
  def self.DrawTextInt(prefix, value, x, y, size, color)
    DrawText("#{prefix}#{value}", x, y, size, color)
  end

  # ---- UpdateCamera ----
  # The gem binds raylib's UpdateCamera(Camera*, int) and expects a raw
  # pointer; Spinel passes the native Camera object straight to the same
  # shim. Accept the Camera object (an FFI::Struct / Camera3D) here and hand
  # FFI its pointer so game code is identical on both backends.
  class << self
    alias_method :__binding_UpdateCamera, :UpdateCamera
    def UpdateCamera(camera, mode)
      __binding_UpdateCamera(camera.pointer, mode)
    end
  end

  # ---- Vector3 helper (mirror of the Color.new override above) ----
  # Under Spinel, Vector3.new(x,y,z) lowers to the native sp_Vector3_new.
  # Under MRI, Vector3 is an FFI::Struct whose positional-arg new is treated
  # as a layout array, so accept the 3-float x/y/z form to match Spinel.
  class Vector3
    class << self
      def new(*args)
        if args.length == 3
          allocate.tap { |v| v.set(*args) }
        else
          super
        end
      end
    end
  end

  # ---- Color helper ----
  # Under Spinel, Color.new(r,g,b,a) lowers to the native sp_Color_new. Under
  # MRI, Raylib::Color is an FFI::Struct whose default .new treats positional
  # args as a layout array, so accept the 4-int RGBA form to match Spinel.
  class Color
    class << self
      def new(*args)
        if args.length == 4
          allocate.tap { |c| c.set(*args) }
        else
          super
        end
      end

      # Color factories — same logic as the Spinel side in raylib_ffi.rb.
      def from_u8(r = 0, g = 0, b = 0, a = 255)
        Color.new(r, g, b, a)
      end

      def from_u32(rgba = 255)
        Color.new(
          (rgba >> 24) & 0xFF,
          (rgba >> 16) & 0xFF,
          (rgba >> 8) & 0xFF,
          rgba & 0xFF
        )
      end
    end
  end
end
