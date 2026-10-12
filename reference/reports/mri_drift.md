# MRI raylib-bindings drift report — 2026-10-11

Tool: `tools/mri_drift.py`. Compares installed MRI gem versions and the MRI 0.8.4 surface against raylib-spinel.

== MRI gem versions installed: 0.7.10, 0.8.2, 0.8.3, 0.8.4

== 0.7.10 -> 0.8.2
  raylib: +['ComputeSHA256', 'DrawCircleLinesEx', 'DrawEllipseLinesV', 'DrawEllipseV', 'DrawLineDashed', 'DrawTriangleGradient', 'FileCopy', 'FileMove', 'FileRemove', 'FileRename', 'FileTextFindIndex', 'FileTextReplace', 'GetDirectoryFileCount', 'GetDirectoryFileCountEx', 'GetSplinePointBezierQuadratic', 'GetTextBetween', 'ImageDrawCircleGradient', 'ImageDrawImage', 'ImageDrawImageEx', 'ImageDrawImagePro', 'ImageDrawImageRec', 'ImageDrawLineStrip', 'ImageDrawRectangleGradientEx', 'ImageDrawRectangleLinesEx', 'ImageDrawRectanglePro', 'ImageDrawTextPro', 'ImageDrawTriangleGradient', 'IsPathDirectory', 'LoadTextLines', 'MeasureTextCodepoints', 'TextInsertAlloc', 'TextRemoveSpaces', 'TextReplaceAlloc', 'TextReplaceBetween', 'TextReplaceBetweenAlloc', 'UnloadTextLines', 'UpdateModelAnimationEx'] -['DrawModelPoints', 'DrawModelPointsEx', 'GetSplinePointBezierQuad', 'ImageDraw', 'ImageDrawTriangleEx', 'UnloadModelAnimation', 'UpdateModelAnimationBones'] ~6
      ChangeDirectory: ChangeDirectory(pointer)->bool  =>  ChangeDirectory(pointer)->int
      DrawCircleGradient: DrawCircleGradient(int,int,float,Color.by_value,Color.by_value)->void  =>  DrawCircleGradient(Vector2.by_value,float,Color.by_value,Color.by_value)->void
      ImageColorContrast: ImageColorContrast(pointer,float)->void  =>  ImageColorContrast(pointer,int)->void
      ImageDrawRectangleLines: ImageDrawRectangleLines(pointer,Rectangle.by_value,int,Color.by_value)->void  =>  ImageDrawRectangleLines(pointer,int,int,int,int,Color.by_value)->void
      LoadFontData: LoadFontData(pointer,int,int,pointer,int,int)->pointer  =>  LoadFontData(pointer,int,int,pointer,int,int,pointer)->pointer
      UpdateModelAnimation: UpdateModelAnimation(Model.by_value,ModelAnimation.by_value,int)->void  =>  UpdateModelAnimation(Model.by_value,ModelAnimation.by_value,float)->void
  raymath: +['MatrixCompose', 'MatrixMultiplyValue'] -- ~0
  rlgl: +['rlCopyFramebuffer', 'rlDisablePointMode', 'rlDisableStatePointer', 'rlEnableStatePointer', 'rlGetPointSize', 'rlGetProcAddress', 'rlLoadShader', 'rlLoadShaderProgramCompute', 'rlLoadShaderProgramEx', 'rlResizeFramebuffer', 'rlSetPointSize', 'rlUnloadShader'] -['rlCompileShader', 'rlLoadComputeShaderProgram', 'rlLoadShaderCode'] ~1
      rlLoadShaderProgram: rlLoadShaderProgram(uint,uint)->uint  =>  rlLoadShaderProgram(pointer,pointer)->uint
  physac: unchanged (19 fns)
  rcamera: unchanged (12 fns)
  raygui: +['GuiGetTextWidth', 'GuiLoadIconsFromMemory', 'GuiLoadStyleFromMemory', 'GuiTabBarEx'] -- ~1
      GuiTabBar: GuiTabBar(Rectangle.by_value,pointer,int,pointer)->int  =>  GuiTabBar(Rectangle.by_value,pointer,pointer,pointer)->int

== 0.8.2 -> 0.8.3
  raylib: +['IsPathAbsolute'] -- ~0
  raymath: unchanged (146 fns)
  rlgl: unchanged (163 fns)
  physac: unchanged (19 fns)
  rcamera: unchanged (12 fns)
  raygui: +- -- ~2
      GuiMessageBox: GuiMessageBox(Rectangle.by_value,pointer,pointer,pointer)->int  =>  GuiMessageBox(Rectangle.by_value,pointer,pointer,pointer,pointer)->int
      GuiTextInputBox: GuiTextInputBox(Rectangle.by_value,pointer,pointer,pointer,pointer,int,pointer)->int  =>  GuiTextInputBox(Rectangle.by_value,pointer,pointer,pointer,int,pointer,pointer,pointer)->int

== 0.8.3 -> 0.8.4
  raylib: +['DrawCircleSectorLinesEx', 'DrawEllipseLinesEx', 'DrawRingLinesEx', 'DrawTriangleLinesEx', 'IsFileHidden', 'LoadRenderTextureEx'] -- ~0
  raymath: unchanged (146 fns)
  rlgl: unchanged (163 fns)
  physac: unchanged (19 fns)
  rcamera: unchanged (12 fns)
  raygui: unchanged (61 fns)

== MRI 0.8.4 vs raylib-spinel surface
  raylib: mri-only=3
     mri-only: TextFormat, TraceLog, internalDrawModelEx
  raymath: mri-only=0
  rlgl: mri-only=0
  physac: mri-only=0
  rcamera: mri-only=0
  raygui: mri-only=0
