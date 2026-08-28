# raylib_ffi.rb — FFI declarations for Spinel AOT
# All C implementations live in raylib_adapter.o
# Under MRI, ffi_func/ffi_lib/ffi_cflags are no-ops defined in main.rb

module Raylib
  ffi_lib "raylib"
  ffi_cflags "-I/usr/local/include"
  ffi_cflags "-Wl,-rpath,/usr/local/lib"

  # Window
  ffi_func :InitWindow, %i[int int str], :void
  ffi_func :IsWindowReady, [], :bool
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
  ffi_func :DrawFPS, %i[int int], :void

  # Input
  ffi_func :sp_IsKeyDown, [:int], :bool
  ffi_func :sp_IsKeyPressed, [:int], :bool
  ffi_func :sp_IsGamepadButtonDown, %i[int int], :bool

  # Time
  ffi_func :GetFrameTime, [], :float
  ffi_func :GetTime, [], :double # raylib returns double
  ffi_func :GetFPS, [], :int

  # Color struct (ffi_struct generates Color_new, Color_get_r/g/b/a,
  # Color_set_r/g/b/a — heap-allocated, returned as a void* pointer)
  ffi_struct :Color, [%i[r uchar], %i[g uchar], %i[b uchar], %i[a uchar]]
  ffi_func :sp_ColorFree, [:ptr], :void

  # Texture (opaque pointer — sp_LoadTexture mallocs Texture2D)
  ffi_func :sp_LoadTexture, [:str], :ptr
  ffi_func :sp_DrawTexture, %i[ptr int int ptr], :void
  ffi_func :sp_DrawTextureEx, %i[ptr float float float float ptr], :void
  ffi_func :sp_UnloadTexture, [:ptr], :void

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

    # Wrappers accepting Color pointers (game code stays backend-agnostic;
    # MRI gets these from the gem, which marshals structs itself).
    def self.ClearBackground(color)
      Raylib.sp_ClearBackground(color)
    end

    def self.DrawText(text, x, y, size, color)
      Raylib.sp_DrawText(text, x, y, size, color)
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

    def self.IsGamepadButtonDown(gamepad, button)
      Raylib.sp_IsGamepadButtonDown(gamepad, button)
    end

    class Color
      def self.from_u8(r = 0, g = 0, b = 0, a = 255)
        ptr = Raylib.Color_new
        Raylib.Color_set_r(ptr, r)
        Raylib.Color_set_g(ptr, g)
        Raylib.Color_set_b(ptr, b)
        Raylib.Color_set_a(ptr, a)
        ptr
      end

      def self.free(color)
        Raylib.sp_ColorFree(color)
      end
    end

    LIGHTGRAY = Color.from_u8(200, 200, 200, 255)
    GRAY = Color.from_u8(130, 130, 130, 255)
    DARKGRAY = Color.from_u8(80, 80, 80, 255)
    YELLOW = Color.from_u8(253, 249, 0, 255)
    GOLD = Color.from_u8(255, 203, 0, 255)
    ORANGE = Color.from_u8(255, 161, 0, 255)
    PINK = Color.from_u8(255, 109, 194, 255)
    RED = Color.from_u8(230, 41, 55, 255)
    MAROON = Color.from_u8(190, 33, 55, 255)
    GREEN = Color.from_u8(0, 228, 48, 255)
    LIME = Color.from_u8(0, 158, 47, 255)
    DARKGREEN = Color.from_u8(0, 117, 44, 255)
    SKYBLUE = Color.from_u8(102, 191, 255, 255)
    BLUE = Color.from_u8(0, 121, 241, 255)
    DARKBLUE = Color.from_u8(0, 82, 172, 255)
    PURPLE = Color.from_u8(200, 122, 255, 255)
    VIOLET = Color.from_u8(135, 60, 190, 255)
    DARKPURPLE = Color.from_u8(112, 31, 126, 255)
    BEIGE = Color.from_u8(211, 176, 131, 255)
    BROWN = Color.from_u8(127, 106, 79, 255)
    DARKBROWN = Color.from_u8(76, 63, 47, 255)

    WHITE = Color.from_u8(255, 255, 255, 255)
    BLACK = Color.from_u8(0, 0, 0, 255)
    BLANK = Color.from_u8(0, 0, 0, 0)
    MAGENTA = Color.from_u8(255, 0, 255, 255)
    RAYWHITE = Color.from_u8(245, 245, 245, 255)
  end
end
