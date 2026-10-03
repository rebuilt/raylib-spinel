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
  ffi_func :sp_Vector2Fill, %i[ptr float float], :void
  ffi_func :sp_Vector4Fill, %i[ptr float float float float], :void
  ffi_func :sp_MatrixFill,
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
  ffi_func :sp_SetWindowIcon, [:ptr], :void
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
  ffi_func :sp_GetMonitorPosition, [:int, :ptr], :void
  ffi_func :GetMonitorWidth, [:int], :int
  ffi_func :GetMonitorHeight, [:int], :int
  ffi_func :GetMonitorPhysicalWidth, [:int], :int
  ffi_func :GetMonitorPhysicalHeight, [:int], :int
  ffi_func :GetMonitorRefreshRate, [:int], :int
  ffi_func :sp_GetWindowPosition, [:ptr], :void
  ffi_func :sp_GetWindowScaleDPI, [:ptr], :void
  ffi_func :GetMonitorName, [:int], :str
  ffi_func :SetClipboardText, [:str], :void
  ffi_func :GetClipboardText, [], :str
  ffi_func :sp_GetClipboardImage, [], :ptr
  ffi_func :EnableEventWaiting, [], :void
  ffi_func :DisableEventWaiting, [], :void
  ffi_func :ShowCursor, [], :void
  ffi_func :HideCursor, [], :void
  ffi_func :IsCursorHidden, [], :bool
  ffi_func :IsCursorOnScreen, [], :bool
  ffi_func :sp_BeginMode2D, [:ptr], :void
  ffi_func :EndMode2D, [], :void
  ffi_func :sp_BeginTextureMode, [:ptr], :void
  ffi_func :EndTextureMode, [], :void
  ffi_func :sp_BeginShaderMode, [:ptr], :void
  ffi_func :EndShaderMode, [], :void
  ffi_func :BeginBlendMode, [:int], :void
  ffi_func :EndBlendMode, [], :void
  ffi_func :BeginScissorMode, [:int, :int, :int, :int], :void
  ffi_func :EndScissorMode, [], :void
  ffi_func :sp_BeginVrStereoMode, [:ptr], :void
  ffi_func :EndVrStereoMode, [], :void
  ffi_func :sp_LoadVrStereoConfig, [:ptr, :ptr], :void
  ffi_func :sp_UnloadVrStereoConfig, [:ptr], :void
  ffi_func :sp_LoadShader, [:str, :str], :ptr
  ffi_func :sp_LoadShaderFromMemory, [:str, :str], :ptr
  ffi_func :sp_IsShaderValid, [:ptr], :bool
  ffi_func :sp_GetShaderLocation, [:ptr, :str], :int
  ffi_func :sp_GetShaderLocationAttrib, [:ptr, :str], :int
  ffi_func :sp_SetShaderValue, [:ptr, :int, :ptr, :int], :void
  ffi_func :sp_SetShaderValueV, [:ptr, :int, :ptr, :int, :int], :void
  ffi_func :sp_SetShaderValueMatrix, [:ptr, :int, :ptr], :void
  ffi_func :sp_SetShaderValueTexture, [:ptr, :int, :ptr], :void
  ffi_func :sp_UnloadShader, [:ptr], :void
  ffi_func :sp_GetScreenToWorldRay, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_GetScreenToWorldRayEx, [:ptr, :ptr, :int, :int, :ptr], :void
  ffi_func :sp_GetWorldToScreen, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_GetWorldToScreenEx, [:ptr, :ptr, :int, :int, :ptr], :void
  ffi_func :sp_GetWorldToScreen2D, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_GetScreenToWorld2D, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_GetCameraMatrix, [:ptr, :ptr], :void
  ffi_func :sp_GetCameraMatrix2D, [:ptr, :ptr], :void
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
  ffi_func :sp_SetTraceLogCallback, [:ptr], :void
  ffi_func :MemAlloc, [:uint], :ptr
  ffi_func :MemRealloc, [:ptr, :uint], :ptr
  ffi_func :MemFree, [:ptr], :void
  ffi_func :LoadFileData, [:str, :ptr], :ptr
  ffi_func :UnloadFileData, [:ptr], :void
  ffi_func :SaveFileData, [:str, :ptr, :int], :bool
  ffi_func :ExportDataAsCode, [:ptr, :int, :str], :bool
  ffi_func :LoadFileText, [:str], :str
  ffi_func :sp_LoadFileTextPtr, [:str], :ptr
  ffi_func :sp_UnloadFileTextPtr, [:ptr], :void
  ffi_func :sp_PtrToString, [:ptr], :str
  ffi_func :UnloadFileText, [:str], :void
  ffi_func :SaveFileText, [:str, :str], :bool
  ffi_func :sp_SetLoadFileDataCallback, [:ptr], :void
  ffi_func :sp_SetSaveFileDataCallback, [:ptr], :void
  ffi_func :sp_SetLoadFileTextCallback, [:ptr], :void
  ffi_func :sp_SetSaveFileTextCallback, [:ptr], :void
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
  ffi_func :sp_LoadDirectoryFiles, [:str, :ptr], :void
  ffi_func :sp_LoadDirectoryFilesEx, [:str, :str, :bool, :ptr], :void
  ffi_func :sp_UnloadDirectoryFiles, [:ptr], :void
  ffi_func :IsFileDropped, [], :bool
  ffi_func :sp_LoadDroppedFiles, [:ptr], :void
  ffi_func :sp_UnloadDroppedFiles, [:ptr], :void
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
  ffi_func :sp_LoadAutomationEventList, [:str, :ptr], :void
  ffi_func :sp_UnloadAutomationEventList, [:ptr], :void
  ffi_func :sp_ExportAutomationEventList, [:ptr, :str], :bool
  ffi_func :sp_SetAutomationEventList, [:ptr], :void
  ffi_func :SetAutomationEventBaseFrame, [:int], :void
  ffi_func :StartAutomationEventRecording, [], :void
  ffi_func :StopAutomationEventRecording, [], :void
  ffi_func :sp_PlayAutomationEvent, [:ptr], :void
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
  ffi_func :sp_GetMousePosition, [:ptr], :void
  ffi_func :sp_GetMouseDelta, [:ptr], :void
  ffi_func :SetMousePosition, [:int, :int], :void
  ffi_func :SetMouseOffset, [:int, :int], :void
  ffi_func :SetMouseScale, [:float, :float], :void
  ffi_func :GetMouseWheelMove, [], :float
  ffi_func :sp_GetMouseWheelMoveV, [:ptr], :void
  ffi_func :SetMouseCursor, [:int], :void
  ffi_func :GetTouchX, [], :int
  ffi_func :GetTouchY, [], :int
  ffi_func :sp_GetTouchPosition, [:int, :ptr], :void
  ffi_func :GetTouchPointId, [:int], :int
  ffi_func :GetTouchPointCount, [], :int
  ffi_func :SetGesturesEnabled, [:uint], :void
  ffi_func :IsGestureDetected, [:uint], :bool
  ffi_func :GetGestureDetected, [], :int
  ffi_func :GetGestureHoldDuration, [], :float
  ffi_func :sp_GetGestureDragVector, [:ptr], :void
  ffi_func :GetGestureDragAngle, [], :float
  ffi_func :sp_GetGesturePinchVector, [:ptr], :void
  ffi_func :GetGesturePinchAngle, [], :float
  ffi_func :sp_UpdateCameraPro, [:ptr, :ptr, :ptr, :float], :void
  ffi_func :sp_SetShapesTexture, [:ptr, :ptr], :void
  ffi_func :sp_GetShapesTexture, [], :ptr
  ffi_func :sp_GetShapesTextureRectangle, [:ptr], :void
  ffi_func :sp_DrawPixelV, [:ptr, :ptr], :void
  ffi_func :sp_DrawLine, [:int, :int, :int, :int, :ptr], :void
  ffi_func :sp_DrawLineV, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_DrawLineEx, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_DrawLineStrip, [:ptr, :int, :ptr], :void
  ffi_func :sp_DrawLineBezier, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_DrawLineDashed, [:ptr, :ptr, :int, :int, :ptr], :void
  ffi_func :sp_DrawTriangleGradient, [:ptr, :ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_DrawTriangleLines, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_DrawTriangleLinesEx, [:ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_DrawTriangleFan, [:ptr, :int, :ptr], :void
  ffi_func :sp_DrawTriangleStrip, [:ptr, :int, :ptr], :void
  ffi_func :sp_DrawRectangleV, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_DrawRectangleRec, [:ptr, :ptr], :void
  ffi_func :sp_DrawRectanglePro, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_DrawRectangleGradientV, [:int, :int, :int, :int, :ptr, :ptr], :void
  ffi_func :sp_DrawRectangleGradientH, [:int, :int, :int, :int, :ptr, :ptr], :void
  ffi_func :sp_DrawRectangleGradientEx, [:ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_DrawRectangleLinesEx, [:ptr, :float, :ptr], :void
  ffi_func :sp_DrawRectangleRounded, [:ptr, :float, :int, :ptr], :void
  ffi_func :sp_DrawRectangleRoundedLines, [:ptr, :float, :int, :ptr], :void
  ffi_func :sp_DrawRectangleRoundedLinesEx, [:ptr, :float, :int, :float, :ptr], :void
  ffi_func :sp_DrawPoly, [:ptr, :int, :float, :float, :ptr], :void
  ffi_func :sp_DrawPolyLines, [:ptr, :int, :float, :float, :ptr], :void
  ffi_func :sp_DrawPolyLinesEx, [:ptr, :int, :float, :float, :float, :ptr], :void
  ffi_func :sp_DrawCircle, [:int, :int, :float, :ptr], :void
  ffi_func :sp_DrawCircleGradient, [:ptr, :float, :ptr, :ptr], :void
  ffi_func :sp_DrawCircleSector, [:ptr, :float, :float, :float, :int, :ptr], :void
  ffi_func :sp_DrawCircleSectorLines, [:ptr, :float, :float, :float, :int, :ptr], :void
  ffi_func :sp_DrawCircleSectorLinesEx, [:ptr, :float, :float, :float, :int, :float, :ptr], :void
  ffi_func :sp_DrawCircleLines, [:int, :int, :float, :ptr], :void
  ffi_func :sp_DrawCircleLinesV, [:ptr, :float, :ptr], :void
  ffi_func :sp_DrawCircleLinesEx, [:ptr, :float, :float, :ptr], :void
  ffi_func :sp_DrawEllipse, [:int, :int, :float, :float, :ptr], :void
  ffi_func :sp_DrawEllipseV, [:ptr, :float, :float, :ptr], :void
  ffi_func :sp_DrawEllipseLines, [:int, :int, :float, :float, :ptr], :void
  ffi_func :sp_DrawEllipseLinesV, [:ptr, :float, :float, :ptr], :void
  ffi_func :sp_DrawEllipseLinesEx, [:ptr, :float, :float, :float, :ptr], :void
  ffi_func :sp_DrawRing, [:ptr, :float, :float, :float, :float, :int, :ptr], :void
  ffi_func :sp_DrawRingLines, [:ptr, :float, :float, :float, :float, :int, :ptr], :void
  ffi_func :sp_DrawRingLinesEx, [:ptr, :float, :float, :float, :float, :int, :float, :ptr], :void
  ffi_func :sp_DrawSplineLinear, [:ptr, :int, :float, :ptr], :void
  ffi_func :sp_DrawSplineBasis, [:ptr, :int, :float, :ptr], :void
  ffi_func :sp_DrawSplineCatmullRom, [:ptr, :int, :float, :ptr], :void
  ffi_func :sp_DrawSplineBezierQuadratic, [:ptr, :int, :float, :ptr], :void
  ffi_func :sp_DrawSplineBezierCubic, [:ptr, :int, :float, :ptr], :void
  ffi_func :sp_DrawSplineSegmentLinear, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_DrawSplineSegmentBasis, [:ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_DrawSplineSegmentCatmullRom, [:ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_DrawSplineSegmentBezierQuadratic, [:ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_DrawSplineSegmentBezierCubic, [:ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_GetSplinePointLinear, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_GetSplinePointBasis, [:ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_GetSplinePointCatmullRom, [:ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_GetSplinePointBezierQuadratic, [:ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_GetSplinePointBezierCubic, [:ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_CheckCollisionRecs, [:ptr, :ptr], :bool
  ffi_func :sp_CheckCollisionCircles, [:ptr, :float, :ptr, :float], :bool
  ffi_func :sp_CheckCollisionCircleRec, [:ptr, :float, :ptr], :bool
  ffi_func :sp_CheckCollisionCircleLine, [:ptr, :float, :ptr, :ptr], :bool
  ffi_func :sp_CheckCollisionPointRec, [:ptr, :ptr], :bool
  ffi_func :sp_CheckCollisionPointCircle, [:ptr, :ptr, :float], :bool
  ffi_func :sp_CheckCollisionPointTriangle, [:ptr, :ptr, :ptr, :ptr], :bool
  ffi_func :sp_CheckCollisionPointLine, [:ptr, :ptr, :ptr, :int], :bool
  ffi_func :sp_CheckCollisionPointPoly, [:ptr, :ptr, :int], :bool
  ffi_func :sp_CheckCollisionLines, [:ptr, :ptr, :ptr, :ptr, :ptr], :bool
  ffi_func :sp_GetCollisionRec, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_LoadImage, [:str], :ptr
  ffi_func :sp_LoadImageRaw, [:str, :int, :int, :int, :int], :ptr
  ffi_func :sp_LoadImageAnim, [:str, :ptr], :ptr
  ffi_func :sp_LoadImageAnimFromMemory, [:str, :ptr, :int, :ptr], :ptr
  ffi_func :sp_LoadImageFromMemory, [:str, :ptr, :int], :ptr
  ffi_func :sp_LoadImageFromTexture, [:ptr], :ptr
  ffi_func :sp_LoadImageFromScreen, [], :ptr
  ffi_func :sp_IsImageValid, [:ptr], :bool
  ffi_func :sp_UnloadImage, [:ptr], :void
  ffi_func :sp_ExportImage, [:ptr, :str], :bool
  ffi_func :sp_ExportImageToMemory, [:ptr, :str, :ptr], :ptr
  ffi_func :sp_ExportImageAsCode, [:ptr, :str], :bool
  ffi_func :sp_GenImageColor, [:int, :int, :ptr], :ptr
  ffi_func :sp_GenImageGradientLinear, [:int, :int, :int, :ptr, :ptr], :ptr
  ffi_func :sp_GenImageGradientRadial, [:int, :int, :float, :ptr, :ptr], :ptr
  ffi_func :sp_GenImageGradientSquare, [:int, :int, :float, :ptr, :ptr], :ptr
  ffi_func :sp_GenImageChecked, [:int, :int, :int, :int, :ptr, :ptr], :ptr
  ffi_func :sp_GenImageWhiteNoise, [:int, :int, :float], :ptr
  ffi_func :sp_GenImagePerlinNoise, [:int, :int, :int, :int, :float], :ptr
  ffi_func :sp_GenImageCellular, [:int, :int, :int], :ptr
  ffi_func :sp_GenImageText, [:int, :int, :str], :ptr
  ffi_func :sp_ImageCopy, [:ptr], :ptr
  ffi_func :sp_ImageFromImage, [:ptr, :ptr], :ptr
  ffi_func :sp_ImageFromChannel, [:ptr, :int], :ptr
  ffi_func :sp_ImageText, [:str, :int, :ptr], :ptr
  ffi_func :sp_ImageTextEx, [:ptr, :str, :float, :float, :ptr], :ptr
  ffi_func :ImageFormat, [:ptr, :int], :void
  ffi_func :sp_ImageToPOT, [:ptr, :ptr], :void
  ffi_func :sp_ImageCrop, [:ptr, :ptr], :void
  ffi_func :ImageAlphaCrop, [:ptr, :float], :void
  ffi_func :sp_ImageAlphaClear, [:ptr, :ptr, :float], :void
  ffi_func :sp_ImageAlphaMask, [:ptr, :ptr], :void
  ffi_func :ImageAlphaPremultiply, [:ptr], :void
  ffi_func :ImageBlurGaussian, [:ptr, :int], :void
  ffi_func :ImageKernelConvolution, [:ptr, :ptr, :int], :void
  ffi_func :ImageResize, [:ptr, :int, :int], :void
  ffi_func :ImageResizeNN, [:ptr, :int, :int], :void
  ffi_func :sp_ImageResizeCanvas, [:ptr, :int, :int, :int, :int, :ptr], :void
  ffi_func :ImageMipmaps, [:ptr], :void
  ffi_func :ImageDither, [:ptr, :int, :int, :int, :int], :void
  ffi_func :ImageFlipVertical, [:ptr], :void
  ffi_func :ImageFlipHorizontal, [:ptr], :void
  ffi_func :ImageRotate, [:ptr, :int], :void
  ffi_func :ImageRotateCW, [:ptr], :void
  ffi_func :ImageRotateCCW, [:ptr], :void
  ffi_func :sp_ImageColorTint, [:ptr, :ptr], :void
  ffi_func :ImageColorInvert, [:ptr], :void
  ffi_func :ImageColorGrayscale, [:ptr], :void
  ffi_func :ImageColorContrast, [:ptr, :int], :void
  ffi_func :ImageColorBrightness, [:ptr, :int], :void
  ffi_func :sp_ImageColorReplace, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_LoadImageColors, [:ptr], :ptr
  ffi_func :sp_LoadImagePalette, [:ptr, :int, :ptr], :ptr
  ffi_func :sp_UnloadImageColors, [:ptr], :void
  ffi_func :sp_UnloadImagePalette, [:ptr], :void
  ffi_func :sp_GetImageAlphaBorder, [:ptr, :float, :ptr], :void
  ffi_func :sp_GetImageColor, [:ptr, :int, :int, :ptr], :void
  ffi_func :sp_ImageClearBackground, [:ptr, :ptr], :void
  ffi_func :sp_ImageDrawPixel, [:ptr, :int, :int, :ptr], :void
  ffi_func :sp_ImageDrawPixelV, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_ImageDrawLine, [:ptr, :int, :int, :int, :int, :ptr], :void
  ffi_func :sp_ImageDrawLineV, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_ImageDrawLineEx, [:ptr, :ptr, :ptr, :int, :ptr], :void
  ffi_func :sp_ImageDrawLineStrip, [:ptr, :ptr, :int, :ptr], :void
  ffi_func :sp_ImageDrawTriangle, [:ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_ImageDrawTriangleGradient, [:ptr, :ptr, :ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_ImageDrawTriangleLines, [:ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_ImageDrawTriangleFan, [:ptr, :ptr, :int, :ptr], :void
  ffi_func :sp_ImageDrawTriangleStrip, [:ptr, :ptr, :int, :ptr], :void
  ffi_func :sp_ImageDrawRectangle, [:ptr, :int, :int, :int, :int, :ptr], :void
  ffi_func :sp_ImageDrawRectangleV, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_ImageDrawRectangleRec, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_ImageDrawRectanglePro, [:ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_ImageDrawRectangleLines, [:ptr, :int, :int, :int, :int, :ptr], :void
  ffi_func :sp_ImageDrawRectangleLinesEx, [:ptr, :ptr, :int, :ptr], :void
  ffi_func :sp_ImageDrawRectangleGradientEx, [:ptr, :ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_ImageDrawCircle, [:ptr, :int, :int, :int, :ptr], :void
  ffi_func :sp_ImageDrawCircleV, [:ptr, :ptr, :int, :ptr], :void
  ffi_func :sp_ImageDrawCircleLines, [:ptr, :int, :int, :int, :ptr], :void
  ffi_func :sp_ImageDrawCircleLinesV, [:ptr, :ptr, :int, :ptr], :void
  ffi_func :sp_ImageDrawCircleGradient, [:ptr, :ptr, :float, :ptr, :ptr], :void
  ffi_func :sp_ImageDrawImage, [:ptr, :ptr, :int, :int, :ptr], :void
  ffi_func :sp_ImageDrawImageEx, [:ptr, :ptr, :ptr, :float, :float, :ptr], :void
  ffi_func :sp_ImageDrawImageRec, [:ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_ImageDrawImagePro, [:ptr, :ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_ImageDrawText, [:ptr, :str, :int, :int, :int, :ptr], :void
  ffi_func :sp_ImageDrawTextEx, [:ptr, :ptr, :str, :ptr, :float, :float, :ptr], :void
  ffi_func :sp_ImageDrawTextPro, [:ptr, :ptr, :str, :ptr, :ptr, :float, :float, :float, :ptr], :void
  ffi_func :sp_LoadTextureFromImage, [:ptr], :ptr
  ffi_func :sp_LoadTextureCubemap, [:ptr, :int], :ptr
  ffi_func :sp_LoadRenderTexture, [:int, :int], :ptr
  ffi_func :sp_LoadRenderTextureEx, [:int, :int, :int], :ptr
  ffi_func :sp_IsTextureValid, [:ptr], :bool
  ffi_func :sp_IsRenderTextureValid, [:ptr], :bool
  ffi_func :sp_UnloadRenderTexture, [:ptr], :void
  ffi_func :sp_UpdateTexture, [:ptr, :ptr], :void
  ffi_func :sp_UpdateTextureRec, [:ptr, :ptr, :ptr], :void
  ffi_func :GenTextureMipmaps, [:ptr], :void
  ffi_func :sp_SetTextureFilter, [:ptr, :int], :void
  ffi_func :sp_SetTextureWrap, [:ptr, :int], :void
  ffi_func :sp_DrawTextureV, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_DrawTextureRec, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_DrawTexturePro, [:ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_DrawTextureNPatch, [:ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_ColorIsEqual, [:ptr, :ptr], :bool
  ffi_func :sp_Fade, [:ptr, :float, :ptr], :void
  ffi_func :sp_ColorToInt, [:ptr], :int
  ffi_func :sp_ColorNormalize, [:ptr, :ptr], :void
  ffi_func :sp_ColorFromNormalized, [:ptr, :ptr], :void
  ffi_func :sp_ColorToHSV, [:ptr, :ptr], :void
  ffi_func :sp_ColorFromHSV, [:float, :float, :float, :ptr], :void
  ffi_func :sp_ColorTint, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_ColorBrightness, [:ptr, :float, :ptr], :void
  ffi_func :sp_ColorContrast, [:ptr, :float, :ptr], :void
  ffi_func :sp_ColorAlpha, [:ptr, :float, :ptr], :void
  ffi_func :sp_ColorAlphaBlend, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_ColorLerp, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_GetColor, [:uint, :ptr], :void
  ffi_func :sp_GetPixelColor, [:ptr, :int, :ptr], :void
  ffi_func :sp_SetPixelColor, [:ptr, :ptr, :int], :void
  ffi_func :GetPixelDataSize, [:int, :int, :int], :int
  ffi_func :sp_GetFontDefault, [], :ptr
  ffi_func :sp_FontBaseSize, [:ptr], :float
  ffi_func :sp_DirListCount, [:ptr], :int
  ffi_func :sp_DirListName, %i[ptr int], :str
  ffi_func :sp_AudioStreamSineReset, [], :void
  ffi_func :sp_UpdateAudioStreamSine, %i[ptr int float float int], :void
  ffi_func :sp_FontTexture, [:ptr], :ptr
  ffi_func :sp_FontGlyphAdvanceX, [:ptr, :int], :int
  ffi_func :sp_FontGlyphRecWidth, [:ptr, :int], :float
  ffi_func :sp_LoadFontAtlas, %i[str int int int int int int], :ptr
  ffi_func :sp_DrawRectangleLinesExF, %i[float float float float float ptr], :void
  ffi_func :sp_CheckCollisionPointRecF, %i[ptr float float float float], :bool
  ffi_func :sp_Model_material, [:ptr, :int], :ptr
  ffi_func :sp_Model_transform, [:ptr, :ptr], :void
  ffi_func :sp_Model_set_transform, [:ptr, :ptr], :void
  ffi_func :sp_Model_mesh, [:ptr, :int], :ptr
  ffi_func :sp_Model_meshCount, [:ptr], :int
  ffi_func :sp_ModelAnimationAt, [:ptr, :int], :ptr
  ffi_func :sp_ModelAnimation_frameCount, [:ptr], :int
  ffi_func :sp_Model_boneCount, [:ptr], :int
  ffi_func :sp_Model_boneParent, [:ptr, :int], :int
  ffi_func :sp_Model_bindPoseTranslation, [:ptr, :int, :ptr], :void
  ffi_func :sp_ModelAnimation_framePoseTranslation, [:ptr, :int, :int, :ptr], :void
  ffi_func :sp_LoadShaderFS, [:str], :ptr
  ffi_func :sp_SetShaderValueFloat, [:ptr, :int, :float, :int], :void
  ffi_func :sp_SetShaderValueVec2, [:ptr, :int, :float, :float, :int], :void
  ffi_func :sp_SetShaderValueVec3, [:ptr, :int, :float, :float, :float, :int], :void
  ffi_func :sp_SetShaderValueVec4, [:ptr, :int, :float, :float, :float, :float, :int], :void
  ffi_func :sp_SetShaderValueInt, [:ptr, :int, :int, :int], :void
  ffi_func :sp_SetShaderValueColor, [:ptr, :int, :ptr, :int], :void
  ffi_func :sp_Shader_setLoc, [:ptr, :int, :int], :void
  ffi_func :sp_Material_set_shader, [:ptr, :ptr], :void
  # Diffuse texture poke: Material.maps[] is embedded in the Material struct,
  # so Ruby cannot reach maps[MAP_DIFFUSE].texture. Both return 1 on success,
  # 0 on a NULL / out-of-range handle.
  ffi_func :sp_Material_set_diffuse, [:ptr, :ptr], :int
  ffi_func :sp_ModelSetDiffuseTexture, %i[ptr int ptr], :int
  ffi_func :sp_RayCollision_point, [:ptr, :ptr], :void
  ffi_func :sp_RayCollision_normal, [:ptr, :ptr], :void
  ffi_func :sp_Camera_position_x, [:ptr], :float
  ffi_func :sp_Camera_position_y, [:ptr], :float
  ffi_func :sp_Camera_position_z, [:ptr], :float
  ffi_func :sp_Camera_target_x, [:ptr], :float
  ffi_func :sp_Camera_target_y, [:ptr], :float
  ffi_func :sp_Camera_target_z, [:ptr], :float
  ffi_func :sp_ImageColorR, [:ptr, :int], :int
  ffi_func :sp_CheckCollisionCircleRecF, %i[ptr float float float float float], :bool
  # CheckCollisionBoxes from 12 raw floats, bypassing native BoundingBox/Vector3
  # construction (single-TU cls_id mismatch; see AGENTS.md section A). Arg order
  # is (min x,y,z, max x,y,z) for box 1 then box 2.
  ffi_func :sp_CheckCollisionBoxesF,
           %i[float float float float float float float float float float float float],
           :bool
  ffi_func :sp_MatrixRotateXYZ, [:ptr, :ptr], :void
  ffi_func :sp_IntAlloc, [], :ptr
  ffi_func :sp_IntGet, [:ptr], :int
  ffi_func :sp_IntFree, [:ptr], :void
  ffi_func :sp_ImageWidth, [:ptr], :int
  ffi_func :sp_ImageHeight, [:ptr], :int
  ffi_func :sp_ImageFrameData, [:ptr, :int], :ptr
  ffi_func :sp_Camera_position_from_bounds, %i[ptr ptr float], :void
  ffi_func :sp_RenderTexture_texture, [:ptr], :ptr
  ffi_func :sp_TextureWidth, [:ptr], :int
  ffi_func :sp_TextureHeight, [:ptr], :int
  ffi_func :sp_ImageFromImageF, %i[ptr float float float float], :ptr
  ffi_func :sp_DrawRectangleProF, %i[float float float float float float float ptr], :void
  ffi_func :sp_DrawRectangleRoundedF, %i[float float float float float int ptr], :void
  ffi_func :sp_DrawRectangleRoundedLinesExF, %i[float float float float float int float ptr], :void
  ffi_func :sp_DrawTextureRecF, %i[ptr float float float float float float ptr], :void
  ffi_func :sp_DrawTextureProF, %i[ptr float float float float float float float float float float float ptr], :void
  ffi_func :sp_DrawTextureRec4, %i[ptr float float float float ptr ptr], :void
  ffi_func :sp_BeginMode2DF, %i[float float float float float float], :void
  ffi_func :sp_DrawRectangleRecF, %i[float float float float ptr], :void
  ffi_func :sp_Camera3DCreate, %i[float float float float float float float float float float int], :ptr
  ffi_func :sp_EndMode3D, [], :void
  ffi_func :sp_DrawGrid, [:int, :float], :void
  ffi_func :sp_DrawRenderTexture, [:ptr, :ptr], :void
  ffi_func :sp_DrawRenderTextureAt, [:ptr, :int, :int, :ptr], :void
  ffi_func :sp_DrawRenderTexturePro, %i[ptr float ptr], :void
  ffi_func :sp_LoadImageFromRenderTexture, [:ptr], :ptr
  def self.SaveRenderTextureImage(target, path)
    image = Raylib.sp_LoadImageFromRenderTexture(target)
    Raylib.ImageFlipVertical(image)
    Raylib.sp_ExportImage(image, path)
    Raylib.sp_UnloadImage(image)
  end
  ffi_func :sp_LoadFont, [:str], :ptr
  ffi_func :sp_LoadFontEx, [:str, :int, :ptr, :int], :ptr
  ffi_func :sp_LoadFontFromImage, [:ptr, :ptr, :int], :ptr
  ffi_func :sp_LoadFontFromMemory, [:str, :ptr, :int, :int, :ptr, :int], :ptr
  ffi_func :sp_IsFontValid, [:ptr], :bool
  ffi_func :LoadFontData, [:ptr, :int, :int, :ptr, :int, :int, :ptr], :ptr
  ffi_func :sp_GenImageFontAtlas, [:ptr, :ptr, :int, :int, :int, :int], :ptr
  ffi_func :UnloadFontData, [:ptr, :int], :void
  ffi_func :sp_UnloadFont, [:ptr], :void
  ffi_func :sp_ExportFontAsCode, [:ptr, :str], :bool
  ffi_func :sp_DrawTextEx, [:ptr, :str, :ptr, :float, :float, :ptr], :void
  ffi_func :sp_DrawTextPro, [:ptr, :str, :ptr, :ptr, :float, :float, :float, :ptr], :void
  ffi_func :sp_DrawTextCodepoint, [:ptr, :int, :ptr, :float, :ptr], :void
  ffi_func :sp_DrawTextCodepoints, [:ptr, :ptr, :int, :ptr, :float, :float, :ptr], :void
  ffi_func :SetTextLineSpacing, [:int], :void
  ffi_func :MeasureText, [:str, :int], :int
  ffi_func :sp_MeasureTextEx, [:ptr, :str, :float, :float, :ptr], :void
  ffi_func :sp_MeasureTextCodepoints, [:ptr, :ptr, :int, :float, :float, :ptr], :void
  ffi_func :sp_GetGlyphIndex, [:ptr, :int], :int
  ffi_func :sp_GetGlyphInfo, [:ptr, :int], :ptr
  ffi_func :sp_GetGlyphAtlasRec, [:ptr, :int, :ptr], :void
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
  ffi_func :sp_DrawLine3D, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_DrawPoint3D, [:ptr, :ptr], :void
  ffi_func :sp_DrawCircle3D, [:ptr, :float, :ptr, :float, :ptr], :void
  ffi_func :sp_DrawTriangle3D, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_DrawTriangleStrip3D, [:ptr, :int, :ptr], :void
  ffi_func :sp_DrawCubeV, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_DrawCubeWiresV, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_DrawSphere, [:ptr, :float, :ptr], :void
  ffi_func :sp_DrawSphereEx, [:ptr, :float, :int, :int, :ptr], :void
  ffi_func :sp_DrawSphereWires, [:ptr, :float, :int, :int, :ptr], :void
  ffi_func :sp_DrawCylinder, [:ptr, :float, :float, :float, :int, :ptr], :void
  ffi_func :sp_DrawCylinderEx, [:ptr, :ptr, :float, :float, :int, :ptr], :void
  ffi_func :sp_DrawCylinderWires, [:ptr, :float, :float, :float, :int, :ptr], :void
  ffi_func :sp_DrawCylinderWiresEx, [:ptr, :ptr, :float, :float, :int, :ptr], :void
  ffi_func :sp_DrawCapsule, [:ptr, :ptr, :float, :int, :int, :ptr], :void
  ffi_func :sp_DrawCapsuleWires, [:ptr, :ptr, :float, :int, :int, :ptr], :void
  ffi_func :sp_DrawRay, [:ptr, :ptr], :void
  ffi_func :DrawGrid, [:int, :float], :void
  ffi_func :sp_LoadModel, [:str], :ptr
  ffi_func :sp_LoadModelFromMesh, [:ptr], :ptr
  ffi_func :sp_IsModelValid, [:ptr], :bool
  ffi_func :sp_UnloadModel, [:ptr], :void
  ffi_func :sp_GetModelBoundingBox, [:ptr, :ptr], :void
  ffi_func :sp_DrawModel, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_DrawModelEx, [:ptr, :ptr, :ptr, :float, :ptr, :ptr], :void
  ffi_func :sp_DrawModelWires, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_DrawModelWiresEx, [:ptr, :ptr, :ptr, :float, :ptr, :ptr], :void
  ffi_func :sp_DrawBoundingBox, [:ptr, :ptr], :void
  ffi_func :sp_DrawBillboard, [:ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_DrawBillboardRec, [:ptr, :ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_DrawBillboardPro, [:ptr, :ptr, :ptr, :ptr, :ptr, :ptr, :ptr, :float, :ptr], :void
  ffi_func :UploadMesh, [:ptr, :bool], :void
  ffi_func :sp_UpdateMeshBuffer, [:ptr, :int, :ptr, :int, :int], :void
  ffi_func :sp_UnloadMesh, [:ptr], :void
  ffi_func :sp_DrawMesh, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_DrawMeshInstanced, [:ptr, :ptr, :ptr, :int], :void
  ffi_func :sp_GetMeshBoundingBox, [:ptr, :ptr], :void
  ffi_func :GenMeshTangents, [:ptr], :void
  ffi_func :sp_ExportMesh, [:ptr, :str], :bool
  ffi_func :sp_ExportMeshAsCode, [:ptr, :str], :bool
  ffi_func :sp_GenMeshPoly, [:int, :float], :ptr
  ffi_func :sp_GenMeshPlane, [:float, :float, :int, :int], :ptr
  ffi_func :sp_GenMeshCube, [:float, :float, :float], :ptr
  ffi_func :sp_GenMeshSphere, [:float, :int, :int], :ptr
  ffi_func :sp_GenMeshHemiSphere, [:float, :int, :int], :ptr
  ffi_func :sp_GenMeshCylinder, [:float, :float, :int], :ptr
  ffi_func :sp_GenMeshCone, [:float, :float, :int], :ptr
  ffi_func :sp_GenMeshTorus, [:float, :float, :int, :int], :ptr
  ffi_func :sp_GenMeshKnot, [:float, :float, :int, :int], :ptr
  ffi_func :sp_GenMeshHeightmap, [:ptr, :ptr], :ptr
  ffi_func :sp_GenMeshCubicmap, [:ptr, :ptr], :ptr
  ffi_func :LoadMaterials, [:str, :ptr], :ptr
  ffi_func :sp_LoadMaterialDefault, [], :ptr
  ffi_func :sp_IsMaterialValid, [:ptr], :bool
  ffi_func :sp_UnloadMaterial, [:ptr], :void
  ffi_func :sp_SetMaterialTexture, [:ptr, :int, :ptr], :void
  ffi_func :SetModelMeshMaterial, [:ptr, :int, :int], :void
  ffi_func :LoadModelAnimations, [:str, :ptr], :ptr
  ffi_func :sp_UpdateModelAnimation, [:ptr, :ptr, :float], :void
  ffi_func :sp_UpdateModelAnimationEx, [:ptr, :ptr, :float, :ptr, :float, :float], :void
  ffi_func :UnloadModelAnimations, [:ptr, :int], :void
  ffi_func :sp_IsModelAnimationValid, [:ptr, :ptr], :bool
  ffi_func :sp_CheckCollisionSpheres, [:ptr, :float, :ptr, :float], :bool
  ffi_func :sp_CheckCollisionBoxes, [:ptr, :ptr], :bool
  ffi_func :sp_CheckCollisionBoxSphere, [:ptr, :ptr, :float], :bool
  ffi_func :sp_GetRayCollisionSphere, [:ptr, :ptr, :float, :ptr], :void
  ffi_func :sp_GetRayCollisionBox, [:ptr, :ptr, :ptr], :void
  ffi_func :sp_GetRayCollisionMesh, [:ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_GetRayCollisionTriangle, [:ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :sp_GetRayCollisionQuad, [:ptr, :ptr, :ptr, :ptr, :ptr, :ptr], :void
  ffi_func :InitAudioDevice, [], :void
  ffi_func :CloseAudioDevice, [], :void
  ffi_func :IsAudioDeviceReady, [], :bool
  ffi_func :SetMasterVolume, [:float], :void
  ffi_func :GetMasterVolume, [], :float
  ffi_func :sp_LoadWave, [:str], :ptr
  ffi_func :sp_LoadWaveFromMemory, [:str, :ptr, :int], :ptr
  ffi_func :sp_IsWaveValid, [:ptr], :bool
  ffi_func :sp_LoadSound, [:str], :ptr
  ffi_func :sp_LoadSoundFromWave, [:ptr], :ptr
  ffi_func :sp_LoadSoundAlias, [:ptr], :ptr
  ffi_func :sp_IsSoundValid, [:ptr], :bool
  ffi_func :sp_UpdateSound, [:ptr, :ptr, :int], :void
  ffi_func :sp_UnloadWave, [:ptr], :void
  ffi_func :sp_UnloadSound, [:ptr], :void
  ffi_func :sp_UnloadSoundAlias, [:ptr], :void
  ffi_func :sp_ExportWave, [:ptr, :str], :bool
  ffi_func :sp_ExportWaveAsCode, [:ptr, :str], :bool
  ffi_func :sp_PlaySound, [:ptr], :void
  ffi_func :sp_StopSound, [:ptr], :void
  ffi_func :sp_PauseSound, [:ptr], :void
  ffi_func :sp_ResumeSound, [:ptr], :void
  ffi_func :sp_IsSoundPlaying, [:ptr], :bool
  ffi_func :sp_SetSoundVolume, [:ptr, :float], :void
  ffi_func :sp_SetSoundPitch, [:ptr, :float], :void
  ffi_func :sp_SetSoundPan, [:ptr, :float], :void
  ffi_func :sp_WaveCopy, [:ptr], :ptr
  ffi_func :WaveCrop, [:ptr, :int, :int], :void
  ffi_func :WaveFormat, [:ptr, :int, :int, :int], :void
  ffi_func :sp_LoadWaveSamples, [:ptr], :ptr
  ffi_func :UnloadWaveSamples, [:ptr], :void
  ffi_func :sp_LoadMusicStream, [:str], :ptr
  ffi_func :sp_LoadMusicStreamFromMemory, [:str, :ptr, :int], :ptr
  ffi_func :sp_IsMusicValid, [:ptr], :bool
  ffi_func :sp_UnloadMusicStream, [:ptr], :void
  ffi_func :sp_PlayMusicStream, [:ptr], :void
  ffi_func :sp_IsMusicStreamPlaying, [:ptr], :bool
  ffi_func :sp_UpdateMusicStream, [:ptr], :void
  ffi_func :sp_StopMusicStream, [:ptr], :void
  ffi_func :sp_PauseMusicStream, [:ptr], :void
  ffi_func :sp_ResumeMusicStream, [:ptr], :void
  ffi_func :sp_SeekMusicStream, [:ptr, :float], :void
  ffi_func :sp_SetMusicVolume, [:ptr, :float], :void
  ffi_func :sp_SetMusicPitch, [:ptr, :float], :void
  ffi_func :sp_SetMusicPan, [:ptr, :float], :void
  ffi_func :sp_GetMusicTimeLength, [:ptr], :float
  ffi_func :sp_GetMusicTimePlayed, [:ptr], :float
  ffi_func :sp_LoadAudioStream, [:uint, :uint, :uint], :ptr
  ffi_func :sp_IsAudioStreamValid, [:ptr], :bool
  ffi_func :sp_UnloadAudioStream, [:ptr], :void
  ffi_func :sp_UpdateAudioStream, [:ptr, :str, :int], :void
  ffi_func :sp_IsAudioStreamProcessed, [:ptr], :bool
  ffi_func :sp_PlayAudioStream, [:ptr], :void
  ffi_func :sp_PauseAudioStream, [:ptr], :void
  ffi_func :sp_ResumeAudioStream, [:ptr], :void
  ffi_func :sp_IsAudioStreamPlaying, [:ptr], :bool
  ffi_func :sp_StopAudioStream, [:ptr], :void
  ffi_func :sp_SetAudioStreamVolume, [:ptr, :float], :void
  ffi_func :sp_SetAudioStreamPitch, [:ptr, :float], :void
  ffi_func :sp_SetAudioStreamPan, [:ptr, :float], :void
  ffi_func :SetAudioStreamBufferSizeDefault, [:int], :void
  ffi_func :sp_SetAudioStreamCallback, [:ptr, :ptr], :void
  ffi_func :sp_AttachAudioStreamProcessor, [:ptr, :ptr], :void
  ffi_func :sp_DetachAudioStreamProcessor, [:ptr, :ptr], :void
  ffi_func :sp_AttachAudioMixedProcessor, [:ptr], :void
  ffi_func :sp_DetachAudioMixedProcessor, [:ptr], :void
  native_struct "Vector4", "sp_Vector4"
  native_new [], "sp_Vector4_new"
  native_method :x, [], :float, "sp_Vector4_x"
  native_method :x=, [:float], :float, "sp_Vector4_set_x"
  native_method :y, [], :float, "sp_Vector4_y"
  native_method :y=, [:float], :float, "sp_Vector4_set_y"
  native_method :z, [], :float, "sp_Vector4_z"
  native_method :z=, [:float], :float, "sp_Vector4_set_z"
  native_method :w, [], :float, "sp_Vector4_w"
  native_method :w=, [:float], :float, "sp_Vector4_set_w"
  native_struct "Rectangle", "sp_Rectangle"
  native_new [], "sp_Rectangle_new"
  native_method :x, [], :float, "sp_Rectangle_x"
  native_method :x=, [:float], :float, "sp_Rectangle_set_x"
  native_method :y, [], :float, "sp_Rectangle_y"
  native_method :y=, [:float], :float, "sp_Rectangle_set_y"
  native_method :width, [], :float, "sp_Rectangle_width"
  native_method :width=, [:float], :float, "sp_Rectangle_set_width"
  native_method :height, [], :float, "sp_Rectangle_height"
  native_method :height=, [:float], :float, "sp_Rectangle_set_height"
  native_struct "Camera2D", "sp_Camera2D"
  native_new [], "sp_Camera2D_new"
  native_method :rotation, [], :float, "sp_Camera2D_rotation"
  native_method :rotation=, [:float], :float, "sp_Camera2D_set_rotation"
  native_method :zoom, [], :float, "sp_Camera2D_zoom"
  native_method :zoom=, [:float], :float, "sp_Camera2D_set_zoom"
  native_struct "BoundingBox", "sp_BoundingBox"
  native_new [], "sp_BoundingBox_new"
  native_method :with_min, %i[float float float], :self, "sp_BoundingBox_with_min"
  native_method :with_max, %i[float float float], :self, "sp_BoundingBox_with_max"
  native_struct "Ray", "sp_Ray"
  native_new [], "sp_Ray_new"
  native_struct "RayCollision", "sp_RayCollision"
  native_new [], "sp_RayCollision_new"
  native_method :hit, [], :int, "sp_RayCollision_hit"
  native_method :hit=, [:int], :int, "sp_RayCollision_set_hit"
  native_method :distance, [], :float, "sp_RayCollision_distance"
  native_method :distance=, [:float], :float, "sp_RayCollision_set_distance"
  native_struct "Matrix", "sp_Matrix"
  native_new [], "sp_Matrix_new"
  native_method :m0, [], :float, "sp_Matrix_m0"
  native_method :m0=, [:float], :float, "sp_Matrix_set_m0"
  native_method :m4, [], :float, "sp_Matrix_m4"
  native_method :m4=, [:float], :float, "sp_Matrix_set_m4"
  native_method :m8, [], :float, "sp_Matrix_m8"
  native_method :m8=, [:float], :float, "sp_Matrix_set_m8"
  native_method :m12, [], :float, "sp_Matrix_m12"
  native_method :m12=, [:float], :float, "sp_Matrix_set_m12"
  native_method :m1, [], :float, "sp_Matrix_m1"
  native_method :m1=, [:float], :float, "sp_Matrix_set_m1"
  native_method :m5, [], :float, "sp_Matrix_m5"
  native_method :m5=, [:float], :float, "sp_Matrix_set_m5"
  native_method :m9, [], :float, "sp_Matrix_m9"
  native_method :m9=, [:float], :float, "sp_Matrix_set_m9"
  native_method :m13, [], :float, "sp_Matrix_m13"
  native_method :m13=, [:float], :float, "sp_Matrix_set_m13"
  native_method :m2, [], :float, "sp_Matrix_m2"
  native_method :m2=, [:float], :float, "sp_Matrix_set_m2"
  native_method :m6, [], :float, "sp_Matrix_m6"
  native_method :m6=, [:float], :float, "sp_Matrix_set_m6"
  native_method :m10, [], :float, "sp_Matrix_m10"
  native_method :m10=, [:float], :float, "sp_Matrix_set_m10"
  native_method :m14, [], :float, "sp_Matrix_m14"
  native_method :m14=, [:float], :float, "sp_Matrix_set_m14"
  native_method :m3, [], :float, "sp_Matrix_m3"
  native_method :m3=, [:float], :float, "sp_Matrix_set_m3"
  native_method :m7, [], :float, "sp_Matrix_m7"
  native_method :m7=, [:float], :float, "sp_Matrix_set_m7"
  native_method :m11, [], :float, "sp_Matrix_m11"
  native_method :m11=, [:float], :float, "sp_Matrix_set_m11"
  native_method :m15, [], :float, "sp_Matrix_m15"
  native_method :m15=, [:float], :float, "sp_Matrix_set_m15"
  native_struct "NPatchInfo", "sp_NPatchInfo"
  native_new [], "sp_NPatchInfo_new"
  native_method :left, [], :int, "sp_NPatchInfo_left"
  native_method :left=, [:int], :int, "sp_NPatchInfo_set_left"
  native_method :top, [], :int, "sp_NPatchInfo_top"
  native_method :top=, [:int], :int, "sp_NPatchInfo_set_top"
  native_method :right, [], :int, "sp_NPatchInfo_right"
  native_method :right=, [:int], :int, "sp_NPatchInfo_set_right"
  native_method :bottom, [], :int, "sp_NPatchInfo_bottom"
  native_method :bottom=, [:int], :int, "sp_NPatchInfo_set_bottom"
  native_method :layout, [], :int, "sp_NPatchInfo_layout"
  native_method :layout=, [:int], :int, "sp_NPatchInfo_set_layout"
  native_struct "VrDeviceInfo", "sp_VrDeviceInfo"
  native_new [], "sp_VrDeviceInfo_new"
  native_method :hResolution, [], :int, "sp_VrDeviceInfo_hResolution"
  native_method :hResolution=, [:int], :int, "sp_VrDeviceInfo_set_hResolution"
  native_method :vResolution, [], :int, "sp_VrDeviceInfo_vResolution"
  native_method :vResolution=, [:int], :int, "sp_VrDeviceInfo_set_vResolution"
  native_method :hScreenSize, [], :float, "sp_VrDeviceInfo_hScreenSize"
  native_method :hScreenSize=, [:float], :float, "sp_VrDeviceInfo_set_hScreenSize"
  native_method :vScreenSize, [], :float, "sp_VrDeviceInfo_vScreenSize"
  native_method :vScreenSize=, [:float], :float, "sp_VrDeviceInfo_set_vScreenSize"
  native_method :eyeToScreenDistance, [], :float, "sp_VrDeviceInfo_eyeToScreenDistance"
  native_method :eyeToScreenDistance=, [:float], :float, "sp_VrDeviceInfo_set_eyeToScreenDistance"
  native_method :lensSeparationDistance, [], :float, "sp_VrDeviceInfo_lensSeparationDistance"
  native_method :lensSeparationDistance=, [:float], :float, "sp_VrDeviceInfo_set_lensSeparationDistance"
  native_method :interpupillaryDistance, [], :float, "sp_VrDeviceInfo_interpupillaryDistance"
  native_method :interpupillaryDistance=, [:float], :float, "sp_VrDeviceInfo_set_interpupillaryDistance"
  native_struct "VrStereoConfig", "sp_VrStereoConfig"
  native_new [], "sp_VrStereoConfig_new"
  native_struct "FilePathList", "sp_FilePathList"
  native_new [], "sp_FilePathList_new"
  native_method :count, [], :int, "sp_FilePathList_count"
  native_method :count=, [:int], :int, "sp_FilePathList_set_count"
  native_method :path, [:int], :str, "sp_FilePathList_path"
  native_struct "AutomationEvent", "sp_AutomationEvent"
  native_new [], "sp_AutomationEvent_new"
  native_method :frame, [], :int, "sp_AutomationEvent_frame"
  native_method :frame=, [:int], :int, "sp_AutomationEvent_set_frame"
  native_method :type, [], :int, "sp_AutomationEvent_type"
  native_method :type=, [:int], :int, "sp_AutomationEvent_set_type"
  native_struct "AutomationEventList", "sp_AutomationEventList"
  native_new [], "sp_AutomationEventList_new"
  native_method :capacity, [], :int, "sp_AutomationEventList_capacity"
  native_method :capacity=, [:int], :int, "sp_AutomationEventList_set_capacity"
  native_method :count, [], :int, "sp_AutomationEventList_count"
  native_method :count=, [:int], :int, "sp_AutomationEventList_set_count"
  native_struct "Vector2", "sp_Vector2"
  native_new [], "sp_Vector2_new"
  native_method :x, [], :float, "sp_Vector2_x"
  native_method :x=, [:float], :float, "sp_Vector2_set_x"
  native_method :y, [], :float, "sp_Vector2_y"
  native_method :y=, [:float], :float, "sp_Vector2_set_y"

  # Window
  ffi_func :InitWindow, %i[int int str], :void
  ffi_func :CloseWindow, [], :void
  # Bool-returning raylib functions go through sp_ shims (see
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
  native_method :r, [], :int, "sp_Color_r"
  native_method :g, [], :int, "sp_Color_g"
  native_method :b, [], :int, "sp_Color_b"
  native_method :a, [], :int, "sp_Color_a"

  # Texture (opaque pointer — sp_LoadTexture mallocs Texture2D)
  ffi_func :sp_LoadTexture, [:str], :ptr
  ffi_func :sp_DrawTexture, %i[ptr int int ptr], :void
  # Tint passed as a packed 0xRRGGBBAA int (data-oriented sprite pools).
  ffi_func :sp_DrawTexturePacked, %i[ptr int int int], :void
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
  # Color passed as a packed 0xRRGGBBAA int (data-oriented particle pools).
  ffi_func :sp_DrawPixelPacked, %i[int int int], :void
  # Batch-draw a whole pool in one call: parallel x/y FloatArrays and a packed
  # color IntArray (passed as their flat data pointers by the FFI).
  ffi_func :sp_DrawPixelsPacked, %i[float_array float_array int_array int], :void

  # Vector3 — native GC object (mirrors Color). Passed to the 3D shims as its
  # pointer; field-read with .x/.y/.z.
  native_struct "Vector3", "sp_Vector3"
  native_new [:float, :float, :float], "sp_Vector3_new"
  native_method :x, [], :float, "sp_Vector3_x"
  native_method :y, [], :float, "sp_Vector3_y"
  native_method :z, [], :float, "sp_Vector3_z"

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

    def self.DrawPixelPacked(x, y, rgba)
      Raylib.sp_DrawPixelPacked(x, y, rgba)
    end

    def self.DrawPixelsPacked(xs, ys, colors, count)
      Raylib.sp_DrawPixelsPacked(xs, ys, colors, count)
    end

    def self.DrawPixel(x, y, color)
      Raylib.sp_DrawPixel(x, y, color)
    end

    # Predicate wrappers return true/false in both backends: the gem
    # binds raylib's bool directly; here spinel marshals the shims'
    # 0/1 ints via the :bool declarations above.
    # def self.WindowShouldClose
    #   Raylib.sp_WindowShouldClose
    # end
    #
    # def self.IsKeyDown(key)
    #   Raylib.sp_IsKeyDown(key)
    # end
    #
    # def self.IsKeyPressed(key)
    #   Raylib.sp_IsKeyPressed(key)
    # end
    #
    # def self.IsMouseButtonDown(button)
    #   Raylib.sp_IsMouseButtonDown(button)
    # end
    #
    # def self.IsGamepadButtonDown(gamepad, button)
    #   Raylib.sp_IsGamepadButtonDown(gamepad, button)
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

    # Positional factories (Vector2/Vector4/Matrix).
    # The core native ctors for these are no-arg (they are mostly out-params),
    # and Spinel inlines Klass.new(args) straight to the native ctor, so a Ruby
    # `.new` override can never carry the values. Positional construction lives
    # here instead; MRI gets identical helpers in raylib_ruby.rb.
    #
    # Construction goes through C fill helpers (sp_*Fill in raylib_adapter.c):
    # Spinel's type analysis can degrade the accessor writers (v.x = x) to
    # generic ivar dispatch when other classes share those field names, which
    # miscompiles against the incomplete native struct in larger programs.
    # (ffi_func declarations live at the top of the module, with the others.)

    def self.Vector2(x, y)
      o = Vector2.new
      Raylib.sp_Vector2Fill(o, x, y)
      o
    end

    def self.Vector4(x, y, z, w)
      o = Vector4.new
      Raylib.sp_Vector4Fill(o, x, y, z, w)
      o
    end

    def self.Matrix(values)
      m = Matrix.new
      Raylib.sp_MatrixFill(m, values[0], values[1], values[2], values[3],
                           values[4], values[5], values[6], values[7],
                           values[8], values[9], values[10], values[11],
                           values[12], values[13], values[14], values[15])
      m
    end

    # ====== generated: wrappers + constants ======
    def self.SetWindowIcon(image)
      Raylib.sp_SetWindowIcon(image)
    end
    def self.GetMonitorPosition(monitor)
      _out = Vector2.new
      Raylib.sp_GetMonitorPosition(monitor, _out)
      _out
    end
    def self.GetWindowPosition()
      _out = Vector2.new
      Raylib.sp_GetWindowPosition(_out)
      _out
    end
    def self.GetWindowScaleDPI()
      _out = Vector2.new
      Raylib.sp_GetWindowScaleDPI(_out)
      _out
    end
    def self.GetClipboardImage()
      Raylib.sp_GetClipboardImage()
    end
    def self.BeginMode2D(camera)
      Raylib.sp_BeginMode2D(camera)
    end
    def self.BeginTextureMode(target)
      Raylib.sp_BeginTextureMode(target)
    end
    def self.BeginShaderMode(shader)
      Raylib.sp_BeginShaderMode(shader)
    end
    def self.BeginVrStereoMode(config)
      Raylib.sp_BeginVrStereoMode(config)
    end
    def self.LoadVrStereoConfig(device)
      _out = VrStereoConfig.new
      Raylib.sp_LoadVrStereoConfig(device, _out)
      _out
    end
    def self.UnloadVrStereoConfig(config)
      Raylib.sp_UnloadVrStereoConfig(config)
    end
    def self.LoadShader(vsFileName, fsFileName)
      Raylib.sp_LoadShader(vsFileName, fsFileName)
    end
    def self.LoadShaderFromMemory(vsCode, fsCode)
      Raylib.sp_LoadShaderFromMemory(vsCode, fsCode)
    end
    def self.IsShaderValid(shader)
      Raylib.sp_IsShaderValid(shader)
    end
    def self.GetShaderLocation(shader, uniformName)
      Raylib.sp_GetShaderLocation(shader, uniformName)
    end
    def self.GetShaderLocationAttrib(shader, attribName)
      Raylib.sp_GetShaderLocationAttrib(shader, attribName)
    end
    def self.SetShaderValue(shader, locIndex, value, uniformType)
      Raylib.sp_SetShaderValue(shader, locIndex, value, uniformType)
    end
    def self.SetShaderValueV(shader, locIndex, value, uniformType, count)
      Raylib.sp_SetShaderValueV(shader, locIndex, value, uniformType, count)
    end
    def self.SetShaderValueMatrix(shader, locIndex, mat)
      Raylib.sp_SetShaderValueMatrix(shader, locIndex, mat)
    end
    def self.SetShaderValueTexture(shader, locIndex, texture)
      Raylib.sp_SetShaderValueTexture(shader, locIndex, texture)
    end
    def self.UnloadShader(shader)
      Raylib.sp_UnloadShader(shader)
    end
    def self.GetScreenToWorldRay(position, camera)
      _out = Ray.new
      Raylib.sp_GetScreenToWorldRay(position, camera, _out)
      _out
    end
    def self.GetScreenToWorldRayEx(position, camera, width, height)
      _out = Ray.new
      Raylib.sp_GetScreenToWorldRayEx(position, camera, width, height, _out)
      _out
    end
    def self.GetWorldToScreen(position, camera)
      _out = Vector2.new
      Raylib.sp_GetWorldToScreen(position, camera, _out)
      _out
    end
    def self.GetWorldToScreenEx(position, camera, width, height)
      _out = Vector2.new
      Raylib.sp_GetWorldToScreenEx(position, camera, width, height, _out)
      _out
    end
    def self.GetWorldToScreen2D(position, camera)
      _out = Vector2.new
      Raylib.sp_GetWorldToScreen2D(position, camera, _out)
      _out
    end
    def self.GetScreenToWorld2D(position, camera)
      _out = Vector2.new
      Raylib.sp_GetScreenToWorld2D(position, camera, _out)
      _out
    end
    def self.GetCameraMatrix(camera)
      _out = Matrix.new
      Raylib.sp_GetCameraMatrix(camera, _out)
      _out
    end
    def self.GetCameraMatrix2D(camera)
      _out = Matrix.new
      Raylib.sp_GetCameraMatrix2D(camera, _out)
      _out
    end
    def self.SetTraceLogCallback(callback)
      Raylib.sp_SetTraceLogCallback(callback)
    end
    def self.SetLoadFileDataCallback(callback)
      Raylib.sp_SetLoadFileDataCallback(callback)
    end
    def self.SetSaveFileDataCallback(callback)
      Raylib.sp_SetSaveFileDataCallback(callback)
    end
    def self.SetLoadFileTextCallback(callback)
      Raylib.sp_SetLoadFileTextCallback(callback)
    end
    def self.SetSaveFileTextCallback(callback)
      Raylib.sp_SetSaveFileTextCallback(callback)
    end
    def self.LoadDirectoryFiles(dirPath)
      _out = FilePathList.new
      Raylib.sp_LoadDirectoryFiles(dirPath, _out)
      _out
    end
    def self.LoadDirectoryFilesEx(basePath, filter, scanSubdirs)
      _out = FilePathList.new
      Raylib.sp_LoadDirectoryFilesEx(basePath, filter, scanSubdirs, _out)
      _out
    end
    def self.UnloadDirectoryFiles(files)
      Raylib.sp_UnloadDirectoryFiles(files)
    end
    def self.LoadDroppedFiles()
      _out = FilePathList.new
      Raylib.sp_LoadDroppedFiles(_out)
      _out
    end
    def self.UnloadDroppedFiles(files)
      Raylib.sp_UnloadDroppedFiles(files)
    end
    def self.LoadAutomationEventList(fileName)
      _out = AutomationEventList.new
      Raylib.sp_LoadAutomationEventList(fileName, _out)
      _out
    end
    def self.UnloadAutomationEventList(list)
      Raylib.sp_UnloadAutomationEventList(list)
    end
    def self.ExportAutomationEventList(list, fileName)
      Raylib.sp_ExportAutomationEventList(list, fileName)
    end
    def self.SetAutomationEventList(list)
      Raylib.sp_SetAutomationEventList(list)
    end
    def self.PlayAutomationEvent(event)
      Raylib.sp_PlayAutomationEvent(event)
    end
    def self.GetMousePosition()
      _out = Vector2.new
      Raylib.sp_GetMousePosition(_out)
      _out
    end
    def self.GetMouseDelta()
      _out = Vector2.new
      Raylib.sp_GetMouseDelta(_out)
      _out
    end
    def self.GetMouseWheelMoveV()
      _out = Vector2.new
      Raylib.sp_GetMouseWheelMoveV(_out)
      _out
    end
    def self.GetTouchPosition(index)
      _out = Vector2.new
      Raylib.sp_GetTouchPosition(index, _out)
      _out
    end
    def self.GetGestureDragVector()
      _out = Vector2.new
      Raylib.sp_GetGestureDragVector(_out)
      _out
    end
    def self.GetGesturePinchVector()
      _out = Vector2.new
      Raylib.sp_GetGesturePinchVector(_out)
      _out
    end
    def self.UpdateCameraPro(camera, movement, rotation, zoom)
      Raylib.sp_UpdateCameraPro(camera, movement, rotation, zoom)
    end
    def self.SetShapesTexture(texture, rec)
      Raylib.sp_SetShapesTexture(texture, rec)
    end
    def self.GetShapesTexture()
      Raylib.sp_GetShapesTexture()
    end
    def self.GetShapesTextureRectangle()
      _out = Rectangle.new
      Raylib.sp_GetShapesTextureRectangle(_out)
      _out
    end
    def self.DrawPixelV(position, color)
      Raylib.sp_DrawPixelV(position, color)
    end
    def self.DrawLine(startPosX, startPosY, endPosX, endPosY, color)
      Raylib.sp_DrawLine(startPosX, startPosY, endPosX, endPosY, color)
    end
    def self.DrawLineV(startPos, endPos, color)
      Raylib.sp_DrawLineV(startPos, endPos, color)
    end
    def self.DrawLineEx(startPos, endPos, thick, color)
      Raylib.sp_DrawLineEx(startPos, endPos, thick, color)
    end
    def self.DrawLineStrip(points, pointCount, color)
      Raylib.sp_DrawLineStrip(points, pointCount, color)
    end
    def self.DrawLineBezier(startPos, endPos, thick, color)
      Raylib.sp_DrawLineBezier(startPos, endPos, thick, color)
    end
    def self.DrawLineDashed(startPos, endPos, dashSize, spaceSize, color)
      Raylib.sp_DrawLineDashed(startPos, endPos, dashSize, spaceSize, color)
    end
    def self.DrawTriangleGradient(v1, v2, v3, c1, c2, c3)
      Raylib.sp_DrawTriangleGradient(v1, v2, v3, c1, c2, c3)
    end
    def self.DrawTriangleLines(v1, v2, v3, color)
      Raylib.sp_DrawTriangleLines(v1, v2, v3, color)
    end
    def self.DrawTriangleLinesEx(v1, v2, v3, thick, color)
      Raylib.sp_DrawTriangleLinesEx(v1, v2, v3, thick, color)
    end
    def self.DrawTriangleFan(points, pointCount, color)
      Raylib.sp_DrawTriangleFan(points, pointCount, color)
    end
    def self.DrawTriangleStrip(points, pointCount, color)
      Raylib.sp_DrawTriangleStrip(points, pointCount, color)
    end
    def self.DrawRectangleV(position, size, color)
      Raylib.sp_DrawRectangleV(position, size, color)
    end
    def self.DrawRectangleRec(rec, color)
      Raylib.sp_DrawRectangleRec(rec, color)
    end
    def self.DrawRectanglePro(rec, origin, rotation, color)
      Raylib.sp_DrawRectanglePro(rec, origin, rotation, color)
    end
    def self.DrawRectangleGradientV(posX, posY, width, height, top, bottom)
      Raylib.sp_DrawRectangleGradientV(posX, posY, width, height, top, bottom)
    end
    def self.DrawRectangleGradientH(posX, posY, width, height, left, right)
      Raylib.sp_DrawRectangleGradientH(posX, posY, width, height, left, right)
    end
    def self.DrawRectangleGradientEx(rec, col1, col2, col3, col4)
      Raylib.sp_DrawRectangleGradientEx(rec, col1, col2, col3, col4)
    end
    def self.DrawRectangleLinesEx(rec, thick, color)
      Raylib.sp_DrawRectangleLinesEx(rec, thick, color)
    end
    def self.DrawRectangleRounded(rec, roundness, segments, color)
      Raylib.sp_DrawRectangleRounded(rec, roundness, segments, color)
    end
    def self.DrawRectangleRoundedLines(rec, roundness, segments, color)
      Raylib.sp_DrawRectangleRoundedLines(rec, roundness, segments, color)
    end
    def self.DrawRectangleRoundedLinesEx(rec, roundness, segments, thick, color)
      Raylib.sp_DrawRectangleRoundedLinesEx(rec, roundness, segments, thick, color)
    end
    def self.DrawPoly(center, sides, radius, rotation, color)
      Raylib.sp_DrawPoly(center, sides, radius, rotation, color)
    end
    def self.DrawPolyLines(center, sides, radius, rotation, color)
      Raylib.sp_DrawPolyLines(center, sides, radius, rotation, color)
    end
    def self.DrawPolyLinesEx(center, sides, radius, rotation, thick, color)
      Raylib.sp_DrawPolyLinesEx(center, sides, radius, rotation, thick, color)
    end
    def self.DrawCircle(centerX, centerY, radius, color)
      Raylib.sp_DrawCircle(centerX, centerY, radius, color)
    end
    def self.DrawCircleGradient(center, radius, inner, outer)
      Raylib.sp_DrawCircleGradient(center, radius, inner, outer)
    end
    def self.DrawCircleSector(center, radius, startAngle, endAngle, segments, color)
      Raylib.sp_DrawCircleSector(center, radius, startAngle, endAngle, segments, color)
    end
    def self.DrawCircleSectorLines(center, radius, startAngle, endAngle, segments, color)
      Raylib.sp_DrawCircleSectorLines(center, radius, startAngle, endAngle, segments, color)
    end
    def self.DrawCircleSectorLinesEx(center, radius, startAngle, endAngle, segments, thick, color)
      Raylib.sp_DrawCircleSectorLinesEx(center, radius, startAngle, endAngle, segments, thick, color)
    end
    def self.DrawCircleLines(centerX, centerY, radius, color)
      Raylib.sp_DrawCircleLines(centerX, centerY, radius, color)
    end
    def self.DrawCircleLinesV(center, radius, color)
      Raylib.sp_DrawCircleLinesV(center, radius, color)
    end
    def self.DrawCircleLinesEx(center, radius, thick, color)
      Raylib.sp_DrawCircleLinesEx(center, radius, thick, color)
    end
    def self.DrawEllipse(centerX, centerY, radiusH, radiusV, color)
      Raylib.sp_DrawEllipse(centerX, centerY, radiusH, radiusV, color)
    end
    def self.DrawEllipseV(center, radiusH, radiusV, color)
      Raylib.sp_DrawEllipseV(center, radiusH, radiusV, color)
    end
    def self.DrawEllipseLines(centerX, centerY, radiusH, radiusV, color)
      Raylib.sp_DrawEllipseLines(centerX, centerY, radiusH, radiusV, color)
    end
    def self.DrawEllipseLinesV(center, radiusH, radiusV, color)
      Raylib.sp_DrawEllipseLinesV(center, radiusH, radiusV, color)
    end
    def self.DrawEllipseLinesEx(center, radiusH, radiusV, thick, color)
      Raylib.sp_DrawEllipseLinesEx(center, radiusH, radiusV, thick, color)
    end
    def self.DrawRing(center, innerRadius, outerRadius, startAngle, endAngle, segments, color)
      Raylib.sp_DrawRing(center, innerRadius, outerRadius, startAngle, endAngle, segments, color)
    end
    def self.DrawRingLines(center, innerRadius, outerRadius, startAngle, endAngle, segments, color)
      Raylib.sp_DrawRingLines(center, innerRadius, outerRadius, startAngle, endAngle, segments, color)
    end
    def self.DrawRingLinesEx(center, innerRadius, outerRadius, startAngle, endAngle, segments, thick, color)
      Raylib.sp_DrawRingLinesEx(center, innerRadius, outerRadius, startAngle, endAngle, segments, thick, color)
    end
    def self.DrawSplineLinear(points, pointCount, thick, color)
      Raylib.sp_DrawSplineLinear(points, pointCount, thick, color)
    end
    def self.DrawSplineBasis(points, pointCount, thick, color)
      Raylib.sp_DrawSplineBasis(points, pointCount, thick, color)
    end
    def self.DrawSplineCatmullRom(points, pointCount, thick, color)
      Raylib.sp_DrawSplineCatmullRom(points, pointCount, thick, color)
    end
    def self.DrawSplineBezierQuadratic(points, pointCount, thick, color)
      Raylib.sp_DrawSplineBezierQuadratic(points, pointCount, thick, color)
    end
    def self.DrawSplineBezierCubic(points, pointCount, thick, color)
      Raylib.sp_DrawSplineBezierCubic(points, pointCount, thick, color)
    end
    def self.DrawSplineSegmentLinear(p1, p2, thick, color)
      Raylib.sp_DrawSplineSegmentLinear(p1, p2, thick, color)
    end
    def self.DrawSplineSegmentBasis(p1, p2, p3, p4, thick, color)
      Raylib.sp_DrawSplineSegmentBasis(p1, p2, p3, p4, thick, color)
    end
    def self.DrawSplineSegmentCatmullRom(p1, p2, p3, p4, thick, color)
      Raylib.sp_DrawSplineSegmentCatmullRom(p1, p2, p3, p4, thick, color)
    end
    def self.DrawSplineSegmentBezierQuadratic(p1, c2, p3, thick, color)
      Raylib.sp_DrawSplineSegmentBezierQuadratic(p1, c2, p3, thick, color)
    end
    def self.DrawSplineSegmentBezierCubic(p1, c2, c3, p4, thick, color)
      Raylib.sp_DrawSplineSegmentBezierCubic(p1, c2, c3, p4, thick, color)
    end
    def self.GetSplinePointLinear(startPos, endPos, t)
      _out = Vector2.new
      Raylib.sp_GetSplinePointLinear(startPos, endPos, t, _out)
      _out
    end
    def self.GetSplinePointBasis(p1, p2, p3, p4, t)
      _out = Vector2.new
      Raylib.sp_GetSplinePointBasis(p1, p2, p3, p4, t, _out)
      _out
    end
    def self.GetSplinePointCatmullRom(p1, p2, p3, p4, t)
      _out = Vector2.new
      Raylib.sp_GetSplinePointCatmullRom(p1, p2, p3, p4, t, _out)
      _out
    end
    def self.GetSplinePointBezierQuadratic(p1, c2, p3, t)
      _out = Vector2.new
      Raylib.sp_GetSplinePointBezierQuadratic(p1, c2, p3, t, _out)
      _out
    end
    def self.GetSplinePointBezierCubic(p1, c2, c3, p4, t)
      _out = Vector2.new
      Raylib.sp_GetSplinePointBezierCubic(p1, c2, c3, p4, t, _out)
      _out
    end
    def self.CheckCollisionRecs(rec1, rec2)
      Raylib.sp_CheckCollisionRecs(rec1, rec2)
    end
    def self.CheckCollisionCircles(center1, radius1, center2, radius2)
      Raylib.sp_CheckCollisionCircles(center1, radius1, center2, radius2)
    end
    def self.CheckCollisionCircleRec(center, radius, rec)
      Raylib.sp_CheckCollisionCircleRec(center, radius, rec)
    end
    def self.CheckCollisionCircleLine(center, radius, p1, p2)
      Raylib.sp_CheckCollisionCircleLine(center, radius, p1, p2)
    end
    def self.CheckCollisionPointRec(point, rec)
      Raylib.sp_CheckCollisionPointRec(point, rec)
    end
    def self.CheckCollisionPointCircle(point, center, radius)
      Raylib.sp_CheckCollisionPointCircle(point, center, radius)
    end
    def self.CheckCollisionPointTriangle(point, p1, p2, p3)
      Raylib.sp_CheckCollisionPointTriangle(point, p1, p2, p3)
    end
    def self.CheckCollisionPointLine(point, p1, p2, threshold)
      Raylib.sp_CheckCollisionPointLine(point, p1, p2, threshold)
    end
    def self.CheckCollisionPointPoly(point, points, pointCount)
      Raylib.sp_CheckCollisionPointPoly(point, points, pointCount)
    end
    def self.CheckCollisionLines(startPos1, endPos1, startPos2, endPos2, collisionPoint)
      Raylib.sp_CheckCollisionLines(startPos1, endPos1, startPos2, endPos2, collisionPoint)
    end
    def self.GetCollisionRec(rec1, rec2)
      _out = Rectangle.new
      Raylib.sp_GetCollisionRec(rec1, rec2, _out)
      _out
    end
    def self.LoadImage(fileName)
      Raylib.sp_LoadImage(fileName)
    end
    def self.LoadImageRaw(fileName, width, height, format, headerSize)
      Raylib.sp_LoadImageRaw(fileName, width, height, format, headerSize)
    end
    def self.LoadImageAnim(fileName, frames)
      Raylib.sp_LoadImageAnim(fileName, frames)
    end
    def self.LoadImageAnimFromMemory(fileType, fileData, dataSize, frames)
      Raylib.sp_LoadImageAnimFromMemory(fileType, fileData, dataSize, frames)
    end
    def self.LoadImageFromMemory(fileType, fileData, dataSize)
      Raylib.sp_LoadImageFromMemory(fileType, fileData, dataSize)
    end
    def self.LoadImageFromTexture(texture)
      Raylib.sp_LoadImageFromTexture(texture)
    end
    def self.LoadImageFromScreen()
      Raylib.sp_LoadImageFromScreen()
    end
    def self.IsImageValid(image)
      Raylib.sp_IsImageValid(image)
    end
    def self.UnloadImage(image)
      Raylib.sp_UnloadImage(image)
    end
    def self.ExportImage(image, fileName)
      Raylib.sp_ExportImage(image, fileName)
    end
    def self.ExportImageToMemory(image, fileType, fileSize)
      Raylib.sp_ExportImageToMemory(image, fileType, fileSize)
    end
    def self.ExportImageAsCode(image, fileName)
      Raylib.sp_ExportImageAsCode(image, fileName)
    end
    def self.GenImageColor(width, height, color)
      Raylib.sp_GenImageColor(width, height, color)
    end
    def self.GenImageGradientLinear(width, height, direction, start, kw_end)
      Raylib.sp_GenImageGradientLinear(width, height, direction, start, kw_end)
    end
    def self.GenImageGradientRadial(width, height, density, inner, outer)
      Raylib.sp_GenImageGradientRadial(width, height, density, inner, outer)
    end
    def self.GenImageGradientSquare(width, height, density, inner, outer)
      Raylib.sp_GenImageGradientSquare(width, height, density, inner, outer)
    end
    def self.GenImageChecked(width, height, checksX, checksY, col1, col2)
      Raylib.sp_GenImageChecked(width, height, checksX, checksY, col1, col2)
    end
    def self.GenImageWhiteNoise(width, height, factor)
      Raylib.sp_GenImageWhiteNoise(width, height, factor)
    end
    def self.GenImagePerlinNoise(width, height, offsetX, offsetY, scale)
      Raylib.sp_GenImagePerlinNoise(width, height, offsetX, offsetY, scale)
    end
    def self.GenImageCellular(width, height, tileSize)
      Raylib.sp_GenImageCellular(width, height, tileSize)
    end
    def self.GenImageText(width, height, text)
      Raylib.sp_GenImageText(width, height, text)
    end
    def self.ImageCopy(image)
      Raylib.sp_ImageCopy(image)
    end
    def self.ImageFromImage(image, rec)
      Raylib.sp_ImageFromImage(image, rec)
    end
    def self.ImageFromChannel(image, selectedChannel)
      Raylib.sp_ImageFromChannel(image, selectedChannel)
    end
    def self.ImageText(text, fontSize, color)
      Raylib.sp_ImageText(text, fontSize, color)
    end
    def self.ImageTextEx(font, text, fontSize, spacing, tint)
      Raylib.sp_ImageTextEx(font, text, fontSize, spacing, tint)
    end
    def self.ImageToPOT(image, fill)
      Raylib.sp_ImageToPOT(image, fill)
    end
    def self.ImageCrop(image, crop)
      Raylib.sp_ImageCrop(image, crop)
    end
    def self.ImageAlphaClear(image, color, threshold)
      Raylib.sp_ImageAlphaClear(image, color, threshold)
    end
    def self.ImageAlphaMask(image, alphaMask)
      Raylib.sp_ImageAlphaMask(image, alphaMask)
    end
    def self.ImageResizeCanvas(image, newWidth, newHeight, offsetX, offsetY, fill)
      Raylib.sp_ImageResizeCanvas(image, newWidth, newHeight, offsetX, offsetY, fill)
    end
    def self.ImageColorTint(image, color)
      Raylib.sp_ImageColorTint(image, color)
    end
    def self.ImageColorReplace(image, color, replace)
      Raylib.sp_ImageColorReplace(image, color, replace)
    end
    def self.LoadImageColors(image)
      Raylib.sp_LoadImageColors(image)
    end
    def self.LoadImagePalette(image, maxPaletteSize, colorCount)
      Raylib.sp_LoadImagePalette(image, maxPaletteSize, colorCount)
    end
    def self.UnloadImageColors(colors)
      Raylib.sp_UnloadImageColors(colors)
    end
    def self.UnloadImagePalette(colors)
      Raylib.sp_UnloadImagePalette(colors)
    end
    def self.GetImageAlphaBorder(image, threshold)
      _out = Rectangle.new
      Raylib.sp_GetImageAlphaBorder(image, threshold, _out)
      _out
    end
    def self.GetImageColor(image, x, y)
      _out = Color.new(0, 0, 0, 0)
      Raylib.sp_GetImageColor(image, x, y, _out)
      _out
    end
    def self.ImageClearBackground(dst, color)
      Raylib.sp_ImageClearBackground(dst, color)
    end
    def self.ImageDrawPixel(dst, posX, posY, color)
      Raylib.sp_ImageDrawPixel(dst, posX, posY, color)
    end
    def self.ImageDrawPixelV(dst, position, color)
      Raylib.sp_ImageDrawPixelV(dst, position, color)
    end
    def self.ImageDrawLine(dst, startPosX, startPosY, endPosX, endPosY, color)
      Raylib.sp_ImageDrawLine(dst, startPosX, startPosY, endPosX, endPosY, color)
    end
    def self.ImageDrawLineV(dst, start, kw_end, color)
      Raylib.sp_ImageDrawLineV(dst, start, kw_end, color)
    end
    def self.ImageDrawLineEx(dst, start, kw_end, thick, color)
      Raylib.sp_ImageDrawLineEx(dst, start, kw_end, thick, color)
    end
    def self.ImageDrawLineStrip(dst, points, pointCount, color)
      Raylib.sp_ImageDrawLineStrip(dst, points, pointCount, color)
    end
    def self.ImageDrawTriangle(dst, v1, v2, v3, color)
      Raylib.sp_ImageDrawTriangle(dst, v1, v2, v3, color)
    end
    def self.ImageDrawTriangleGradient(dst, v1, v2, v3, c1, c2, c3)
      Raylib.sp_ImageDrawTriangleGradient(dst, v1, v2, v3, c1, c2, c3)
    end
    def self.ImageDrawTriangleLines(dst, v1, v2, v3, color)
      Raylib.sp_ImageDrawTriangleLines(dst, v1, v2, v3, color)
    end
    def self.ImageDrawTriangleFan(dst, points, pointCount, color)
      Raylib.sp_ImageDrawTriangleFan(dst, points, pointCount, color)
    end
    def self.ImageDrawTriangleStrip(dst, points, pointCount, color)
      Raylib.sp_ImageDrawTriangleStrip(dst, points, pointCount, color)
    end
    def self.ImageDrawRectangle(dst, posX, posY, width, height, color)
      Raylib.sp_ImageDrawRectangle(dst, posX, posY, width, height, color)
    end
    def self.ImageDrawRectangleV(dst, position, size, color)
      Raylib.sp_ImageDrawRectangleV(dst, position, size, color)
    end
    def self.ImageDrawRectangleRec(dst, rec, color)
      Raylib.sp_ImageDrawRectangleRec(dst, rec, color)
    end
    def self.ImageDrawRectanglePro(dst, rec, origin, rotation, color)
      Raylib.sp_ImageDrawRectanglePro(dst, rec, origin, rotation, color)
    end
    def self.ImageDrawRectangleLines(dst, posX, posY, width, height, color)
      Raylib.sp_ImageDrawRectangleLines(dst, posX, posY, width, height, color)
    end
    def self.ImageDrawRectangleLinesEx(dst, rec, thick, color)
      Raylib.sp_ImageDrawRectangleLinesEx(dst, rec, thick, color)
    end
    def self.ImageDrawRectangleGradientEx(dst, rec, col1, col2, col3, col4)
      Raylib.sp_ImageDrawRectangleGradientEx(dst, rec, col1, col2, col3, col4)
    end
    def self.ImageDrawCircle(dst, centerX, centerY, radius, color)
      Raylib.sp_ImageDrawCircle(dst, centerX, centerY, radius, color)
    end
    def self.ImageDrawCircleV(dst, center, radius, color)
      Raylib.sp_ImageDrawCircleV(dst, center, radius, color)
    end
    def self.ImageDrawCircleLines(dst, centerX, centerY, radius, color)
      Raylib.sp_ImageDrawCircleLines(dst, centerX, centerY, radius, color)
    end
    def self.ImageDrawCircleLinesV(dst, center, radius, color)
      Raylib.sp_ImageDrawCircleLinesV(dst, center, radius, color)
    end
    def self.ImageDrawCircleGradient(dst, center, radius, inner, outer)
      Raylib.sp_ImageDrawCircleGradient(dst, center, radius, inner, outer)
    end
    def self.ImageDrawImage(dst, src, posX, posY, tint)
      Raylib.sp_ImageDrawImage(dst, src, posX, posY, tint)
    end
    def self.ImageDrawImageEx(dst, src, position, rotation, scale, tint)
      Raylib.sp_ImageDrawImageEx(dst, src, position, rotation, scale, tint)
    end
    def self.ImageDrawImageRec(dst, src, srcRec, position, tint)
      Raylib.sp_ImageDrawImageRec(dst, src, srcRec, position, tint)
    end
    def self.ImageDrawImagePro(dst, src, srcRec, dstRec, origin, rotation, tint)
      Raylib.sp_ImageDrawImagePro(dst, src, srcRec, dstRec, origin, rotation, tint)
    end
    def self.ImageDrawText(dst, text, posX, posY, fontSize, color)
      Raylib.sp_ImageDrawText(dst, text, posX, posY, fontSize, color)
    end
    def self.ImageDrawTextEx(dst, font, text, position, fontSize, spacing, tint)
      Raylib.sp_ImageDrawTextEx(dst, font, text, position, fontSize, spacing, tint)
    end
    def self.ImageDrawTextPro(dst, font, text, position, origin, rotation, fontSize, spacing, tint)
      Raylib.sp_ImageDrawTextPro(dst, font, text, position, origin, rotation, fontSize, spacing, tint)
    end
    def self.LoadTextureFromImage(image)
      Raylib.sp_LoadTextureFromImage(image)
    end
    def self.LoadTextureCubemap(image, layout)
      Raylib.sp_LoadTextureCubemap(image, layout)
    end
    def self.LoadRenderTexture(width, height)
      Raylib.sp_LoadRenderTexture(width, height)
    end
    def self.LoadRenderTextureEx(width, height, format)
      Raylib.sp_LoadRenderTextureEx(width, height, format)
    end
    def self.IsTextureValid(texture)
      Raylib.sp_IsTextureValid(texture)
    end
    def self.IsRenderTextureValid(target)
      Raylib.sp_IsRenderTextureValid(target)
    end
    def self.UnloadRenderTexture(target)
      Raylib.sp_UnloadRenderTexture(target)
    end
    def self.UpdateTexture(texture, pixels)
      Raylib.sp_UpdateTexture(texture, pixels)
    end
    def self.UpdateTextureRec(texture, rec, pixels)
      Raylib.sp_UpdateTextureRec(texture, rec, pixels)
    end
    def self.SetTextureFilter(texture, filter)
      Raylib.sp_SetTextureFilter(texture, filter)
    end
    def self.SetTextureWrap(texture, wrap)
      Raylib.sp_SetTextureWrap(texture, wrap)
    end
    def self.DrawTextureV(texture, position, tint)
      Raylib.sp_DrawTextureV(texture, position, tint)
    end
    def self.DrawTextureRec(texture, rec, position, tint)
      Raylib.sp_DrawTextureRec(texture, rec, position, tint)
    end
    def self.DrawTexturePro(texture, srcrec, dstrec, origin, rotation, tint)
      Raylib.sp_DrawTexturePro(texture, srcrec, dstrec, origin, rotation, tint)
    end
    def self.DrawTextureNPatch(texture, nPatchInfo, dstrec, origin, rotation, tint)
      Raylib.sp_DrawTextureNPatch(texture, nPatchInfo, dstrec, origin, rotation, tint)
    end
    def self.ColorIsEqual(col1, col2)
      Raylib.sp_ColorIsEqual(col1, col2)
    end
    def self.Fade(color, alpha)
      _out = Color.new(0, 0, 0, 0)
      Raylib.sp_Fade(color, alpha, _out)
      _out
    end
    def self.ColorToInt(color)
      Raylib.sp_ColorToInt(color)
    end
    def self.ColorNormalize(color)
      _out = Vector4.new
      Raylib.sp_ColorNormalize(color, _out)
      _out
    end
    def self.ColorFromNormalized(normalized)
      _out = Color.new(0, 0, 0, 0)
      Raylib.sp_ColorFromNormalized(normalized, _out)
      _out
    end
    def self.ColorToHSV(color)
      _out = Vector3.new(0.0, 0.0, 0.0)
      Raylib.sp_ColorToHSV(color, _out)
      _out
    end
    def self.ColorFromHSV(hue, saturation, value)
      _out = Color.new(0, 0, 0, 0)
      Raylib.sp_ColorFromHSV(hue, saturation, value, _out)
      _out
    end
    def self.ColorTint(color, tint)
      _out = Color.new(0, 0, 0, 0)
      Raylib.sp_ColorTint(color, tint, _out)
      _out
    end
    def self.ColorBrightness(color, factor)
      _out = Color.new(0, 0, 0, 0)
      Raylib.sp_ColorBrightness(color, factor, _out)
      _out
    end
    def self.ColorContrast(color, contrast)
      _out = Color.new(0, 0, 0, 0)
      Raylib.sp_ColorContrast(color, contrast, _out)
      _out
    end
    def self.ColorAlpha(color, alpha)
      _out = Color.new(0, 0, 0, 0)
      Raylib.sp_ColorAlpha(color, alpha, _out)
      _out
    end
    def self.ColorAlphaBlend(dst, src, tint)
      _out = Color.new(0, 0, 0, 0)
      Raylib.sp_ColorAlphaBlend(dst, src, tint, _out)
      _out
    end
    def self.ColorLerp(color1, color2, factor)
      _out = Color.new(0, 0, 0, 0)
      Raylib.sp_ColorLerp(color1, color2, factor, _out)
      _out
    end
    def self.GetColor(hexValue)
      _out = Color.new(0, 0, 0, 0)
      Raylib.sp_GetColor(hexValue, _out)
      _out
    end
    def self.GetPixelColor(srcPtr, format)
      _out = Color.new(0, 0, 0, 0)
      Raylib.sp_GetPixelColor(srcPtr, format, _out)
      _out
    end
    def self.SetPixelColor(dstPtr, color, format)
      Raylib.sp_SetPixelColor(dstPtr, color, format)
    end
    def self.GetFontDefault()
      Raylib.sp_GetFontDefault()
    end
    def self.LoadFont(fileName)
      Raylib.sp_LoadFont(fileName)
    end
    def self.LoadFontEx(fileName, fontSize, codepoints, codepointCount)
      Raylib.sp_LoadFontEx(fileName, fontSize, codepoints, codepointCount)
    end
    def self.LoadFontFromImage(image, key, firstChar)
      Raylib.sp_LoadFontFromImage(image, key, firstChar)
    end
    def self.LoadFontFromMemory(fileType, fileData, dataSize, fontSize, codepoints, codepointCount)
      Raylib.sp_LoadFontFromMemory(fileType, fileData, dataSize, fontSize, codepoints, codepointCount)
    end
    def self.IsFontValid(font)
      Raylib.sp_IsFontValid(font)
    end
    def self.GenImageFontAtlas(glyphs, glyphRecs, glyphCount, fontSize, padding, packMethod)
      Raylib.sp_GenImageFontAtlas(glyphs, glyphRecs, glyphCount, fontSize, padding, packMethod)
    end
    def self.UnloadFont(font)
      Raylib.sp_UnloadFont(font)
    end
    def self.ExportFontAsCode(font, fileName)
      Raylib.sp_ExportFontAsCode(font, fileName)
    end
    def self.DrawTextEx(font, text, position, fontSize, spacing, tint)
      Raylib.sp_DrawTextEx(font, text, position, fontSize, spacing, tint)
    end
    def self.DrawTextPro(font, text, position, origin, rotation, fontSize, spacing, tint)
      Raylib.sp_DrawTextPro(font, text, position, origin, rotation, fontSize, spacing, tint)
    end
    def self.DrawTextCodepoint(font, codepoint, position, fontSize, tint)
      Raylib.sp_DrawTextCodepoint(font, codepoint, position, fontSize, tint)
    end
    def self.DrawTextCodepoints(font, codepoints, codepointCount, position, fontSize, spacing, tint)
      Raylib.sp_DrawTextCodepoints(font, codepoints, codepointCount, position, fontSize, spacing, tint)
    end
    def self.MeasureTextEx(font, text, fontSize, spacing)
      _out = Vector2.new
      Raylib.sp_MeasureTextEx(font, text, fontSize, spacing, _out)
      _out
    end
    def self.MeasureTextCodepoints(font, codepoints, length, fontSize, spacing)
      _out = Vector2.new
      Raylib.sp_MeasureTextCodepoints(font, codepoints, length, fontSize, spacing, _out)
      _out
    end
    def self.GetGlyphIndex(font, codepoint)
      Raylib.sp_GetGlyphIndex(font, codepoint)
    end
    def self.GetGlyphInfo(font, codepoint)
      Raylib.sp_GetGlyphInfo(font, codepoint)
    end
    def self.GetGlyphAtlasRec(font, codepoint)
      _out = Rectangle.new
      Raylib.sp_GetGlyphAtlasRec(font, codepoint, _out)
      _out
    end
    def self.DrawLine3D(startPos, endPos, color)
      Raylib.sp_DrawLine3D(startPos, endPos, color)
    end
    def self.DrawPoint3D(position, color)
      Raylib.sp_DrawPoint3D(position, color)
    end
    def self.DrawCircle3D(center, radius, rotationAxis, rotationAngle, color)
      Raylib.sp_DrawCircle3D(center, radius, rotationAxis, rotationAngle, color)
    end
    def self.DrawTriangle3D(v1, v2, v3, color)
      Raylib.sp_DrawTriangle3D(v1, v2, v3, color)
    end
    def self.DrawTriangleStrip3D(points, pointCount, color)
      Raylib.sp_DrawTriangleStrip3D(points, pointCount, color)
    end
    def self.DrawCubeV(position, size, color)
      Raylib.sp_DrawCubeV(position, size, color)
    end
    def self.DrawCubeWiresV(position, size, color)
      Raylib.sp_DrawCubeWiresV(position, size, color)
    end
    def self.DrawSphere(centerPos, radius, color)
      Raylib.sp_DrawSphere(centerPos, radius, color)
    end
    def self.DrawSphereEx(centerPos, radius, rings, slices, color)
      Raylib.sp_DrawSphereEx(centerPos, radius, rings, slices, color)
    end
    def self.DrawSphereWires(centerPos, radius, rings, slices, color)
      Raylib.sp_DrawSphereWires(centerPos, radius, rings, slices, color)
    end
    def self.DrawCylinder(position, radiusTop, radiusBottom, height, sides, color)
      Raylib.sp_DrawCylinder(position, radiusTop, radiusBottom, height, sides, color)
    end
    def self.DrawCylinderEx(startPos, endPos, startRadius, endRadius, sides, color)
      Raylib.sp_DrawCylinderEx(startPos, endPos, startRadius, endRadius, sides, color)
    end
    def self.DrawCylinderWires(position, radiusTop, radiusBottom, height, sides, color)
      Raylib.sp_DrawCylinderWires(position, radiusTop, radiusBottom, height, sides, color)
    end
    def self.DrawCylinderWiresEx(startPos, endPos, startRadius, endRadius, sides, color)
      Raylib.sp_DrawCylinderWiresEx(startPos, endPos, startRadius, endRadius, sides, color)
    end
    def self.DrawCapsule(startPos, endPos, radius, rings, slices, color)
      Raylib.sp_DrawCapsule(startPos, endPos, radius, rings, slices, color)
    end
    def self.DrawCapsuleWires(startPos, endPos, radius, rings, slices, color)
      Raylib.sp_DrawCapsuleWires(startPos, endPos, radius, rings, slices, color)
    end
    def self.DrawRay(ray, color)
      Raylib.sp_DrawRay(ray, color)
    end
    def self.LoadModel(fileName)
      Raylib.sp_LoadModel(fileName)
    end
    def self.LoadModelFromMesh(mesh)
      Raylib.sp_LoadModelFromMesh(mesh)
    end
    def self.IsModelValid(model)
      Raylib.sp_IsModelValid(model)
    end
    def self.UnloadModel(model)
      Raylib.sp_UnloadModel(model)
    end
    def self.GetModelBoundingBox(model)
      _out = BoundingBox.new
      Raylib.sp_GetModelBoundingBox(model, _out)
      _out
    end
    def self.DrawModel(model, position, scale, tint)
      Raylib.sp_DrawModel(model, position, scale, tint)
    end
    def self.DrawModelEx(model, position, rotationAxis, rotationAngle, scale, tint)
      Raylib.sp_DrawModelEx(model, position, rotationAxis, rotationAngle, scale, tint)
    end
    def self.DrawModelWires(model, position, scale, tint)
      Raylib.sp_DrawModelWires(model, position, scale, tint)
    end
    def self.DrawModelWiresEx(model, position, rotationAxis, rotationAngle, scale, tint)
      Raylib.sp_DrawModelWiresEx(model, position, rotationAxis, rotationAngle, scale, tint)
    end
    def self.DrawBoundingBox(box, color)
      Raylib.sp_DrawBoundingBox(box, color)
    end
    def self.DrawBillboard(camera, texture, position, scale, tint)
      Raylib.sp_DrawBillboard(camera, texture, position, scale, tint)
    end
    def self.DrawBillboardRec(camera, texture, rec, position, size, tint)
      Raylib.sp_DrawBillboardRec(camera, texture, rec, position, size, tint)
    end
    def self.DrawBillboardPro(camera, texture, rec, position, up, size, origin, rotation, tint)
      Raylib.sp_DrawBillboardPro(camera, texture, rec, position, up, size, origin, rotation, tint)
    end
    def self.UpdateMeshBuffer(mesh, index, data, dataSize, offset)
      Raylib.sp_UpdateMeshBuffer(mesh, index, data, dataSize, offset)
    end
    def self.UnloadMesh(mesh)
      Raylib.sp_UnloadMesh(mesh)
    end
    def self.DrawMesh(mesh, material, transform)
      Raylib.sp_DrawMesh(mesh, material, transform)
    end
    def self.DrawMeshInstanced(mesh, material, transforms, instances)
      Raylib.sp_DrawMeshInstanced(mesh, material, transforms, instances)
    end
    def self.GetMeshBoundingBox(mesh)
      _out = BoundingBox.new
      Raylib.sp_GetMeshBoundingBox(mesh, _out)
      _out
    end
    def self.ExportMesh(mesh, fileName)
      Raylib.sp_ExportMesh(mesh, fileName)
    end
    def self.ExportMeshAsCode(mesh, fileName)
      Raylib.sp_ExportMeshAsCode(mesh, fileName)
    end
    def self.GenMeshPoly(sides, radius)
      Raylib.sp_GenMeshPoly(sides, radius)
    end
    def self.GenMeshPlane(width, length, resX, resZ)
      Raylib.sp_GenMeshPlane(width, length, resX, resZ)
    end
    def self.GenMeshCube(width, height, length)
      Raylib.sp_GenMeshCube(width, height, length)
    end
    def self.GenMeshSphere(radius, rings, slices)
      Raylib.sp_GenMeshSphere(radius, rings, slices)
    end
    def self.GenMeshHemiSphere(radius, rings, slices)
      Raylib.sp_GenMeshHemiSphere(radius, rings, slices)
    end
    def self.GenMeshCylinder(radius, height, slices)
      Raylib.sp_GenMeshCylinder(radius, height, slices)
    end
    def self.GenMeshCone(radius, height, slices)
      Raylib.sp_GenMeshCone(radius, height, slices)
    end
    def self.GenMeshTorus(radius, size, radSeg, sides)
      Raylib.sp_GenMeshTorus(radius, size, radSeg, sides)
    end
    def self.GenMeshKnot(radius, size, radSeg, sides)
      Raylib.sp_GenMeshKnot(radius, size, radSeg, sides)
    end
    def self.GenMeshHeightmap(heightmap, size)
      Raylib.sp_GenMeshHeightmap(heightmap, size)
    end
    def self.GenMeshCubicmap(cubicmap, cubeSize)
      Raylib.sp_GenMeshCubicmap(cubicmap, cubeSize)
    end
    def self.LoadMaterialDefault()
      Raylib.sp_LoadMaterialDefault()
    end
    def self.IsMaterialValid(material)
      Raylib.sp_IsMaterialValid(material)
    end
    def self.UnloadMaterial(material)
      Raylib.sp_UnloadMaterial(material)
    end
    def self.SetMaterialTexture(material, mapType, texture)
      Raylib.sp_SetMaterialTexture(material, mapType, texture)
    end
    def self.UpdateModelAnimation(model, anim, frame)
      Raylib.sp_UpdateModelAnimation(model, anim, frame)
    end
    def self.UpdateModelAnimationEx(model, animA, frameA, animB, frameB, blend)
      Raylib.sp_UpdateModelAnimationEx(model, animA, frameA, animB, frameB, blend)
    end
    def self.IsModelAnimationValid(model, anim)
      Raylib.sp_IsModelAnimationValid(model, anim)
    end
    def self.CheckCollisionSpheres(center1, radius1, center2, radius2)
      Raylib.sp_CheckCollisionSpheres(center1, radius1, center2, radius2)
    end
    def self.CheckCollisionBoxes(box1, box2)
      Raylib.sp_CheckCollisionBoxes(box1, box2)
    end
    def self.CheckCollisionBoxSphere(box, center, radius)
      Raylib.sp_CheckCollisionBoxSphere(box, center, radius)
    end
    def self.GetRayCollisionSphere(ray, center, radius)
      _out = RayCollision.new
      Raylib.sp_GetRayCollisionSphere(ray, center, radius, _out)
      _out
    end
    def self.GetRayCollisionBox(ray, box)
      _out = RayCollision.new
      Raylib.sp_GetRayCollisionBox(ray, box, _out)
      _out
    end
    def self.GetRayCollisionMesh(ray, mesh, transform)
      _out = RayCollision.new
      Raylib.sp_GetRayCollisionMesh(ray, mesh, transform, _out)
      _out
    end
    def self.GetRayCollisionTriangle(ray, p1, p2, p3)
      _out = RayCollision.new
      Raylib.sp_GetRayCollisionTriangle(ray, p1, p2, p3, _out)
      _out
    end
    def self.GetRayCollisionQuad(ray, p1, p2, p3, p4)
      _out = RayCollision.new
      Raylib.sp_GetRayCollisionQuad(ray, p1, p2, p3, p4, _out)
      _out
    end
    def self.LoadWave(fileName)
      Raylib.sp_LoadWave(fileName)
    end
    def self.LoadWaveFromMemory(fileType, fileData, dataSize)
      Raylib.sp_LoadWaveFromMemory(fileType, fileData, dataSize)
    end
    def self.IsWaveValid(wave)
      Raylib.sp_IsWaveValid(wave)
    end
    def self.LoadSound(fileName)
      Raylib.sp_LoadSound(fileName)
    end
    def self.LoadSoundFromWave(wave)
      Raylib.sp_LoadSoundFromWave(wave)
    end
    def self.LoadSoundAlias(source)
      Raylib.sp_LoadSoundAlias(source)
    end
    def self.IsSoundValid(sound)
      Raylib.sp_IsSoundValid(sound)
    end
    def self.UpdateSound(sound, data, frameCount)
      Raylib.sp_UpdateSound(sound, data, frameCount)
    end
    def self.UnloadWave(wave)
      Raylib.sp_UnloadWave(wave)
    end
    def self.UnloadSound(sound)
      Raylib.sp_UnloadSound(sound)
    end
    def self.UnloadSoundAlias(kw_alias)
      Raylib.sp_UnloadSoundAlias(kw_alias)
    end
    def self.ExportWave(wave, fileName)
      Raylib.sp_ExportWave(wave, fileName)
    end
    def self.ExportWaveAsCode(wave, fileName)
      Raylib.sp_ExportWaveAsCode(wave, fileName)
    end
    def self.PlaySound(sound)
      Raylib.sp_PlaySound(sound)
    end
    def self.StopSound(sound)
      Raylib.sp_StopSound(sound)
    end
    def self.PauseSound(sound)
      Raylib.sp_PauseSound(sound)
    end
    def self.ResumeSound(sound)
      Raylib.sp_ResumeSound(sound)
    end
    def self.IsSoundPlaying(sound)
      Raylib.sp_IsSoundPlaying(sound)
    end
    def self.SetSoundVolume(sound, volume)
      Raylib.sp_SetSoundVolume(sound, volume)
    end
    def self.SetSoundPitch(sound, pitch)
      Raylib.sp_SetSoundPitch(sound, pitch)
    end
    def self.SetSoundPan(sound, pan)
      Raylib.sp_SetSoundPan(sound, pan)
    end
    def self.WaveCopy(wave)
      Raylib.sp_WaveCopy(wave)
    end
    def self.LoadWaveSamples(wave)
      Raylib.sp_LoadWaveSamples(wave)
    end
    def self.LoadMusicStream(fileName)
      Raylib.sp_LoadMusicStream(fileName)
    end
    def self.LoadMusicStreamFromMemory(fileType, data, dataSize)
      Raylib.sp_LoadMusicStreamFromMemory(fileType, data, dataSize)
    end
    def self.IsMusicValid(music)
      Raylib.sp_IsMusicValid(music)
    end
    def self.UnloadMusicStream(music)
      Raylib.sp_UnloadMusicStream(music)
    end
    def self.PlayMusicStream(music)
      Raylib.sp_PlayMusicStream(music)
    end
    def self.IsMusicStreamPlaying(music)
      Raylib.sp_IsMusicStreamPlaying(music)
    end
    def self.UpdateMusicStream(music)
      Raylib.sp_UpdateMusicStream(music)
    end
    def self.StopMusicStream(music)
      Raylib.sp_StopMusicStream(music)
    end
    def self.PauseMusicStream(music)
      Raylib.sp_PauseMusicStream(music)
    end
    def self.ResumeMusicStream(music)
      Raylib.sp_ResumeMusicStream(music)
    end
    def self.SeekMusicStream(music, position)
      Raylib.sp_SeekMusicStream(music, position)
    end
    def self.SetMusicVolume(music, volume)
      Raylib.sp_SetMusicVolume(music, volume)
    end
    def self.SetMusicPitch(music, pitch)
      Raylib.sp_SetMusicPitch(music, pitch)
    end
    def self.SetMusicPan(music, pan)
      Raylib.sp_SetMusicPan(music, pan)
    end
    def self.GetMusicTimeLength(music)
      Raylib.sp_GetMusicTimeLength(music)
    end
    def self.GetMusicTimePlayed(music)
      Raylib.sp_GetMusicTimePlayed(music)
    end
    def self.LoadAudioStream(sampleRate, sampleSize, channels)
      Raylib.sp_LoadAudioStream(sampleRate, sampleSize, channels)
    end
    def self.IsAudioStreamValid(stream)
      Raylib.sp_IsAudioStreamValid(stream)
    end
    def self.UnloadAudioStream(stream)
      Raylib.sp_UnloadAudioStream(stream)
    end
    def self.UpdateAudioStream(stream, data, frameCount)
      Raylib.sp_UpdateAudioStream(stream, data, frameCount)
    end
    def self.IsAudioStreamProcessed(stream)
      Raylib.sp_IsAudioStreamProcessed(stream)
    end
    def self.PlayAudioStream(stream)
      Raylib.sp_PlayAudioStream(stream)
    end
    def self.PauseAudioStream(stream)
      Raylib.sp_PauseAudioStream(stream)
    end
    def self.ResumeAudioStream(stream)
      Raylib.sp_ResumeAudioStream(stream)
    end
    def self.IsAudioStreamPlaying(stream)
      Raylib.sp_IsAudioStreamPlaying(stream)
    end
    def self.StopAudioStream(stream)
      Raylib.sp_StopAudioStream(stream)
    end
    def self.SetAudioStreamVolume(stream, volume)
      Raylib.sp_SetAudioStreamVolume(stream, volume)
    end
    def self.SetAudioStreamPitch(stream, pitch)
      Raylib.sp_SetAudioStreamPitch(stream, pitch)
    end
    def self.SetAudioStreamPan(stream, pan)
      Raylib.sp_SetAudioStreamPan(stream, pan)
    end
    def self.SetAudioStreamCallback(stream, callback)
      Raylib.sp_SetAudioStreamCallback(stream, callback)
    end
    def self.AttachAudioStreamProcessor(stream, processor)
      Raylib.sp_AttachAudioStreamProcessor(stream, processor)
    end
    def self.DetachAudioStreamProcessor(stream, processor)
      Raylib.sp_DetachAudioStreamProcessor(stream, processor)
    end
    def self.AttachAudioMixedProcessor(processor)
      Raylib.sp_AttachAudioMixedProcessor(processor)
    end
    def self.DetachAudioMixedProcessor(processor)
      Raylib.sp_DetachAudioMixedProcessor(processor)
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
end
