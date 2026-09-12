# physac_ffi.rb — FFI declarations for Spinel AOT
# Under MRI, ffi_func/ffi_lib/ffi_cflags are no-ops defined in main.rb

module Physac
  ffi_lib "physac"
  ffi_cflags "-I/usr/local/include"
  ffi_cflags "-Wl,-rpath,/usr/local/lib"

# ====== generated: complete physac API surface ======
  ffi_func :InitPhysics, [], :void
  ffi_func :UpdatePhysics, [], :void
  ffi_func :ResetPhysics, [], :void
  ffi_func :ClosePhysics, [], :void
  ffi_func :SetPhysicsTimeStep, [:double], :void
  ffi_func :SetPhysicsGravity, [:float, :float], :void
  ffi_func :sp_CreatePhysicsBodyCircle, [:ptr, :float, :float], :ptr
  ffi_func :sp_CreatePhysicsBodyRectangle, [:ptr, :float, :float, :float], :ptr
  ffi_func :sp_CreatePhysicsBodyPolygon, [:ptr, :float, :int, :float], :ptr
  ffi_func :sp_DestroyPhysicsBody, [:ptr], :void
  ffi_func :sp_PhysicsAddForce, [:ptr, :ptr], :void
  ffi_func :sp_PhysicsAddTorque, [:ptr, :float], :void
  ffi_func :sp_PhysicsShatter, [:ptr, :ptr, :float], :void
  ffi_func :sp_SetPhysicsBodyRotation, [:ptr, :float], :void
  ffi_func :sp_GetPhysicsBody, [:int], :ptr
  ffi_func :GetPhysicsBodiesCount, [], :int
  ffi_func :GetPhysicsShapeType, [:int], :int
  ffi_func :GetPhysicsShapeVerticesCount, [:int], :int
  ffi_func :sp_GetPhysicsShapeVertex, [:ptr, :int, :ptr], :void
  native_struct "Vector3", "sp_Vector3"
  native_new [], "sp_Vector3_new"
  native_struct "Vector4", "sp_Vector4"
  native_new [], "sp_Vector4_new"
  native_struct "Matrix", "sp_Matrix"
  native_new [], "sp_Matrix_new"

  # Window
  ffi_func :InitPhysac, [], :void
  ffi_func :ClosePhysac, [], :void
  ffi_func :SetTraceLogLevel, [:int], :void
  ffi_func :EnableTraceLog, [], :void
  ffi_func :DisableTraceLog, [], :void
  ffi_func :SetLogLevel, [:int], :void
  ffi_func :SetMasterClock, [:int], :void
  ffi_func :GetMasterClock, [], :int
  ffi_func :ClearMasterClock, [], :void

  # Math
  ffi_func :SetConfigFlags, [:uint], :void
  ffi_func :GetConfigFlags, [], :uint
  ffi_func :TakeScreenshot, [:str], :void

  # Shapes
  ffi_func :DrawPixel, [:int, :int, :ptr], :void
  ffi_func :DrawPixelV, %i[ptr float ptr], :void
  ffi_func :DrawLine, [:int, :int, :int, :int, :ptr], :void
  ffi_func :DrawLineV, %i[ptr ptr ptr], :void
  ffi_func :DrawLineEx, %i[ptr ptr float ptr], :void
  ffi_func :DrawLineStrip, %i[ptr int ptr], :void
  ffi_func :DrawRectangle, [%i[int int int int ptr]]
  ffi_func :DrawRectangleV, %i[ptr ptr ptr], :void
  ffi_func :DrawRectangleRec, %i[ptr ptr ptr], :void
  ffi_func :DrawRectangleLines, [%i[int int int int ptr]]
  ffi_func :DrawRectangleLinesEx, %i[ptr float ptr]
  ffi_func :DrawCircle, [%i[int int float ptr]]
  ffi_func :DrawCircleV, %i[ptr float ptr]
  ffi_func :DrawCircleWires, [%i[int int float ptr]]
  ffi_func :DrawCircleSector, %i[ptr float float int ptr]
  ffi_func :DrawCircleSectorLines, %i[ptr float float int ptr]
  ffi_func :DrawCircleLines, [%i[int int float ptr]]
  ffi_func :DrawCircleLinesV, %i[ptr float ptr]
  ffi_func :DrawEllipse, [%i[int int float float ptr]]
  ffi_func :DrawEllipseV, %i[ptr float float ptr]
  ffi_func :DrawEllipseLines, [%i[int int float float ptr]]
  ffi_func :DrawEllipseLinesV, %i[ptr float float ptr]
  ffi_func :DrawRing, %i[ptr float float float int ptr]
  ffi_func :DrawRingLines, %i[ptr float float float int ptr]
  ffi_func :DrawRingLinesEx, %i[ptr float float float float ptr]
  ffi_func :DrawPoly, %i[ptr int float ptr]
  ffi_func :DrawPolyLines, %i[ptr int float ptr]
  ffi_func :DrawPolyLinesEx, %i[ptr int float float ptr]
  ffi_func :DrawStar, %i[ptr int float float ptr]
  ffi_func :DrawCross, %i[ptr float ptr]
  ffi_func :DrawGrid, [%i[int float]]
  ffi_func :DrawPatch, %i[ptr float float float float ptr]

  # Models
  ffi_func :LoadModel, [:str], :ptr
  ffi_func :LoadModelFromMesh, [:ptr], :ptr
  ffi_func :IsModelValid, [:ptr], :bool
  ffi_func :UnloadModel, [:ptr], :void
  ffi_func :UpdateModelAnimation, [%i[ptr ptr float]]
  ffi_func :UpdateModelAnimationEx, [%i[ptr ptr float float float]]
  ffi_func :UnloadModelAnimation, [%i[ptr int]]
  ffi_func :DrawModel, [%i[ptr ptr float ptr]]
  ffi_func :DrawModelWires, [%i[ptr float ptr]]
  ffi_func :DrawModelEx, %i[ptr ptr ptr float ptr ptr]
  ffi_func :DrawModelWiresEx, %i[ptr ptr ptr float ptr ptr]
  ffi_func :ExportModel, [%i[ptr str]]
  ffi_func :ExportModelAsCode, [%i[ptr str]]
  ffi_func :GetModelBoundingBox, [%i[ptr ptr]]

  # Materials
  ffi_func :LoadMaterialDefault, [], :ptr
  ffi_func :IsMaterialValid, [:ptr], :bool
  ffi_func :UnloadMaterial, [:ptr], :void
  ffi_func :SetMaterialTexture, [%i[ptr int ptr]]

  # Meshes
  ffi_func :LoadMesh, [:str], :ptr
  ffi_func :LoadMeshFromVertex, [%i[str int int int ptr]]
  ffi_func :UnloadMesh, [:ptr], :void
  ffi_func :ExportMesh, [%i[ptr str]]
  ffi_func :ExportMeshAsCode, [%i[ptr str]]
  ffi_func :GetMeshBoundingBox, [%i[ptr ptr]]
  ffi_func :GenMeshTangents, [:ptr]
  ffi_func :GenMeshPoly, [%i[int float]] ptr
  ffi_func :GenMeshPlane, [%i[float float int int]] ptr
  ffi_func :GenMeshCube, [%i[float float float]] ptr
  ffi_func :GenMeshSphere, [%i[float int int]] ptr
  ffi_func :GenMeshHemiSphere, [%i[float int int]] ptr
  ffi_func :GenMeshCylinder, [%i[float float int]] ptr
  ffi_func :GenMeshCone, [%i[float float int]] ptr
  ffi_func :GenMeshTorus, [%i[float float int int]] ptr
  ffi_func :GenMeshKnot, [%i[float float int int]] ptr
  ffi_func :GenMeshHeightmap, [%i[ptr ptr]] ptr

  # Animations
  ffi_func :LoadAnimation, [%i[str int]], :ptr
  ffi_func :UpdateAnimation, [%i[ptr int float]]
  ffi_func :UnloadAnimation, [:ptr], :void
  ffi_func :ExportAnimation, [%i[ptr str]]
  ffi_func :ExportAnimationAsCode, [%i[ptr str]]

  # Camera
  ffi_func :SetCameraMode, [%i[ptr int]]
  ffi_func :SetCameraPanZoom, [%i[ptr float float]]
  ffi_func :UpdateCamera, [%i[ptr int]]
  ffi_func :BeginMode2D, [%i[ptr]]
  ffi_func :EndMode2D, []
  ffi_func :BeginMode3D, [%i[ptr]]
  ffi_func :EndMode3D, []
  ffi_func :BeginModeStereo, [%i[ptr]]
  ffi_func :EndModeStereo, []
  ffi_func :MoveCamera, [%i[ptr float float float]]
  ffi_func :CameraMove, [%i[ptr float float float]]
  ffi_func :CameraRotate, [%i[ptr float float float]]
  ffi_func :CameraZoom, [%i[ptr float]]
  ffi_func :SetShadesValue, [%i[ptr int int]]
  ffi_func :GetCameraWidth, [%i[ptr]] :int
  ffi_func :GetCameraHeight, [%i[ptr]] :int

  # Lights
  ffi_func :LoadLight, [%i[str int int int int]], :ptr
  ffi_func :UpdateLight, [%i[ptr int int int int]]
  ffi_func :UnloadLight, [:ptr], :void
  ffi_func :DrawLight, [%i[ptr]]
  ffi_func :SetShaderValueLight, [%i[ptr int ptr int]]

  # Textures
  ffi_func :LoadTexture, [:str], :ptr
  ffi_func :LoadTextureCubemap, [%i[str int]], :ptr
  ffi_func :IsTextureValid, [%i[ptr]] :bool
  ffi_func :UnloadTexture, [%i[ptr]], :void
  ffi_func :UpdateTexture, [%i[ptr ptr]]
  ffi_func :GenTextureMipmaps, [%i[ptr]]
  ffi_func :SetTextureFilter, [%i[ptr int]]
  ffi_func :SetTextureWrap, [%i[ptr int]]

  # Render textures
  ffi_func :LoadRenderTexture, [%i[int int]], :ptr
  ffi_func :IsRenderTextureValid, [%i[ptr]] :bool
  ffi_func :UnloadRenderTexture, [%i[ptr]], :void
  ffi_func :UpdateTextureRec, [%i[ptr ptr ptr]]
  ffi_func :DrawRenderTexture, [%i[ptr ptr]]

  # Shaders
  ffi_func :LoadShader, [%i[str str]], :ptr
  ffi_func :LoadShaderFromMemory, [%i[str str]], :ptr
  ffi_func :IsShaderValid, [%i[ptr]] :bool
  ffi_func :UnloadShader, [%i[ptr]], :void
  ffi_func :SetShaderValue, [%i[ptr int ptr int]]
  ffi_func :SetShaderValueV, [%i[ptr int ptr int int]]
  ffi_func :SetShaderValueMatrix, [%i[ptr int ptr]]
  ffi_func :SetShaderValueTexture, [%i[ptr int ptr]]
  ffi_func :GetShaderLocation, [%i[ptr str]] :int
  ffi_func :GetShaderLocationAttrib, [%i[ptr str]] :int
  ffi_func :UnloadShader, [%i[ptr]], :void

  # Fonts
  ffi_func :LoadFont, [:str], :ptr
  ffi_func :LoadFontEx, [%i[str int ptr int]], :ptr
  ffi_func :LoadFontFromMemory, [%i[str int int ptr int int ptr int]], :ptr
  ffi_func :IsFontValid, [%i[ptr]] :bool
  ffi_func :UnloadFontData, [%i[ptr int]]
  ffi_func :UnloadFont, [%i[ptr]], :void
  ffi_func :GenImageFontAtlas, [%i[ptr ptr int int int int]] ptr
  ffi_func :DrawText, %i[str int int int ptr]
  ffi_func :DrawTextEx, %i[ptr ptr float float ptr]
  ffi_func :DrawTextCodepoint, [%i[int ptr float ptr]]
  ffi_func :DrawTextCodepoints, %i[ptr int float float ptr]
  ffi_func :GetGlyphIndex, [%i[ptr int]] :int
  ffi_func :GetGlyphInfo, [%i[ptr int]] ptr
  ffi_func :GetGlyphAtlasRec, [%i[ptr int ptr]]

  # Audio
  ffi_func :InitAudioDevice, []
  ffi_func :CloseAudioDevice, []
  ffi_func :IsAudioDeviceReady, []
  ffi_func :SetMasterVolume, [%i[float]]
  ffi_func :GetMasterVolume, [] :float
  ffi_func :LoadWave, [:str] ptr
  ffi_func :LoadWaveFromMemory, [%i[str ptr int]] ptr
  ffi_func :IsWaveValid, [%i[ptr]] :bool
  ffi_func :UnloadWave, [%i[ptr]], :void
  ffi_func :LoadSound, [:str] ptr
  ffi_func :LoadSoundFromWave, [%i[ptr]] ptr
  ffi_func :LoadSoundAlias, [%i[ptr]] ptr
  ffi_func :IsSoundValid, [%i[ptr]] :bool
  ffi_func :UpdateSound, [%i[ptr ptr int]]
  ffi_func :UnloadSound, [%i[ptr]], :void
  ffi_func :UnloadSoundAlias, [%i[ptr]], :void
  ffi_func :PlaySound, [%i[ptr]] :void
  ffi_func :StopSound, [%i[ptr]] :void
  ffi_func :PauseSound, [%i[ptr]] :void
  ffi_func :ResumeSound, [%i[ptr]] :void
  ffi_func :IsSoundPlaying, [%i[ptr]] :bool
  ffi_func :SetSoundVolume, [%i[ptr float]]
  ffi_func :SetSoundPitch, [%i[ptr float]]
  ffi_func :SetSoundPan, [%i[ptr float]]
  ffi_func :SetSoundPosition, [%i[ptr float float float]]
  ffi_func :GetSoundLength, [%i[ptr]] :float
  ffi_func :ExportWave, [%i[ptr str]] :bool
  ffi_func :ExportWaveAsCode, [%i[ptr str]] :bool

  # Misc
  ffi_func :EnableTraceLog, []
  ffi_func :DisableTraceLog, []
  ffi_func :SetTargetFPS, [%i[int]]
  ffi_func :GetFrameTime, [] :float
  ffi_func :GetTime, [] :double
  ffi_func :GetFPS, [] :int

  # Native structs
  native_struct "Vector2", "sp_Vector2"
  native_new [], "sp_Vector2_new"
  native_method :x, [], :float, "sp_Vector2_x"
  native_method :x=, [:float], :float, "sp_Vector2_set_x"
  native_method :y, [], :float, "sp_Vector2_y"
  native_method :y=, [:float], :float, "sp_Vector2_set_y"
  native_struct "Color", "sp_Color"
  native_new [:int, :int, :int, :int], "sp_Color_new"
  native_method :r, [], :int, "sp_Color_r"
  native_method :r=, [:int], :int, "sp_Color_set_r"
  native_method :g, [], :int, "sp_Color_g"
  native_method :g=, [:int], :int, "sp_Color_set_g"
  native_method :b, [], :int, "sp_Color_b"
  native_method :b=, [:int], :int, "sp_Color_set_b"
  native_method :a, [], :int, "sp_Color_a"
  native_method :a=, [:int], :int, "sp_Color_set_a"

  # Constants
  PHYSAC_MOUSE_BUTTON_LEFT = 0
  PHYSAC_MOUSE_BUTTON_RIGHT = 1
  PHYSAC_MOUSE_BUTTON_MIDDLE = 2
  PHYSAC_MOUSE_BUTTON_EXTRA = 3
  PHYSAC_MOUSE_BUTTON_FORWARD = 4
  PHYSAC_MOUSE_BUTTON_BACK = 5

  PHYSAC_KEY_NULL = 0
  PHYSAC_KEY_APOSTROPHE = 39
  PHYSAC_KEY_COMMA = 44
  PHYSAC_KEY_MINUS = 45
  PHYSAC_KEY_PERIOD = 46
  PHYSAC_KEY_SLASH = 47
  PHYSAC_KEY_ZERO = 48
  PHYSAC_KEY_ONE = 49
  PHYSAC_KEY_TWO = 50
  PHYSAC_KEY_THREE = 51
  PHYSAC_KEY_FOUR = 52
  PHYSAC_KEY_FIVE = 53
  PHYSAC_KEY_SIX = 54
  PHYSAC_KEY_SEVEN = 55
  PHYSAC_KEY_EIGHT = 56
  PHYSAC_KEY_NINE = 57
  PHYSAC_KEY_SEMICOLON = 59
  PHYSAC_KEY_EQUAL = 61
  PHYSAC_KEY_A = 65
  PHYSAC_KEY_B = 66
  PHYSAC_KEY_C = 67
  PHYSAC_KEY_D = 68
  PHYSAC_KEY_E = 69
  PHYSAC_KEY_F = 70
  PHYSAC_KEY_G = 71
  PHYSAC_KEY_H = 72
  PHYSAC_KEY_I = 73
  PHYSAC_KEY_J = 74
  PHYSAC_KEY_K = 75
  PHYSAC_KEY_L = 76
  PHYSAC_KEY_M = 77
  PHYSAC_KEY_N = 78
  PHYSAC_KEY_O = 79
  PHYSAC_KEY_P = 80
  PHYSAC_KEY_Q = 81
  PHYSAC_KEY_R = 82
  PHYSAC_KEY_S = 83
  PHYSAC_KEY_T = 84
  PHYSAC_KEY_U = 85
  PHYSAC_KEY_V = 86
  PHYSAC_KEY_W = 87
  PHYSAC_KEY_X = 88
  PHYSAC_KEY_Y = 89
  PHYSAC_KEY_Z = 90
  PHYSAC_KEY_LEFT_BRACKET = 91
  PHYSAC_KEY_BACKSLASH = 92
  PHYSAC_KEY_RIGHT_BRACKET = 93
  PHYSAC_KEY_GRAVE = 96
  PHYSAC_KEY_SPACE = 32
  PHYSAC_KEY_ESCAPE = 256
  PHYSAC_KEY_ENTER = 257
  PHYSAC_KEY_TAB = 258
  PHYSAC_KEY_BACKSPACE = 259
  PHYSAC_KEY_INSERT = 260
  PHYSAC_KEY_DELETE = 261
  PHYSAC_KEY_RIGHT = 262
  PHYSAC_KEY_LEFT = 263
  PHYSAC_KEY_DOWN = 264
  PHYSAC_KEY_UP = 265
  PHYSAC_KEY_PAGE_UP = 266
  PHYSAC_KEY_PAGE_DOWN = 267
  PHYSAC_KEY_HOME = 268
  PHYSAC_KEY_END = 269
  PHYSAC_KEY_CAPS_LOCK = 280
  PHYSAC_KEY_SCROLL_LOCK = 281
  PHYSAC_KEY_NUM_LOCK = 282
  PHYSAC_KEY_PRINT_SCREEN = 283
  PHYSAC_KEY_PAUSE = 284

    # ====== generated: wrappers + constants ======
    def self.CreatePhysicsBodyCircle(pos, radius, density)
      Raylib.sp_CreatePhysicsBodyCircle(pos, radius, density)
    end
    def self.CreatePhysicsBodyRectangle(pos, width, height, density)
      Raylib.sp_CreatePhysicsBodyRectangle(pos, width, height, density)
    end
    def self.CreatePhysicsBodyPolygon(pos, radius, sides, density)
      Raylib.sp_CreatePhysicsBodyPolygon(pos, radius, sides, density)
    end
    def self.DestroyPhysicsBody(body)
      Raylib.sp_DestroyPhysicsBody(body)
    end
    def self.PhysicsAddForce(body, force)
      Raylib.sp_PhysicsAddForce(body, force)
    end
    def self.PhysicsAddTorque(body, amount)
      Raylib.sp_PhysicsAddTorque(body, amount)
    end
    def self.PhysicsShatter(body, position, force)
      Raylib.sp_PhysicsShatter(body, position, force)
    end
    def self.SetPhysicsBodyRotation(body, radians)
      Raylib.sp_SetPhysicsBodyRotation(body, radians)
    end
    def self.GetPhysicsBody(index)
      Raylib.sp_GetPhysicsBody(index)
    end
    def self.GetPhysicsShapeVertex(body, vertex)
      _out = Vector2.new
      Raylib.sp_GetPhysicsShapeVertex(body, vertex, _out)
      _out
    end
    PHYSAC_MAX_BODIES = 64
    PHYSAC_MAX_MANIFOLDS = 4096
    PHYSAC_MAX_VERTICES = 24
    PHYSAC_DEFAULT_CIRCLE_VERTICES = 24
    PHYSAC_COLLISION_ITERATIONS = 100
    PHYSAC_PENETRATION_ALLOWANCE = 0.05
    PHYSAC_PENETRATION_CORRECTION = 0.4
    PHYSAC_PI = 3.141592653589793
  end
end
