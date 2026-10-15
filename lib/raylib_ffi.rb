# raylib_ffi.rb — FFI declarations for Spinel AOT
# All C implementations live in raylib_adapter.o
# Under MRI, ffi_func/ffi_lib/ffi_cflags are no-ops defined in main.rb

module Raylib
  ffi_lib "raylib"
  # -I/usr/local/include keeps the adapter's raylib.h include resolving.
  # -Wl,-rpath,'$ORIGIN/../raylib' makes the produced binary (build/bin/<target>)
  # prefer the known-good raylib-bindings gem lib that the Makefile vendors at
  # build/raylib. Without it the loader falls back to /usr/local/lib's raylib,
  # whose LoadRenderTexture creates an incomplete FBO (black render textures).
  # Single quotes are required so the shell preserves $ORIGIN for the linker;
  # spinel appends ffi_cflags verbatim to the single compile+link cc invocation.
  ffi_cflags "-I/usr/local/include -Wl,-rpath,'$ORIGIN/../raylib'"

  # Positional-construction fills (see the factory block below).
  ffi_func :rl_Vector2Fill, %i[ptr float float], :void
  ffi_func :rl_Vector4Fill, %i[ptr float float float float], :void
  ffi_func :rl_MatrixFill,
           %i[ptr float float float float
              float float float float
              float float float float
              float float float float], :void

