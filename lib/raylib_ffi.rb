# raylib_ffi.rb — FFI declarations for Spinel AOT
# All C implementations live in raylib_adapter.o
# Under MRI, ffi_func/ffi_lib/ffi_cflags are no-ops defined in main.rb

module Raylib
  ffi_lib "raylib"
  ffi_cflags "-I/usr/local/include"
  ffi_cflags "-Wl,-rpath,/usr/local/lib"

  # Window
  ffi_func :InitWindow, %i[int int str], :void
  ffi_func :CloseWindow, [], :void
  # Bool-returning raylib functions go through sp_ shims (see
  # raylib_adapter.c — _Bool returns only define AL on x86-64).
  # Spinel marshals :bool results as real true/false objects.
  ffi_func :sp_WindowShouldClose, [], :bool
  ffi_func :SetTargetFPS, [:int], :void
  ffi_func :EnableCursor, [], :void
  ffi_func :GetScreenWidth, [], :int
  ffi_func :GetScreenHeight, [], :int

  # Vector2 helpers (custom — not raylib functions)
  ffi_func :Vector2Create, %i[float float], :ptr
  ffi_func :Vector2GetX, [:ptr], :float
  ffi_func :Vector2GetY, [:ptr], :float
  ffi_func :Vector2SetX, %i[ptr float], :void
  ffi_func :Vector2SetY, %i[ptr float], :void

  # Drawing
  # Color/vector-taking raylib functions are redeclared as sp_ shims
  # (pointers only) — see raylib_adapter.c. Color structs are
  # heap-allocated via ffi_struct and passed as void*.
  ffi_func :BeginDrawing, [], :void
  ffi_func :EndDrawing, [], :void
  ffi_func :sp_ClearBackground, [:ptr], :void
  ffi_func :sp_DrawCircleV, %i[ptr float ptr], :void
  ffi_func :sp_DrawTriangle, %i[ptr ptr ptr ptr], :void
  ffi_func :sp_DrawText, %i[str int int int ptr], :void
  ffi_func :sp_DrawTextInt, %i[str int int int int ptr], :void
  ffi_func :DrawFPS, %i[int int], :void

  # Input
  ffi_func :sp_IsKeyDown, [:int], :bool
  ffi_func :sp_IsKeyPressed, [:int], :bool
  ffi_func :sp_IsMouseButtonDown, [:int], :bool
  ffi_func :sp_IsGamepadButtonDown, %i[int int], :bool
  ffi_func :GetMouseX, [], :int
  ffi_func :GetMouseY, [], :int

  # Time
  ffi_func :GetFrameTime, [], :float
  ffi_func :GetTime, [], :double # raylib returns double
  ffi_func :GetFPS, [], :int

  # Color is a native (C-backed) GC-managed class (see raylib_adapter.c:
  # sp_Color embeds the raylib Color struct). Instances live in spinel's GC
  # heap, so a color is reclaimed automatically when the last reference
  # (e.g. a Bunny) is collected — no manual Color.free is needed.
  #
  # Spinel cannot pass a native object to an ffi_func :ptr/:any argument
  # (only as a native_method receiver), so every color-consuming draw call
  # is a method on the Color itself (the color is the receiver).
  native_struct "Color", "sp_Color"
  native_new [:int, :int, :int, :int], "sp_Color_new"
  native_method :fill_background, [], :void, "sp_Color_fill_background"
  native_method :draw_texture, [:any, :int, :int], :void, "sp_Color_draw_texture"
  native_method :draw_text, [:string, :int, :int, :int], :void, "sp_Color_draw_text"
  native_method :draw_text_int, [:string, :int, :int, :int, :int], :void, "sp_Color_draw_text_int"

  # Texture (opaque pointer — sp_LoadTexture mallocs Texture2D)
  ffi_func :sp_LoadTexture, [:str], :ptr
  ffi_func :sp_DrawTexture, %i[ptr int int ptr], :void
  ffi_func :sp_DrawTextureEx, %i[ptr float float float float ptr], :void
  ffi_func :sp_UnloadTexture, [:ptr], :void

  # Input / misc (plain raylib functions — no struct args)
  ffi_func :GetRandomValue, %i[int int], :int
  ffi_func :DisableCursor, [], :void
  ffi_func :EndMode3D, [], :void

  # 3D / extra drawing (Vector3, Vector2, Camera3D, Color passed as pointers)
  ffi_func :sp_BeginMode3D, [:ptr], :void
  ffi_func :sp_UpdateCamera, %i[ptr int], :void
  ffi_func :sp_DrawPlane, %i[ptr ptr ptr], :void
  ffi_func :sp_DrawCube, %i[ptr float float float ptr], :void
  ffi_func :sp_DrawCubeWires, %i[ptr float float float ptr], :void
  ffi_func :sp_DrawRectangle, %i[int int int int ptr], :void
  ffi_func :sp_DrawRectangleLines, %i[int int int int ptr], :void
  ffi_func :sp_DrawPixel, %i[int int ptr], :void

  # Vector3 — native GC object (mirrors Color). Passed to the 3D shims as its
  # pointer; field-read with .x/.y/.z.
  native_struct "Vector3", "sp_Vector3"
  native_new [:float, :float, :float], "sp_Vector3_new"
  # native_method :x, [], :float, "sp_Vector3_x"
  # native_method :y, [], :float, "sp_Vector3_y"
  # native_method :z, [], :float, "sp_Vector3_z"
  # native_method :pointer, [], :ptr, "sp_Vector3_ptr"

  # Camera — native GC object wrapping Camera3D. Built with the with_* chain,
  # mutated by sp_UpdateCamera, passed to sp_BeginMode3D.
  native_struct "Camera", "sp_Camera"
  native_new [], "sp_Camera_new"
  native_method :with_position, [:float, :float, :float], :self, "sp_Camera_with_position"
  native_method :with_target, [:float, :float, :float], :self, "sp_Camera_with_target"
  native_method :with_up, [:float, :float, :float], :self, "sp_Camera_with_up"
  native_method :with_fovy, [:float], :self, "sp_Camera_with_fovy"
  native_method :with_projection, [:int], :self, "sp_Camera_with_projection"
  native_method :pointer, [], :ptr, "sp_Camera_ptr"

  # Constants — only define under Spinel (MRI gets them from the gem)
  unless $PROGRAM_NAME.end_with?(".rb")
    # KeyboardKey enum — mirrors raylib.h (raylib 5.0), same order
    KEY_NULL = 0
    KEY_APOSTROPHE = 39
    KEY_COMMA = 44
    KEY_MINUS = 45
    KEY_PERIOD = 46
    KEY_SLASH = 47
    KEY_ZERO = 48
    KEY_ONE = 49
    KEY_TWO = 50
    KEY_THREE = 51
    KEY_FOUR = 52
    KEY_FIVE = 53
    KEY_SIX = 54
    KEY_SEVEN = 55
    KEY_EIGHT = 56
    KEY_NINE = 57
    KEY_SEMICOLON = 59
    KEY_EQUAL = 61
    KEY_A = 65
    KEY_B = 66
    KEY_C = 67
    KEY_D = 68
    KEY_E = 69
    KEY_F = 70
    KEY_G = 71
    KEY_H = 72
    KEY_I = 73
    KEY_J = 74
    KEY_K = 75
    KEY_L = 76
    KEY_M = 77
    KEY_N = 78
    KEY_O = 79
    KEY_P = 80
    KEY_Q = 81
    KEY_R = 82
    KEY_S = 83
    KEY_T = 84
    KEY_U = 85
    KEY_V = 86
    KEY_W = 87
    KEY_X = 88
    KEY_Y = 89
    KEY_Z = 90
    KEY_LEFT_BRACKET = 91
    KEY_BACKSLASH = 92
    KEY_RIGHT_BRACKET = 93
    KEY_GRAVE = 96
    KEY_SPACE = 32
    KEY_ESCAPE = 256
    KEY_ENTER = 257
    KEY_TAB = 258
    KEY_BACKSPACE = 259
    KEY_INSERT = 260
    KEY_DELETE = 261
    KEY_RIGHT = 262
    KEY_LEFT = 263
    KEY_DOWN = 264
    KEY_UP = 265
    KEY_PAGE_UP = 266
    KEY_PAGE_DOWN = 267
    KEY_HOME = 268
    KEY_END = 269
    KEY_CAPS_LOCK = 280
    KEY_SCROLL_LOCK = 281
    KEY_NUM_LOCK = 282
    KEY_PRINT_SCREEN = 283
    KEY_PAUSE = 284
    KEY_F1 = 290
    KEY_F2 = 291
    KEY_F3 = 292
    KEY_F4 = 293
    KEY_F5 = 294
    KEY_F6 = 295
    KEY_F7 = 296
    KEY_F8 = 297
    KEY_F9 = 298
    KEY_F10 = 299
    KEY_F11 = 300
    KEY_F12 = 301
    KEY_LEFT_SHIFT = 340
    KEY_LEFT_CONTROL = 341
    KEY_LEFT_ALT = 342
    KEY_LEFT_SUPER = 343
    KEY_RIGHT_SHIFT = 344
    KEY_RIGHT_CONTROL = 345
    KEY_RIGHT_ALT = 346
    KEY_RIGHT_SUPER = 347
    KEY_KB_MENU = 348
    KEY_KP_0 = 320
    KEY_KP_1 = 321
    KEY_KP_2 = 322
    KEY_KP_3 = 323
    KEY_KP_4 = 324
    KEY_KP_5 = 325
    KEY_KP_6 = 326
    KEY_KP_7 = 327
    KEY_KP_8 = 328
    KEY_KP_9 = 329
    KEY_KP_DECIMAL = 330
    KEY_KP_DIVIDE = 331
    KEY_KP_MULTIPLY = 332
    KEY_KP_SUBTRACT = 333
    KEY_KP_ADD = 334
    KEY_KP_ENTER = 335
    KEY_KP_EQUAL = 336
    KEY_BACK = 4
    KEY_MENU = 5
    KEY_VOLUME_UP = 24
    KEY_VOLUME_DOWN = 25

    GAMEPAD_BUTTON_LEFT_FACE_LEFT = 1
    GAMEPAD_BUTTON_LEFT_FACE_RIGHT = 3
    GAMEPAD_BUTTON_LEFT_FACE_UP = 0
    GAMEPAD_BUTTON_LEFT_FACE_DOWN = 2
    GAMEPAD_BUTTON_RIGHT_FACE_LEFT = 4

    GAMEPAD_BUTTON_UNKNOWN = 0
    GAMEPAD_BUTTON_LEFT_FACE_UP = 1
    GAMEPAD_BUTTON_LEFT_FACE_RIGHT = 2
    GAMEPAD_BUTTON_LEFT_FACE_DOWN = 3
    GAMEPAD_BUTTON_LEFT_FACE_LEFT = 4
    GAMEPAD_BUTTON_RIGHT_FACE_UP = 5
    GAMEPAD_BUTTON_RIGHT_FACE_RIGHT = 6
    GAMEPAD_BUTTON_RIGHT_FACE_DOWN = 7
    GAMEPAD_BUTTON_RIGHT_FACE_LEFT = 8
    GAMEPAD_BUTTON_LEFT_TRIGGER_1 = 9
    GAMEPAD_BUTTON_LEFT_TRIGGER_2 = 10
    GAMEPAD_BUTTON_RIGHT_TRIGGER_1 = 11
    GAMEPAD_BUTTON_RIGHT_TRIGGER_2 = 12
    GAMEPAD_BUTTON_MIDDLE_LEFT = 13
    GAMEPAD_BUTTON_MIDDLE = 14
    GAMEPAD_BUTTON_MIDDLE_RIGHT = 15
    GAMEPAD_BUTTON_LEFT_THUMB = 16
    GAMEPAD_BUTTON_RIGHT_THUMB = 17

    CAMERA_CUSTOM = 0
    CAMERA_FREE = 1
    CAMERA_ORBITAL = 2
    CAMERA_FIRST_PERSON = 3
    CAMERA_THIRD_PERSON = 4
    CAMERA_ORTHOGRAPHIC = 5
    CAMERA_PERSPECTIVE = 0
    CAMERA_RIGHT_HAND_XYZ = 0

    MOUSE_BUTTON_LEFT    = 0       
    MOUSE_BUTTON_RIGHT   = 1       
    MOUSE_BUTTON_MIDDLE  = 2       
    MOUSE_BUTTON_SIDE    = 3       
    MOUSE_BUTTON_EXTRA   = 4       
    MOUSE_BUTTON_FORWARD = 5       
    MOUSE_BUTTON_BACK    = 6       

    MOUSE_CURSOR_DEFAULT       = 0
    MOUSE_CURSOR_ARROW         = 1
    MOUSE_CURSOR_IBEAM         = 2
    MOUSE_CURSOR_CROSSHAIR     = 3
    MOUSE_CURSOR_POINTING_HAND = 4
    MOUSE_CURSOR_RESIZE_EW     = 5
    MOUSE_CURSOR_RESIZE_NS     = 6
    MOUSE_CURSOR_RESIZE_NWSE   = 7
    MOUSE_CURSOR_RESIZE_NESW   = 8
    MOUSE_CURSOR_RESIZE_ALL    = 9
    MOUSE_CURSOR_NOT_ALLOWED   = 10 


    # Wrappers accepting Color pointers (game code stays backend-agnostic;
    # MRI gets these from the gem, which marshals structs itself).
    def self.ClearBackground(color)
      Raylib.sp_ClearBackground(color)
    end

    def self.DrawText(text, x, y, size, color)
      Raylib.sp_DrawText(text, x, y, size, color)
    end

    def self.DrawTextInt(text, n, x, y, size, color)
      Raylib.sp_DrawTextInt(text, n, x, y, size, color)
    end
    def self.DrawTexture(texture, x, y, color)
      Raylib.sp_DrawTexture(texture, x, y, color)
    end

    def self.DrawTextureEx(texture, x, y, rotation, scale, color)
      Raylib.sp_DrawTextureEx(texture, x, y, rotation, scale, color)
    end

    def self.LoadTexture(path)
      Raylib.sp_LoadTexture(path)
    end

    def self.UnloadTexture(texture)
      Raylib.sp_UnloadTexture(texture)
    end

    def self.DrawCircleV(center, radius, color)
      Raylib.sp_DrawCircleV(center, radius, color)
    end

    def self.DrawTriangle(v1, v2, v3, color)
      Raylib.sp_DrawTriangle(v1, v2, v3, color)
    end

    def self.BeginMode3D(camera)
      Raylib.sp_BeginMode3D(camera)
    end

    def self.UpdateCamera(camera, mode)
      Raylib.sp_UpdateCamera(camera, mode)
    end

    def self.DrawPlane(center_pos, size, color)
      Raylib.sp_DrawPlane(center_pos, size, color)
    end

    def self.DrawCube(position, width, height, length, color)
      Raylib.sp_DrawCube(position, width, height, length, color)
    end

    def self.DrawCubeWires(position, width, height, length, color)
      Raylib.sp_DrawCubeWires(position, width, height, length, color)
    end

    def self.DrawRectangle(x, y, width, height, color)
      Raylib.sp_DrawRectangle(x, y, width, height, color)
    end

    def self.DrawRectangleLines(x, y, width, height, color)
      Raylib.sp_DrawRectangleLines(x, y, width, height, color)
    end

    def self.DrawPixel(x, y, color)
      Raylib.sp_DrawPixel(x, y, color)
    end

    # Predicate wrappers return true/false in both backends: the gem
    # binds raylib's bool directly; here spinel marshals the shims'
    # 0/1 ints via the :bool declarations above.
    def self.WindowShouldClose
      Raylib.sp_WindowShouldClose
    end

    def self.IsKeyDown(key)
      Raylib.sp_IsKeyDown(key)
    end

    def self.IsKeyPressed(key)
      Raylib.sp_IsKeyPressed(key)
    end

    def self.IsMouseButtonDown(button)
      Raylib.sp_IsMouseButtonDown(button)
    end

    def self.IsGamepadButtonDown(gamepad, button)
      Raylib.sp_IsGamepadButtonDown(gamepad, button)
    end

    LIGHTGRAY = Color.new(200, 200, 200, 255)
    GRAY = Color.new(130, 130, 130, 255)
    DARKGRAY = Color.new(80, 80, 80, 255)
    YELLOW = Color.new(253, 249, 0, 255)
    GOLD = Color.new(255, 203, 0, 255)
    ORANGE = Color.new(255, 161, 0, 255)
    PINK = Color.new(255, 109, 194, 255)
    RED = Color.new(230, 41, 55, 255)
    MAROON = Color.new(190, 33, 55, 255)
    GREEN = Color.new(0, 228, 48, 255)
    LIME = Color.new(0, 158, 47, 255)
    DARKGREEN = Color.new(0, 117, 44, 255)
    SKYBLUE = Color.new(102, 191, 255, 255)
    BLUE = Color.new(0, 121, 241, 255)
    DARKBLUE = Color.new(0, 82, 172, 255)
    PURPLE = Color.new(200, 122, 255, 255)
    VIOLET = Color.new(135, 60, 190, 255)
    DARKPURPLE = Color.new(112, 31, 126, 255)
    BEIGE = Color.new(211, 176, 131, 255)
    BROWN = Color.new(127, 106, 79, 255)
    DARKBROWN = Color.new(76, 63, 47, 255)

    WHITE = Color.new(255, 255, 255, 255)
    BLACK = Color.new(0, 0, 0, 255)
    BLANK = Color.new(0, 0, 0, 0)
    MAGENTA = Color.new(255, 0, 255, 255)
    RAYWHITE = Color.new(245, 245, 245, 255)


    # Color factories — thin wrappers over the native ctor (Color.new lowers to
    # sp_Color_new). Kept here (Spinel side) so they compile as Ruby methods on
    # the native class; MRI gets the identical helpers in raylib_ruby.rb.
    class Color
      def self.from_u8(r = 0, g = 0, b = 0, a = 255)
        Color.new(r, g, b, a)
      end

      def self.from_u32(rgba = 255)
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
