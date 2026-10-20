# raylib_ruby.rb — MRI/CRuby FFI layer using raylib-bindings gem
# Provides PascalCase API matching Spinel's raylib_adapter.o
# Loaded conditionally via the RUBY_ENGINE branch in raylib-spinel.rb
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
  require "debug"

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


  # ---- DrawTextInt (custom — adapter has rl_DrawTextInt, gem doesn't) ----
  def self.DrawTextInt(prefix, value, x, y, size, color)
    DrawText("#{prefix}#{value}", x, y, size, color)
  end

  # ---- SaveRenderTextureImage ----
  # AOT twin in raylib_ffi.rb. Saves a render texture's canvas (y-flipped back
  # to top-down) to path. Lives here so the gem-only image.pointer call is
  # never compiled by Spinel.
  def self.SaveRenderTextureImage(target, path)
    image = LoadImageFromTexture(target.texture)
    ImageFlipVertical(image.pointer)
    ExportImage(image, path)
    UnloadImage(image)
  end

  # ---- raygui helpers as module functions ----
  # The gem's value-returning helpers (RGuiCheckBox, RGuiSlider, RGuiListView,
  # ... in raygui_helper.rb) are module *instance* methods, available to code
  # that does `include Raylib`. Scenes call them as Raylib.RGuiX like every
  # other binding, so mirror the whole instance surface onto the module.
  # Methods defined directly on the singleton (the snake_case aliases, the
  # Vector2/Color factories, ...) take precedence over the included ones.
  singleton_class.include(Raylib)

  # ---- FilePathList#path (mirror of the Spinel-side helper) ----
  # The gem's FilePathList stores a char** in `paths`; expose the same
  # per-entry reader the Spinel adapter provides, so directory scenes can
  # write files.path(i) on both engines.
  class FilePathList
    def path(index)
      return "" if index < 0 || index >= count

      ptr = paths.get_pointer(index * FFI.type_size(:pointer))
      return "" if ptr.null?

      ptr.read_string
    end
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
  # Under Spinel, Vector3.new(x,y,z) lowers to the native rl_Vector3_new.
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
  # Under Spinel, Color.new(r,g,b,a) lowers to the native rl_Color_new. Under
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

  # ---- PI ----
  # raylib-bindings defines no PI; Spinel's raylib_ffi.rb does. Mirror it so
  # game code can use Raylib::PI on both backends.
  PI = 3.141592653589793

  # ---- Positional factories (Vector2/Vector4/Matrix) ----
  # Twins of the Spinel-side helpers in raylib_ffi.rb. The gem's native ctors
  # are no-arg out-params too; .new(x, y) would treat the args as an FFI
  # layout description, so construction goes through these factories on both
  # backends (Spinel inlines Klass.new for native structs and cannot honor a
  # .new override).
  def self.Vector2(x, y)
    Vector2.allocate.tap { |v| v.set(x, y) }
  end

  def self.Vector4(x, y, z, w)
    Vector4.allocate.tap { |v| v.set(x, y, z, w) }
  end

  def self.Matrix(values)
    Matrix.allocate.tap do |m|
      m.m0 = values[0]; m.m4 = values[1]; m.m8 = values[2]; m.m12 = values[3]
      m.m1 = values[4]; m.m5 = values[5]; m.m9 = values[6]; m.m13 = values[7]
      m.m2 = values[8]; m.m6 = values[9]; m.m10 = values[10]; m.m14 = values[11]
      m.m3 = values[12]; m.m7 = values[13]; m.m11 = values[14]; m.m15 = values[15]
    end
  end

  # ---- Model mesh/skeleton helpers (mirror of the Spinel ModelRef) ----
  # The gem's helper surface has material/material_count/bone_count; scenes
  # also index meshes. Its bone_count/bone_info/bind_pose_transform still read
  # the raylib 5 field layout (Model[:boneCount]), but this gem's own Model
  # struct keeps the skeleton under Model[:skeleton] -- so those three are
  # overridden here with the layout the gem actually binds.
  class Model
    def mesh(index = 0)
      Mesh.new(self[:meshes] + index * FFI::NativeType::POINTER.size)
    end

    def mesh_count
      self[:meshCount]
    end

    def bone_count
      self[:skeleton][:boneCount]
    end

    def bone_info(index)
      BoneInfo.new(self[:skeleton][:bones] + index * BoneInfo.size)
    end

    def bind_pose_transform(index)
      Transform.new(self[:skeleton][:bindPose] + index * Transform.size)
    end
  end

  # ---- Rectangle factory (mirror of the Spinel-side helper) ----
  # raylib_ffi.rb defines Raylib::Rectangle(x, y, w, h) next to the Vector2/4
  # factories; scenes write Raylib::Rectangle(...) in places, so provide the
  # same call shape here (the gem's own factory is Rectangle.create).
  def self.Rectangle(x, y, width, height)
    Rectangle.create(x, y, width, height)
  end

  # ---- snake_case aliases (MRI gem :snake_case naming) ----
  # The *_ffi.rb files carry static alias blocks for Spinel; derive the same
  # names at runtime here so gem-style snake_case code runs identically under
  # CRuby. Conversion mirrors raylib_main.rb's entries loop.
  class << self
    Raylib.singleton_methods.each do |m|
      s = m.to_s.gsub(/([A-Z]+)([A-Z0-9][a-z])/, '\1_\2')
                .gsub(/([a-z\d])([A-Z0-9])/, '\1_\2')
                .downcase
      s = s.gsub('vector_3', 'vector3_') if s.include?('vector_3')
      s = s.gsub('vector_2', 'vector2_') if s.include?('vector_2')
      s = s.chop if s.end_with?('_')
      next if s == m.to_s || Raylib.respond_to?(s)
      alias_method s, m
      # The gem's snake mode attaches names as module *and* instance methods
      # (attach_function + module_function); mirror that so `include Raylib` +
      # bare snake calls work like on the Spinel side.
      Raylib.send(:define_method, s) { |*args| Raylib.send(m, *args) }
    end
  end
end