# ====== generated: complete raylib API surface ======
  ffi_func :IsWindowReady, [], :bool
  ffi_func :IsWindowFullscreen, [], :bool
  ffi_func :IsWindowHidden, [], :bool
  ffi_func :IsWindowMinimized, [], :bool
  ffi_func :IsWindowMaximized, [], :bool
  ffi_func :IsWindowFocused, [], :bool
  ffi_func :IsWindowResized, [], :bool
  ffi_func :IsWindowState, [:uint], :bool
  ffi_func :SetWindowState, [:uint], :void
  ffi_func :ClearWindowState, [:uint], :void
  ffi_func :ToggleFullscreen, [], :void
  ffi_func :ToggleBorderlessWindowed, [], :void
  ffi_func :MaximizeWindow, [], :void
  ffi_func :MinimizeWindow, [], :void
  ffi_func :RestoreWindow, [], :void
  ffi_func :rl_SetWindowIcon, [:ptr], :void
  ffi_func :SetWindowIcons, [:ptr, :int], :void
  ffi_func :SetWindowTitle, [:str], :void
  ffi_func :SetWindowPosition, [:int, :int], :void
  ffi_func :SetWindowMonitor, [:int], :void
  ffi_func :SetWindowMinSize, [:int, :int], :void
  ffi_func :SetWindowMaxSize, [:int, :int], :void
  ffi_func :SetWindowSize, [:int, :int], :void
  ffi_func :SetWindowOpacity, [:float], :void
  ffi_func :SetWindowFocused, [], :void
  ffi_func :GetWindowHandle, [], :ptr
  ffi_func :GetRenderWidth, [], :int
  ffi_func :GetRenderHeight, [], :int
  ffi_func :GetMonitorCount, [], :int
  ffi_func :GetCurrentMonitor, [], :int
  ffi_func :rl_GetMonitorPosition, [:int, :ptr], :void
  ffi_func :GetMonitorWidth, [:int], :int
  ffi_func :GetMonitorHeight, [:int], :int
  ffi_func :GetMonitorPhysicalWidth, [:int], :int
  ffi_func :GetMonitorPhysicalHeight, [:int], :int
  ffi_func :GetMonitorRefreshRate, [:int], :int
  ffi_func :rl_GetWindowPosition, [:ptr], :void
  ffi_func :rl_GetWindowScaleDPI, [:ptr], :void
  ffi_func :GetMonitorName, [:int], :str
  ffi_func :SetClipboardText, [:str], :void
  ffi_func :GetClipboardText, [], :str
  ffi_func :rl_GetClipboardImage, [], :ptr
  ffi_func :EnableEventWaiting, [], :void
  ffi_func :DisableEventWaiting, [], :void
  ffi_func :ShowCursor, [], :void
  ffi_func :HideCursor, [], :void
  ffi_func :IsCursorHidden, [], :bool
  ffi_func :IsCursorOnScreen, [], :bool
  ffi_func :rl_BeginMode2D, [:ptr], :void
  ffi_func :EndMode2D, [], :void
  ffi_func :rl_BeginTextureMode, [:ptr], :void
  ffi_func :EndTextureMode, [], :void
  ffi_func :rl_BeginShaderMode, [:ptr], :void
  ffi_func :EndShaderMode, [], :void
  ffi_func :BeginBlendMode, [:int], :void
  ffi_func :EndBlendMode, [], :void
  ffi_func :BeginScissorMode, [:int, :int, :int, :int], :void
  ffi_func :EndScissorMode, [], :void
  ffi_func :rl_BeginVrStereoMode, [:ptr], :void
  ffi_func :EndVrStereoMode, [], :void
  ffi_func :rl_LoadVrStereoConfig, [:ptr, :ptr], :void
  ffi_func :rl_UnloadVrStereoConfig, [:ptr], :void
  ffi_func :rl_LoadShader, [:str, :str], :ptr
  ffi_func :rl_LoadShaderFromMemory, [:str, :str], :ptr
  ffi_func :rl_IsShaderValid, [:ptr], :bool
  ffi_func :rl_GetShaderLocation, [:ptr, :str], :int
  ffi_func :rl_GetShaderLocationAttrib, [:ptr, :str], :int
  ffi_func :rl_SetShaderValue, [:ptr, :int, :ptr, :int], :void
  ffi_func :rl_SetShaderValueV, [:ptr, :int, :ptr, :int, :int], :void
  ffi_func :rl_SetShaderValueMatrix, [:ptr, :int, :ptr], :void
  ffi_func :rl_SetShaderValueTexture, [:ptr, :int, :ptr], :void
  ffi_func :rl_UnloadShader, [:ptr], :void
  ffi_func :rl_GetScreenToWorldRay, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_GetScreenToWorldRayEx, [:ptr, :ptr, :int, :int, :ptr], :void
  ffi_func :rl_GetWorldToScreen, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_GetWorldToScreenEx, [:ptr, :ptr, :int, :int, :ptr], :void
  ffi_func :rl_GetWorldToScreen2D, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_GetScreenToWorld2D, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_GetCameraMatrix, [:ptr, :ptr], :void
  ffi_func :rl_GetCameraMatrix2D, [:ptr, :ptr], :void
  ffi_func :SwapScreenBuffer, [], :void
  ffi_func :PollInputEvents, [], :void
  ffi_func :WaitTime, [:double], :void
  ffi_func :SetRandomSeed, [:uint], :void
  ffi_func :LoadRandomSequence, [:uint, :int, :int], :ptr
  ffi_func :UnloadRandomSequence, [:ptr], :void
  ffi_func :TakeScreenshot, [:str], :void
  ffi_func :SetConfigFlags, [:uint], :void
  ffi_func :OpenURL, [:str], :void
  ffi_func :SetTraceLogLevel, [:int], :void
  # TraceLog is C-varargs; the gem/example calls pass (level, text) and raylib
  # only walks the va_list when the text carries format specifiers.
  ffi_func :TraceLog, %i[int str], :void
  ffi_func :rl_SetTraceLogCallback, [:ptr], :void
  ffi_func :MemAlloc, [:uint], :ptr
  ffi_func :MemRealloc, [:ptr, :uint], :ptr
  ffi_func :MemFree, [:ptr], :void
  ffi_func :LoadFileData, [:str, :ptr], :ptr
  ffi_func :UnloadFileData, [:ptr], :void
  ffi_func :SaveFileData, [:str, :ptr, :int], :bool
  ffi_func :ExportDataAsCode, [:ptr, :int, :str], :bool
  ffi_func :LoadFileText, [:str], :str
  ffi_func :rl_LoadFileTextPtr, [:str], :ptr
  ffi_func :rl_UnloadFileTextPtr, [:ptr], :void
  ffi_func :rl_PtrToString, [:ptr], :str
  ffi_func :UnloadFileText, [:str], :void
  ffi_func :SaveFileText, [:str, :str], :bool
  ffi_func :rl_SetLoadFileDataCallback, [:ptr], :void
  ffi_func :rl_SetSaveFileDataCallback, [:ptr], :void
  ffi_func :rl_SetLoadFileTextCallback, [:ptr], :void
  ffi_func :rl_SetSaveFileTextCallback, [:ptr], :void
  ffi_func :FileRename, [:str, :str], :int
  ffi_func :FileRemove, [:str], :int
  ffi_func :FileCopy, [:str, :str], :int
  ffi_func :FileMove, [:str, :str], :int
  ffi_func :FileTextReplace, [:str, :str, :str], :int
  ffi_func :FileTextFindIndex, [:str, :str], :int
  ffi_func :FileExists, [:str], :bool
  ffi_func :DirectoryExists, [:str], :bool
  ffi_func :IsFileExtension, [:str, :str], :bool
  ffi_func :IsFileHidden, [:str], :bool
  ffi_func :GetFileLength, [:str], :int
  ffi_func :GetFileModTime, [:str], :long
  ffi_func :GetFileExtension, [:str], :str
  ffi_func :GetFileName, [:str], :str
  ffi_func :GetFileNameWithoutExt, [:str], :str
  ffi_func :GetDirectoryPath, [:str], :str
  ffi_func :GetPrevDirectoryPath, [:str], :str
  ffi_func :GetWorkingDirectory, [], :str
  ffi_func :GetApplicationDirectory, [], :str
  ffi_func :MakeDirectory, [:str], :int
  ffi_func :ChangeDirectory, [:str], :int
  ffi_func :IsPathFile, [:str], :bool
  ffi_func :IsPathDirectory, [:str], :bool
  ffi_func :IsPathAbsolute, [:str], :bool
  ffi_func :IsFileNameValid, [:str], :bool
  ffi_func :rl_LoadDirectoryFiles, [:str, :ptr], :void
  ffi_func :rl_LoadDirectoryFilesEx, [:str, :str, :bool, :ptr], :void
  ffi_func :rl_UnloadDirectoryFiles, [:ptr], :void
  ffi_func :IsFileDropped, [], :bool
  ffi_func :rl_LoadDroppedFiles, [:ptr], :void
  ffi_func :rl_UnloadDroppedFiles, [:ptr], :void
  ffi_func :GetDirectoryFileCount, [:str], :uint
  ffi_func :GetDirectoryFileCountEx, [:str, :str, :bool], :uint
  ffi_func :CompressData, [:ptr, :int, :ptr], :ptr
  ffi_func :DecompressData, [:ptr, :int, :ptr], :ptr
  ffi_func :EncodeDataBase64, [:ptr, :int, :ptr], :str
  ffi_func :DecodeDataBase64, [:str, :ptr], :ptr
  ffi_func :ComputeCRC32, [:ptr, :int], :uint
  ffi_func :ComputeMD5, [:ptr, :int], :ptr
  ffi_func :ComputeSHA1, [:ptr, :int], :ptr
  ffi_func :ComputeSHA256, [:ptr, :int], :ptr
  ffi_func :rl_LoadAutomationEventList, [:str, :ptr], :void
  ffi_func :rl_UnloadAutomationEventList, [:ptr], :void
  ffi_func :rl_ExportAutomationEventList, [:ptr, :str], :bool
  ffi_func :rl_SetAutomationEventList, [:ptr], :void
  ffi_func :SetAutomationEventBaseFrame, [:int], :void
  ffi_func :StartAutomationEventRecording, [], :void
  ffi_func :StopAutomationEventRecording, [], :void
  ffi_func :rl_PlayAutomationEvent, [:ptr], :void
  ffi_func :IsKeyPressedRepeat, [:int], :bool
  ffi_func :IsKeyReleased, [:int], :bool
  ffi_func :IsKeyUp, [:int], :bool
  ffi_func :GetKeyPressed, [], :int
  ffi_func :GetCharPressed, [], :int
  ffi_func :GetKeyName, [:int], :str
  ffi_func :SetExitKey, [:int], :void
  ffi_func :IsGamepadAvailable, [:int], :bool
  ffi_func :GetGamepadName, [:int], :str
  ffi_func :IsGamepadButtonPressed, [:int, :int], :bool
  ffi_func :IsGamepadButtonReleased, [:int, :int], :bool
  ffi_func :IsGamepadButtonUp, [:int, :int], :bool
  ffi_func :GetGamepadButtonPressed, [], :int
  ffi_func :GetGamepadAxisCount, [:int], :int
  ffi_func :GetGamepadAxisMovement, [:int, :int], :float
  ffi_func :SetGamepadMappings, [:str], :int
  ffi_func :SetGamepadVibration, [:int, :float, :float, :float], :void
  ffi_func :IsMouseButtonPressed, [:int], :bool
  ffi_func :IsMouseButtonReleased, [:int], :bool
  ffi_func :IsMouseButtonUp, [:int], :bool
  ffi_func :rl_GetMousePosition, [:ptr], :void
  ffi_func :rl_GetMouseDelta, [:ptr], :void
  ffi_func :SetMousePosition, [:int, :int], :void
  ffi_func :SetMouseOffset, [:int, :int], :void
  ffi_func :SetMouseScale, [:float, :float], :void
  ffi_func :GetMouseWheelMove, [], :float
  ffi_func :rl_GetMouseWheelMoveV, [:ptr], :void
  ffi_func :SetMouseCursor, [:int], :void
  ffi_func :GetTouchX, [], :int
  ffi_func :GetTouchY, [], :int
  ffi_func :rl_GetTouchPosition, [:int, :ptr], :void
  ffi_func :GetTouchPointId, [:int], :int
  ffi_func :GetTouchPointCount, [], :int
  ffi_func :SetGesturesEnabled, [:uint], :void
  ffi_func :IsGestureDetected, [:uint], :bool
  ffi_func :GetGestureDetected, [], :int
  ffi_func :GetGestureHoldDuration, [], :float
  ffi_func :rl_GetGestureDragVector, [:ptr], :void
  ffi_func :GetGestureDragAngle, [], :float
  ffi_func :rl_GetGesturePinchVector, [:ptr], :void
  ffi_func :GetGesturePinchAngle, [], :float
  ffi_func :rl_UpdateCameraPro, [:ptr, :ptr, :ptr, :float], :void
  ffi_func :rl_SetShapesTexture, [:ptr, :ptr], :void
  ffi_func :rl_GetShapesTexture, [], :ptr
  ffi_func :rl_GetShapesTextureRectangle, [:ptr], :void
  ffi_func :rl_DrawPixelV, [:ptr, :ptr], :void
  ffi_func :rl_DrawLine, [:int, :int, :int, :int, :ptr], :void
  ffi_func :rl_DrawLineV, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_DrawLineEx, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_DrawLineStrip, [:ptr, :int, :ptr], :void
  ffi_func :rl_DrawLineBezier, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_DrawLineDashed, [:ptr, :ptr, :int, :int, :ptr], :void
  ffi_func :rl_DrawTriangleGradient, [:ptr, :ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_DrawTriangleLines, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_DrawTriangleLinesEx, [:ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_DrawTriangleFan, [:ptr, :int, :ptr], :void
  ffi_func :rl_DrawTriangleStrip, [:ptr, :int, :ptr], :void
  ffi_func :rl_DrawRectangleV, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_DrawRectangleRec, [:ptr, :ptr], :void
  ffi_func :rl_DrawRectanglePro, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_DrawRectangleGradientV, [:int, :int, :int, :int, :ptr, :ptr], :void
  ffi_func :rl_DrawRectangleGradientH, [:int, :int, :int, :int, :ptr, :ptr], :void
  ffi_func :rl_DrawRectangleGradientEx, [:ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_DrawRectangleLinesEx, [:ptr, :float, :ptr], :void
  ffi_func :rl_DrawRectangleRounded, [:ptr, :float, :int, :ptr], :void
  ffi_func :rl_DrawRectangleRoundedLines, [:ptr, :float, :int, :ptr], :void
  ffi_func :rl_DrawRectangleRoundedLinesEx, [:ptr, :float, :int, :float, :ptr], :void
  ffi_func :rl_DrawPoly, [:ptr, :int, :float, :float, :ptr], :void
  ffi_func :rl_DrawPolyLines, [:ptr, :int, :float, :float, :ptr], :void
  ffi_func :rl_DrawPolyLinesEx, [:ptr, :int, :float, :float, :float, :ptr], :void
  ffi_func :rl_DrawCircle, [:int, :int, :float, :ptr], :void
  ffi_func :rl_DrawCircleGradient, [:ptr, :float, :ptr, :ptr], :void
  ffi_func :rl_DrawCircleSector, [:ptr, :float, :float, :float, :int, :ptr], :void
  ffi_func :rl_DrawCircleSectorLines, [:ptr, :float, :float, :float, :int, :ptr], :void
  ffi_func :rl_DrawCircleSectorLinesEx, [:ptr, :float, :float, :float, :int, :float, :ptr], :void
  ffi_func :rl_DrawCircleLines, [:int, :int, :float, :ptr], :void
  ffi_func :rl_DrawCircleLinesV, [:ptr, :float, :ptr], :void
  ffi_func :rl_DrawCircleLinesEx, [:ptr, :float, :float, :ptr], :void
  ffi_func :rl_DrawEllipse, [:int, :int, :float, :float, :ptr], :void
  ffi_func :rl_DrawEllipseV, [:ptr, :float, :float, :ptr], :void
  ffi_func :rl_DrawEllipseLines, [:int, :int, :float, :float, :ptr], :void
  ffi_func :rl_DrawEllipseLinesV, [:ptr, :float, :float, :ptr], :void
  ffi_func :rl_DrawEllipseLinesEx, [:ptr, :float, :float, :float, :ptr], :void
  ffi_func :rl_DrawRing, [:ptr, :float, :float, :float, :float, :int, :ptr], :void
  ffi_func :rl_DrawRingLines, [:ptr, :float, :float, :float, :float, :int, :ptr], :void
  ffi_func :rl_DrawRingLinesEx, [:ptr, :float, :float, :float, :float, :int, :float, :ptr], :void
  ffi_func :rl_DrawSplineLinear, [:ptr, :int, :float, :ptr], :void
  ffi_func :rl_DrawSplineBasis, [:ptr, :int, :float, :ptr], :void
  ffi_func :rl_DrawSplineCatmullRom, [:ptr, :int, :float, :ptr], :void
  ffi_func :rl_DrawSplineBezierQuadratic, [:ptr, :int, :float, :ptr], :void
  ffi_func :rl_DrawSplineBezierCubic, [:ptr, :int, :float, :ptr], :void
  ffi_func :rl_DrawSplineSegmentLinear, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_DrawSplineSegmentBasis, [:ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_DrawSplineSegmentCatmullRom, [:ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_DrawSplineSegmentBezierQuadratic, [:ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_DrawSplineSegmentBezierCubic, [:ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_GetSplinePointLinear, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_GetSplinePointBasis, [:ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_GetSplinePointCatmullRom, [:ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_GetSplinePointBezierQuadratic, [:ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_GetSplinePointBezierCubic, [:ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_CheckCollisionRecs, [:ptr, :ptr], :bool
  ffi_func :rl_CheckCollisionCircles, [:ptr, :float, :ptr, :float], :bool
  ffi_func :rl_CheckCollisionCircleRec, [:ptr, :float, :ptr], :bool
  ffi_func :rl_CheckCollisionCircleLine, [:ptr, :float, :ptr, :ptr], :bool
  ffi_func :rl_CheckCollisionPointRec, [:ptr, :ptr], :bool
  ffi_func :rl_CheckCollisionPointCircle, [:ptr, :ptr, :float], :bool
  ffi_func :rl_CheckCollisionPointTriangle, [:ptr, :ptr, :ptr, :ptr], :bool
  ffi_func :rl_CheckCollisionPointLine, [:ptr, :ptr, :ptr, :int], :bool
  ffi_func :rl_CheckCollisionPointPoly, [:ptr, :ptr, :int], :bool
  ffi_func :rl_CheckCollisionLines, [:ptr, :ptr, :ptr, :ptr, :ptr], :bool
  ffi_func :rl_GetCollisionRec, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_LoadImage, [:str], :ptr
  ffi_func :rl_LoadImageRaw, [:str, :int, :int, :int, :int], :ptr
  ffi_func :rl_LoadImageAnim, [:str, :ptr], :ptr
  ffi_func :rl_LoadImageAnimFromMemory, [:str, :ptr, :int, :ptr], :ptr
  ffi_func :rl_LoadImageFromMemory, [:str, :ptr, :int], :ptr
  ffi_func :rl_LoadImageFromTexture, [:ptr], :ptr
  ffi_func :rl_LoadImageFromScreen, [], :ptr
  ffi_func :rl_IsImageValid, [:ptr], :bool
  ffi_func :rl_UnloadImage, [:ptr], :void
  ffi_func :rl_ExportImage, [:ptr, :str], :bool
  ffi_func :rl_ExportImageToMemory, [:ptr, :str, :ptr], :ptr
  ffi_func :rl_ExportImageAsCode, [:ptr, :str], :bool
  ffi_func :rl_GenImageColor, [:int, :int, :ptr], :ptr
  ffi_func :rl_GenImageGradientLinear, [:int, :int, :int, :ptr, :ptr], :ptr
  ffi_func :rl_GenImageGradientRadial, [:int, :int, :float, :ptr, :ptr], :ptr
  ffi_func :rl_GenImageGradientSquare, [:int, :int, :float, :ptr, :ptr], :ptr
  ffi_func :rl_GenImageChecked, [:int, :int, :int, :int, :ptr, :ptr], :ptr
  ffi_func :rl_GenImageWhiteNoise, [:int, :int, :float], :ptr
  ffi_func :rl_GenImagePerlinNoise, [:int, :int, :int, :int, :float], :ptr
  ffi_func :rl_GenImageCellular, [:int, :int, :int], :ptr
  ffi_func :rl_GenImageText, [:int, :int, :str], :ptr
  ffi_func :rl_ImageCopy, [:ptr], :ptr
  ffi_func :rl_ImageFromImage, [:ptr, :ptr], :ptr
  ffi_func :rl_ImageFromChannel, [:ptr, :int], :ptr
  ffi_func :rl_ImageText, [:str, :int, :ptr], :ptr
  ffi_func :rl_ImageTextEx, [:ptr, :str, :float, :float, :ptr], :ptr
  ffi_func :ImageFormat, [:ptr, :int], :void
  ffi_func :rl_ImageToPOT, [:ptr, :ptr], :void
  ffi_func :rl_ImageCrop, [:ptr, :ptr], :void
  ffi_func :ImageAlphaCrop, [:ptr, :float], :void
  ffi_func :rl_ImageAlphaClear, [:ptr, :ptr, :float], :void
  ffi_func :rl_ImageAlphaMask, [:ptr, :ptr], :void
  ffi_func :ImageAlphaPremultiply, [:ptr], :void
  ffi_func :ImageBlurGaussian, [:ptr, :int], :void
  ffi_func :ImageKernelConvolution, [:ptr, :ptr, :int], :void
  ffi_func :ImageResize, [:ptr, :int, :int], :void
  ffi_func :ImageResizeNN, [:ptr, :int, :int], :void
  ffi_func :rl_ImageResizeCanvas, [:ptr, :int, :int, :int, :int, :ptr], :void
  ffi_func :ImageMipmaps, [:ptr], :void
  ffi_func :ImageDither, [:ptr, :int, :int, :int, :int], :void
  ffi_func :ImageFlipVertical, [:ptr], :void
  ffi_func :ImageFlipHorizontal, [:ptr], :void
  ffi_func :ImageRotate, [:ptr, :int], :void
  ffi_func :ImageRotateCW, [:ptr], :void
  ffi_func :ImageRotateCCW, [:ptr], :void
  ffi_func :rl_ImageColorTint, [:ptr, :ptr], :void
  ffi_func :ImageColorInvert, [:ptr], :void
  ffi_func :ImageColorGrayscale, [:ptr], :void
  ffi_func :ImageColorContrast, [:ptr, :int], :void
  ffi_func :ImageColorBrightness, [:ptr, :int], :void
  ffi_func :rl_ImageColorReplace, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_LoadImageColors, [:ptr], :ptr
  ffi_func :rl_LoadImagePalette, [:ptr, :int, :ptr], :ptr
  ffi_func :rl_UnloadImageColors, [:ptr], :void
  ffi_func :rl_UnloadImagePalette, [:ptr], :void
  ffi_func :rl_GetImageAlphaBorder, [:ptr, :float, :ptr], :void
  ffi_func :rl_GetImageColor, [:ptr, :int, :int, :ptr], :void
  ffi_func :rl_ImageClearBackground, [:ptr, :ptr], :void
  ffi_func :rl_ImageDrawPixel, [:ptr, :int, :int, :ptr], :void
  ffi_func :rl_ImageDrawPixelV, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_ImageDrawLine, [:ptr, :int, :int, :int, :int, :ptr], :void
  ffi_func :rl_ImageDrawLineV, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_ImageDrawLineEx, [:ptr, :ptr, :ptr, :int, :ptr], :void
  ffi_func :rl_ImageDrawLineStrip, [:ptr, :ptr, :int, :ptr], :void
  ffi_func :rl_ImageDrawTriangle, [:ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_ImageDrawTriangleGradient, [:ptr, :ptr, :ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_ImageDrawTriangleLines, [:ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_ImageDrawTriangleFan, [:ptr, :ptr, :int, :ptr], :void
  ffi_func :rl_ImageDrawTriangleStrip, [:ptr, :ptr, :int, :ptr], :void
  ffi_func :rl_ImageDrawRectangle, [:ptr, :int, :int, :int, :int, :ptr], :void
  ffi_func :rl_ImageDrawRectangleV, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_ImageDrawRectangleRec, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_ImageDrawRectanglePro, [:ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_ImageDrawRectangleLines, [:ptr, :int, :int, :int, :int, :ptr], :void
  ffi_func :rl_ImageDrawRectangleLinesEx, [:ptr, :ptr, :int, :ptr], :void
  ffi_func :rl_ImageDrawRectangleGradientEx, [:ptr, :ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_ImageDrawCircle, [:ptr, :int, :int, :int, :ptr], :void
  ffi_func :rl_ImageDrawCircleV, [:ptr, :ptr, :int, :ptr], :void
  ffi_func :rl_ImageDrawCircleLines, [:ptr, :int, :int, :int, :ptr], :void
  ffi_func :rl_ImageDrawCircleLinesV, [:ptr, :ptr, :int, :ptr], :void
  ffi_func :rl_ImageDrawCircleGradient, [:ptr, :ptr, :float, :ptr, :ptr], :void
  ffi_func :rl_ImageDrawImage, [:ptr, :ptr, :int, :int, :ptr], :void
  ffi_func :rl_ImageDrawImageEx, [:ptr, :ptr, :ptr, :float, :float, :ptr], :void
  ffi_func :rl_ImageDrawImageRec, [:ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_ImageDrawImagePro, [:ptr, :ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_ImageDrawText, [:ptr, :str, :int, :int, :int, :ptr], :void
  ffi_func :rl_ImageDrawTextEx, [:ptr, :ptr, :str, :ptr, :float, :float, :ptr], :void
  ffi_func :rl_ImageDrawTextPro, [:ptr, :ptr, :str, :ptr, :ptr, :float, :float, :float, :ptr], :void
  ffi_func :rl_LoadTextureFromImage, [:ptr], :ptr
  ffi_func :rl_LoadTextureCubemap, [:ptr, :int], :ptr
  ffi_func :rl_LoadRenderTexture, [:int, :int], :ptr
  ffi_func :rl_LoadRenderTextureEx, [:int, :int, :int], :ptr
  ffi_func :rl_IsTextureValid, [:ptr], :bool
  ffi_func :rl_IsRenderTextureValid, [:ptr], :bool
  ffi_func :rl_UnloadRenderTexture, [:ptr], :void
  ffi_func :rl_UpdateTexture, [:ptr, :ptr], :void
  ffi_func :rl_UpdateTextureRec, [:ptr, :ptr, :ptr], :void
  ffi_func :GenTextureMipmaps, [:ptr], :void
  ffi_func :rl_SetTextureFilter, [:ptr, :int], :void
  ffi_func :rl_SetTextureWrap, [:ptr, :int], :void
  ffi_func :rl_DrawTextureV, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_DrawTextureRec, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_DrawTexturePro, [:ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_DrawTextureNPatch, [:ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_ColorIsEqual, [:ptr, :ptr], :bool
  ffi_func :rl_Fade, [:ptr, :float, :ptr], :void
  ffi_func :rl_ColorToInt, [:ptr], :int
  ffi_func :rl_ColorNormalize, [:ptr, :ptr], :void
  ffi_func :rl_ColorFromNormalized, [:ptr, :ptr], :void
  ffi_func :rl_ColorToHSV, [:ptr, :ptr], :void
  ffi_func :rl_ColorFromHSV, [:float, :float, :float, :ptr], :void
  ffi_func :rl_ColorTint, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_ColorBrightness, [:ptr, :float, :ptr], :void
  ffi_func :rl_ColorContrast, [:ptr, :float, :ptr], :void
  ffi_func :rl_ColorAlpha, [:ptr, :float, :ptr], :void
  ffi_func :rl_ColorAlphaBlend, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_ColorLerp, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_GetColor, [:uint, :ptr], :void
  ffi_func :rl_GetPixelColor, [:ptr, :int, :ptr], :void
  ffi_func :rl_SetPixelColor, [:ptr, :ptr, :int], :void
  ffi_func :GetPixelDataSize, [:int, :int, :int], :int
  ffi_func :rl_GetFontDefault, [], :ptr
  ffi_func :rl_FontBaseSize, [:ptr], :float
  ffi_func :rl_DirListCount, [:ptr], :int
  ffi_func :rl_DirListName, %i[ptr int], :str
  ffi_func :rl_AudioStreamSineReset, [], :void
  ffi_func :rl_UpdateAudioStreamSine, %i[ptr int float float int], :void
  ffi_func :rl_FontTexture_ptr, [:ptr], :ptr
  ffi_func :rl_FontGlyphAdvanceX, [:ptr, :int], :int
  ffi_func :rl_FontGlyphRecWidth, [:ptr, :int], :float
  ffi_func :rl_LoadFontAtlas_ptr, %i[str int int int int int int], :ptr
  ffi_func :rl_DrawRectangleLinesExF, %i[float float float float float ptr], :void
  ffi_func :rl_CheckCollisionPointRecF, %i[ptr float float float float], :bool
  ffi_func :rl_Model_material_ptr, [:ptr, :int], :ptr
  ffi_func :rl_Model_transform, [:ptr, :ptr], :void
  ffi_func :rl_Model_set_transform, [:ptr, :ptr], :void
  ffi_func :rl_Model_mesh_ptr, [:ptr, :int], :ptr
  ffi_func :rl_Model_meshCount, [:ptr], :int
  ffi_func :rl_ModelAnimationAt_ptr, [:ptr, :int], :ptr
  ffi_func :rl_ModelAnimation_frameCount, [:ptr], :int
  ffi_func :rl_Model_boneCount, [:ptr], :int
  ffi_func :rl_Model_boneParent, [:ptr, :int], :int
  ffi_func :rl_Model_bindPoseTranslation, [:ptr, :int, :ptr], :void
  ffi_func :rl_ModelAnimation_framePoseTranslation, [:ptr, :int, :int, :ptr], :void
  ffi_func :rl_LoadShaderFS_ptr, [:str], :ptr
  ffi_func :rl_SetShaderValueFloat, [:ptr, :int, :float, :int], :void
  ffi_func :rl_SetShaderValueVec2, [:ptr, :int, :float, :float, :int], :void
  ffi_func :rl_SetShaderValueVec3, [:ptr, :int, :float, :float, :float, :int], :void
  ffi_func :rl_SetShaderValueVec4, [:ptr, :int, :float, :float, :float, :float, :int], :void
  ffi_func :rl_SetShaderValueInt, [:ptr, :int, :int, :int], :void
  ffi_func :rl_SetShaderValueColor, [:ptr, :int, :ptr, :int], :void
  ffi_func :rl_Shader_setLoc, [:ptr, :int, :int], :void
  ffi_func :rl_Material_set_shader, [:ptr, :ptr], :void
  # Diffuse texture poke: Material.maps[] is embedded in the Material struct,
  # so Ruby cannot reach maps[MAP_DIFFUSE].texture. Both return 1 on success,
  # 0 on a NULL / out-of-range handle.
  ffi_func :rl_Material_set_diffuse, [:ptr, :ptr], :int
  ffi_func :rl_ModelSetDiffuseTexture, %i[ptr int ptr], :int
  ffi_func :rl_RayCollision_point, [:ptr, :ptr], :void
  ffi_func :rl_RayCollision_normal, [:ptr, :ptr], :void
  ffi_func :rl_Camera_position_x, [:ptr], :float
  ffi_func :rl_Camera_position_y, [:ptr], :float
  ffi_func :rl_Camera_position_z, [:ptr], :float
  ffi_func :rl_Camera_target_x, [:ptr], :float
  ffi_func :rl_Camera_target_y, [:ptr], :float
  ffi_func :rl_Camera_target_z, [:ptr], :float
  ffi_func :rl_ImageColorR, [:ptr, :int], :int
  ffi_func :rl_CheckCollisionCircleRecF, %i[ptr float float float float float], :bool
  # CheckCollisionBoxes from 12 raw floats, bypassing native BoundingBox/Vector3
  # construction (single-TU cls_id mismatch; see AGENTS.md section A). Arg order
  # is (min x,y,z, max x,y,z) for box 1 then box 2.
  ffi_func :rl_CheckCollisionBoxesF,
           %i[float float float float float float float float float float float float],
           :bool
  ffi_func :rl_MatrixRotateXYZ, [:ptr, :ptr], :void
  ffi_func :rl_IntAlloc, [], :ptr
  ffi_func :rl_IntGet, [:ptr], :int
  ffi_func :rl_IntFree, [:ptr], :void
  ffi_func :rl_ImageWidth, [:ptr], :int
  ffi_func :rl_ImageHeight, [:ptr], :int
  ffi_func :rl_ImageFrameData, [:ptr, :int], :ptr
  ffi_func :rl_Camera_position_from_bounds, %i[ptr ptr float], :void
  ffi_func :rl_RenderTexture_texture_ptr, [:ptr], :ptr
  ffi_func :rl_TextureWidth, [:ptr], :int
  ffi_func :rl_TextureHeight, [:ptr], :int
  ffi_func :rl_ImageFromImageF_ptr, %i[ptr float float float float], :ptr
  ffi_func :rl_DrawRectangleProF, %i[float float float float float float float ptr], :void
  ffi_func :rl_DrawRectangleRoundedF, %i[float float float float float int ptr], :void
  ffi_func :rl_DrawRectangleRoundedLinesExF, %i[float float float float float int float ptr], :void
  ffi_func :rl_DrawTextureRecF, %i[ptr float float float float float float ptr], :void
  ffi_func :rl_DrawTextureProF, %i[ptr float float float float float float float float float float float ptr], :void
  ffi_func :rl_DrawTextureRec4, %i[ptr float float float float ptr ptr], :void
  ffi_func :rl_BeginMode2DF, %i[float float float float float float], :void
  ffi_func :rl_DrawRectangleRecF, %i[float float float float ptr], :void
  ffi_func :rl_Camera3DCreate, %i[float float float float float float float float float float int], :ptr
  ffi_func :rl_EndMode3D, [], :void
  ffi_func :rl_DrawGrid, [:int, :float], :void
  ffi_func :rl_DrawRenderTexture, [:ptr, :ptr], :void
  ffi_func :rl_DrawRenderTextureAt, [:ptr, :int, :int, :ptr], :void
  ffi_func :rl_DrawRenderTexturePro, %i[ptr float ptr], :void
  ffi_func :rl_LoadImageFromRenderTexture, [:ptr], :ptr
  def self.SaveRenderTextureImage(target, path)
    image = Raylib.rl_LoadImageFromRenderTexture(target)
    Raylib.ImageFlipVertical(image)
    Raylib.rl_ExportImage(image, path)
    Raylib.rl_UnloadImage(image)
  end
  ffi_func :rl_LoadFont, [:str], :ptr
  ffi_func :rl_LoadFontEx, [:str, :int, :ptr, :int], :ptr
  ffi_func :rl_LoadFontFromImage, [:ptr, :ptr, :int], :ptr
  ffi_func :rl_LoadFontFromMemory, [:str, :ptr, :int, :int, :ptr, :int], :ptr
  ffi_func :rl_IsFontValid, [:ptr], :bool
  ffi_func :LoadFontData, [:ptr, :int, :int, :ptr, :int, :int, :ptr], :ptr
  ffi_func :rl_GenImageFontAtlas, [:ptr, :ptr, :int, :int, :int, :int], :ptr
  ffi_func :UnloadFontData, [:ptr, :int], :void
  ffi_func :rl_UnloadFont, [:ptr], :void
  ffi_func :rl_ExportFontAsCode, [:ptr, :str], :bool
  ffi_func :rl_DrawTextEx, [:ptr, :str, :ptr, :float, :float, :ptr], :void
  ffi_func :rl_DrawTextPro, [:ptr, :str, :ptr, :ptr, :float, :float, :float, :ptr], :void
  ffi_func :rl_DrawTextCodepoint, [:ptr, :int, :ptr, :float, :ptr], :void
  ffi_func :rl_DrawTextCodepoints, [:ptr, :ptr, :int, :ptr, :float, :float, :ptr], :void
  ffi_func :SetTextLineSpacing, [:int], :void
  ffi_func :MeasureText, [:str, :int], :int
  ffi_func :rl_MeasureTextEx, [:ptr, :str, :float, :float, :ptr], :void
  ffi_func :rl_MeasureTextCodepoints, [:ptr, :ptr, :int, :float, :float, :ptr], :void
  ffi_func :rl_GetGlyphIndex, [:ptr, :int], :int
  ffi_func :rl_GetGlyphInfo, [:ptr, :int], :ptr
  ffi_func :rl_GetGlyphAtlasRec, [:ptr, :int, :ptr], :void
  ffi_func :LoadUTF8, [:ptr, :int], :str
  ffi_func :UnloadUTF8, [:str], :void
  ffi_func :LoadCodepoints, [:str, :ptr], :ptr
  ffi_func :UnloadCodepoints, [:ptr], :void
  ffi_func :GetCodepointCount, [:str], :int
  ffi_func :GetCodepoint, [:str, :ptr], :int
  ffi_func :GetCodepointNext, [:str, :ptr], :int
  ffi_func :GetCodepointPrevious, [:str, :ptr], :int
  ffi_func :CodepointToUTF8, [:int, :ptr], :str
  ffi_func :LoadTextLines, [:str, :ptr], :ptr
  ffi_func :UnloadTextLines, [:ptr, :int], :void
  ffi_func :TextCopy, [:str, :str], :int
  ffi_func :TextIsEqual, [:str, :str], :bool
  ffi_func :TextLength, [:str], :uint
  ffi_func :TextSubtext, [:str, :int, :int], :str
  ffi_func :TextRemoveSpaces, [:str], :str
  ffi_func :GetTextBetween, [:str, :str, :str], :str
  ffi_func :TextReplace, [:str, :str, :str], :str
  ffi_func :TextReplaceAlloc, [:str, :str, :str], :str
  ffi_func :TextReplaceBetween, [:str, :str, :str, :str], :str
  ffi_func :TextReplaceBetweenAlloc, [:str, :str, :str, :str], :str
  ffi_func :TextInsert, [:str, :str, :int], :str
  ffi_func :TextInsertAlloc, [:str, :str, :int], :str
  ffi_func :TextJoin, [:ptr, :int, :str], :str
  ffi_func :TextSplit, [:str, :char, :ptr], :ptr
  ffi_func :TextAppend, [:str, :str, :ptr], :void
  ffi_func :TextFindIndex, [:str, :str], :int
  ffi_func :TextToUpper, [:str], :str
  ffi_func :TextToLower, [:str], :str
  ffi_func :TextToPascal, [:str], :str
  ffi_func :TextToSnake, [:str], :str
  ffi_func :TextToCamel, [:str], :str
  ffi_func :TextToInteger, [:str], :int
  ffi_func :TextToFloat, [:str], :float
  ffi_func :rl_DrawLine3D, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_DrawPoint3D, [:ptr, :ptr], :void
  ffi_func :rl_DrawCircle3D, [:ptr, :float, :ptr, :float, :ptr], :void
  ffi_func :rl_DrawTriangle3D, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_DrawTriangleStrip3D, [:ptr, :int, :ptr], :void
  ffi_func :rl_DrawCubeV, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_DrawCubeWiresV, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_DrawSphere, [:ptr, :float, :ptr], :void
  ffi_func :rl_DrawSphereEx, [:ptr, :float, :int, :int, :ptr], :void
  ffi_func :rl_DrawSphereWires, [:ptr, :float, :int, :int, :ptr], :void
  ffi_func :rl_DrawCylinder, [:ptr, :float, :float, :float, :int, :ptr], :void
  ffi_func :rl_DrawCylinderEx, [:ptr, :ptr, :float, :float, :int, :ptr], :void
  ffi_func :rl_DrawCylinderWires, [:ptr, :float, :float, :float, :int, :ptr], :void
  ffi_func :rl_DrawCylinderWiresEx, [:ptr, :ptr, :float, :float, :int, :ptr], :void
  ffi_func :rl_DrawCapsule, [:ptr, :ptr, :float, :int, :int, :ptr], :void
  ffi_func :rl_DrawCapsuleWires, [:ptr, :ptr, :float, :int, :int, :ptr], :void
  ffi_func :rl_DrawRay, [:ptr, :ptr], :void
  ffi_func :DrawGrid, [:int, :float], :void
  ffi_func :rl_LoadModel, [:str], :ptr
  ffi_func :rl_LoadModelFromMesh, [:ptr], :ptr
  ffi_func :rl_IsModelValid, [:ptr], :bool
  ffi_func :rl_UnloadModel, [:ptr], :void
  ffi_func :rl_GetModelBoundingBox, [:ptr, :ptr], :void
  ffi_func :rl_DrawModel, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_DrawModelEx, [:ptr, :ptr, :ptr, :float, :ptr, :ptr], :void
  ffi_func :rl_DrawModelWires, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_DrawModelWiresEx, [:ptr, :ptr, :ptr, :float, :ptr, :ptr], :void
  ffi_func :rl_DrawBoundingBox, [:ptr, :ptr], :void
  ffi_func :rl_DrawBillboard, [:ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_DrawBillboardRec, [:ptr, :ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_DrawBillboardPro, [:ptr, :ptr, :ptr, :ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :UploadMesh, [:ptr, :bool], :void
  ffi_func :rl_UpdateMeshBuffer, [:ptr, :int, :ptr, :int, :int], :void
  ffi_func :rl_UnloadMesh, [:ptr], :void
  ffi_func :rl_DrawMesh, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_DrawMeshInstanced, [:ptr, :ptr, :ptr, :int], :void
  ffi_func :rl_GetMeshBoundingBox, [:ptr, :ptr], :void
  ffi_func :GenMeshTangents, [:ptr], :void
  ffi_func :rl_ExportMesh, [:ptr, :str], :bool
  ffi_func :rl_ExportMeshAsCode, [:ptr, :str], :bool
  ffi_func :rl_GenMeshPoly, [:int, :float], :ptr
  ffi_func :rl_GenMeshPlane, [:float, :float, :int, :int], :ptr
  ffi_func :rl_GenMeshCube, [:float, :float, :float], :ptr
  ffi_func :rl_GenMeshSphere, [:float, :int, :int], :ptr
  ffi_func :rl_GenMeshHemiSphere, [:float, :int, :int], :ptr
  ffi_func :rl_GenMeshCylinder, [:float, :float, :int], :ptr
  ffi_func :rl_GenMeshCone, [:float, :float, :int], :ptr
  ffi_func :rl_GenMeshTorus, [:float, :float, :int, :int], :ptr
  ffi_func :rl_GenMeshKnot, [:float, :float, :int, :int], :ptr
  ffi_func :rl_GenMeshHeightmap, [:ptr, :ptr], :ptr
  ffi_func :rl_GenMeshCubicmap, [:ptr, :ptr], :ptr
  ffi_func :LoadMaterials, [:str, :ptr], :ptr
  ffi_func :rl_LoadMaterialDefault, [], :ptr
  ffi_func :rl_IsMaterialValid, [:ptr], :bool
  ffi_func :rl_UnloadMaterial, [:ptr], :void
  ffi_func :rl_SetMaterialTexture, [:ptr, :int, :ptr], :void
  ffi_func :SetModelMeshMaterial, [:ptr, :int, :int], :void
  ffi_func :LoadModelAnimations, [:str, :ptr], :ptr
  ffi_func :rl_UpdateModelAnimation, [:ptr, :ptr, :float], :void
  ffi_func :rl_UpdateModelAnimationEx, [:ptr, :ptr, :float, :ptr, :float, :float], :void
  ffi_func :UnloadModelAnimations, [:ptr, :int], :void
  ffi_func :rl_IsModelAnimationValid, [:ptr, :ptr], :bool
  ffi_func :rl_CheckCollisionSpheres, [:ptr, :float, :ptr, :float], :bool
  ffi_func :rl_CheckCollisionBoxes, [:ptr, :ptr], :bool
  ffi_func :rl_CheckCollisionBoxSphere, [:ptr, :ptr, :float], :bool
  ffi_func :rl_GetRayCollisionSphere, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :rl_GetRayCollisionBox, [:ptr, :ptr, :ptr], :void
  ffi_func :rl_GetRayCollisionMesh, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_GetRayCollisionTriangle, [:ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :rl_GetRayCollisionQuad, [:ptr, :ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :InitAudioDevice, [], :void
  ffi_func :CloseAudioDevice, [], :void
  ffi_func :IsAudioDeviceReady, [], :bool
  ffi_func :SetMasterVolume, [:float], :void
  ffi_func :GetMasterVolume, [], :float
  ffi_func :rl_LoadWave, [:str], :ptr
  ffi_func :rl_LoadWaveFromMemory, [:str, :ptr, :int], :ptr
  ffi_func :rl_IsWaveValid, [:ptr], :bool
  ffi_func :rl_LoadSound, [:str], :ptr
  ffi_func :rl_LoadSoundFromWave, [:ptr], :ptr
  ffi_func :rl_LoadSoundAlias, [:ptr], :ptr
  ffi_func :rl_IsSoundValid, [:ptr], :bool
  ffi_func :rl_UpdateSound, [:ptr, :ptr, :int], :void
  ffi_func :rl_UnloadWave, [:ptr], :void
  ffi_func :rl_UnloadSound, [:ptr], :void
  ffi_func :rl_UnloadSoundAlias, [:ptr], :void
  ffi_func :rl_ExportWave, [:ptr, :str], :bool
  ffi_func :rl_ExportWaveAsCode, [:ptr, :str], :bool
  ffi_func :rl_PlaySound, [:ptr], :void
  ffi_func :rl_StopSound, [:ptr], :void
  ffi_func :rl_PauseSound, [:ptr], :void
  ffi_func :rl_ResumeSound, [:ptr], :void
  ffi_func :rl_IsSoundPlaying, [:ptr], :bool
  ffi_func :rl_SetSoundVolume, [:ptr, :float], :void
  ffi_func :rl_SetSoundPitch, [:ptr, :float], :void
  ffi_func :rl_SetSoundPan, [:ptr, :float], :void
  ffi_func :rl_WaveCopy, [:ptr], :ptr
  ffi_func :WaveCrop, [:ptr, :int, :int], :void
  ffi_func :WaveFormat, [:ptr, :int, :int, :int], :void
  ffi_func :rl_LoadWaveSamples, [:ptr], :ptr
  ffi_func :UnloadWaveSamples, [:ptr], :void
  ffi_func :rl_LoadMusicStream, [:str], :ptr
  ffi_func :rl_LoadMusicStreamFromMemory, [:str, :ptr, :int], :ptr
  ffi_func :rl_IsMusicValid, [:ptr], :bool
  ffi_func :rl_UnloadMusicStream, [:ptr], :void
  ffi_func :rl_PlayMusicStream, [:ptr], :void
  ffi_func :rl_IsMusicStreamPlaying, [:ptr], :bool
  ffi_func :rl_UpdateMusicStream, [:ptr], :void
  ffi_func :rl_StopMusicStream, [:ptr], :void
  ffi_func :rl_PauseMusicStream, [:ptr], :void
  ffi_func :rl_ResumeMusicStream, [:ptr], :void
  ffi_func :rl_SeekMusicStream, [:ptr, :float], :void
  ffi_func :rl_SetMusicVolume, [:ptr, :float], :void
  ffi_func :rl_SetMusicPitch, [:ptr, :float], :void
  ffi_func :rl_SetMusicPan, [:ptr, :float], :void
  ffi_func :rl_GetMusicTimeLength, [:ptr], :float
  ffi_func :rl_GetMusicTimePlayed, [:ptr], :float
  ffi_func :rl_LoadAudioStream, [:uint, :uint, :uint], :ptr
  ffi_func :rl_IsAudioStreamValid, [:ptr], :bool
  ffi_func :rl_UnloadAudioStream, [:ptr], :void
  ffi_func :rl_UpdateAudioStream, [:ptr, :str, :int], :void
  ffi_func :rl_IsAudioStreamProcessed, [:ptr], :bool
  ffi_func :rl_PlayAudioStream, [:ptr], :void
  ffi_func :rl_PauseAudioStream, [:ptr], :void
  ffi_func :rl_ResumeAudioStream, [:ptr], :void
  ffi_func :rl_IsAudioStreamPlaying, [:ptr], :bool
  ffi_func :rl_StopAudioStream, [:ptr], :void
  ffi_func :rl_SetAudioStreamVolume, [:ptr, :float], :void
  ffi_func :rl_SetAudioStreamPitch, [:ptr, :float], :void
  ffi_func :rl_SetAudioStreamPan, [:ptr, :float], :void
  ffi_func :SetAudioStreamBufferSizeDefault, [:int], :void
  ffi_func :rl_SetAudioStreamCallback, [:ptr, :ptr], :void
  ffi_func :rl_AttachAudioStreamProcessor, [:ptr, :ptr], :void
  ffi_func :rl_DetachAudioStreamProcessor, [:ptr, :ptr], :void
  ffi_func :rl_AttachAudioMixedProcessor, [:ptr], :void
  ffi_func :rl_DetachAudioMixedProcessor, [:ptr], :void
  native_struct "Vector4", "rl_Vector4"
  native_new [], "rl_Vector4_new"
  native_new [:ptr, :any], "rl_Vector4_view"
  native_method :x, [], :float, "rl_Vector4_x"
  native_method :x=, [:float], :float, "rl_Vector4_set_x"
  native_method :y, [], :float, "rl_Vector4_y"
  native_method :y=, [:float], :float, "rl_Vector4_set_y"
  native_method :z, [], :float, "rl_Vector4_z"
  native_method :z=, [:float], :float, "rl_Vector4_set_z"
  native_method :w, [], :float, "rl_Vector4_w"
  native_method :w=, [:float], :float, "rl_Vector4_set_w"
  native_struct "Rectangle", "rl_Rectangle"
  native_new [], "rl_Rectangle_new"
  # Address view (gem: Rectangle.new(font.recs + i * Rectangle.size)).
  native_new [:any], "rl_Rectangle_view_addr"
  native_method :x, [], :float, "rl_Rectangle_x"
  native_method :x=, [:float], :float, "rl_Rectangle_set_x"
  native_method :y, [], :float, "rl_Rectangle_y"
  native_method :y=, [:float], :float, "rl_Rectangle_set_y"
  native_method :width, [], :float, "rl_Rectangle_width"
  native_method :width=, [:float], :float, "rl_Rectangle_set_width"
  native_method :height, [], :float, "rl_Rectangle_height"
  native_method :height=, [:float], :float, "rl_Rectangle_set_height"
  native_struct "Camera2D", "rl_Camera2D"
  native_new [], "rl_Camera2D_new"
  native_method :offset_ptr, [], :ptr, "rl_Camera2D_offset_ptr"
  native_method :target_ptr, [], :ptr, "rl_Camera2D_target_ptr"
  native_method :rotation, [], :float, "rl_Camera2D_rotation"
  native_method :rotation=, [:float], :float, "rl_Camera2D_set_rotation"
  native_method :zoom, [], :float, "rl_Camera2D_zoom"
  native_method :zoom=, [:float], :float, "rl_Camera2D_set_zoom"
  native_struct "BoundingBox", "rl_BoundingBox"
  native_new [], "rl_BoundingBox_new"
  native_method :with_min, %i[float float float], :self, "rl_BoundingBox_with_min"
  native_method :with_max, %i[float float float], :self, "rl_BoundingBox_with_max"
  native_method :min_ptr, [], :ptr, "rl_BoundingBox_min_ptr"
  native_method :max_ptr, [], :ptr, "rl_BoundingBox_max_ptr"
  # Transform (3 Vector3s): the gem helper class, views for t/r/s.
  native_struct "Transform", "rl_Transform"
  native_new [], "rl_Transform_new"
  native_method :t_ptr, [], :ptr, "rl_Transform_t_ptr"
  native_method :r_ptr, [], :ptr, "rl_Transform_r_ptr"
  native_method :s_ptr, [], :ptr, "rl_Transform_s_ptr"
  native_struct "Ray", "rl_Ray"
  native_new [], "rl_Ray_new"
  native_struct "RayCollision", "rl_RayCollision"
  native_new [], "rl_RayCollision_new"
  native_method :hit, [], :int, "rl_RayCollision_hit"
  native_method :hit=, [:int], :int, "rl_RayCollision_set_hit"
  native_method :distance, [], :float, "rl_RayCollision_distance"
  native_method :distance=, [:float], :float, "rl_RayCollision_set_distance"
  native_struct "Matrix", "rl_Matrix"
  native_new [], "rl_Matrix_new"
  native_method :m0, [], :float, "rl_Matrix_m0"
  native_method :m0=, [:float], :float, "rl_Matrix_set_m0"
  native_method :m4, [], :float, "rl_Matrix_m4"
  native_method :m4=, [:float], :float, "rl_Matrix_set_m4"
  native_method :m8, [], :float, "rl_Matrix_m8"
  native_method :m8=, [:float], :float, "rl_Matrix_set_m8"
  native_method :m12, [], :float, "rl_Matrix_m12"
  native_method :m12=, [:float], :float, "rl_Matrix_set_m12"
  native_method :m1, [], :float, "rl_Matrix_m1"
  native_method :m1=, [:float], :float, "rl_Matrix_set_m1"
  native_method :m5, [], :float, "rl_Matrix_m5"
  native_method :m5=, [:float], :float, "rl_Matrix_set_m5"
  native_method :m9, [], :float, "rl_Matrix_m9"
  native_method :m9=, [:float], :float, "rl_Matrix_set_m9"
  native_method :m13, [], :float, "rl_Matrix_m13"
  native_method :m13=, [:float], :float, "rl_Matrix_set_m13"
  native_method :m2, [], :float, "rl_Matrix_m2"
  native_method :m2=, [:float], :float, "rl_Matrix_set_m2"
  native_method :m6, [], :float, "rl_Matrix_m6"
  native_method :m6=, [:float], :float, "rl_Matrix_set_m6"
  native_method :m10, [], :float, "rl_Matrix_m10"
  native_method :m10=, [:float], :float, "rl_Matrix_set_m10"
  native_method :m14, [], :float, "rl_Matrix_m14"
  native_method :m14=, [:float], :float, "rl_Matrix_set_m14"
  native_method :m3, [], :float, "rl_Matrix_m3"
  native_method :m3=, [:float], :float, "rl_Matrix_set_m3"
  native_method :m7, [], :float, "rl_Matrix_m7"
  native_method :m7=, [:float], :float, "rl_Matrix_set_m7"
  native_method :m11, [], :float, "rl_Matrix_m11"
  native_method :m11=, [:float], :float, "rl_Matrix_set_m11"
  native_method :m15, [], :float, "rl_Matrix_m15"
  native_method :m15=, [:float], :float, "rl_Matrix_set_m15"
  native_struct "NPatchInfo", "rl_NPatchInfo"
  native_new [], "rl_NPatchInfo_new"
  native_method :left, [], :int, "rl_NPatchInfo_left"
  native_method :left=, [:int], :int, "rl_NPatchInfo_set_left"
  native_method :top, [], :int, "rl_NPatchInfo_top"
  native_method :top=, [:int], :int, "rl_NPatchInfo_set_top"
  native_method :right, [], :int, "rl_NPatchInfo_right"
  native_method :right=, [:int], :int, "rl_NPatchInfo_set_right"
  native_method :bottom, [], :int, "rl_NPatchInfo_bottom"
  native_method :bottom=, [:int], :int, "rl_NPatchInfo_set_bottom"
  native_method :layout, [], :int, "rl_NPatchInfo_layout"
  native_method :layout=, [:int], :int, "rl_NPatchInfo_set_layout"
  native_struct "VrDeviceInfo", "rl_VrDeviceInfo"
  native_new [], "rl_VrDeviceInfo_new"
  native_method :hResolution, [], :int, "rl_VrDeviceInfo_hResolution"
  native_method :hResolution=, [:int], :int, "rl_VrDeviceInfo_set_hResolution"
  native_method :vResolution, [], :int, "rl_VrDeviceInfo_vResolution"
  native_method :vResolution=, [:int], :int, "rl_VrDeviceInfo_set_vResolution"
  native_method :hScreenSize, [], :float, "rl_VrDeviceInfo_hScreenSize"
  native_method :hScreenSize=, [:float], :float, "rl_VrDeviceInfo_set_hScreenSize"
  native_method :vScreenSize, [], :float, "rl_VrDeviceInfo_vScreenSize"
  native_method :vScreenSize=, [:float], :float, "rl_VrDeviceInfo_set_vScreenSize"
  native_method :eyeToScreenDistance, [], :float, "rl_VrDeviceInfo_eyeToScreenDistance"
  native_method :eyeToScreenDistance=, [:float], :float, "rl_VrDeviceInfo_set_eyeToScreenDistance"
  native_method :lensSeparationDistance, [], :float, "rl_VrDeviceInfo_lensSeparationDistance"
  native_method :lensSeparationDistance=, [:float], :float, "rl_VrDeviceInfo_set_lensSeparationDistance"
  native_method :interpupillaryDistance, [], :float, "rl_VrDeviceInfo_interpupillaryDistance"
  native_method :interpupillaryDistance=, [:float], :float, "rl_VrDeviceInfo_set_interpupillaryDistance"
  native_struct "VrStereoConfig", "rl_VrStereoConfig"
  native_new [], "rl_VrStereoConfig_new"
  native_struct "FilePathList", "rl_FilePathList"
  native_new [], "rl_FilePathList_new"
  native_method :count, [], :int, "rl_FilePathList_count"
  native_method :count=, [:int], :int, "rl_FilePathList_set_count"
  native_method :path, [:int], :str, "rl_FilePathList_path"
  native_struct "AutomationEvent", "rl_AutomationEvent"
  native_new [], "rl_AutomationEvent_new"
  native_method :frame, [], :int, "rl_AutomationEvent_frame"
  native_method :frame=, [:int], :int, "rl_AutomationEvent_set_frame"
  native_method :type, [], :int, "rl_AutomationEvent_type"
  native_method :type=, [:int], :int, "rl_AutomationEvent_set_type"
  native_struct "AutomationEventList", "rl_AutomationEventList"
  native_new [], "rl_AutomationEventList_new"
  native_method :capacity, [], :int, "rl_AutomationEventList_capacity"
  native_method :capacity=, [:int], :int, "rl_AutomationEventList_set_capacity"
  native_method :count, [], :int, "rl_AutomationEventList_count"
  native_method :count=, [:int], :int, "rl_AutomationEventList_set_count"
  native_struct "Vector2", "rl_Vector2"
  native_new [], "rl_Vector2_new"
  # View constructor: payload pointer + owner (kept alive by the view's scan).
  native_new [:ptr, :any], "rl_Vector2_view"
  native_method :x, [], :float, "rl_Vector2_x"
  native_method :x=, [:float], :float, "rl_Vector2_set_x"
  native_method :y, [], :float, "rl_Vector2_y"
  native_method :y=, [:float], :float, "rl_Vector2_set_y"

  # Window
  ffi_func :InitWindow, %i[int int str], :void
  ffi_func :CloseWindow, [], :void
  # Bool-returning raylib functions go through rl_ shims (see
  # raylib_adapter.c — _Bool returns only define AL on x86-64).
  # Spinel marshals :bool results as real true/false objects.
  ffi_func :WindowShouldClose, [], :bool
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
  # Color/vector-taking raylib functions are redeclared as rl_ shims
  # (pointers only) — see raylib_adapter.c. Color structs are
  # heap-allocated via ffi_struct and passed as void*.
  ffi_func :BeginDrawing, [], :void
  ffi_func :EndDrawing, [], :void
  ffi_func :rl_ClearBackground, [:ptr], :void
  ffi_func :rl_DrawCircleV, %i[ptr float ptr], :void
  ffi_func :rl_DrawTriangle, %i[ptr ptr ptr ptr], :void
  ffi_func :rl_DrawText, %i[str int int int ptr], :void
  ffi_func :rl_DrawTextInt, %i[str int int int int ptr], :void
  ffi_func :DrawFPS, %i[int int], :void

  # Input
  ffi_func :IsKeyDown, [:int], :bool
  ffi_func :IsKeyPressed, [:int], :bool
  ffi_func :IsMouseButtonDown, [:int], :bool
  ffi_func :IsGamepadButtonDown, %i[int int], :bool
  ffi_func :GetMouseX, [], :int
  ffi_func :GetMouseY, [], :int

  # Time
  ffi_func :GetFrameTime, [], :float
  ffi_func :GetTime, [], :double # raylib returns double
  ffi_func :GetFPS, [], :int

  # Color is a native (C-backed) GC-managed class (see raylib_adapter.c:
  # rl_Color embeds the raylib Color struct). Instances live in spinel's GC
  # heap, so a color is reclaimed automatically when the last reference
  # (e.g. a Bunny) is collected — no manual Color.free is needed.
  #
  # Spinel cannot pass a native object to an ffi_func :ptr/:any argument
  # (only as a native_method receiver), so every color-consuming draw call
  # is a method on the Color itself (the color is the receiver).
  native_struct "Color", "rl_Color"
  native_new [:int, :int, :int, :int], "rl_Color_new"
  # Views: Color.new(ptr, owner) / Color.new(addr) (gem code indexes
  # LoadImageColors with Color.new(mapPixels + Color.size * i)).
  native_new [:ptr, :any], "rl_Color_view"
  native_new [:any], "rl_Color_view_addr"
  native_method :fill_background, [], :void, "rl_Color_fill_background"
  native_method :draw_texture, [:any, :int, :int], :void, "rl_Color_draw_texture"
  native_method :draw_text, [:string, :int, :int, :int], :void, "rl_Color_draw_text"
  native_method :draw_text_int, [:string, :int, :int, :int, :int], :void, "rl_Color_draw_text_int"
  native_method :r, [], :int, "rl_Color_r"
  native_method :g, [], :int, "rl_Color_g"
  native_method :b, [], :int, "rl_Color_b"
  native_method :a, [], :int, "rl_Color_a"
  native_method :r=, [:int], :int, "rl_Color_set_r"
  native_method :g=, [:int], :int, "rl_Color_set_g"
  native_method :b=, [:int], :int, "rl_Color_set_b"
  native_method :a=, [:int], :int, "rl_Color_set_a"
  # Texture (opaque pointer — rl_LoadTexture mallocs Texture2D)
  ffi_func :rl_LoadTexture, [:str], :ptr
  ffi_func :rl_DrawTexture, %i[ptr int int ptr], :void
  # Tint passed as a packed 0xRRGGBBAA int (data-oriented sprite pools).
  ffi_func :rl_DrawTexturePacked, %i[ptr int int int], :void
  ffi_func :rl_DrawTextureEx, %i[ptr float float float float ptr], :void
  ffi_func :rl_UnloadTexture, [:ptr], :void

  # Input / misc (plain raylib functions — no struct args)
  ffi_func :GetRandomValue, %i[int int], :int
  ffi_func :DisableCursor, [], :void
  ffi_func :EndMode3D, [], :void

  # 3D / extra drawing (Vector3, Vector2, Camera3D, Color passed as pointers)
  ffi_func :rl_BeginMode3D, [:ptr], :void
  ffi_func :rl_UpdateCamera, %i[ptr int], :void
  ffi_func :rl_DrawPlane, %i[ptr ptr ptr], :void
  ffi_func :rl_DrawCube, %i[ptr float float float ptr], :void
  ffi_func :rl_DrawCubeWires, %i[ptr float float float ptr], :void
  ffi_func :rl_DrawRectangle, %i[int int int int ptr], :void
  ffi_func :rl_DrawRectangleLines, %i[int int int int ptr], :void
  ffi_func :rl_DrawPixel, %i[int int ptr], :void
  # Color passed as a packed 0xRRGGBBAA int (data-oriented particle pools).
  ffi_func :rl_DrawPixelPacked, %i[int int int], :void
  # Batch-draw a whole pool in one call: parallel x/y FloatArrays and a packed
  # color IntArray (passed as their flat data pointers by the FFI).
  ffi_func :rl_DrawPixelsPacked, %i[float_array float_array int_array int], :void

  # Vector3 — native GC object (mirrors Color). Passed to the 3D shims as its
  # pointer; field-read with .x/.y/.z.
  native_struct "Vector3", "rl_Vector3"
  native_new [:float, :float, :float], "rl_Vector3_new"
  native_new [:ptr, :any], "rl_Vector3_view"
  native_method :x, [], :float, "rl_Vector3_x"
  native_method :y, [], :float, "rl_Vector3_y"
  native_method :z, [], :float, "rl_Vector3_z"
  native_method :x=, [:float], :float, "rl_Vector3_set_x"
  native_method :y=, [:float], :float, "rl_Vector3_set_y"
  native_method :z=, [:float], :float, "rl_Vector3_set_z"

  # Camera — native GC object wrapping Camera3D. Built with the with_* chain,
  # mutated by rl_UpdateCamera, passed to rl_BeginMode3D.
  native_struct "Camera", "rl_Camera"
  native_new [], "rl_Camera_new"
  native_method :with_position, [:float, :float, :float], :self, "rl_Camera_with_position"
  native_method :with_target, [:float, :float, :float], :self, "rl_Camera_with_target"
  native_method :with_up, [:float, :float, :float], :self, "rl_Camera_with_up"
  native_method :with_fovy, [:float], :self, "rl_Camera_with_fovy"
  native_method :with_projection, [:int], :self, "rl_Camera_with_projection"
  native_method :pointer, [], :ptr, "rl_Camera_ptr"
  # Gem-shaped field access (sub-struct views; see raylib_structs.rb).
  native_method :position_ptr, [], :ptr, "rl_Camera_position_ptr"
  native_method :target_ptr, [], :ptr, "rl_Camera_target_ptr"
  native_method :up_ptr, [], :ptr, "rl_Camera_up_ptr"
  native_method :fovy, [], :float, "rl_Camera_fovy"
  native_method :fovy=, [:float], :float, "rl_Camera_set_fovy"
  native_method :projection, [], :int, "rl_Camera_projection"
  native_method :projection=, [:int], :int, "rl_Camera_set_projection"

  # Constants — only define under Spinel (MRI gets them from the gem).
  # RUBY_ENGINE is a compile-time constant under AOT ("spinel") and "ruby"
  # under MRI, so the branch is folded away instead of being a runtime
  # condition wrapping method definitions (which newer Spinel rejects).
  if RUBY_ENGINE == "spinel"
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
    CAMERA_ORTHOGRAPHIC = 1
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
      Raylib.rl_ClearBackground(color)
    end

    def self.DrawText(text, x, y, size, color)
      Raylib.rl_DrawText(text, x, y, size, color)
    end

    def self.DrawTextInt(text, n, x, y, size, color)
      Raylib.rl_DrawTextInt(text, n, x, y, size, color)
    end
    def self.DrawTexture(texture, x, y, color)
      Raylib.rl_DrawTexture(texture, (x || 0).to_i, (y || 0).to_i, color)
    end

    def self.DrawTextureEx(texture, x, y, rotation, scale, color)
      Raylib.rl_DrawTextureEx(texture, x, y, rotation, scale, color)
    end

    def self.LoadTexture(path)
      Texture2D.new(Raylib.rl_LoadTexture(path), nil)
    end

    def self.UnloadTexture(texture)
      Raylib.rl_UnloadTexture(texture)
    end

    def self.DrawCircleV(center, radius, color)
      Raylib.rl_DrawCircleV(center, radius, color)
    end

    def self.DrawTriangle(v1, v2, v3, color)
      Raylib.rl_DrawTriangle(v1, v2, v3, color)
    end

    def self.BeginMode3D(camera)
      Raylib.rl_BeginMode3D(camera)
    end

    def self.UpdateCamera(camera, mode)
      Raylib.rl_UpdateCamera(camera, mode)
    end

    def self.DrawPlane(center_pos, size, color)
      Raylib.rl_DrawPlane(center_pos, size, color)
    end

    def self.DrawCube(position, width, height, length, color)
      Raylib.rl_DrawCube(position, width, height, length, color)
    end

    def self.DrawCubeWires(position, width, height, length, color)
      Raylib.rl_DrawCubeWires(position, (width || 0.0).to_f,
                              (height || 0.0).to_f, (length || 0.0).to_f,
                              color)
    end

    def self.DrawRectangle(x, y, width, height, color)
      Raylib.rl_DrawRectangle(x, y, width, height, color)
    end

    def self.DrawRectangleLines(x, y, width, height, color)
      Raylib.rl_DrawRectangleLines(x, y, width, height, color)
    end

    def self.DrawPixelPacked(x, y, rgba)
      Raylib.rl_DrawPixelPacked(x, y, rgba)
    end

    def self.DrawPixelsPacked(xs, ys, colors, count)
      Raylib.rl_DrawPixelsPacked(xs, ys, colors, count)
    end

    def self.DrawPixel(x, y, color)
      Raylib.rl_DrawPixel(x, y, color)
    end

    # Predicate wrappers return true/false in both backends: the gem
    # binds raylib's bool directly; here spinel marshals the shims'
    # 0/1 ints via the :bool declarations above.
    # def self.WindowShouldClose
    #   Raylib.rl_WindowShouldClose
    # end
    #
    # def self.IsKeyDown(key)
    #   Raylib.rl_IsKeyDown(key)
    # end
    #
    # def self.IsKeyPressed(key)
    #   Raylib.rl_IsKeyPressed(key)
    # end
    #
    # def self.IsMouseButtonDown(button)
    #   Raylib.rl_IsMouseButtonDown(button)
    # end
    #
    # def self.IsGamepadButtonDown(gamepad, button)
    #   Raylib.rl_IsGamepadButtonDown(gamepad, button)
    # end

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
    # rl_Color_new). Kept here (Spinel side) so they compile as Ruby methods on
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

    # Positional factories (Vector2/Vector4/Matrix).
    # The core native ctors for these are no-arg (they are mostly out-params),
    # and Spinel inlines Klass.new(args) straight to the native ctor, so a Ruby
    # `.new` override can never carry the values. Positional construction lives
    # here instead; MRI gets identical helpers in raylib_ruby.rb.
    #
    # Construction goes through C fill helpers (rl_*Fill in raylib_adapter.c):
    # Spinel's type analysis can degrade the accessor writers (v.x = x) to
    # generic ivar dispatch when other classes share those field names, which
    # miscompiles against the incomplete native struct in larger programs.
    # (ffi_func declarations live at the top of the module, with the others.)

    def self.Vector2(x, y)
      o = Vector2.new
      Raylib.rl_Vector2Fill(o, x, y)
      o
    end

    def self.Vector4(x, y, z, w)
      o = Vector4.new
      Raylib.rl_Vector4Fill(o, x, y, z, w)
      o
    end

    def self.Matrix(values)
      m = Matrix.new
      Raylib.rl_MatrixFill(m, values[0], values[1], values[2], values[3],
                           values[4], values[5], values[6], values[7],
                           values[8], values[9], values[10], values[11],
                           values[12], values[13], values[14], values[15])
      m
    end

    # ====== generated: wrappers + constants ======
    def self.SetWindowIcon(image)
      Raylib.rl_SetWindowIcon(image)
    end
    def self.GetMonitorPosition(monitor)
      _out = Vector2.new
      Raylib.rl_GetMonitorPosition(monitor, _out)
      _out
    end
    def self.GetWindowPosition()
      _out = Vector2.new
      Raylib.rl_GetWindowPosition(_out)
      _out
    end
    def self.GetWindowScaleDPI()
      _out = Vector2.new
      Raylib.rl_GetWindowScaleDPI(_out)
      _out
    end
    def self.GetClipboardImage()
      Image.new(Raylib.rl_GetClipboardImage(), nil)
    end
    def self.BeginMode2D(camera)
      Raylib.rl_BeginMode2D(camera)
    end
    def self.BeginTextureMode(target)
      Raylib.rl_BeginTextureMode(target)
    end
    def self.BeginShaderMode(shader)
      Raylib.rl_BeginShaderMode(shader)
    end
    def self.BeginVrStereoMode(config)
      Raylib.rl_BeginVrStereoMode(config)
    end
    def self.LoadVrStereoConfig(device)
      _out = VrStereoConfig.new
      Raylib.rl_LoadVrStereoConfig(device, _out)
      _out
    end
    def self.UnloadVrStereoConfig(config)
      Raylib.rl_UnloadVrStereoConfig(config)
    end
    def self.LoadShader(vsFileName, fsFileName)
      Shader.new(Raylib.rl_LoadShader(vsFileName, fsFileName), nil)
    end
    def self.LoadShaderFromMemory(vsCode, fsCode)
      Shader.new(Raylib.rl_LoadShaderFromMemory(vsCode, fsCode), nil)
    end
    def self.IsShaderValid(shader)
      Raylib.rl_IsShaderValid(shader)
    end
    def self.GetShaderLocation(shader, uniformName)
      Raylib.rl_GetShaderLocation(shader, uniformName)
    end
    def self.GetShaderLocationAttrib(shader, attribName)
      Raylib.rl_GetShaderLocationAttrib(shader, attribName)
    end
    def self.SetShaderValue(shader, locIndex, value, uniformType)
      Raylib.rl_SetShaderValue(shader, (locIndex || 0).to_i, value,
                               (uniformType || 0).to_i)
    end
    def self.SetShaderValueV(shader, locIndex, value, uniformType, count)
      Raylib.rl_SetShaderValueV(shader, locIndex, value, uniformType, count)
    end
    def self.SetShaderValueMatrix(shader, locIndex, mat)
      Raylib.rl_SetShaderValueMatrix(shader, locIndex, mat)
    end
    def self.SetShaderValueTexture(shader, locIndex, texture)
      Raylib.rl_SetShaderValueTexture(shader, locIndex, texture)
    end
    def self.UnloadShader(shader)
      Raylib.rl_UnloadShader(shader)
    end
    def self.GetScreenToWorldRay(position, camera)
      _out = Ray.new
      Raylib.rl_GetScreenToWorldRay(position, camera, _out)
      _out
    end
    def self.GetScreenToWorldRayEx(position, camera, width, height)
      _out = Ray.new
      Raylib.rl_GetScreenToWorldRayEx(position, camera, width, height, _out)
      _out
    end
    def self.GetWorldToScreen(position, camera)
      _out = Vector2.new
      Raylib.rl_GetWorldToScreen(position, camera, _out)
      _out
    end
    def self.GetWorldToScreenEx(position, camera, width, height)
      _out = Vector2.new
      Raylib.rl_GetWorldToScreenEx(position, camera, width, height, _out)
      _out
    end
    def self.GetWorldToScreen2D(position, camera)
      _out = Vector2.new
      Raylib.rl_GetWorldToScreen2D(position, camera, _out)
      _out
    end
    def self.GetScreenToWorld2D(position, camera)
      _out = Vector2.new
      Raylib.rl_GetScreenToWorld2D(position, camera, _out)
      _out
    end
    def self.GetCameraMatrix(camera)
      _out = Matrix.new
      Raylib.rl_GetCameraMatrix(camera, _out)
      _out
    end
    def self.GetCameraMatrix2D(camera)
      _out = Matrix.new
      Raylib.rl_GetCameraMatrix2D(camera, _out)
      _out
    end
    def self.SetTraceLogCallback(callback)
      Raylib.rl_SetTraceLogCallback(callback)
    end
    def self.SetLoadFileDataCallback(callback)
      Raylib.rl_SetLoadFileDataCallback(callback)
    end
    def self.SetSaveFileDataCallback(callback)
      Raylib.rl_SetSaveFileDataCallback(callback)
    end
    def self.SetLoadFileTextCallback(callback)
      Raylib.rl_SetLoadFileTextCallback(callback)
    end
    def self.SetSaveFileTextCallback(callback)
      Raylib.rl_SetSaveFileTextCallback(callback)
    end
    def self.LoadDirectoryFiles(dirPath)
      _out = FilePathList.new
      Raylib.rl_LoadDirectoryFiles(dirPath, _out)
      _out
    end
    def self.LoadDirectoryFilesEx(basePath, filter, scanSubdirs)
      _out = FilePathList.new
      Raylib.rl_LoadDirectoryFilesEx(basePath, filter, scanSubdirs, _out)
      _out
    end
    def self.UnloadDirectoryFiles(files)
      Raylib.rl_UnloadDirectoryFiles(files)
    end
    def self.LoadDroppedFiles()
      _out = FilePathList.new
      Raylib.rl_LoadDroppedFiles(_out)
      _out
    end
    def self.UnloadDroppedFiles(files)
      Raylib.rl_UnloadDroppedFiles(files)
    end
    def self.LoadAutomationEventList(fileName)
      _out = AutomationEventList.new
      Raylib.rl_LoadAutomationEventList(fileName, _out)
      _out
    end
    def self.UnloadAutomationEventList(list)
      Raylib.rl_UnloadAutomationEventList(list)
    end
    def self.ExportAutomationEventList(list, fileName)
      Raylib.rl_ExportAutomationEventList(list, fileName)
    end
    def self.SetAutomationEventList(list)
      Raylib.rl_SetAutomationEventList(list)
    end
    def self.PlayAutomationEvent(event)
      Raylib.rl_PlayAutomationEvent(event)
    end
    def self.GetMousePosition()
      _out = Vector2.new
      Raylib.rl_GetMousePosition(_out)
      _out
    end
    def self.GetMouseDelta()
      _out = Vector2.new
      Raylib.rl_GetMouseDelta(_out)
      _out
    end
    def self.GetMouseWheelMoveV()
      _out = Vector2.new
      Raylib.rl_GetMouseWheelMoveV(_out)
      _out
    end
    def self.GetTouchPosition(index)
      _out = Vector2.new
      Raylib.rl_GetTouchPosition(index, _out)
      _out
    end
    def self.GetGestureDragVector()
      _out = Vector2.new
      Raylib.rl_GetGestureDragVector(_out)
      _out
    end
    def self.GetGesturePinchVector()
      _out = Vector2.new
      Raylib.rl_GetGesturePinchVector(_out)
      _out
    end
    def self.UpdateCameraPro(camera, movement, rotation, zoom)
      Raylib.rl_UpdateCameraPro(camera, movement, rotation, zoom)
    end
    def self.SetShapesTexture(texture, rec)
      Raylib.rl_SetShapesTexture(texture, rec)
    end
    def self.GetShapesTexture()
      Texture2D.new(Raylib.rl_GetShapesTexture(), nil)
    end
    def self.GetShapesTextureRectangle()
      _out = Rectangle.new
      Raylib.rl_GetShapesTextureRectangle(_out)
      _out
    end
    def self.DrawPixelV(position, color)
      Raylib.rl_DrawPixelV(position, color)
    end
    def self.DrawLine(startPosX, startPosY, endPosX, endPosY, color)
      Raylib.rl_DrawLine(startPosX, startPosY, endPosX, endPosY, color)
    end
    def self.DrawLineV(startPos, endPos, color)
      Raylib.rl_DrawLineV(startPos, endPos, color)
    end
    def self.DrawLineEx(startPos, endPos, thick, color)
      Raylib.rl_DrawLineEx(startPos, endPos, thick, color)
    end
    def self.DrawLineStrip(points, pointCount, color)
      Raylib.rl_DrawLineStrip(points, pointCount, color)
    end
    def self.DrawLineBezier(startPos, endPos, thick, color)
      Raylib.rl_DrawLineBezier(startPos, endPos, thick, color)
    end
    def self.DrawLineDashed(startPos, endPos, dashSize, spaceSize, color)
      Raylib.rl_DrawLineDashed(startPos, endPos, dashSize, spaceSize, color)
    end
    def self.DrawTriangleGradient(v1, v2, v3, c1, c2, c3)
      Raylib.rl_DrawTriangleGradient(v1, v2, v3, c1, c2, c3)
    end
    def self.DrawTriangleLines(v1, v2, v3, color)
      Raylib.rl_DrawTriangleLines(v1, v2, v3, color)
    end
    def self.DrawTriangleLinesEx(v1, v2, v3, thick, color)
      Raylib.rl_DrawTriangleLinesEx(v1, v2, v3, thick, color)
    end
    def self.DrawTriangleFan(points, pointCount, color)
      Raylib.rl_DrawTriangleFan(points, pointCount, color)
    end
    def self.DrawTriangleStrip(points, pointCount, color)
      Raylib.rl_DrawTriangleStrip(points, pointCount, color)
    end
    def self.DrawRectangleV(position, size, color)
      Raylib.rl_DrawRectangleV(position, size, color)
    end
    def self.DrawRectangleRec(rec, color)
      Raylib.rl_DrawRectangleRec(rec, color)
    end
    def self.DrawRectanglePro(rec, origin, rotation, color)
      Raylib.rl_DrawRectanglePro(rec, origin, rotation, color)
    end
    def self.DrawRectangleGradientV(posX, posY, width, height, top, bottom)
      Raylib.rl_DrawRectangleGradientV(posX, posY, width, height, top, bottom)
    end
    def self.DrawRectangleGradientH(posX, posY, width, height, left, right)
      Raylib.rl_DrawRectangleGradientH(posX, posY, width, height, left, right)
    end
    def self.DrawRectangleGradientEx(rec, col1, col2, col3, col4)
      Raylib.rl_DrawRectangleGradientEx(rec, col1, col2, col3, col4)
    end
    def self.DrawRectangleLinesEx(rec, thick, color)
      Raylib.rl_DrawRectangleLinesEx(rec, thick, color)
    end
    def self.DrawRectangleRounded(rec, roundness, segments, color)
      Raylib.rl_DrawRectangleRounded(rec, roundness, segments, color)
    end
    def self.DrawRectangleRoundedLines(rec, roundness, segments, color)
      Raylib.rl_DrawRectangleRoundedLines(rec, roundness, segments, color)
    end
    def self.DrawRectangleRoundedLinesEx(rec, roundness, segments, thick, color)
      Raylib.rl_DrawRectangleRoundedLinesEx(rec, roundness, segments, thick, color)
    end
    def self.DrawPoly(center, sides, radius, rotation, color)
      Raylib.rl_DrawPoly(center, sides, radius, rotation, color)
    end
    def self.DrawPolyLines(center, sides, radius, rotation, color)
      Raylib.rl_DrawPolyLines(center, sides, radius, rotation, color)
    end
    def self.DrawPolyLinesEx(center, sides, radius, rotation, thick, color)
      Raylib.rl_DrawPolyLinesEx(center, sides, radius, rotation, thick, color)
    end
    def self.DrawCircle(centerX, centerY, radius, color)
      Raylib.rl_DrawCircle(centerX, centerY, radius, color)
    end
    def self.DrawCircleGradient(center, radius, inner, outer)
      Raylib.rl_DrawCircleGradient(center, radius, inner, outer)
    end
    def self.DrawCircleSector(center, radius, startAngle, endAngle, segments, color)
      Raylib.rl_DrawCircleSector(center, radius, startAngle, endAngle, segments, color)
    end
    def self.DrawCircleSectorLines(center, radius, startAngle, endAngle, segments, color)
      Raylib.rl_DrawCircleSectorLines(center, radius, startAngle, endAngle, segments, color)
    end
    def self.DrawCircleSectorLinesEx(center, radius, startAngle, endAngle, segments, thick, color)
      Raylib.rl_DrawCircleSectorLinesEx(center, radius, startAngle, endAngle, segments, thick, color)
    end
    def self.DrawCircleLines(centerX, centerY, radius, color)
      Raylib.rl_DrawCircleLines(centerX, centerY, radius, color)
    end
    def self.DrawCircleLinesV(center, radius, color)
      Raylib.rl_DrawCircleLinesV(center, radius, color)
    end
    def self.DrawCircleLinesEx(center, radius, thick, color)
      Raylib.rl_DrawCircleLinesEx(center, radius, thick, color)
    end
    def self.DrawEllipse(centerX, centerY, radiusH, radiusV, color)
      Raylib.rl_DrawEllipse(centerX, centerY, radiusH, radiusV, color)
    end
    def self.DrawEllipseV(center, radiusH, radiusV, color)
      Raylib.rl_DrawEllipseV(center, radiusH, radiusV, color)
    end
    def self.DrawEllipseLines(centerX, centerY, radiusH, radiusV, color)
      Raylib.rl_DrawEllipseLines(centerX, centerY, radiusH, radiusV, color)
    end
    def self.DrawEllipseLinesV(center, radiusH, radiusV, color)
      Raylib.rl_DrawEllipseLinesV(center, radiusH, radiusV, color)
    end
    def self.DrawEllipseLinesEx(center, radiusH, radiusV, thick, color)
      Raylib.rl_DrawEllipseLinesEx(center, radiusH, radiusV, thick, color)
    end
    def self.DrawRing(center, innerRadius, outerRadius, startAngle, endAngle, segments, color)
      Raylib.rl_DrawRing(center, innerRadius, outerRadius, startAngle, endAngle, segments, color)
    end
    def self.DrawRingLines(center, innerRadius, outerRadius, startAngle, endAngle, segments, color)
      Raylib.rl_DrawRingLines(center, innerRadius, outerRadius, startAngle, endAngle, segments, color)
    end
    def self.DrawRingLinesEx(center, innerRadius, outerRadius, startAngle, endAngle, segments, thick, color)
      Raylib.rl_DrawRingLinesEx(center, innerRadius, outerRadius, startAngle, endAngle, segments, thick, color)
    end
    def self.DrawSplineLinear(points, pointCount, thick, color)
      Raylib.rl_DrawSplineLinear(points, pointCount, thick, color)
    end
    def self.DrawSplineBasis(points, pointCount, thick, color)
      Raylib.rl_DrawSplineBasis(points, pointCount, thick, color)
    end
    def self.DrawSplineCatmullRom(points, pointCount, thick, color)
      Raylib.rl_DrawSplineCatmullRom(points, pointCount, thick, color)
    end
    def self.DrawSplineBezierQuadratic(points, pointCount, thick, color)
      Raylib.rl_DrawSplineBezierQuadratic(points, pointCount, thick, color)
    end
    def self.DrawSplineBezierCubic(points, pointCount, thick, color)
      Raylib.rl_DrawSplineBezierCubic(points, pointCount, thick, color)
    end
    def self.DrawSplineSegmentLinear(p1, p2, thick, color)
      Raylib.rl_DrawSplineSegmentLinear(p1, p2, thick, color)
    end
    def self.DrawSplineSegmentBasis(p1, p2, p3, p4, thick, color)
      Raylib.rl_DrawSplineSegmentBasis(p1, p2, p3, p4, thick, color)
    end
    def self.DrawSplineSegmentCatmullRom(p1, p2, p3, p4, thick, color)
      Raylib.rl_DrawSplineSegmentCatmullRom(p1, p2, p3, p4, thick, color)
    end
    def self.DrawSplineSegmentBezierQuadratic(p1, c2, p3, thick, color)
      Raylib.rl_DrawSplineSegmentBezierQuadratic(p1, c2, p3, thick, color)
    end
    def self.DrawSplineSegmentBezierCubic(p1, c2, c3, p4, thick, color)
      Raylib.rl_DrawSplineSegmentBezierCubic(p1, c2, c3, p4, thick, color)
    end
    def self.GetSplinePointLinear(startPos, endPos, t)
      _out = Vector2.new
      Raylib.rl_GetSplinePointLinear(startPos, endPos, t, _out)
      _out
    end
    def self.GetSplinePointBasis(p1, p2, p3, p4, t)
      _out = Vector2.new
      Raylib.rl_GetSplinePointBasis(p1, p2, p3, p4, t, _out)
      _out
    end
    def self.GetSplinePointCatmullRom(p1, p2, p3, p4, t)
      _out = Vector2.new
      Raylib.rl_GetSplinePointCatmullRom(p1, p2, p3, p4, t, _out)
      _out
    end
    def self.GetSplinePointBezierQuadratic(p1, c2, p3, t)
      _out = Vector2.new
      Raylib.rl_GetSplinePointBezierQuadratic(p1, c2, p3, t, _out)
      _out
    end
    def self.GetSplinePointBezierCubic(p1, c2, c3, p4, t)
      _out = Vector2.new
      Raylib.rl_GetSplinePointBezierCubic(p1, c2, c3, p4, t, _out)
      _out
    end
    def self.CheckCollisionRecs(rec1, rec2)
      Raylib.rl_CheckCollisionRecs(rec1, rec2)
    end
    def self.CheckCollisionCircles(center1, radius1, center2, radius2)
      Raylib.rl_CheckCollisionCircles(center1, radius1, center2, radius2)
    end
    def self.CheckCollisionCircleRec(center, radius, rec)
      Raylib.rl_CheckCollisionCircleRec(center, radius, rec)
    end
    def self.CheckCollisionCircleLine(center, radius, p1, p2)
      Raylib.rl_CheckCollisionCircleLine(center, radius, p1, p2)
    end
    def self.CheckCollisionPointRec(point, rec)
      Raylib.rl_CheckCollisionPointRec(point, rec)
    end
    def self.CheckCollisionPointCircle(point, center, radius)
      Raylib.rl_CheckCollisionPointCircle(point, center, radius)
    end
    def self.CheckCollisionPointTriangle(point, p1, p2, p3)
      Raylib.rl_CheckCollisionPointTriangle(point, p1, p2, p3)
    end
    def self.CheckCollisionPointLine(point, p1, p2, threshold)
      Raylib.rl_CheckCollisionPointLine(point, p1, p2, threshold)
    end
    def self.CheckCollisionPointPoly(point, points, pointCount)
      Raylib.rl_CheckCollisionPointPoly(point, points, pointCount)
    end
    def self.CheckCollisionLines(startPos1, endPos1, startPos2, endPos2, collisionPoint)
      Raylib.rl_CheckCollisionLines(startPos1, endPos1, startPos2, endPos2, collisionPoint)
    end
    def self.GetCollisionRec(rec1, rec2)
      _out = Rectangle.new
      Raylib.rl_GetCollisionRec(rec1, rec2, _out)
      _out
    end
    def self.LoadImage(fileName)
      Image.new(Raylib.rl_LoadImage(fileName), nil)
    end
    def self.LoadImageRaw(fileName, width, height, format, headerSize)
      Image.new(Raylib.rl_LoadImageRaw(fileName, width, height, format, headerSize), nil)
    end
    def self.LoadImageAnim(fileName, frames)
      Image.new(Raylib.rl_LoadImageAnim(fileName, frames), nil)
    end
    def self.LoadImageAnimFromMemory(fileType, fileData, dataSize, frames)
      Image.new(Raylib.rl_LoadImageAnimFromMemory(fileType, fileData, dataSize, frames), nil)
    end
    def self.LoadImageFromMemory(fileType, fileData, dataSize)
      Image.new(Raylib.rl_LoadImageFromMemory(fileType, fileData, dataSize), nil)
    end
    def self.LoadImageFromTexture(texture)
      Image.new(Raylib.rl_LoadImageFromTexture(texture), nil)
    end
    def self.LoadImageFromScreen()
      Image.new(Raylib.rl_LoadImageFromScreen(), nil)
    end
    def self.IsImageValid(image)
      Raylib.rl_IsImageValid(image)
    end
    def self.UnloadImage(image)
      Raylib.rl_UnloadImage(image)
    end
    def self.ExportImage(image, fileName)
      Raylib.rl_ExportImage(image, fileName)
    end
    def self.ExportImageToMemory(image, fileType, fileSize)
      Raylib.rl_ExportImageToMemory(image, fileType, fileSize)
    end
    def self.ExportImageAsCode(image, fileName)
      Raylib.rl_ExportImageAsCode(image, fileName)
    end
    def self.GenImageColor(width, height, color)
      Image.new(Raylib.rl_GenImageColor(width, height, color), nil)
    end
    def self.GenImageGradientLinear(width, height, direction, start, kw_end)
      Image.new(Raylib.rl_GenImageGradientLinear(width, height, direction, start, kw_end), nil)
    end
    def self.GenImageGradientRadial(width, height, density, inner, outer)
      Image.new(Raylib.rl_GenImageGradientRadial(width, height, density, inner, outer), nil)
    end
    def self.GenImageGradientSquare(width, height, density, inner, outer)
      Image.new(Raylib.rl_GenImageGradientSquare(width, height, density, inner, outer), nil)
    end
    def self.GenImageChecked(width, height, checksX, checksY, col1, col2)
      Image.new(Raylib.rl_GenImageChecked(width, height, checksX, checksY, col1, col2), nil)
    end
    def self.GenImageWhiteNoise(width, height, factor)
      Image.new(Raylib.rl_GenImageWhiteNoise(width, height, factor), nil)
    end
    def self.GenImagePerlinNoise(width, height, offsetX, offsetY, scale)
      Image.new(Raylib.rl_GenImagePerlinNoise(width, height, offsetX, offsetY, scale), nil)
    end
    def self.GenImageCellular(width, height, tileSize)
      Image.new(Raylib.rl_GenImageCellular(width, height, tileSize), nil)
    end
    def self.GenImageText(width, height, text)
      Image.new(Raylib.rl_GenImageText(width, height, text), nil)
    end
    def self.ImageCopy(image)
      Image.new(Raylib.rl_ImageCopy(image), nil)
    end
    def self.ImageFromImage(image, rec)
      Image.new(Raylib.rl_ImageFromImage(image, rec), nil)
    end
    def self.ImageFromChannel(image, selectedChannel)
      Image.new(Raylib.rl_ImageFromChannel(image, selectedChannel), nil)
    end
    def self.ImageText(text, fontSize, color)
      Image.new(Raylib.rl_ImageText(text, fontSize, color), nil)
    end
    def self.ImageTextEx(font, text, fontSize, spacing, tint)
      Image.new(Raylib.rl_ImageTextEx(font, text, fontSize, spacing, tint), nil)
    end
    def self.ImageToPOT(image, fill)
      Raylib.rl_ImageToPOT(image, fill)
    end
    def self.ImageCrop(image, crop)
      Raylib.rl_ImageCrop(image, crop)
    end
    def self.ImageAlphaClear(image, color, threshold)
      Raylib.rl_ImageAlphaClear(image, color, threshold)
    end
    def self.ImageAlphaMask(image, alphaMask)
      Raylib.rl_ImageAlphaMask(image, alphaMask)
    end
    def self.ImageResizeCanvas(image, newWidth, newHeight, offsetX, offsetY, fill)
      Raylib.rl_ImageResizeCanvas(image, newWidth, newHeight, offsetX, offsetY, fill)
    end
    def self.ImageColorTint(image, color)
      Raylib.rl_ImageColorTint(image, color)
    end
    def self.ImageColorReplace(image, color, replace)
      Raylib.rl_ImageColorReplace(image, color, replace)
    end
    def self.LoadImageColors(image)
      Raylib.rl_LoadImageColors(image)
    end
    def self.LoadImagePalette(image, maxPaletteSize, colorCount)
      Raylib.rl_LoadImagePalette(image, maxPaletteSize, colorCount)
    end
    def self.UnloadImageColors(colors)
      Raylib.rl_UnloadImageColors(colors)
    end
    def self.UnloadImagePalette(colors)
      Raylib.rl_UnloadImagePalette(colors)
    end
    def self.GetImageAlphaBorder(image, threshold)
      _out = Rectangle.new
      Raylib.rl_GetImageAlphaBorder(image, threshold, _out)
      _out
    end
    def self.GetImageColor(image, x, y)
      _out = Color.new(0, 0, 0, 0)
      Raylib.rl_GetImageColor(image, x, y, _out)
      _out
    end
    def self.ImageClearBackground(dst, color)
      Raylib.rl_ImageClearBackground(dst, color)
    end
    def self.ImageDrawPixel(dst, posX, posY, color)
      Raylib.rl_ImageDrawPixel(dst, posX, posY, color)
    end
    def self.ImageDrawPixelV(dst, position, color)
      Raylib.rl_ImageDrawPixelV(dst, position, color)
    end
    def self.ImageDrawLine(dst, startPosX, startPosY, endPosX, endPosY, color)
      Raylib.rl_ImageDrawLine(dst, startPosX, startPosY, endPosX, endPosY, color)
    end
    def self.ImageDrawLineV(dst, start, kw_end, color)
      Raylib.rl_ImageDrawLineV(dst, start, kw_end, color)
    end
    def self.ImageDrawLineEx(dst, start, kw_end, thick, color)
      Raylib.rl_ImageDrawLineEx(dst, start, kw_end, thick, color)
    end
    def self.ImageDrawLineStrip(dst, points, pointCount, color)
      Raylib.rl_ImageDrawLineStrip(dst, points, pointCount, color)
    end
    def self.ImageDrawTriangle(dst, v1, v2, v3, color)
      Raylib.rl_ImageDrawTriangle(dst, v1, v2, v3, color)
    end
    def self.ImageDrawTriangleGradient(dst, v1, v2, v3, c1, c2, c3)
      Raylib.rl_ImageDrawTriangleGradient(dst, v1, v2, v3, c1, c2, c3)
    end
    def self.ImageDrawTriangleLines(dst, v1, v2, v3, color)
      Raylib.rl_ImageDrawTriangleLines(dst, v1, v2, v3, color)
    end
    def self.ImageDrawTriangleFan(dst, points, pointCount, color)
      Raylib.rl_ImageDrawTriangleFan(dst, points, pointCount, color)
    end
    def self.ImageDrawTriangleStrip(dst, points, pointCount, color)
      Raylib.rl_ImageDrawTriangleStrip(dst, points, pointCount, color)
    end
    def self.ImageDrawRectangle(dst, posX, posY, width, height, color)
      Raylib.rl_ImageDrawRectangle(dst, posX, posY, width, height, color)
    end
    def self.ImageDrawRectangleV(dst, position, size, color)
      Raylib.rl_ImageDrawRectangleV(dst, position, size, color)
    end
    def self.ImageDrawRectangleRec(dst, rec, color)
      Raylib.rl_ImageDrawRectangleRec(dst, rec, color)
    end
    def self.ImageDrawRectanglePro(dst, rec, origin, rotation, color)
      Raylib.rl_ImageDrawRectanglePro(dst, rec, origin, rotation, color)
    end
    def self.ImageDrawRectangleLines(dst, posX, posY, width, height, color)
      Raylib.rl_ImageDrawRectangleLines(dst, posX, posY, width, height, color)
    end
    def self.ImageDrawRectangleLinesEx(dst, rec, thick, color)
      Raylib.rl_ImageDrawRectangleLinesEx(dst, rec, thick, color)
    end
    def self.ImageDrawRectangleGradientEx(dst, rec, col1, col2, col3, col4)
      Raylib.rl_ImageDrawRectangleGradientEx(dst, rec, col1, col2, col3, col4)
    end
    def self.ImageDrawCircle(dst, centerX, centerY, radius, color)
      Raylib.rl_ImageDrawCircle(dst, centerX, centerY, radius, color)
    end
    def self.ImageDrawCircleV(dst, center, radius, color)
      Raylib.rl_ImageDrawCircleV(dst, center, radius, color)
    end
    def self.ImageDrawCircleLines(dst, centerX, centerY, radius, color)
      Raylib.rl_ImageDrawCircleLines(dst, centerX, centerY, radius, color)
    end
    def self.ImageDrawCircleLinesV(dst, center, radius, color)
      Raylib.rl_ImageDrawCircleLinesV(dst, center, radius, color)
    end
    def self.ImageDrawCircleGradient(dst, center, radius, inner, outer)
      Raylib.rl_ImageDrawCircleGradient(dst, center, radius, inner, outer)
    end
    def self.ImageDrawImage(dst, src, posX, posY, tint)
      Raylib.rl_ImageDrawImage(dst, src, posX, posY, tint)
    end
    def self.ImageDrawImageEx(dst, src, position, rotation, scale, tint)
      Raylib.rl_ImageDrawImageEx(dst, src, position, rotation, scale, tint)
    end
    def self.ImageDrawImageRec(dst, src, srcRec, position, tint)
      Raylib.rl_ImageDrawImageRec(dst, src, srcRec, position, tint)
    end
    def self.ImageDrawImagePro(dst, src, srcRec, dstRec, origin, rotation, tint)
      Raylib.rl_ImageDrawImagePro(dst, src, srcRec, dstRec, origin, rotation, tint)
    end
    def self.ImageDrawText(dst, text, posX, posY, fontSize, color)
      Raylib.rl_ImageDrawText(dst, text, posX, posY, fontSize, color)
    end
    def self.ImageDrawTextEx(dst, font, text, position, fontSize, spacing, tint)
      Raylib.rl_ImageDrawTextEx(dst, font, text, position, fontSize, spacing, tint)
    end
    def self.ImageDrawTextPro(dst, font, text, position, origin, rotation, fontSize, spacing, tint)
      Raylib.rl_ImageDrawTextPro(dst, font, text, position, origin, rotation, fontSize, spacing, tint)
    end
    def self.LoadTextureFromImage(image)
      Texture2D.new(Raylib.rl_LoadTextureFromImage(image), nil)
    end
    def self.LoadTextureCubemap(image, layout)
      Raylib.rl_LoadTextureCubemap(image, layout)
    end
    def self.LoadRenderTexture(width, height)
      Raylib.rl_LoadRenderTexture(width, height)
    end
    def self.LoadRenderTextureEx(width, height, format)
      Raylib.rl_LoadRenderTextureEx(width, height, format)
    end
    def self.IsTextureValid(texture)
      Raylib.rl_IsTextureValid(texture)
    end
    def self.IsRenderTextureValid(target)
      Raylib.rl_IsRenderTextureValid(target)
    end
    def self.UnloadRenderTexture(target)
      Raylib.rl_UnloadRenderTexture(target)
    end
    def self.UpdateTexture(texture, pixels)
      Raylib.rl_UpdateTexture(texture, pixels)
    end
    def self.UpdateTextureRec(texture, rec, pixels)
      Raylib.rl_UpdateTextureRec(texture, rec, pixels)
    end
    def self.SetTextureFilter(texture, filter)
      Raylib.rl_SetTextureFilter(texture, filter)
    end
    def self.SetTextureWrap(texture, wrap)
      Raylib.rl_SetTextureWrap(texture, wrap)
    end
    def self.DrawTextureV(texture, position, tint)
      Raylib.rl_DrawTextureV(texture, position, tint)
    end
    def self.DrawTextureRec(texture, rec, position, tint)
      Raylib.rl_DrawTextureRec(texture, rec, position, tint)
    end
    def self.DrawTexturePro(texture, srcrec, dstrec, origin, rotation, tint)
      Raylib.rl_DrawTexturePro(texture, srcrec, dstrec, origin, rotation, tint)
    end
    def self.DrawTextureNPatch(texture, nPatchInfo, dstrec, origin, rotation, tint)
      Raylib.rl_DrawTextureNPatch(texture, nPatchInfo, dstrec, origin, rotation, tint)
    end
    def self.ColorIsEqual(col1, col2)
      Raylib.rl_ColorIsEqual(col1, col2)
    end
    def self.Fade(color, alpha)
      _out = Color.new(0, 0, 0, 0)
      Raylib.rl_Fade(color, alpha, _out)
      _out
    end
    def self.ColorToInt(color)
      Raylib.rl_ColorToInt(color)
    end
    def self.ColorNormalize(color)
      _out = Vector4.new
      Raylib.rl_ColorNormalize(color, _out)
      _out
    end
    def self.ColorFromNormalized(normalized)
      _out = Color.new(0, 0, 0, 0)
      Raylib.rl_ColorFromNormalized(normalized, _out)
      _out
    end
    def self.ColorToHSV(color)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.rl_ColorToHSV(color, _out)
      _out
    end
    def self.ColorFromHSV(hue, saturation, value)
      _out = Color.new(0, 0, 0, 0)
      Raylib.rl_ColorFromHSV(hue, saturation, value, _out)
      _out
    end
    def self.ColorTint(color, tint)
      _out = Color.new(0, 0, 0, 0)
      Raylib.rl_ColorTint(color, tint, _out)
      _out
    end
    def self.ColorBrightness(color, factor)
      _out = Color.new(0, 0, 0, 0)
      Raylib.rl_ColorBrightness(color, factor, _out)
      _out
    end
    def self.ColorContrast(color, contrast)
      _out = Color.new(0, 0, 0, 0)
      Raylib.rl_ColorContrast(color, contrast, _out)
      _out
    end
    def self.ColorAlpha(color, alpha)
      _out = Color.new(0, 0, 0, 0)
      Raylib.rl_ColorAlpha(color, alpha, _out)
      _out
    end
    def self.ColorAlphaBlend(dst, src, tint)
      _out = Color.new(0, 0, 0, 0)
      Raylib.rl_ColorAlphaBlend(dst, src, tint, _out)
      _out
    end
    def self.ColorLerp(color1, color2, factor)
      _out = Color.new(0, 0, 0, 0)
      Raylib.rl_ColorLerp(color1, color2, factor, _out)
      _out
    end
    def self.GetColor(hexValue)
      _out = Color.new(0, 0, 0, 0)
      Raylib.rl_GetColor(hexValue, _out)
      _out
    end
    def self.GetPixelColor(srcPtr, format)
      _out = Color.new(0, 0, 0, 0)
      Raylib.rl_GetPixelColor(srcPtr, format, _out)
      _out
    end
    def self.SetPixelColor(dstPtr, color, format)
      Raylib.rl_SetPixelColor(dstPtr, color, format)
    end
    def self.GetFontDefault()
      Font.new(Raylib.rl_GetFontDefault(), nil)
    end
    def self.LoadFont(fileName)
      Font.new(Raylib.rl_LoadFont(fileName), nil)
    end
    def self.LoadFontEx(fileName, fontSize, codepoints, codepointCount)
      Font.new(Raylib.rl_LoadFontEx(fileName, fontSize, codepoints, codepointCount), nil)
    end
    def self.LoadFontFromImage(image, key, firstChar)
      Font.new(Raylib.rl_LoadFontFromImage(image, key, firstChar), nil)
    end
    def self.LoadFontFromMemory(fileType, fileData, dataSize, fontSize, codepoints, codepointCount)
      Font.new(Raylib.rl_LoadFontFromMemory(fileType, fileData, dataSize, fontSize, codepoints, codepointCount), nil)
    end
    def self.IsFontValid(font)
      Raylib.rl_IsFontValid(font)
    end
    def self.GenImageFontAtlas(glyphs, glyphRecs, glyphCount, fontSize, padding, packMethod)
      Image.new(Raylib.rl_GenImageFontAtlas(glyphs, glyphRecs, glyphCount, fontSize, padding, packMethod), nil)
    end
    def self.UnloadFont(font)
      Raylib.rl_UnloadFont(font)
    end
    def self.ExportFontAsCode(font, fileName)
      Raylib.rl_ExportFontAsCode(font, fileName)
    end
    def self.DrawTextEx(font, text, position, fontSize, spacing, tint)
      Raylib.rl_DrawTextEx(font, text, position, fontSize, spacing, tint)
    end
    def self.DrawTextPro(font, text, position, origin, rotation, fontSize, spacing, tint)
      Raylib.rl_DrawTextPro(font, text, position, origin, rotation, fontSize, spacing, tint)
    end
    def self.DrawTextCodepoint(font, codepoint, position, fontSize, tint)
      Raylib.rl_DrawTextCodepoint(font, codepoint, position, fontSize, tint)
    end
    def self.DrawTextCodepoints(font, codepoints, codepointCount, position, fontSize, spacing, tint)
      Raylib.rl_DrawTextCodepoints(font, codepoints, codepointCount, position, fontSize, spacing, tint)
    end
    def self.MeasureTextEx(font, text, fontSize, spacing)
      _out = Vector2.new
      Raylib.rl_MeasureTextEx(font, text, fontSize, spacing, _out)
      _out
    end
    def self.MeasureTextCodepoints(font, codepoints, length, fontSize, spacing)
      _out = Vector2.new
      Raylib.rl_MeasureTextCodepoints(font, codepoints, length, fontSize, spacing, _out)
      _out
    end
    def self.GetGlyphIndex(font, codepoint)
      Raylib.rl_GetGlyphIndex(font, codepoint)
    end
    def self.GetGlyphInfo(font, codepoint)
      GlyphInfo.new(Raylib.rl_GetGlyphInfo(font, codepoint), nil)
    end
    def self.GetGlyphAtlasRec(font, codepoint)
      _out = Rectangle.new
      Raylib.rl_GetGlyphAtlasRec(font, codepoint, _out)
      _out
    end
    def self.DrawLine3D(startPos, endPos, color)
      Raylib.rl_DrawLine3D(startPos, endPos, color)
    end
    def self.DrawPoint3D(position, color)
      Raylib.rl_DrawPoint3D(position, color)
    end
    def self.DrawCircle3D(center, radius, rotationAxis, rotationAngle, color)
      Raylib.rl_DrawCircle3D(center, radius, rotationAxis, rotationAngle, color)
    end
    def self.DrawTriangle3D(v1, v2, v3, color)
      Raylib.rl_DrawTriangle3D(v1, v2, v3, color)
    end
    def self.DrawTriangleStrip3D(points, pointCount, color)
      Raylib.rl_DrawTriangleStrip3D(points, pointCount, color)
    end
    def self.DrawCubeV(position, size, color)
      Raylib.rl_DrawCubeV(position, size, color)
    end
    def self.DrawCubeWiresV(position, size, color)
      Raylib.rl_DrawCubeWiresV(position, size, color)
    end
    def self.DrawSphere(centerPos, radius, color)
      Raylib.rl_DrawSphere(centerPos, radius, color)
    end
    def self.DrawSphereEx(centerPos, radius, rings, slices, color)
      Raylib.rl_DrawSphereEx(centerPos, radius, rings, slices, color)
    end
    def self.DrawSphereWires(centerPos, radius, rings, slices, color)
      Raylib.rl_DrawSphereWires(centerPos, radius, rings, slices, color)
    end
    def self.DrawCylinder(position, radiusTop, radiusBottom, height, sides, color)
      Raylib.rl_DrawCylinder(position, radiusTop, radiusBottom, height, sides, color)
    end
    def self.DrawCylinderEx(startPos, endPos, startRadius, endRadius, sides, color)
      Raylib.rl_DrawCylinderEx(startPos, endPos, startRadius, endRadius, sides, color)
    end
    def self.DrawCylinderWires(position, radiusTop, radiusBottom, height, sides, color)
      Raylib.rl_DrawCylinderWires(position, radiusTop, radiusBottom, height, sides, color)
    end
    def self.DrawCylinderWiresEx(startPos, endPos, startRadius, endRadius, sides, color)
      Raylib.rl_DrawCylinderWiresEx(startPos, endPos, startRadius, endRadius, sides, color)
    end
    def self.DrawCapsule(startPos, endPos, radius, rings, slices, color)
      Raylib.rl_DrawCapsule(startPos, endPos, radius, rings, slices, color)
    end
    def self.DrawCapsuleWires(startPos, endPos, radius, rings, slices, color)
      Raylib.rl_DrawCapsuleWires(startPos, endPos, radius, rings, slices, color)
    end
    def self.DrawRay(ray, color)
      Raylib.rl_DrawRay(ray, color)
    end
    def self.LoadModel(fileName)
      Model.new(Raylib.rl_LoadModel(fileName), nil)
    end
    def self.LoadModelFromMesh(mesh)
      Model.new(Raylib.rl_LoadModelFromMesh(mesh), nil)
    end
    def self.IsModelValid(model)
      Raylib.rl_IsModelValid(model)
    end
    def self.UnloadModel(model)
      Raylib.rl_UnloadModel(model)
    end
    def self.GetModelBoundingBox(model)
      _out = BoundingBox.new
      Raylib.rl_GetModelBoundingBox(model, _out)
      _out
    end
    def self.DrawModel(model, position, scale, tint)
      Raylib.rl_DrawModel(model, position, scale, tint)
    end
    def self.DrawModelEx(model, position, rotationAxis, rotationAngle, scale, tint)
      Raylib.rl_DrawModelEx(model, position, rotationAxis, rotationAngle, scale, tint)
    end
    def self.DrawModelWires(model, position, scale, tint)
      Raylib.rl_DrawModelWires(model, position, scale, tint)
    end
    def self.DrawModelWiresEx(model, position, rotationAxis, rotationAngle, scale, tint)
      Raylib.rl_DrawModelWiresEx(model, position, rotationAxis, rotationAngle, scale, tint)
    end
    def self.DrawBoundingBox(box, color)
      Raylib.rl_DrawBoundingBox(box, color)
    end
    def self.DrawBillboard(camera, texture, position, scale, tint)
      Raylib.rl_DrawBillboard(camera, texture, position, scale, tint)
    end
    def self.DrawBillboardRec(camera, texture, rec, position, size, tint)
      Raylib.rl_DrawBillboardRec(camera, texture, rec, position, size, tint)
    end
    def self.DrawBillboardPro(camera, texture, rec, position, up, size, origin, rotation, tint)
      Raylib.rl_DrawBillboardPro(camera, texture, rec, position, up, size, origin, rotation, tint)
    end
    def self.UpdateMeshBuffer(mesh, index, data, dataSize, offset)
      Raylib.rl_UpdateMeshBuffer(mesh, index, data, dataSize, offset)
    end
    def self.UnloadMesh(mesh)
      Raylib.rl_UnloadMesh(mesh)
    end
    def self.DrawMesh(mesh, material, transform)
      Raylib.rl_DrawMesh(mesh, material, transform)
    end
    def self.DrawMeshInstanced(mesh, material, transforms, instances)
      Raylib.rl_DrawMeshInstanced(mesh, material, transforms, instances)
    end
    def self.GetMeshBoundingBox(mesh)
      _out = BoundingBox.new
      Raylib.rl_GetMeshBoundingBox(mesh, _out)
      _out
    end
    def self.ExportMesh(mesh, fileName)
      Raylib.rl_ExportMesh(mesh, fileName)
    end
    def self.ExportMeshAsCode(mesh, fileName)
      Raylib.rl_ExportMeshAsCode(mesh, fileName)
    end
    def self.GenMeshPoly(sides, radius)
      Mesh.new(Raylib.rl_GenMeshPoly(sides, radius), nil)
    end
    def self.GenMeshPlane(width, length, resX, resZ)
      Mesh.new(Raylib.rl_GenMeshPlane(width, length, resX, resZ), nil)
    end
    def self.GenMeshCube(width, height, length)
      Mesh.new(Raylib.rl_GenMeshCube(width, height, length), nil)
    end
    def self.GenMeshSphere(radius, rings, slices)
      Mesh.new(Raylib.rl_GenMeshSphere(radius, rings, slices), nil)
    end
    def self.GenMeshHemiSphere(radius, rings, slices)
      Mesh.new(Raylib.rl_GenMeshHemiSphere(radius, rings, slices), nil)
    end
    def self.GenMeshCylinder(radius, height, slices)
      Mesh.new(Raylib.rl_GenMeshCylinder(radius, height, slices), nil)
    end
    def self.GenMeshCone(radius, height, slices)
      Mesh.new(Raylib.rl_GenMeshCone(radius, height, slices), nil)
    end
    def self.GenMeshTorus(radius, size, radSeg, sides)
      Mesh.new(Raylib.rl_GenMeshTorus(radius, size, radSeg, sides), nil)
    end
    def self.GenMeshKnot(radius, size, radSeg, sides)
      Mesh.new(Raylib.rl_GenMeshKnot(radius, size, radSeg, sides), nil)
    end
    def self.GenMeshHeightmap(heightmap, size)
      Mesh.new(Raylib.rl_GenMeshHeightmap(heightmap, size), nil)
    end
    def self.GenMeshCubicmap(cubicmap, cubeSize)
      Mesh.new(Raylib.rl_GenMeshCubicmap(cubicmap, cubeSize), nil)
    end
    def self.LoadMaterialDefault()
      Material.new(Raylib.rl_LoadMaterialDefault(), nil)
    end
    def self.IsMaterialValid(material)
      Raylib.rl_IsMaterialValid(material)
    end
    def self.UnloadMaterial(material)
      Raylib.rl_UnloadMaterial(material)
    end
    def self.SetMaterialTexture(material, mapType, texture)
      Raylib.rl_SetMaterialTexture(material, mapType, texture)
    end
    def self.UpdateModelAnimation(model, anim, frame)
      Raylib.rl_UpdateModelAnimation(model, anim, frame)
    end
    def self.UpdateModelAnimationEx(model, animA, frameA, animB, frameB, blend)
      Raylib.rl_UpdateModelAnimationEx(model, animA, (frameA || 0.0).to_f,
                                       animB, (frameB || 0.0).to_f,
                                       (blend || 0.0).to_f)
    end
    def self.IsModelAnimationValid(model, anim)
      Raylib.rl_IsModelAnimationValid(model, anim)
    end
    def self.CheckCollisionSpheres(center1, radius1, center2, radius2)
      Raylib.rl_CheckCollisionSpheres(center1, radius1, center2, radius2)
    end
    def self.CheckCollisionBoxes(box1, box2)
      Raylib.rl_CheckCollisionBoxes(box1, box2)
    end
    def self.CheckCollisionBoxSphere(box, center, radius)
      Raylib.rl_CheckCollisionBoxSphere(box, center, radius)
    end
    def self.GetRayCollisionSphere(ray, center, radius)
      _out = RayCollision.new
      Raylib.rl_GetRayCollisionSphere(ray, center, radius, _out)
      _out
    end
    def self.GetRayCollisionBox(ray, box)
      _out = RayCollision.new
      Raylib.rl_GetRayCollisionBox(ray, box, _out)
      _out
    end
    def self.GetRayCollisionMesh(ray, mesh, transform)
      _out = RayCollision.new
      Raylib.rl_GetRayCollisionMesh(ray, mesh, transform, _out)
      _out
    end
    def self.GetRayCollisionTriangle(ray, p1, p2, p3)
      _out = RayCollision.new
      Raylib.rl_GetRayCollisionTriangle(ray, p1, p2, p3, _out)
      _out
    end
    def self.GetRayCollisionQuad(ray, p1, p2, p3, p4)
      _out = RayCollision.new
      Raylib.rl_GetRayCollisionQuad(ray, p1, p2, p3, p4, _out)
      _out
    end
    def self.LoadWave(fileName)
      Raylib.rl_LoadWave(fileName)
    end
    def self.LoadWaveFromMemory(fileType, fileData, dataSize)
      Raylib.rl_LoadWaveFromMemory(fileType, fileData, dataSize)
    end
    def self.IsWaveValid(wave)
      Raylib.rl_IsWaveValid(wave)
    end
    def self.LoadSound(fileName)
      Raylib.rl_LoadSound(fileName)
    end
    def self.LoadSoundFromWave(wave)
      Raylib.rl_LoadSoundFromWave(wave)
    end
    def self.LoadSoundAlias(source)
      Raylib.rl_LoadSoundAlias(source)
    end
    def self.IsSoundValid(sound)
      Raylib.rl_IsSoundValid(sound)
    end
    def self.UpdateSound(sound, data, frameCount)
      Raylib.rl_UpdateSound(sound, data, frameCount)
    end
    def self.UnloadWave(wave)
      Raylib.rl_UnloadWave(wave)
    end
    def self.UnloadSound(sound)
      Raylib.rl_UnloadSound(sound)
    end
    def self.UnloadSoundAlias(kw_alias)
      Raylib.rl_UnloadSoundAlias(kw_alias)
    end
    def self.ExportWave(wave, fileName)
      Raylib.rl_ExportWave(wave, fileName)
    end
    def self.ExportWaveAsCode(wave, fileName)
      Raylib.rl_ExportWaveAsCode(wave, fileName)
    end
    def self.PlaySound(sound)
      Raylib.rl_PlaySound(sound)
    end
    def self.StopSound(sound)
      Raylib.rl_StopSound(sound)
    end
    def self.PauseSound(sound)
      Raylib.rl_PauseSound(sound)
    end
    def self.ResumeSound(sound)
      Raylib.rl_ResumeSound(sound)
    end
    def self.IsSoundPlaying(sound)
      Raylib.rl_IsSoundPlaying(sound)
    end
    def self.SetSoundVolume(sound, volume)
      Raylib.rl_SetSoundVolume(sound, volume)
    end
    def self.SetSoundPitch(sound, pitch)
      Raylib.rl_SetSoundPitch(sound, pitch)
    end
    def self.SetSoundPan(sound, pan)
      Raylib.rl_SetSoundPan(sound, pan)
    end
    def self.WaveCopy(wave)
      Raylib.rl_WaveCopy(wave)
    end
    def self.LoadWaveSamples(wave)
      Raylib.rl_LoadWaveSamples(wave)
    end
    def self.LoadMusicStream(fileName)
      Raylib.rl_LoadMusicStream(fileName)
    end
    def self.LoadMusicStreamFromMemory(fileType, data, dataSize)
      Raylib.rl_LoadMusicStreamFromMemory(fileType, data, dataSize)
    end
    def self.IsMusicValid(music)
      Raylib.rl_IsMusicValid(music)
    end
    def self.UnloadMusicStream(music)
      Raylib.rl_UnloadMusicStream(music)
    end
    def self.PlayMusicStream(music)
      Raylib.rl_PlayMusicStream(music)
    end
    def self.IsMusicStreamPlaying(music)
      Raylib.rl_IsMusicStreamPlaying(music)
    end
    def self.UpdateMusicStream(music)
      Raylib.rl_UpdateMusicStream(music)
    end
    def self.StopMusicStream(music)
      Raylib.rl_StopMusicStream(music)
    end
    def self.PauseMusicStream(music)
      Raylib.rl_PauseMusicStream(music)
    end
    def self.ResumeMusicStream(music)
      Raylib.rl_ResumeMusicStream(music)
    end
    def self.SeekMusicStream(music, position)
      Raylib.rl_SeekMusicStream(music, position)
    end
    def self.SetMusicVolume(music, volume)
      Raylib.rl_SetMusicVolume(music, volume)
    end
    def self.SetMusicPitch(music, pitch)
      Raylib.rl_SetMusicPitch(music, pitch)
    end
    def self.SetMusicPan(music, pan)
      Raylib.rl_SetMusicPan(music, pan)
    end
    def self.GetMusicTimeLength(music)
      Raylib.rl_GetMusicTimeLength(music)
    end
    def self.GetMusicTimePlayed(music)
      Raylib.rl_GetMusicTimePlayed(music)
    end
    def self.LoadAudioStream(sampleRate, sampleSize, channels)
      Raylib.rl_LoadAudioStream(sampleRate, sampleSize, channels)
    end
    def self.IsAudioStreamValid(stream)
      Raylib.rl_IsAudioStreamValid(stream)
    end
    def self.UnloadAudioStream(stream)
      Raylib.rl_UnloadAudioStream(stream)
    end
    def self.UpdateAudioStream(stream, data, frameCount)
      Raylib.rl_UpdateAudioStream(stream, data, frameCount)
    end
    def self.IsAudioStreamProcessed(stream)
      Raylib.rl_IsAudioStreamProcessed(stream)
    end
    def self.PlayAudioStream(stream)
      Raylib.rl_PlayAudioStream(stream)
    end
    def self.PauseAudioStream(stream)
      Raylib.rl_PauseAudioStream(stream)
    end
    def self.ResumeAudioStream(stream)
      Raylib.rl_ResumeAudioStream(stream)
    end
    def self.IsAudioStreamPlaying(stream)
      Raylib.rl_IsAudioStreamPlaying(stream)
    end
    def self.StopAudioStream(stream)
      Raylib.rl_StopAudioStream(stream)
    end
    def self.SetAudioStreamVolume(stream, volume)
      Raylib.rl_SetAudioStreamVolume(stream, volume)
    end
    def self.SetAudioStreamPitch(stream, pitch)
      Raylib.rl_SetAudioStreamPitch(stream, pitch)
    end
    def self.SetAudioStreamPan(stream, pan)
      Raylib.rl_SetAudioStreamPan(stream, pan)
    end
    def self.SetAudioStreamCallback(stream, callback)
      Raylib.rl_SetAudioStreamCallback(stream, callback)
    end
    def self.AttachAudioStreamProcessor(stream, processor)
      Raylib.rl_AttachAudioStreamProcessor(stream, processor)
    end
    def self.DetachAudioStreamProcessor(stream, processor)
      Raylib.rl_DetachAudioStreamProcessor(stream, processor)
    end
    def self.AttachAudioMixedProcessor(processor)
      Raylib.rl_AttachAudioMixedProcessor(processor)
    end
    def self.DetachAudioMixedProcessor(processor)
      Raylib.rl_DetachAudioMixedProcessor(processor)
    end
    FLAG_VSYNC_HINT = 64
    FLAG_FULLSCREEN_MODE = 2
    FLAG_WINDOW_RESIZABLE = 4
    FLAG_WINDOW_UNDECORATED = 8
    FLAG_WINDOW_HIDDEN = 128
    FLAG_WINDOW_MINIMIZED = 512
    FLAG_WINDOW_MAXIMIZED = 1024
    FLAG_WINDOW_UNFOCUSED = 2048
    FLAG_WINDOW_TOPMOST = 4096
    FLAG_WINDOW_ALWAYS_RUN = 256
    FLAG_WINDOW_TRANSPARENT = 16
    FLAG_WINDOW_HIGHDPI = 8192
    FLAG_WINDOW_MOUSE_PASSTHROUGH = 16384
    FLAG_BORDERLESS_WINDOWED_MODE = 32768
    FLAG_MSAA_4X_HINT = 32
    FLAG_INTERLACED_HINT = 65536
    LOG_ALL = 0
    LOG_TRACE = 1
    LOG_DEBUG = 2
    LOG_INFO = 3
    LOG_WARNING = 4
    LOG_ERROR = 5
    LOG_FATAL = 6
    LOG_NONE = 7
    GAMEPAD_AXIS_LEFT_X = 0
    GAMEPAD_AXIS_LEFT_Y = 1
    GAMEPAD_AXIS_RIGHT_X = 2
    GAMEPAD_AXIS_RIGHT_Y = 3
    GAMEPAD_AXIS_LEFT_TRIGGER = 4
    GAMEPAD_AXIS_RIGHT_TRIGGER = 5
    MATERIAL_MAP_ALBEDO = 0
    MATERIAL_MAP_METALNESS = 1
    MATERIAL_MAP_NORMAL = 2
    MATERIAL_MAP_ROUGHNESS = 3
    MATERIAL_MAP_OCCLUSION = 4
    MATERIAL_MAP_EMISSION = 5
    MATERIAL_MAP_HEIGHT = 6
    MATERIAL_MAP_CUBEMAP = 7
    MATERIAL_MAP_IRRADIANCE = 8
    MATERIAL_MAP_PREFILTER = 9
    MATERIAL_MAP_BRDF = 10
    SHADER_LOC_VERTEX_POSITION = 0
    SHADER_LOC_VERTEX_TEXCOORD01 = 1
    SHADER_LOC_VERTEX_TEXCOORD02 = 2
    SHADER_LOC_VERTEX_NORMAL = 3
    SHADER_LOC_VERTEX_TANGENT = 4
    SHADER_LOC_VERTEX_COLOR = 5
    SHADER_LOC_MATRIX_MVP = 6
    SHADER_LOC_MATRIX_VIEW = 7
    SHADER_LOC_MATRIX_PROJECTION = 8
    SHADER_LOC_MATRIX_MODEL = 9
    SHADER_LOC_MATRIX_NORMAL = 10
    SHADER_LOC_VECTOR_VIEW = 11
    SHADER_LOC_COLOR_DIFFUSE = 12
    SHADER_LOC_COLOR_SPECULAR = 13
    SHADER_LOC_COLOR_AMBIENT = 14
    SHADER_LOC_MAP_ALBEDO = 15
    SHADER_LOC_MAP_METALNESS = 16
    SHADER_LOC_MAP_NORMAL = 17
    SHADER_LOC_MAP_ROUGHNESS = 18
    SHADER_LOC_MAP_OCCLUSION = 19
    SHADER_LOC_MAP_EMISSION = 20
    SHADER_LOC_MAP_HEIGHT = 21
    SHADER_LOC_MAP_CUBEMAP = 22
    SHADER_LOC_MAP_IRRADIANCE = 23
    SHADER_LOC_MAP_PREFILTER = 24
    SHADER_LOC_MAP_BRDF = 25
    SHADER_LOC_VERTEX_BONEIDS = 26
    SHADER_LOC_VERTEX_BONEWEIGHTS = 27
    SHADER_LOC_MATRIX_BONETRANSFORMS = 28
    SHADER_LOC_VERTEX_INSTANCETRANSFORM = 29
    SHADER_UNIFORM_FLOAT = 0
    SHADER_UNIFORM_VEC2 = 1
    SHADER_UNIFORM_VEC3 = 2
    SHADER_UNIFORM_VEC4 = 3
    SHADER_UNIFORM_INT = 4
    SHADER_UNIFORM_IVEC2 = 5
    SHADER_UNIFORM_IVEC3 = 6
    SHADER_UNIFORM_IVEC4 = 7
    SHADER_UNIFORM_UINT = 8
    SHADER_UNIFORM_UIVEC2 = 9
    SHADER_UNIFORM_UIVEC3 = 10
    SHADER_UNIFORM_UIVEC4 = 11
    SHADER_UNIFORM_SAMPLER2D = 12
    SHADER_ATTRIB_FLOAT = 0
    SHADER_ATTRIB_VEC2 = 1
    SHADER_ATTRIB_VEC3 = 2
    SHADER_ATTRIB_VEC4 = 3
    PIXELFORMAT_UNCOMPRESSED_GRAYSCALE = 1
    PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA = 2
    PIXELFORMAT_UNCOMPRESSED_R5G6B5 = 3
    PIXELFORMAT_UNCOMPRESSED_R8G8B8 = 4
    PIXELFORMAT_UNCOMPRESSED_R5G5B5A1 = 5
    PIXELFORMAT_UNCOMPRESSED_R4G4B4A4 = 6
    PIXELFORMAT_UNCOMPRESSED_R8G8B8A8 = 7
    PIXELFORMAT_UNCOMPRESSED_R32 = 8
    PIXELFORMAT_UNCOMPRESSED_R32G32B32 = 9
    PIXELFORMAT_UNCOMPRESSED_R32G32B32A32 = 10
    PIXELFORMAT_UNCOMPRESSED_R16 = 11
    PIXELFORMAT_UNCOMPRESSED_R16G16B16 = 12
    PIXELFORMAT_UNCOMPRESSED_R16G16B16A16 = 13
    PIXELFORMAT_COMPRESSED_DXT1_RGB = 14
    PIXELFORMAT_COMPRESSED_DXT1_RGBA = 15
    PIXELFORMAT_COMPRESSED_DXT3_RGBA = 16
    PIXELFORMAT_COMPRESSED_DXT5_RGBA = 17
    PIXELFORMAT_COMPRESSED_ETC1_RGB = 18
    PIXELFORMAT_COMPRESSED_ETC2_RGB = 19
    PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA = 20
    PIXELFORMAT_COMPRESSED_PVRT_RGB = 21
    PIXELFORMAT_COMPRESSED_PVRT_RGBA = 22
    PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA = 23
    PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA = 24
    TEXTURE_FILTER_POINT = 0
    TEXTURE_FILTER_BILINEAR = 1
    TEXTURE_FILTER_TRILINEAR = 2
    TEXTURE_FILTER_ANISOTROPIC_4X = 3
    TEXTURE_FILTER_ANISOTROPIC_8X = 4
    TEXTURE_FILTER_ANISOTROPIC_16X = 5
    TEXTURE_WRAP_REPEAT = 0
    TEXTURE_WRAP_CLAMP = 1
    TEXTURE_WRAP_MIRROR_REPEAT = 2
    TEXTURE_WRAP_MIRROR_CLAMP = 3
    CUBEMAP_LAYOUT_AUTO_DETECT = 0
    CUBEMAP_LAYOUT_LINE_VERTICAL = 1
    CUBEMAP_LAYOUT_LINE_HORIZONTAL = 2
    CUBEMAP_LAYOUT_CROSS_THREE_BY_FOUR = 3
    CUBEMAP_LAYOUT_CROSS_FOUR_BY_THREE = 4
    FONT_DEFAULT = 0
    FONT_BITMAP = 1
    FONT_SDF = 2
    BLEND_ALPHA = 0
    BLEND_ADDITIVE = 1
    BLEND_MULTIPLIED = 2
    BLEND_ADD_COLORS = 3
    BLEND_SUBTRACT_COLORS = 4
    BLEND_ALPHA_PREMULTIPLY = 5
    BLEND_CUSTOM = 6
    BLEND_CUSTOM_SEPARATE = 7
    GESTURE_NONE = 0
    GESTURE_TAP = 1
    GESTURE_DOUBLETAP = 2
    GESTURE_HOLD = 4
    GESTURE_DRAG = 8
    GESTURE_SWIPE_RIGHT = 16
    GESTURE_SWIPE_LEFT = 32
    GESTURE_SWIPE_UP = 64
    GESTURE_SWIPE_DOWN = 128
    GESTURE_PINCH_IN = 256
    GESTURE_PINCH_OUT = 512
    NPATCH_NINE_PATCH = 0
    NPATCH_THREE_PATCH_VERTICAL = 1
    NPATCH_THREE_PATCH_HORIZONTAL = 2
    RAYLIB_VERSION_MAJOR = 6
    RAYLIB_VERSION_MINOR = 1
    RAYLIB_VERSION_PATCH = 0
    PI = 3.141592653589793
  end

  # ====== generated: snake_case aliases (MRI gem naming) ======
  def self.init_window(p0, p1, p2)
    Raylib.InitWindow(p0, p1, p2)
  end
  def self.close_window()
    Raylib.CloseWindow()
  end
  def self.is_window_ready()
    Raylib.IsWindowReady()
  end
  def self.is_window_fullscreen()
    Raylib.IsWindowFullscreen()
  end
  def self.is_window_hidden()
    Raylib.IsWindowHidden()
  end
  def self.is_window_minimized()
    Raylib.IsWindowMinimized()
  end
  def self.is_window_maximized()
    Raylib.IsWindowMaximized()
  end
  def self.is_window_focused()
    Raylib.IsWindowFocused()
  end
  def self.is_window_resized()
    Raylib.IsWindowResized()
  end
  def self.is_window_state(p0)
    Raylib.IsWindowState(p0)
  end
  def self.set_window_state(p0)
    Raylib.SetWindowState(p0)
  end
  def self.clear_window_state(p0)
    Raylib.ClearWindowState(p0)
  end
  def self.toggle_fullscreen()
    Raylib.ToggleFullscreen()
  end
  def self.toggle_borderless_windowed()
    Raylib.ToggleBorderlessWindowed()
  end
  def self.maximize_window()
    Raylib.MaximizeWindow()
  end
  def self.minimize_window()
    Raylib.MinimizeWindow()
  end
  def self.restore_window()
    Raylib.RestoreWindow()
  end
  def self.set_window_icons(p0, p1)
    Raylib.SetWindowIcons(p0, p1)
  end
  def self.set_window_title(p0)
    Raylib.SetWindowTitle(p0)
  end
  def self.set_window_position(p0, p1)
    Raylib.SetWindowPosition(p0, p1)
  end
  def self.set_window_monitor(p0)
    Raylib.SetWindowMonitor(p0)
  end
  def self.set_window_min_size(p0, p1)
    Raylib.SetWindowMinSize(p0, p1)
  end
  def self.set_window_max_size(p0, p1)
    Raylib.SetWindowMaxSize(p0, p1)
  end
  def self.set_window_size(p0, p1)
    Raylib.SetWindowSize(p0, p1)
  end
  def self.set_window_opacity(p0)
    Raylib.SetWindowOpacity(p0)
  end
  def self.set_window_focused()
    Raylib.SetWindowFocused()
  end
  def self.get_window_handle()
    Raylib.GetWindowHandle()
  end
  def self.get_screen_width()
    Raylib.GetScreenWidth()
  end
  def self.get_screen_height()
    Raylib.GetScreenHeight()
  end
  def self.get_render_width()
    Raylib.GetRenderWidth()
  end
  def self.get_render_height()
    Raylib.GetRenderHeight()
  end
  def self.get_monitor_count()
    Raylib.GetMonitorCount()
  end
  def self.get_current_monitor()
    Raylib.GetCurrentMonitor()
  end
  def self.get_monitor_width(p0)
    Raylib.GetMonitorWidth(p0)
  end
  def self.get_monitor_height(p0)
    Raylib.GetMonitorHeight(p0)
  end
  def self.get_monitor_physical_width(p0)
    Raylib.GetMonitorPhysicalWidth(p0)
  end
  def self.get_monitor_physical_height(p0)
    Raylib.GetMonitorPhysicalHeight(p0)
  end
  def self.get_monitor_refresh_rate(p0)
    Raylib.GetMonitorRefreshRate(p0)
  end
  def self.get_monitor_name(p0)
    Raylib.GetMonitorName(p0)
  end
  def self.set_clipboard_text(p0)
    Raylib.SetClipboardText(p0)
  end
  def self.get_clipboard_text()
    Raylib.GetClipboardText()
  end
  def self.enable_event_waiting()
    Raylib.EnableEventWaiting()
  end
  def self.disable_event_waiting()
    Raylib.DisableEventWaiting()
  end
  def self.show_cursor()
    Raylib.ShowCursor()
  end
  def self.hide_cursor()
    Raylib.HideCursor()
  end
  def self.is_cursor_hidden()
    Raylib.IsCursorHidden()
  end
  def self.enable_cursor()
    Raylib.EnableCursor()
  end
  def self.disable_cursor()
    Raylib.DisableCursor()
  end
  def self.is_cursor_on_screen()
    Raylib.IsCursorOnScreen()
  end
  def self.begin_drawing()
    Raylib.BeginDrawing()
  end
  def self.end_drawing()
    Raylib.EndDrawing()
  end
  def self.end_mode_2d()
    Raylib.EndMode2D()
  end
  def self.end_mode_3d()
    Raylib.rl_EndMode3D()
  end
  def self.end_texture_mode()
    Raylib.EndTextureMode()
  end
  def self.end_shader_mode()
    Raylib.EndShaderMode()
  end
  def self.begin_blend_mode(p0)
    Raylib.BeginBlendMode(p0)
  end
  def self.end_blend_mode()
    Raylib.EndBlendMode()
  end
  def self.begin_scissor_mode(p0, p1, p2, p3)
    Raylib.BeginScissorMode(p0, p1, p2, p3)
  end
  def self.end_scissor_mode()
    Raylib.EndScissorMode()
  end
  def self.end_vr_stereo_mode()
    Raylib.EndVrStereoMode()
  end
  def self.set_target_fps(p0)
    Raylib.SetTargetFPS(p0)
  end
  def self.get_frame_time()
    Raylib.GetFrameTime()
  end
  def self.get_time()
    Raylib.GetTime()
  end
  def self.get_fps()
    Raylib.GetFPS()
  end
  def self.swap_screen_buffer()
    Raylib.SwapScreenBuffer()
  end
  def self.poll_input_events()
    Raylib.PollInputEvents()
  end
  def self.wait_time(p0)
    Raylib.WaitTime(p0)
  end
  def self.set_random_seed(p0)
    Raylib.SetRandomSeed(p0)
  end
  def self.get_random_value(p0, p1)
    Raylib.GetRandomValue(p0, p1)
  end
  def self.load_random_sequence(p0, p1, p2)
    Raylib.LoadRandomSequence(p0, p1, p2)
  end
  def self.unload_random_sequence(p0)
    Raylib.UnloadRandomSequence(p0)
  end
  def self.take_screenshot(p0)
    Raylib.TakeScreenshot(p0)
  end
  def self.set_config_flags(p0)
    Raylib.SetConfigFlags(p0)
  end
  def self.open_url(p0)
    Raylib.OpenURL(p0)
  end
  def self.set_trace_log_level(p0)
    Raylib.SetTraceLogLevel(p0)
  end
  def self.mem_alloc(p0)
    Raylib.MemAlloc(p0)
  end
  def self.mem_realloc(p0, p1)
    Raylib.MemRealloc(p0, p1)
  end
  def self.mem_free(p0)
    Raylib.MemFree(p0)
  end
  def self.load_file_data(p0, p1)
    Raylib.LoadFileData(p0, p1)
  end
  def self.unload_file_data(p0)
    Raylib.UnloadFileData(p0)
  end
  def self.save_file_data(p0, p1, p2)
    Raylib.SaveFileData(p0, p1, p2)
  end
  def self.export_data_as_code(p0, p1, p2)
    Raylib.ExportDataAsCode(p0, p1, p2)
  end
  def self.load_file_text(p0)
    Raylib.LoadFileText(p0)
  end
  def self.unload_file_text(p0)
    Raylib.UnloadFileText(p0)
  end
  def self.save_file_text(p0, p1)
    Raylib.SaveFileText(p0, p1)
  end
  def self.file_rename(p0, p1)
    Raylib.FileRename(p0, p1)
  end
  def self.file_remove(p0)
    Raylib.FileRemove(p0)
  end
  def self.file_copy(p0, p1)
    Raylib.FileCopy(p0, p1)
  end
  def self.file_move(p0, p1)
    Raylib.FileMove(p0, p1)
  end
  def self.file_text_replace(p0, p1, p2)
    Raylib.FileTextReplace(p0, p1, p2)
  end
  def self.file_text_find_index(p0, p1)
    Raylib.FileTextFindIndex(p0, p1)
  end
  def self.file_exists(p0)
    Raylib.FileExists(p0)
  end
  def self.directory_exists(p0)
    Raylib.DirectoryExists(p0)
  end
  def self.is_file_extension(p0, p1)
    Raylib.IsFileExtension(p0, p1)
  end
  def self.is_file_hidden(p0)
    Raylib.IsFileHidden(p0)
  end
  def self.get_file_length(p0)
    Raylib.GetFileLength(p0)
  end
  def self.get_file_mod_time(p0)
    Raylib.GetFileModTime(p0)
  end
  def self.get_file_extension(p0)
    Raylib.GetFileExtension(p0)
  end
  def self.get_file_name(p0)
    Raylib.GetFileName(p0)
  end
  def self.get_file_name_without_ext(p0)
    Raylib.GetFileNameWithoutExt(p0)
  end
  def self.get_directory_path(p0)
    Raylib.GetDirectoryPath(p0)
  end
  def self.get_prev_directory_path(p0)
    Raylib.GetPrevDirectoryPath(p0)
  end
  def self.get_working_directory()
    Raylib.GetWorkingDirectory()
  end
  def self.get_application_directory()
    Raylib.GetApplicationDirectory()
  end
  def self.make_directory(p0)
    Raylib.MakeDirectory(p0)
  end
  def self.change_directory(p0)
    Raylib.ChangeDirectory(p0)
  end
  def self.is_path_file(p0)
    Raylib.IsPathFile(p0)
  end
  def self.is_path_directory(p0)
    Raylib.IsPathDirectory(p0)
  end
  def self.is_path_absolute(p0)
    Raylib.IsPathAbsolute(p0)
  end
  def self.is_file_name_valid(p0)
    Raylib.IsFileNameValid(p0)
  end
  def self.is_file_dropped()
    Raylib.IsFileDropped()
  end
  def self.get_directory_file_count(p0)
    Raylib.GetDirectoryFileCount(p0)
  end
  def self.get_directory_file_count_ex(p0, p1, p2)
    Raylib.GetDirectoryFileCountEx(p0, p1, p2)
  end
  def self.compress_data(p0, p1, p2)
    Raylib.CompressData(p0, p1, p2)
  end
  def self.decompress_data(p0, p1, p2)
    Raylib.DecompressData(p0, p1, p2)
  end
  def self.encode_data_base_64(p0, p1, p2)
    Raylib.EncodeDataBase64(p0, p1, p2)
  end
  def self.decode_data_base_64(p0, p1)
    Raylib.DecodeDataBase64(p0, p1)
  end
  def self.compute_crc3_2(p0, p1)
    Raylib.ComputeCRC32(p0, p1)
  end
  def self.compute_md5(p0, p1)
    Raylib.ComputeMD5(p0, p1)
  end
  def self.compute_sha1(p0, p1)
    Raylib.ComputeSHA1(p0, p1)
  end
  def self.compute_sha2_56(p0, p1)
    Raylib.ComputeSHA256(p0, p1)
  end
  def self.set_automation_event_base_frame(p0)
    Raylib.SetAutomationEventBaseFrame(p0)
  end
  def self.start_automation_event_recording()
    Raylib.StartAutomationEventRecording()
  end
  def self.stop_automation_event_recording()
    Raylib.StopAutomationEventRecording()
  end
  def self.is_key_pressed_repeat(p0)
    Raylib.IsKeyPressedRepeat(p0)
  end
  def self.is_key_released(p0)
    Raylib.IsKeyReleased(p0)
  end
  def self.is_key_up(p0)
    Raylib.IsKeyUp(p0)
  end
  def self.get_key_pressed()
    Raylib.GetKeyPressed()
  end
  def self.get_char_pressed()
    Raylib.GetCharPressed()
  end
  def self.get_key_name(p0)
    Raylib.GetKeyName(p0)
  end
  def self.set_exit_key(p0)
    Raylib.SetExitKey(p0)
  end
  def self.is_gamepad_available(p0)
    Raylib.IsGamepadAvailable(p0)
  end
  def self.get_gamepad_name(p0)
    Raylib.GetGamepadName(p0)
  end
  def self.is_gamepad_button_pressed(p0, p1)
    Raylib.IsGamepadButtonPressed(p0, p1)
  end
  def self.is_gamepad_button_released(p0, p1)
    Raylib.IsGamepadButtonReleased(p0, p1)
  end
  def self.is_gamepad_button_up(p0, p1)
    Raylib.IsGamepadButtonUp(p0, p1)
  end
  def self.get_gamepad_button_pressed()
    Raylib.GetGamepadButtonPressed()
  end
  def self.get_gamepad_axis_count(p0)
    Raylib.GetGamepadAxisCount(p0)
  end
  def self.get_gamepad_axis_movement(p0, p1)
    Raylib.GetGamepadAxisMovement(p0, p1)
  end
  def self.set_gamepad_mappings(p0)
    Raylib.SetGamepadMappings(p0)
  end
  def self.set_gamepad_vibration(p0, p1, p2, p3)
    Raylib.SetGamepadVibration(p0, p1, p2, p3)
  end
  def self.is_mouse_button_pressed(p0)
    Raylib.IsMouseButtonPressed(p0)
  end
  def self.is_mouse_button_released(p0)
    Raylib.IsMouseButtonReleased(p0)
  end
  def self.is_mouse_button_up(p0)
    Raylib.IsMouseButtonUp(p0)
  end
  def self.get_mouse_x()
    Raylib.GetMouseX()
  end
  def self.get_mouse_y()
    Raylib.GetMouseY()
  end
  def self.set_mouse_position(p0, p1)
    Raylib.SetMousePosition(p0, p1)
  end
  def self.set_mouse_offset(p0, p1)
    Raylib.SetMouseOffset(p0, p1)
  end
  def self.set_mouse_scale(p0, p1)
    Raylib.SetMouseScale(p0, p1)
  end
  def self.get_mouse_wheel_move()
    Raylib.GetMouseWheelMove()
  end
  def self.set_mouse_cursor(p0)
    Raylib.SetMouseCursor(p0)
  end
  def self.get_touch_x()
    Raylib.GetTouchX()
  end
  def self.get_touch_y()
    Raylib.GetTouchY()
  end
  def self.get_touch_point_id(p0)
    Raylib.GetTouchPointId(p0)
  end
  def self.get_touch_point_count()
    Raylib.GetTouchPointCount()
  end
  def self.set_gestures_enabled(p0)
    Raylib.SetGesturesEnabled(p0)
  end
  def self.is_gesture_detected(p0)
    Raylib.IsGestureDetected(p0)
  end
  def self.get_gesture_detected()
    Raylib.GetGestureDetected()
  end
  def self.get_gesture_hold_duration()
    Raylib.GetGestureHoldDuration()
  end
  def self.get_gesture_drag_angle()
    Raylib.GetGestureDragAngle()
  end
  def self.get_gesture_pinch_angle()
    Raylib.GetGesturePinchAngle()
  end
  def self.image_format(p0, p1)
    Raylib.ImageFormat(p0, p1)
  end
  def self.image_alpha_crop(p0, p1)
    Raylib.ImageAlphaCrop(p0, p1)
  end
  def self.image_alpha_premultiply(p0)
    Raylib.ImageAlphaPremultiply(p0)
  end
  def self.image_blur_gaussian(p0, p1)
    Raylib.ImageBlurGaussian(p0, p1)
  end
  def self.image_kernel_convolution(p0, p1, p2)
    Raylib.ImageKernelConvolution(p0, p1, p2)
  end
  def self.image_resize(p0, p1, p2)
    Raylib.ImageResize(p0, p1, p2)
  end
  def self.image_resize_nn(p0, p1, p2)
    Raylib.ImageResizeNN(p0, p1, p2)
  end
  def self.image_mipmaps(p0)
    Raylib.ImageMipmaps(p0)
  end
  def self.image_dither(p0, p1, p2, p3, p4)
    Raylib.ImageDither(p0, p1, p2, p3, p4)
  end
  def self.image_flip_vertical(p0)
    Raylib.ImageFlipVertical(p0)
  end
  def self.image_flip_horizontal(p0)
    Raylib.ImageFlipHorizontal(p0)
  end
  def self.image_rotate(p0, p1)
    Raylib.ImageRotate(p0, p1)
  end
  def self.image_rotate_cw(p0)
    Raylib.ImageRotateCW(p0)
  end
  def self.image_rotate_ccw(p0)
    Raylib.ImageRotateCCW(p0)
  end
  def self.image_color_invert(p0)
    Raylib.ImageColorInvert(p0)
  end
  def self.image_color_grayscale(p0)
    Raylib.ImageColorGrayscale(p0)
  end
  def self.image_color_contrast(p0, p1)
    Raylib.ImageColorContrast(p0, p1)
  end
  def self.image_color_brightness(p0, p1)
    Raylib.ImageColorBrightness(p0, p1)
  end
  def self.gen_texture_mipmaps(p0)
    Raylib.GenTextureMipmaps(p0)
  end
  def self.get_pixel_data_size(p0, p1, p2)
    Raylib.GetPixelDataSize(p0, p1, p2)
  end
  def self.load_font_data(p0, p1, p2, p3, p4, p5, p6)
    Raylib.LoadFontData(p0, p1, p2, p3, p4, p5, p6)
  end
  def self.unload_font_data(p0, p1)
    Raylib.UnloadFontData(p0, p1)
  end
  def self.draw_fps(p0, p1)
    Raylib.DrawFPS(p0, p1)
  end
  def self.set_text_line_spacing(p0)
    Raylib.SetTextLineSpacing(p0)
  end
  def self.measure_text(p0, p1)
    Raylib.MeasureText(p0, p1)
  end
  def self.load_utf8(p0, p1)
    Raylib.LoadUTF8(p0, p1)
  end
  def self.unload_utf8(p0)
    Raylib.UnloadUTF8(p0)
  end
  def self.load_codepoints(p0, p1)
    Raylib.LoadCodepoints(p0, p1)
  end
  def self.unload_codepoints(p0)
    Raylib.UnloadCodepoints(p0)
  end
  def self.get_codepoint_count(p0)
    Raylib.GetCodepointCount(p0)
  end
  def self.get_codepoint(p0, p1)
    Raylib.GetCodepoint(p0, p1)
  end
  def self.get_codepoint_next(p0, p1)
    Raylib.GetCodepointNext(p0, p1)
  end
  def self.get_codepoint_previous(p0, p1)
    Raylib.GetCodepointPrevious(p0, p1)
  end
  def self.codepoint_to_utf8(p0, p1)
    Raylib.CodepointToUTF8(p0, p1)
  end
  def self.load_text_lines(p0, p1)
    Raylib.LoadTextLines(p0, p1)
  end
  def self.unload_text_lines(p0, p1)
    Raylib.UnloadTextLines(p0, p1)
  end
  def self.text_copy(p0, p1)
    Raylib.TextCopy(p0, p1)
  end
  def self.text_is_equal(p0, p1)
    Raylib.TextIsEqual(p0, p1)
  end
  def self.text_length(p0)
    Raylib.TextLength(p0)
  end
  def self.text_subtext(p0, p1, p2)
    Raylib.TextSubtext(p0, p1, p2)
  end
  def self.text_remove_spaces(p0)
    Raylib.TextRemoveSpaces(p0)
  end
  def self.get_text_between(p0, p1, p2)
    Raylib.GetTextBetween(p0, p1, p2)
  end
  def self.text_replace(p0, p1, p2)
    Raylib.TextReplace(p0, p1, p2)
  end
  def self.text_replace_alloc(p0, p1, p2)
    Raylib.TextReplaceAlloc(p0, p1, p2)
  end
  def self.text_replace_between(p0, p1, p2, p3)
    Raylib.TextReplaceBetween(p0, p1, p2, p3)
  end
  def self.text_replace_between_alloc(p0, p1, p2, p3)
    Raylib.TextReplaceBetweenAlloc(p0, p1, p2, p3)
  end
  def self.text_insert(p0, p1, p2)
    Raylib.TextInsert(p0, p1, p2)
  end
  def self.text_insert_alloc(p0, p1, p2)
    Raylib.TextInsertAlloc(p0, p1, p2)
  end
  def self.text_join(p0, p1, p2)
    Raylib.TextJoin(p0, p1, p2)
  end
  def self.text_split(p0, p1, p2)
    Raylib.TextSplit(p0, p1, p2)
  end
  def self.text_append(p0, p1, p2)
    Raylib.TextAppend(p0, p1, p2)
  end
  def self.text_find_index(p0, p1)
    Raylib.TextFindIndex(p0, p1)
  end
  def self.text_to_upper(p0)
    Raylib.TextToUpper(p0)
  end
  def self.text_to_lower(p0)
    Raylib.TextToLower(p0)
  end
  def self.text_to_pascal(p0)
    Raylib.TextToPascal(p0)
  end
  def self.text_to_snake(p0)
    Raylib.TextToSnake(p0)
  end
  def self.text_to_camel(p0)
    Raylib.TextToCamel(p0)
  end
  def self.text_to_integer(p0)
    Raylib.TextToInteger(p0)
  end
  def self.text_to_float(p0)
    Raylib.TextToFloat(p0)
  end
  def self.draw_grid(p0, p1)
    Raylib.rl_DrawGrid(p0, p1)
  end
  def self.upload_mesh(p0, p1)
    Raylib.UploadMesh(p0, p1)
  end
  def self.gen_mesh_tangents(p0)
    Raylib.GenMeshTangents(p0)
  end
  def self.load_materials(p0, p1)
    Raylib.LoadMaterials(p0, p1)
  end
  def self.set_model_mesh_material(p0, p1, p2)
    Raylib.SetModelMeshMaterial(p0, p1, p2)
  end
  def self.load_model_animations(p0, p1)
    Raylib.LoadModelAnimations(p0, p1)
  end
  def self.unload_model_animations(p0, p1)
    Raylib.UnloadModelAnimations(p0, p1)
  end
  def self.init_audio_device()
    Raylib.InitAudioDevice()
  end
  def self.close_audio_device()
    Raylib.CloseAudioDevice()
  end
  def self.is_audio_device_ready()
    Raylib.IsAudioDeviceReady()
  end
  def self.set_master_volume(p0)
    Raylib.SetMasterVolume(p0)
  end
  def self.get_master_volume()
    Raylib.GetMasterVolume()
  end
  def self.wave_crop(p0, p1, p2)
    Raylib.WaveCrop(p0, p1, p2)
  end
  def self.wave_format(p0, p1, p2, p3)
    Raylib.WaveFormat(p0, p1, p2, p3)
  end
  def self.unload_wave_samples(p0)
    Raylib.UnloadWaveSamples(p0)
  end
  def self.set_audio_stream_buffer_size_default(p0)
    Raylib.SetAudioStreamBufferSizeDefault(p0)
  end
  # Forwarding wrappers (not aliases): the targets are ffi_func declarations,
  # which Spinel cannot alias.
  def self.window_should_close()
    Raylib.WindowShouldClose()
  end
  def self.is_key_pressed(p0)
    Raylib.IsKeyPressed(p0)
  end
  def self.is_key_down(p0)
    Raylib.IsKeyDown(p0)
  end
  def self.is_gamepad_button_down(p0, p1)
    Raylib.IsGamepadButtonDown(p0, p1)
  end
  def self.is_mouse_button_down(p0)
    Raylib.IsMouseButtonDown(p0)
  end
  class << self
    alias_method :set_window_icon, :SetWindowIcon
    alias_method :get_monitor_position, :GetMonitorPosition
    alias_method :get_window_position, :GetWindowPosition
    alias_method :get_window_scale_dpi, :GetWindowScaleDPI
    alias_method :get_clipboard_image, :GetClipboardImage
    alias_method :clear_background, :ClearBackground
    alias_method :begin_mode_2d, :BeginMode2D
    alias_method :begin_mode_3d, :BeginMode3D
    alias_method :begin_texture_mode, :BeginTextureMode
    alias_method :begin_shader_mode, :BeginShaderMode
    alias_method :begin_vr_stereo_mode, :BeginVrStereoMode
    alias_method :load_vr_stereo_config, :LoadVrStereoConfig
    alias_method :unload_vr_stereo_config, :UnloadVrStereoConfig
    alias_method :load_shader, :LoadShader
    alias_method :load_shader_from_memory, :LoadShaderFromMemory
    alias_method :is_shader_valid, :IsShaderValid
    alias_method :get_shader_location, :GetShaderLocation
    alias_method :get_shader_location_attrib, :GetShaderLocationAttrib
    alias_method :set_shader_value, :SetShaderValue
    alias_method :set_shader_value_v, :SetShaderValueV
    alias_method :set_shader_value_matrix, :SetShaderValueMatrix
    alias_method :set_shader_value_texture, :SetShaderValueTexture
    alias_method :unload_shader, :UnloadShader
    alias_method :get_screen_to_world_ray, :GetScreenToWorldRay
    alias_method :get_screen_to_world_ray_ex, :GetScreenToWorldRayEx
    alias_method :get_world_to_screen, :GetWorldToScreen
    alias_method :get_world_to_screen_ex, :GetWorldToScreenEx
    alias_method :get_world_to_screen_2d, :GetWorldToScreen2D
    alias_method :get_screen_to_world_2d, :GetScreenToWorld2D
    alias_method :get_camera_matrix, :GetCameraMatrix
    alias_method :get_camera_matrix_2d, :GetCameraMatrix2D
    alias_method :set_trace_log_callback, :SetTraceLogCallback
    alias_method :set_load_file_data_callback, :SetLoadFileDataCallback
    alias_method :set_save_file_data_callback, :SetSaveFileDataCallback
    alias_method :set_load_file_text_callback, :SetLoadFileTextCallback
    alias_method :set_save_file_text_callback, :SetSaveFileTextCallback
    alias_method :load_directory_files, :LoadDirectoryFiles
    alias_method :load_directory_files_ex, :LoadDirectoryFilesEx
    alias_method :unload_directory_files, :UnloadDirectoryFiles
    alias_method :load_dropped_files, :LoadDroppedFiles
    alias_method :unload_dropped_files, :UnloadDroppedFiles
    alias_method :load_automation_event_list, :LoadAutomationEventList
    alias_method :unload_automation_event_list, :UnloadAutomationEventList
    alias_method :export_automation_event_list, :ExportAutomationEventList
    alias_method :set_automation_event_list, :SetAutomationEventList
    alias_method :play_automation_event, :PlayAutomationEvent
    alias_method :get_mouse_position, :GetMousePosition
    alias_method :get_mouse_delta, :GetMouseDelta
    alias_method :get_mouse_wheel_move_v, :GetMouseWheelMoveV
    alias_method :get_touch_position, :GetTouchPosition
    alias_method :get_gesture_drag_vector, :GetGestureDragVector
    alias_method :get_gesture_pinch_vector, :GetGesturePinchVector
    alias_method :update_camera, :UpdateCamera
    alias_method :update_camera_pro, :UpdateCameraPro
    alias_method :set_shapes_texture, :SetShapesTexture
    alias_method :get_shapes_texture, :GetShapesTexture
    alias_method :get_shapes_texture_rectangle, :GetShapesTextureRectangle
    alias_method :draw_pixel, :DrawPixel
    alias_method :draw_pixel_v, :DrawPixelV
    alias_method :draw_line, :DrawLine
    alias_method :draw_line_v, :DrawLineV
    alias_method :draw_line_ex, :DrawLineEx
    alias_method :draw_line_strip, :DrawLineStrip
    alias_method :draw_line_bezier, :DrawLineBezier
    alias_method :draw_line_dashed, :DrawLineDashed
    alias_method :draw_triangle, :DrawTriangle
    alias_method :draw_triangle_gradient, :DrawTriangleGradient
    alias_method :draw_triangle_lines, :DrawTriangleLines
    alias_method :draw_triangle_lines_ex, :DrawTriangleLinesEx
    alias_method :draw_triangle_fan, :DrawTriangleFan
    alias_method :draw_triangle_strip, :DrawTriangleStrip
    alias_method :draw_rectangle, :DrawRectangle
    alias_method :draw_rectangle_v, :DrawRectangleV
    alias_method :draw_rectangle_rec, :DrawRectangleRec
    alias_method :draw_rectangle_pro, :DrawRectanglePro
    alias_method :draw_rectangle_gradient_v, :DrawRectangleGradientV
    alias_method :draw_rectangle_gradient_h, :DrawRectangleGradientH
    alias_method :draw_rectangle_gradient_ex, :DrawRectangleGradientEx
    alias_method :draw_rectangle_lines, :DrawRectangleLines
    alias_method :draw_rectangle_lines_ex, :DrawRectangleLinesEx
    alias_method :draw_rectangle_rounded, :DrawRectangleRounded
    alias_method :draw_rectangle_rounded_lines, :DrawRectangleRoundedLines
    alias_method :draw_rectangle_rounded_lines_ex, :DrawRectangleRoundedLinesEx
    alias_method :draw_poly, :DrawPoly
    alias_method :draw_poly_lines, :DrawPolyLines
    alias_method :draw_poly_lines_ex, :DrawPolyLinesEx
    alias_method :draw_circle, :DrawCircle
    alias_method :draw_circle_v, :DrawCircleV
    alias_method :draw_circle_gradient, :DrawCircleGradient
    alias_method :draw_circle_sector, :DrawCircleSector
    alias_method :draw_circle_sector_lines, :DrawCircleSectorLines
    alias_method :draw_circle_sector_lines_ex, :DrawCircleSectorLinesEx
    alias_method :draw_circle_lines, :DrawCircleLines
    alias_method :draw_circle_lines_v, :DrawCircleLinesV
    alias_method :draw_circle_lines_ex, :DrawCircleLinesEx
    alias_method :draw_ellipse, :DrawEllipse
    alias_method :draw_ellipse_v, :DrawEllipseV
    alias_method :draw_ellipse_lines, :DrawEllipseLines
    alias_method :draw_ellipse_lines_v, :DrawEllipseLinesV
    alias_method :draw_ellipse_lines_ex, :DrawEllipseLinesEx
    alias_method :draw_ring, :DrawRing
    alias_method :draw_ring_lines, :DrawRingLines
    alias_method :draw_ring_lines_ex, :DrawRingLinesEx
    alias_method :draw_spline_linear, :DrawSplineLinear
    alias_method :draw_spline_basis, :DrawSplineBasis
    alias_method :draw_spline_catmull_rom, :DrawSplineCatmullRom
    alias_method :draw_spline_bezier_quadratic, :DrawSplineBezierQuadratic
    alias_method :draw_spline_bezier_cubic, :DrawSplineBezierCubic
    alias_method :draw_spline_segment_linear, :DrawSplineSegmentLinear
    alias_method :draw_spline_segment_basis, :DrawSplineSegmentBasis
    alias_method :draw_spline_segment_catmull_rom, :DrawSplineSegmentCatmullRom
    alias_method :draw_spline_segment_bezier_quadratic, :DrawSplineSegmentBezierQuadratic
    alias_method :draw_spline_segment_bezier_cubic, :DrawSplineSegmentBezierCubic
    alias_method :get_spline_point_linear, :GetSplinePointLinear
    alias_method :get_spline_point_basis, :GetSplinePointBasis
    alias_method :get_spline_point_catmull_rom, :GetSplinePointCatmullRom
    alias_method :get_spline_point_bezier_quadratic, :GetSplinePointBezierQuadratic
    alias_method :get_spline_point_bezier_cubic, :GetSplinePointBezierCubic
    alias_method :check_collision_recs, :CheckCollisionRecs
    alias_method :check_collision_circles, :CheckCollisionCircles
    alias_method :check_collision_circle_rec, :CheckCollisionCircleRec
    alias_method :check_collision_circle_line, :CheckCollisionCircleLine
    alias_method :check_collision_point_rec, :CheckCollisionPointRec
    alias_method :check_collision_point_circle, :CheckCollisionPointCircle
    alias_method :check_collision_point_triangle, :CheckCollisionPointTriangle
    alias_method :check_collision_point_line, :CheckCollisionPointLine
    alias_method :check_collision_point_poly, :CheckCollisionPointPoly
    alias_method :check_collision_lines, :CheckCollisionLines
    alias_method :get_collision_rec, :GetCollisionRec
    alias_method :load_image, :LoadImage
    alias_method :load_image_raw, :LoadImageRaw
    alias_method :load_image_anim, :LoadImageAnim
    alias_method :load_image_anim_from_memory, :LoadImageAnimFromMemory
    alias_method :load_image_from_memory, :LoadImageFromMemory
    alias_method :load_image_from_texture, :LoadImageFromTexture
    alias_method :load_image_from_screen, :LoadImageFromScreen
    alias_method :is_image_valid, :IsImageValid
    alias_method :unload_image, :UnloadImage
    alias_method :export_image, :ExportImage
    alias_method :export_image_to_memory, :ExportImageToMemory
    alias_method :export_image_as_code, :ExportImageAsCode
    alias_method :gen_image_color, :GenImageColor
    alias_method :gen_image_gradient_linear, :GenImageGradientLinear
    alias_method :gen_image_gradient_radial, :GenImageGradientRadial
    alias_method :gen_image_gradient_square, :GenImageGradientSquare
    alias_method :gen_image_checked, :GenImageChecked
    alias_method :gen_image_white_noise, :GenImageWhiteNoise
    alias_method :gen_image_perlin_noise, :GenImagePerlinNoise
    alias_method :gen_image_cellular, :GenImageCellular
    alias_method :gen_image_text, :GenImageText
    alias_method :image_copy, :ImageCopy
    alias_method :image_from_image, :ImageFromImage
    alias_method :image_from_channel, :ImageFromChannel
    alias_method :image_text, :ImageText
    alias_method :image_text_ex, :ImageTextEx
    alias_method :image_to_pot, :ImageToPOT
    alias_method :image_crop, :ImageCrop
    alias_method :image_alpha_clear, :ImageAlphaClear
    alias_method :image_alpha_mask, :ImageAlphaMask
    alias_method :image_resize_canvas, :ImageResizeCanvas
    alias_method :image_color_tint, :ImageColorTint
    alias_method :image_color_replace, :ImageColorReplace
    alias_method :load_image_colors, :LoadImageColors
    alias_method :load_image_palette, :LoadImagePalette
    alias_method :unload_image_colors, :UnloadImageColors
    alias_method :unload_image_palette, :UnloadImagePalette
    alias_method :get_image_alpha_border, :GetImageAlphaBorder
    alias_method :get_image_color, :GetImageColor
    alias_method :image_clear_background, :ImageClearBackground
    alias_method :image_draw_pixel, :ImageDrawPixel
    alias_method :image_draw_pixel_v, :ImageDrawPixelV
    alias_method :image_draw_line, :ImageDrawLine
    alias_method :image_draw_line_v, :ImageDrawLineV
    alias_method :image_draw_line_ex, :ImageDrawLineEx
    alias_method :image_draw_line_strip, :ImageDrawLineStrip
    alias_method :image_draw_triangle, :ImageDrawTriangle
    alias_method :image_draw_triangle_gradient, :ImageDrawTriangleGradient
    alias_method :image_draw_triangle_lines, :ImageDrawTriangleLines
    alias_method :image_draw_triangle_fan, :ImageDrawTriangleFan
    alias_method :image_draw_triangle_strip, :ImageDrawTriangleStrip
    alias_method :image_draw_rectangle, :ImageDrawRectangle
    alias_method :image_draw_rectangle_v, :ImageDrawRectangleV
    alias_method :image_draw_rectangle_rec, :ImageDrawRectangleRec
    alias_method :image_draw_rectangle_pro, :ImageDrawRectanglePro
    alias_method :image_draw_rectangle_lines, :ImageDrawRectangleLines
    alias_method :image_draw_rectangle_lines_ex, :ImageDrawRectangleLinesEx
    alias_method :image_draw_rectangle_gradient_ex, :ImageDrawRectangleGradientEx
    alias_method :image_draw_circle, :ImageDrawCircle
    alias_method :image_draw_circle_v, :ImageDrawCircleV
    alias_method :image_draw_circle_lines, :ImageDrawCircleLines
    alias_method :image_draw_circle_lines_v, :ImageDrawCircleLinesV
    alias_method :image_draw_circle_gradient, :ImageDrawCircleGradient
    alias_method :image_draw_image, :ImageDrawImage
    alias_method :image_draw_image_ex, :ImageDrawImageEx
    alias_method :image_draw_image_rec, :ImageDrawImageRec
    alias_method :image_draw_image_pro, :ImageDrawImagePro
    alias_method :image_draw_text, :ImageDrawText
    alias_method :image_draw_text_ex, :ImageDrawTextEx
    alias_method :image_draw_text_pro, :ImageDrawTextPro
    alias_method :load_texture, :LoadTexture
    alias_method :load_texture_from_image, :LoadTextureFromImage
    alias_method :load_texture_cubemap, :LoadTextureCubemap
    alias_method :load_render_texture, :LoadRenderTexture
    alias_method :load_render_texture_ex, :LoadRenderTextureEx
    alias_method :is_texture_valid, :IsTextureValid
    alias_method :unload_texture, :UnloadTexture
    alias_method :is_render_texture_valid, :IsRenderTextureValid
    alias_method :unload_render_texture, :UnloadRenderTexture
    alias_method :update_texture, :UpdateTexture
    alias_method :update_texture_rec, :UpdateTextureRec
    alias_method :set_texture_filter, :SetTextureFilter
    alias_method :set_texture_wrap, :SetTextureWrap
    alias_method :draw_texture, :DrawTexture
    alias_method :draw_texture_v, :DrawTextureV
    alias_method :draw_texture_ex, :DrawTextureEx
    alias_method :draw_texture_rec, :DrawTextureRec
    alias_method :draw_texture_pro, :DrawTexturePro
    alias_method :draw_texture_n_patch, :DrawTextureNPatch
    alias_method :color_is_equal, :ColorIsEqual
    alias_method :fade, :Fade
    alias_method :color_to_int, :ColorToInt
    alias_method :color_normalize, :ColorNormalize
    alias_method :color_from_normalized, :ColorFromNormalized
    alias_method :color_to_hsv, :ColorToHSV
    alias_method :color_from_hsv, :ColorFromHSV
    alias_method :color_tint, :ColorTint
    alias_method :color_brightness, :ColorBrightness
    alias_method :color_contrast, :ColorContrast
    alias_method :color_alpha, :ColorAlpha
    alias_method :color_alpha_blend, :ColorAlphaBlend
    alias_method :color_lerp, :ColorLerp
    alias_method :get_color, :GetColor
    alias_method :get_pixel_color, :GetPixelColor
    alias_method :set_pixel_color, :SetPixelColor
    alias_method :get_font_default, :GetFontDefault
    alias_method :load_font, :LoadFont
    alias_method :load_font_ex, :LoadFontEx
    alias_method :load_font_from_image, :LoadFontFromImage
    alias_method :load_font_from_memory, :LoadFontFromMemory
    alias_method :is_font_valid, :IsFontValid
    alias_method :gen_image_font_atlas, :GenImageFontAtlas
    alias_method :unload_font, :UnloadFont
    alias_method :export_font_as_code, :ExportFontAsCode
    alias_method :draw_text, :DrawText
    alias_method :draw_text_ex, :DrawTextEx
    alias_method :draw_text_pro, :DrawTextPro
    alias_method :draw_text_codepoint, :DrawTextCodepoint
    alias_method :draw_text_codepoints, :DrawTextCodepoints
    alias_method :measure_text_ex, :MeasureTextEx
    alias_method :measure_text_codepoints, :MeasureTextCodepoints
    alias_method :get_glyph_index, :GetGlyphIndex
    alias_method :get_glyph_info, :GetGlyphInfo
    alias_method :get_glyph_atlas_rec, :GetGlyphAtlasRec
    alias_method :draw_line_3d, :DrawLine3D
    alias_method :draw_point_3d, :DrawPoint3D
    alias_method :draw_circle_3d, :DrawCircle3D
    alias_method :draw_triangle_3d, :DrawTriangle3D
    alias_method :draw_triangle_strip_3d, :DrawTriangleStrip3D
    alias_method :draw_cube, :DrawCube
    alias_method :draw_cube_v, :DrawCubeV
    alias_method :draw_cube_wires, :DrawCubeWires
    alias_method :draw_cube_wires_v, :DrawCubeWiresV
    alias_method :draw_sphere, :DrawSphere
    alias_method :draw_sphere_ex, :DrawSphereEx
    alias_method :draw_sphere_wires, :DrawSphereWires
    alias_method :draw_cylinder, :DrawCylinder
    alias_method :draw_cylinder_ex, :DrawCylinderEx
    alias_method :draw_cylinder_wires, :DrawCylinderWires
    alias_method :draw_cylinder_wires_ex, :DrawCylinderWiresEx
    alias_method :draw_capsule, :DrawCapsule
    alias_method :draw_capsule_wires, :DrawCapsuleWires
    alias_method :draw_plane, :DrawPlane
    alias_method :draw_ray, :DrawRay
    alias_method :load_model, :LoadModel
    alias_method :load_model_from_mesh, :LoadModelFromMesh
    alias_method :is_model_valid, :IsModelValid
    alias_method :unload_model, :UnloadModel
    alias_method :get_model_bounding_box, :GetModelBoundingBox
    alias_method :draw_model, :DrawModel
    alias_method :draw_model_ex, :DrawModelEx
    alias_method :draw_model_wires, :DrawModelWires
    alias_method :draw_model_wires_ex, :DrawModelWiresEx
    alias_method :draw_bounding_box, :DrawBoundingBox
    alias_method :draw_billboard, :DrawBillboard
    alias_method :draw_billboard_rec, :DrawBillboardRec
    alias_method :draw_billboard_pro, :DrawBillboardPro
    alias_method :update_mesh_buffer, :UpdateMeshBuffer
    alias_method :unload_mesh, :UnloadMesh
    alias_method :draw_mesh, :DrawMesh
    alias_method :draw_mesh_instanced, :DrawMeshInstanced
    alias_method :get_mesh_bounding_box, :GetMeshBoundingBox
    alias_method :export_mesh, :ExportMesh
    alias_method :export_mesh_as_code, :ExportMeshAsCode
    alias_method :gen_mesh_poly, :GenMeshPoly
    alias_method :gen_mesh_plane, :GenMeshPlane
    alias_method :gen_mesh_cube, :GenMeshCube
    alias_method :gen_mesh_sphere, :GenMeshSphere
    alias_method :gen_mesh_hemi_sphere, :GenMeshHemiSphere
    alias_method :gen_mesh_cylinder, :GenMeshCylinder
    alias_method :gen_mesh_cone, :GenMeshCone
    alias_method :gen_mesh_torus, :GenMeshTorus
    alias_method :gen_mesh_knot, :GenMeshKnot
    alias_method :gen_mesh_heightmap, :GenMeshHeightmap
    alias_method :gen_mesh_cubicmap, :GenMeshCubicmap
    alias_method :load_material_default, :LoadMaterialDefault
    alias_method :is_material_valid, :IsMaterialValid
    alias_method :unload_material, :UnloadMaterial
    alias_method :set_material_texture, :SetMaterialTexture
    alias_method :update_model_animation, :UpdateModelAnimation
    alias_method :update_model_animation_ex, :UpdateModelAnimationEx
    alias_method :is_model_animation_valid, :IsModelAnimationValid
    alias_method :check_collision_spheres, :CheckCollisionSpheres
    alias_method :check_collision_boxes, :CheckCollisionBoxes
    alias_method :check_collision_box_sphere, :CheckCollisionBoxSphere
    alias_method :get_ray_collision_sphere, :GetRayCollisionSphere
    alias_method :get_ray_collision_box, :GetRayCollisionBox
    alias_method :get_ray_collision_mesh, :GetRayCollisionMesh
    alias_method :get_ray_collision_triangle, :GetRayCollisionTriangle
    alias_method :get_ray_collision_quad, :GetRayCollisionQuad
    alias_method :load_wave, :LoadWave
    alias_method :load_wave_from_memory, :LoadWaveFromMemory
    alias_method :is_wave_valid, :IsWaveValid
    alias_method :load_sound, :LoadSound
    alias_method :load_sound_from_wave, :LoadSoundFromWave
    alias_method :load_sound_alias, :LoadSoundAlias
    alias_method :is_sound_valid, :IsSoundValid
    alias_method :update_sound, :UpdateSound
    alias_method :unload_wave, :UnloadWave
    alias_method :unload_sound, :UnloadSound
    alias_method :unload_sound_alias, :UnloadSoundAlias
    alias_method :export_wave, :ExportWave
    alias_method :export_wave_as_code, :ExportWaveAsCode
    alias_method :play_sound, :PlaySound
    alias_method :stop_sound, :StopSound
    alias_method :pause_sound, :PauseSound
    alias_method :resume_sound, :ResumeSound
    alias_method :is_sound_playing, :IsSoundPlaying
    alias_method :set_sound_volume, :SetSoundVolume
    alias_method :set_sound_pitch, :SetSoundPitch
    alias_method :set_sound_pan, :SetSoundPan
    alias_method :wave_copy, :WaveCopy
    alias_method :load_wave_samples, :LoadWaveSamples
    alias_method :load_music_stream, :LoadMusicStream
    alias_method :load_music_stream_from_memory, :LoadMusicStreamFromMemory
    alias_method :is_music_valid, :IsMusicValid
    alias_method :unload_music_stream, :UnloadMusicStream
    alias_method :play_music_stream, :PlayMusicStream
    alias_method :is_music_stream_playing, :IsMusicStreamPlaying
    alias_method :update_music_stream, :UpdateMusicStream
    alias_method :stop_music_stream, :StopMusicStream
    alias_method :pause_music_stream, :PauseMusicStream
    alias_method :resume_music_stream, :ResumeMusicStream
    alias_method :seek_music_stream, :SeekMusicStream
    alias_method :set_music_volume, :SetMusicVolume
    alias_method :set_music_pitch, :SetMusicPitch
    alias_method :set_music_pan, :SetMusicPan
    alias_method :get_music_time_length, :GetMusicTimeLength
    alias_method :get_music_time_played, :GetMusicTimePlayed
    alias_method :load_audio_stream, :LoadAudioStream
    alias_method :is_audio_stream_valid, :IsAudioStreamValid
    alias_method :unload_audio_stream, :UnloadAudioStream
    alias_method :update_audio_stream, :UpdateAudioStream
    alias_method :is_audio_stream_processed, :IsAudioStreamProcessed
    alias_method :play_audio_stream, :PlayAudioStream
    alias_method :pause_audio_stream, :PauseAudioStream
    alias_method :resume_audio_stream, :ResumeAudioStream
    alias_method :is_audio_stream_playing, :IsAudioStreamPlaying
    alias_method :stop_audio_stream, :StopAudioStream
    alias_method :set_audio_stream_volume, :SetAudioStreamVolume
    alias_method :set_audio_stream_pitch, :SetAudioStreamPitch
    alias_method :set_audio_stream_pan, :SetAudioStreamPan
    alias_method :set_audio_stream_callback, :SetAudioStreamCallback
    alias_method :attach_audio_stream_processor, :AttachAudioStreamProcessor
    alias_method :detach_audio_stream_processor, :DetachAudioStreamProcessor
    alias_method :attach_audio_mixed_processor, :AttachAudioMixedProcessor
    alias_method :detach_audio_mixed_processor, :DetachAudioMixedProcessor
  end
end
