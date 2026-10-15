# rlgl_ffi.rb — FFI declarations for Spinel AOT
# Under MRI, ffi_func/ffi_lib/ffi_cflags are no-ops defined in main.rb

module Rlgl
  ffi_lib "raylib"
  ffi_cflags "-I/usr/local/include"

# ====== generated: complete rlgl API surface ======
  ffi_func :rlLoadShaderBuffer, [:uint, :ptr, :int], :uint
  ffi_func :rlUpdateShaderBuffer, [:uint, :ptr, :uint, :uint], :void
  ffi_func :rlReadShaderBuffer, [:uint, :ptr, :uint, :uint], :void

# ====== generated: complete rlgl API surface ======
  ffi_func :rlMatrixMode, [:int], :void
  ffi_func :rlPushMatrix, [], :void
  ffi_func :rlPopMatrix, [], :void
  ffi_func :rlLoadIdentity, [], :void
  ffi_func :rlTranslatef, [:float, :float, :float], :void
  ffi_func :rlRotatef, [:float, :float, :float, :float], :void
  ffi_func :rlScalef, [:float, :float, :float], :void
  ffi_func :rlMultMatrixf, [:ptr], :void
  ffi_func :rlFrustum, [:double, :double, :double, :double, :double, :double], :void
  ffi_func :rlOrtho, [:double, :double, :double, :double, :double, :double], :void
  ffi_func :rlViewport, [:int, :int, :int, :int], :void
  ffi_func :rlSetClipPlanes, [:double, :double], :void
  ffi_func :rlGetCullDistanceNear, [], :double
  ffi_func :rlGetCullDistanceFar, [], :double
  ffi_func :rlBegin, [:int], :void
  ffi_func :rlEnd, [], :void
  ffi_func :rlVertex2i, [:int, :int], :void
  ffi_func :rlVertex2f, [:float, :float], :void
  ffi_func :rlVertex3f, [:float, :float, :float], :void
  ffi_func :rlTexCoord2f, [:float, :float], :void
  ffi_func :rlNormal3f, [:float, :float, :float], :void
  ffi_func :rlColor4ub, [:uchar, :uchar, :uchar, :uchar], :void
  ffi_func :rlColor3f, [:float, :float, :float], :void
  ffi_func :rlColor4f, [:float, :float, :float, :float], :void
  ffi_func :rlEnableVertexArray, [:uint], :bool
  ffi_func :rlDisableVertexArray, [], :void
  ffi_func :rlEnableVertexBuffer, [:uint], :void
  ffi_func :rlDisableVertexBuffer, [], :void
  ffi_func :rlEnableVertexBufferElement, [:uint], :void
  ffi_func :rlDisableVertexBufferElement, [], :void
  ffi_func :rlEnableVertexAttribute, [:uint], :void
  ffi_func :rlDisableVertexAttribute, [:uint], :void
  ffi_func :rlEnableStatePointer, [:int, :ptr], :void
  ffi_func :rlDisableStatePointer, [:int], :void
  ffi_func :rlActiveTextureSlot, [:int], :void
  ffi_func :rlEnableTexture, [:uint], :void
  ffi_func :rlDisableTexture, [], :void
  ffi_func :rlEnableTextureCubemap, [:uint], :void
  ffi_func :rlDisableTextureCubemap, [], :void
  ffi_func :rlTextureParameters, [:uint, :int, :int], :void
  ffi_func :rlCubemapParameters, [:uint, :int, :int], :void
  ffi_func :rlEnableShader, [:uint], :void
  ffi_func :rlDisableShader, [], :void
  ffi_func :rlEnableFramebuffer, [:uint], :void
  ffi_func :rlDisableFramebuffer, [], :void
  ffi_func :rlGetActiveFramebuffer, [], :uint
  ffi_func :rlActiveDrawBuffers, [:int], :void
  ffi_func :rlBlitFramebuffer, [:int, :int, :int, :int, :int, :int, :int, :int, :int], :void
  ffi_func :rlBindFramebuffer, [:uint, :uint], :void
  ffi_func :rlEnableColorBlend, [], :void
  ffi_func :rlDisableColorBlend, [], :void
  ffi_func :rlEnableDepthTest, [], :void
  ffi_func :rlDisableDepthTest, [], :void
  ffi_func :rlEnableDepthMask, [], :void
  ffi_func :rlDisableDepthMask, [], :void
  ffi_func :rlEnableBackfaceCulling, [], :void
  ffi_func :rlDisableBackfaceCulling, [], :void
  ffi_func :rlColorMask, [:bool, :bool, :bool, :bool], :void
  ffi_func :rlSetCullFace, [:int], :void
  ffi_func :rlEnableScissorTest, [], :void
  ffi_func :rlDisableScissorTest, [], :void
  ffi_func :rlScissor, [:int, :int, :int, :int], :void
  ffi_func :rlEnablePointMode, [], :void
  ffi_func :rlDisablePointMode, [], :void
  ffi_func :rlSetPointSize, [:float], :void
  ffi_func :rlGetPointSize, [], :float
  ffi_func :rlEnableWireMode, [], :void
  ffi_func :rlDisableWireMode, [], :void
  ffi_func :rlSetLineWidth, [:float], :void
  ffi_func :rlGetLineWidth, [], :float
  ffi_func :rlEnableSmoothLines, [], :void
  ffi_func :rlDisableSmoothLines, [], :void
  ffi_func :rlEnableStereoRender, [], :void
  ffi_func :rlDisableStereoRender, [], :void
  ffi_func :rlIsStereoRenderEnabled, [], :bool
  ffi_func :rlClearColor, [:uchar, :uchar, :uchar, :uchar], :void
  ffi_func :rlClearScreenBuffers, [], :void
  ffi_func :rlCheckErrors, [], :void
  ffi_func :rlSetBlendMode, [:int], :void
  ffi_func :rlSetBlendFactors, [:int, :int, :int], :void
  ffi_func :rlSetBlendFactorsSeparate, [:int, :int, :int, :int, :int, :int], :void
  ffi_func :rlglInit, [:int, :int], :void
  ffi_func :rlglClose, [], :void
  ffi_func :rlLoadExtensions, [:ptr], :void
  ffi_func :rlGetProcAddress, [:str], :ptr
  ffi_func :rlGetVersion, [], :int
  ffi_func :rlSetFramebufferWidth, [:int], :void
  ffi_func :rlGetFramebufferWidth, [], :int
  ffi_func :rlSetFramebufferHeight, [:int], :void
  ffi_func :rlGetFramebufferHeight, [], :int
  ffi_func :rlGetTextureIdDefault, [], :uint
  ffi_func :rlGetShaderIdDefault, [], :uint
  ffi_func :rlGetShaderLocsDefault, [], :ptr
  ffi_func :rlLoadRenderBatch, [:int, :int], :void
  ffi_func :rl_rlUnloadRenderBatch, [:ptr], :void
  ffi_func :rlDrawRenderBatch, [:ptr], :void
  ffi_func :rlSetRenderBatchActive, [:ptr], :void
  ffi_func :rlDrawRenderBatchActive, [], :void
  ffi_func :rlCheckRenderBatchLimit, [:int], :bool
  ffi_func :rlSetTexture, [:uint], :void
  ffi_func :rlLoadVertexArray, [], :uint
  ffi_func :rlLoadVertexBuffer, [:ptr, :int, :bool], :uint
  ffi_func :rlLoadVertexBufferElement, [:ptr, :int, :bool], :uint
  ffi_func :rlUpdateVertexBuffer, [:uint, :ptr, :int, :int], :void
  ffi_func :rlUpdateVertexBufferElements, [:uint, :ptr, :int, :int], :void
  ffi_func :rlUnloadVertexArray, [:uint], :void
  ffi_func :rlUnloadVertexBuffer, [:uint], :void
  ffi_func :rlSetVertexAttribute, [:uint, :int, :int, :bool, :int, :int], :void
  ffi_func :rlSetVertexAttributeDivisor, [:uint, :int], :void
  ffi_func :rlSetVertexAttributeDefault, [:int, :ptr, :int, :int], :void
  ffi_func :rlDrawVertexArray, [:int, :int], :void
  ffi_func :rlDrawVertexArrayElements, [:int, :int, :ptr], :void
  ffi_func :rlDrawVertexArrayInstanced, [:int, :int, :int], :void
  ffi_func :rlDrawVertexArrayElementsInstanced, [:int, :int, :ptr, :int], :void
  ffi_func :rlLoadTexture, [:ptr, :int, :int, :int, :int], :uint
  ffi_func :rlLoadTextureDepth, [:int, :int, :bool], :uint
  ffi_func :rlLoadTextureCubemap, [:ptr, :int, :int, :int], :uint
  ffi_func :rlUpdateTexture, [:uint, :int, :int, :int, :int, :int, :ptr], :void
  ffi_func :rlGetGlTextureFormats, [:int, :ptr, :ptr, :ptr], :void
  ffi_func :rlGetPixelFormatName, [:uint], :str
  ffi_func :rlUnloadTexture, [:uint], :void
  ffi_func :rlGenTextureMipmaps, [:uint, :int, :int, :int, :ptr], :void
  ffi_func :rlReadTexturePixels, [:uint, :int, :int, :int], :ptr
  ffi_func :rlReadScreenPixels, [:int, :int], :ptr
  ffi_func :rlLoadFramebuffer, [], :uint
  ffi_func :rlFramebufferAttach, [:uint, :uint, :int, :int, :int], :void
  ffi_func :rlFramebufferComplete, [:uint], :bool
  ffi_func :rlUnloadFramebuffer, [:uint], :void
  ffi_func :rlCopyFramebuffer, [:int, :int, :int, :int, :int, :ptr], :void
  ffi_func :rlResizeFramebuffer, [:int, :int], :void
  ffi_func :rlLoadShader, [:str, :int], :uint
  ffi_func :rlLoadShaderProgram, [:str, :str], :uint
  ffi_func :rlLoadShaderProgramEx, [:uint, :uint], :uint
  ffi_func :rlLoadShaderProgramCompute, [:uint], :uint
  ffi_func :rlUnloadShader, [:uint], :void
  ffi_func :rlUnloadShaderProgram, [:uint], :void
  ffi_func :rlGetLocationUniform, [:uint, :str], :int
  ffi_func :rlGetLocationAttrib, [:uint, :str], :int
  ffi_func :rlSetUniform, [:int, :ptr, :int, :int], :void
  ffi_func :rl_rlSetUniformMatrix, [:int, :ptr], :void
  ffi_func :rlSetUniformMatrices, [:int, :ptr, :int], :void
  ffi_func :rlSetUniformSampler, [:int, :uint], :void
  ffi_func :rlSetShader, [:uint, :ptr], :void
  ffi_func :rlComputeShaderDispatch, [:uint, :uint, :uint], :void
  ffi_func :rlLoadShaderBuffer_ptr, [:uint, :ptr, :int], :uint
  ffi_func :rlUnloadShaderBuffer, [:uint], :void
  ffi_func :rlUpdateShaderBuffer_ptr, [:uint, :ptr, :uint, :uint], :void
  ffi_func :rlBindShaderBuffer, [:uint, :uint], :void
  ffi_func :rlReadShaderBuffer_ptr, [:uint, :ptr, :uint, :uint], :void
  # Shader-buffer data/dest are flat buffers: gem code passes FFI::MemoryPointer,
  # which cannot fill a :ptr slot, so the Integer address goes instead. The
  # *_ptr symbols are the C shims (raylib_adapter.c) that forward unchanged.
  def self.rlUpdateShaderBuffer(id, data, size, offset)
    Rlgl.rlUpdateShaderBuffer_ptr(id, Raylib.ptr_addr(data), size, offset)
  end
  def self.rlReadShaderBuffer(id, dest, size, offset)
    Rlgl.rlReadShaderBuffer_ptr(id, Raylib.ptr_addr(dest), size, offset)
  end
  def self.rlLoadShaderBuffer(size, data, usage)
    Rlgl.rlLoadShaderBuffer_ptr(size, Raylib.ptr_addr(data), usage)
  end
  ffi_func :rlCopyShaderBuffer, [:uint, :uint, :uint, :uint, :uint], :void
  ffi_func :rlGetShaderBufferSize, [:uint], :uint
  ffi_func :rlBindImageTexture, [:uint, :uint, :int, :bool], :void
  ffi_func :rl_rlGetMatrixModelview, [:ptr], :void
  ffi_func :rl_rlGetMatrixProjection, [:ptr], :void
  ffi_func :rl_rlGetMatrixTransform, [:ptr], :void
  ffi_func :rl_rlGetMatrixProjectionStereo, [:int, :ptr], :void
  ffi_func :rl_rlGetMatrixViewOffsetStereo, [:int, :ptr], :void
  ffi_func :rl_rlSetMatrixProjection, [:ptr], :void
  ffi_func :rl_rlSetMatrixModelview, [:ptr], :void
  ffi_func :rl_rlSetMatrixProjectionStereo, [:ptr, :ptr], :void
  ffi_func :rl_rlSetMatrixViewOffsetStereo, [:ptr, :ptr], :void
  ffi_func :rlLoadDrawCube, [], :void
  ffi_func :rlLoadDrawQuad, [], :void
  native_struct "Vector2", "rl_Vector2"
  native_new [], "rl_Vector2_new"
  native_struct "Vector3", "rl_Vector3"
  native_new [], "rl_Vector3_new"
  native_struct "Vector4", "rl_Vector4"
  native_new [], "rl_Vector4_new"
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
  native_struct "Color", "rl_Color"
  native_new [], "rl_Color_new"
  native_struct "Rectangle", "rl_Rectangle"
  native_new [], "rl_Rectangle_new"
  native_struct "Camera2D", "rl_Camera2D"
  native_new [], "rl_Camera2D_new"
  native_struct "BoundingBox", "rl_BoundingBox"
  native_new [], "rl_BoundingBox_new"
  native_struct "Ray", "rl_Ray"
  native_new [], "rl_Ray_new"
  native_struct "RayCollision", "rl_RayCollision"
  native_new [], "rl_RayCollision_new"
  native_struct "NPatchInfo", "rl_NPatchInfo"
  native_new [], "rl_NPatchInfo_new"
  native_struct "VrDeviceInfo", "rl_VrDeviceInfo"
  native_new [], "rl_VrDeviceInfo_new"
  native_struct "VrStereoConfig", "rl_VrStereoConfig"
  native_new [], "rl_VrStereoConfig_new"

  # Texture
  ffi_func :LoadTexture, [:str], :ptr
  ffi_func :LoadTextureCubemap, [%i[str int]], :ptr
  ffi_func :IsTextureValid, [:ptr], :bool
  ffi_func :UnloadTexture, [%i[ptr]], :void
  ffi_func :UpdateTexture, [:ptr, :ptr], :void
  ffi_func :GenTextureMipmaps, [:ptr], :void
  ffi_func :SetTextureFilter, [:ptr, :int], :void
  ffi_func :SetTextureWrap, [:ptr, :int], :void

  # Render texture
  ffi_func :LoadRenderTexture, [%i[int int]], :ptr
  ffi_func :IsRenderTextureValid, [:ptr], :bool
  ffi_func :UnloadRenderTexture, [%i[ptr]], :void
  ffi_func :UpdateTextureRec, [:ptr, :ptr, :ptr], :void
  ffi_func :DrawRenderTexture, [:ptr, :ptr], :void

  # Shader
  ffi_func :LoadShader, [%i[str str]], :ptr
  ffi_func :LoadShaderFromMemory, [%i[str str]], :ptr
  ffi_func :IsShaderValid, [:ptr], :bool
  ffi_func :UnloadShader, [%i[ptr]], :void
  ffi_func :SetShaderValue, [:ptr, :int, :ptr, :int], :void
  ffi_func :SetShaderValueV, [:ptr, :int, :ptr, :int, :int], :void
  ffi_func :SetShaderValueMatrix, [:ptr, :int, :ptr], :void
  ffi_func :SetShaderValueTexture, [:ptr, :int, :ptr], :void
  ffi_func :GetShaderLocation, [:ptr, :str], :int
  ffi_func :GetShaderLocationAttrib, [:ptr, :str], :int

  # Matrix
  ffi_func :MatrixCreate, [], :ptr
  ffi_func :MatrixGetElement, %i[ptr int], :float
  ffi_func :MatrixSetElement, %i[ptr int float], :void

  # Vector2
  ffi_func :Vector2Create, %i[float float], :ptr
  ffi_func :Vector2GetX, [:ptr], :float
  ffi_func :Vector2GetY, [:ptr], :float

  # Enums
  SHADE_SMOOTH = 0
  SHADE_FLAT = 1
  SHADE_POINT = 2

  # Constants

    # ====== generated: wrappers + constants ======
    def self.rlUnloadRenderBatch(batch)
      Rlgl.rl_rlUnloadRenderBatch(batch)
    end
    def self.rlSetUniformMatrix(locIndex, mat)
      Rlgl.rl_rlSetUniformMatrix(locIndex, mat)
    end
    def self.rlGetMatrixModelview()
      _out = Matrix.new
      Rlgl.rl_rlGetMatrixModelview(_out)
      _out
    end
    def self.rlGetMatrixProjection()
      _out = Matrix.new
      Rlgl.rl_rlGetMatrixProjection(_out)
      _out
    end
    def self.rlGetMatrixTransform()
      _out = Matrix.new
      Rlgl.rl_rlGetMatrixTransform(_out)
      _out
    end
    def self.rlGetMatrixProjectionStereo(eye)
      _out = Matrix.new
      Rlgl.rl_rlGetMatrixProjectionStereo(eye, _out)
      _out
    end
    def self.rlGetMatrixViewOffsetStereo(eye)
      _out = Matrix.new
      Rlgl.rl_rlGetMatrixViewOffsetStereo(eye, _out)
      _out
    end
    def self.rlSetMatrixProjection(proj)
      Rlgl.rl_rlSetMatrixProjection(proj)
    end
    def self.rlSetMatrixModelview(view)
      Rlgl.rl_rlSetMatrixModelview(view)
    end
    def self.rlSetMatrixProjectionStereo(right, left)
      Rlgl.rl_rlSetMatrixProjectionStereo(right, left)
    end
    def self.rlSetMatrixViewOffsetStereo(right, left)
      Rlgl.rl_rlSetMatrixViewOffsetStereo(right, left)
    end
    RL_OPENGL_SOFTWARE = 0
    RL_OPENGL_11 = 1
    RL_OPENGL_21 = 2
    RL_OPENGL_33 = 3
    RL_OPENGL_43 = 4
    RL_OPENGL_ES_20 = 5
    RL_OPENGL_ES_30 = 6
    RL_LOG_ALL = 0
    RL_LOG_TRACE = 1
    RL_LOG_DEBUG = 2
    RL_LOG_INFO = 3
    RL_LOG_WARNING = 4
    RL_LOG_ERROR = 5
    RL_LOG_FATAL = 6
    RL_LOG_NONE = 7
    RL_PIXELFORMAT_UNCOMPRESSED_GRAYSCALE = 1
    RL_PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA = 2
    RL_PIXELFORMAT_UNCOMPRESSED_R5G6B5 = 3
    RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8 = 4
    RL_PIXELFORMAT_UNCOMPRESSED_R5G5B5A1 = 5
    RL_PIXELFORMAT_UNCOMPRESSED_R4G4B4A4 = 6
    RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8A8 = 7
    RL_PIXELFORMAT_UNCOMPRESSED_R32 = 8
    RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32 = 9
    RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32A32 = 10
    RL_PIXELFORMAT_UNCOMPRESSED_R16 = 11
    RL_PIXELFORMAT_UNCOMPRESSED_R16G16B16 = 12
    RL_PIXELFORMAT_UNCOMPRESSED_R16G16B16A16 = 13
    RL_PIXELFORMAT_COMPRESSED_DXT1_RGB = 14
    RL_PIXELFORMAT_COMPRESSED_DXT1_RGBA = 15
    RL_PIXELFORMAT_COMPRESSED_DXT3_RGBA = 16
    RL_PIXELFORMAT_COMPRESSED_DXT5_RGBA = 17
    RL_PIXELFORMAT_COMPRESSED_ETC1_RGB = 18
    RL_PIXELFORMAT_COMPRESSED_ETC2_RGB = 19
    RL_PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA = 20
    RL_PIXELFORMAT_COMPRESSED_PVRT_RGB = 21
    RL_PIXELFORMAT_COMPRESSED_PVRT_RGBA = 22
    RL_PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA = 23
    RL_PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA = 24
    RL_TEXTURE_FILTER_POINT = 0
    RL_TEXTURE_FILTER_BILINEAR = 1
    RL_TEXTURE_FILTER_TRILINEAR = 2
    RL_TEXTURE_FILTER_ANISOTROPIC_4X = 3
    RL_TEXTURE_FILTER_ANISOTROPIC_8X = 4
    RL_TEXTURE_FILTER_ANISOTROPIC_16X = 5
    RL_BLEND_ALPHA = 0
    RL_BLEND_ADDITIVE = 1
    RL_BLEND_MULTIPLIED = 2
    RL_BLEND_ADD_COLORS = 3
    RL_BLEND_SUBTRACT_COLORS = 4
    RL_BLEND_ALPHA_PREMULTIPLY = 5
    RL_BLEND_CUSTOM = 6
    RL_BLEND_CUSTOM_SEPARATE = 7
    RL_SHADER_LOC_VERTEX_POSITION = 0
    RL_SHADER_LOC_VERTEX_TEXCOORD01 = 1
    RL_SHADER_LOC_VERTEX_TEXCOORD02 = 2
    RL_SHADER_LOC_VERTEX_NORMAL = 3
    RL_SHADER_LOC_VERTEX_TANGENT = 4
    RL_SHADER_LOC_VERTEX_COLOR = 5
    RL_SHADER_LOC_MATRIX_MVP = 6
    RL_SHADER_LOC_MATRIX_VIEW = 7
    RL_SHADER_LOC_MATRIX_PROJECTION = 8
    RL_SHADER_LOC_MATRIX_MODEL = 9
    RL_SHADER_LOC_MATRIX_NORMAL = 10
    RL_SHADER_LOC_VECTOR_VIEW = 11
    RL_SHADER_LOC_COLOR_DIFFUSE = 12
    RL_SHADER_LOC_COLOR_SPECULAR = 13
    RL_SHADER_LOC_COLOR_AMBIENT = 14
    RL_SHADER_LOC_MAP_ALBEDO = 15
    RL_SHADER_LOC_MAP_METALNESS = 16
    RL_SHADER_LOC_MAP_NORMAL = 17
    RL_SHADER_LOC_MAP_ROUGHNESS = 18
    RL_SHADER_LOC_MAP_OCCLUSION = 19
    RL_SHADER_LOC_MAP_EMISSION = 20
    RL_SHADER_LOC_MAP_HEIGHT = 21
    RL_SHADER_LOC_MAP_CUBEMAP = 22
    RL_SHADER_LOC_MAP_IRRADIANCE = 23
    RL_SHADER_LOC_MAP_PREFILTER = 24
    RL_SHADER_LOC_MAP_BRDF = 25
    RL_SHADER_UNIFORM_FLOAT = 0
    RL_SHADER_UNIFORM_VEC2 = 1
    RL_SHADER_UNIFORM_VEC3 = 2
    RL_SHADER_UNIFORM_VEC4 = 3
    RL_SHADER_UNIFORM_INT = 4
    RL_SHADER_UNIFORM_IVEC2 = 5
    RL_SHADER_UNIFORM_IVEC3 = 6
    RL_SHADER_UNIFORM_IVEC4 = 7
    RL_SHADER_UNIFORM_UINT = 8
    RL_SHADER_UNIFORM_UIVEC2 = 9
    RL_SHADER_UNIFORM_UIVEC3 = 10
    RL_SHADER_UNIFORM_UIVEC4 = 11
    RL_SHADER_UNIFORM_SAMPLER2D = 12
    RL_SHADER_ATTRIB_FLOAT = 0
    RL_SHADER_ATTRIB_VEC2 = 1
    RL_SHADER_ATTRIB_VEC3 = 2
    RL_SHADER_ATTRIB_VEC4 = 3
    RL_ATTACHMENT_COLOR_CHANNEL0 = 0
    RL_ATTACHMENT_COLOR_CHANNEL1 = 1
    RL_ATTACHMENT_COLOR_CHANNEL2 = 2
    RL_ATTACHMENT_COLOR_CHANNEL3 = 3
    RL_ATTACHMENT_COLOR_CHANNEL4 = 4
    RL_ATTACHMENT_COLOR_CHANNEL5 = 5
    RL_ATTACHMENT_COLOR_CHANNEL6 = 6
    RL_ATTACHMENT_COLOR_CHANNEL7 = 7
    RL_ATTACHMENT_DEPTH = 100
    RL_ATTACHMENT_STENCIL = 200
    RL_ATTACHMENT_CUBEMAP_POSITIVE_X = 0
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_X = 1
    RL_ATTACHMENT_CUBEMAP_POSITIVE_Y = 2
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_Y = 3
    RL_ATTACHMENT_CUBEMAP_POSITIVE_Z = 4
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_Z = 5
    RL_ATTACHMENT_TEXTURE2D = 100
    RL_ATTACHMENT_RENDERBUFFER = 200
    RL_CULL_FACE_FRONT = 0
    RL_CULL_FACE_BACK = 1
    RLGL_VERSION = 6.0
    RL_DEFAULT_BATCH_BUFFER_ELEMENTS = 8192
    RL_DEFAULT_BATCH_BUFFERS = 1
    RL_DEFAULT_BATCH_DRAWCALLS = 256
    RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS = 4
    RL_MAX_MATRIX_STACK_SIZE = 32
    RL_MAX_SHADER_LOCATIONS = 32
    RL_CULL_DISTANCE_NEAR = 0.05
    RL_CULL_DISTANCE_FAR = 4000.0
    RL_TEXTURE_WRAP_S = 10242
    RL_TEXTURE_WRAP_T = 10243
    RL_TEXTURE_MAG_FILTER = 10240
    RL_TEXTURE_MIN_FILTER = 10241
    RL_TEXTURE_FILTER_NEAREST = 9728
    RL_TEXTURE_FILTER_LINEAR = 9729
    RL_TEXTURE_FILTER_MIP_NEAREST = 9984
    RL_TEXTURE_FILTER_NEAREST_MIP_LINEAR = 9986
    RL_TEXTURE_FILTER_LINEAR_MIP_NEAREST = 9985
    RL_TEXTURE_FILTER_MIP_LINEAR = 9987
    RL_TEXTURE_FILTER_ANISOTROPIC = 12288
    RL_TEXTURE_MIPMAP_BIAS_RATIO = 16384
    RL_TEXTURE_WRAP_REPEAT = 10497
    RL_TEXTURE_WRAP_CLAMP = 33071
    RL_TEXTURE_WRAP_MIRROR_REPEAT = 33648
    RL_TEXTURE_WRAP_MIRROR_CLAMP = 34626
    RL_MODELVIEW = 5888
    RL_PROJECTION = 5889
    RL_TEXTURE = 5890
    RL_LINES = 1
    RL_TRIANGLES = 4
    RL_QUADS = 7
    RL_UNSIGNED_BYTE = 5121
    RL_FLOAT = 5126
    RL_STREAM_DRAW = 35040
    RL_STREAM_READ = 35041
    RL_STREAM_COPY = 35042
    RL_STATIC_DRAW = 35044
    RL_STATIC_READ = 35045
    RL_STATIC_COPY = 35046
    RL_DYNAMIC_DRAW = 35048
    RL_DYNAMIC_READ = 35049
    RL_DYNAMIC_COPY = 35050
    RL_FRAGMENT_SHADER = 35632
    RL_VERTEX_SHADER = 35633
    RL_COMPUTE_SHADER = 37305
    RL_ZERO = 0
    RL_ONE = 1
    RL_SRC_COLOR = 768
    RL_ONE_MINUS_SRC_COLOR = 769
    RL_SRC_ALPHA = 770
    RL_ONE_MINUS_SRC_ALPHA = 771
    RL_DST_ALPHA = 772
    RL_ONE_MINUS_DST_ALPHA = 773
    RL_DST_COLOR = 774
    RL_ONE_MINUS_DST_COLOR = 775
    RL_SRC_ALPHA_SATURATE = 776
    RL_CONSTANT_COLOR = 32769
    RL_ONE_MINUS_CONSTANT_COLOR = 32770
    RL_CONSTANT_ALPHA = 32771
    RL_ONE_MINUS_CONSTANT_ALPHA = 32772
    RL_FUNC_ADD = 32774
    RL_MIN = 32775
    RL_MAX = 32776
    RL_FUNC_SUBTRACT = 32778
    RL_FUNC_REVERSE_SUBTRACT = 32779
    RL_BLEND_EQUATION = 32777
    RL_BLEND_EQUATION_RGB = 32777
    RL_BLEND_EQUATION_ALPHA = 34877
    RL_BLEND_DST_RGB = 32968
    RL_BLEND_SRC_RGB = 32969
    RL_BLEND_DST_ALPHA = 32970
    RL_BLEND_SRC_ALPHA = 32971
    RL_BLEND_COLOR = 32773
    RL_READ_FRAMEBUFFER = 36008
    RL_DRAW_FRAMEBUFFER = 36009
    RL_DEFAULT_SHADER_ATTRIB_LOCATION_POSITION = 0
    RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD = 1
    RL_DEFAULT_SHADER_ATTRIB_LOCATION_NORMAL = 2
    RL_DEFAULT_SHADER_ATTRIB_LOCATION_COLOR = 3
    RL_DEFAULT_SHADER_ATTRIB_LOCATION_TANGENT = 4
    RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD2 = 5
    RL_DEFAULT_SHADER_ATTRIB_LOCATION_INDICES = 6
    RL_DEFAULT_SHADER_ATTRIB_LOCATION_BONEINDICES = 7
    RL_DEFAULT_SHADER_ATTRIB_LOCATION_BONEWEIGHTS = 8
    RL_DEFAULT_SHADER_ATTRIB_LOCATION_INSTANCETRANSFORM = 9

    # ====== generated: wrappers + constants ======

  # ====== generated: snake_case aliases (MRI gem naming) ======
  def self.rl_matrix_mode(p0)
    Rlgl.rlMatrixMode(p0)
  end
  def self.rl_push_matrix()
    Rlgl.rlPushMatrix()
  end
  def self.rl_pop_matrix()
    Rlgl.rlPopMatrix()
  end
  def self.rl_load_identity()
    Rlgl.rlLoadIdentity()
  end
  def self.rl_translatef(p0, p1, p2)
    Rlgl.rlTranslatef(p0, p1, p2)
  end
  def self.rl_rotatef(p0, p1, p2, p3)
    Rlgl.rlRotatef(p0, p1, p2, p3)
  end
  def self.rl_scalef(p0, p1, p2)
    Rlgl.rlScalef(p0, p1, p2)
  end
  def self.rl_mult_matrixf(p0)
    Rlgl.rlMultMatrixf(p0)
  end
  def self.rl_frustum(p0, p1, p2, p3, p4, p5)
    Rlgl.rlFrustum(p0, p1, p2, p3, p4, p5)
  end
  def self.rl_ortho(p0, p1, p2, p3, p4, p5)
    Rlgl.rlOrtho(p0, p1, p2, p3, p4, p5)
  end
  def self.rl_viewport(p0, p1, p2, p3)
    Rlgl.rlViewport(p0, p1, p2, p3)
  end
  def self.rl_set_clip_planes(p0, p1)
    Rlgl.rlSetClipPlanes(p0, p1)
  end
  def self.rl_get_cull_distance_near()
    Rlgl.rlGetCullDistanceNear()
  end
  def self.rl_get_cull_distance_far()
    Rlgl.rlGetCullDistanceFar()
  end
  def self.rl_begin(p0)
    Rlgl.rlBegin(p0)
  end
  def self.rl_end()
    Rlgl.rlEnd()
  end
  def self.rl_vertex_2i(p0, p1)
    Rlgl.rlVertex2i(p0, p1)
  end
  def self.rl_vertex_2f(p0, p1)
    Rlgl.rlVertex2f(p0, p1)
  end
  def self.rl_vertex_3f(p0, p1, p2)
    Rlgl.rlVertex3f(p0, p1, p2)
  end
  def self.rl_tex_coord_2f(p0, p1)
    Rlgl.rlTexCoord2f(p0, p1)
  end
  def self.rl_normal_3f(p0, p1, p2)
    Rlgl.rlNormal3f(p0, p1, p2)
  end
  def self.rl_color_4ub(p0, p1, p2, p3)
    Rlgl.rlColor4ub(p0, p1, p2, p3)
  end
  def self.rl_color_3f(p0, p1, p2)
    Rlgl.rlColor3f(p0, p1, p2)
  end
  def self.rl_color_4f(p0, p1, p2, p3)
    Rlgl.rlColor4f(p0, p1, p2, p3)
  end
  def self.rl_enable_vertex_array(p0)
    Rlgl.rlEnableVertexArray(p0)
  end
  def self.rl_disable_vertex_array()
    Rlgl.rlDisableVertexArray()
  end
  def self.rl_enable_vertex_buffer(p0)
    Rlgl.rlEnableVertexBuffer(p0)
  end
  def self.rl_disable_vertex_buffer()
    Rlgl.rlDisableVertexBuffer()
  end
  def self.rl_enable_vertex_buffer_element(p0)
    Rlgl.rlEnableVertexBufferElement(p0)
  end
  def self.rl_disable_vertex_buffer_element()
    Rlgl.rlDisableVertexBufferElement()
  end
  def self.rl_enable_vertex_attribute(p0)
    Rlgl.rlEnableVertexAttribute(p0)
  end
  def self.rl_disable_vertex_attribute(p0)
    Rlgl.rlDisableVertexAttribute(p0)
  end
  def self.rl_enable_state_pointer(p0, p1)
    Rlgl.rlEnableStatePointer(p0, p1)
  end
  def self.rl_disable_state_pointer(p0)
    Rlgl.rlDisableStatePointer(p0)
  end
  def self.rl_active_texture_slot(p0)
    Rlgl.rlActiveTextureSlot(p0)
  end
  def self.rl_enable_texture(p0)
    Rlgl.rlEnableTexture(p0)
  end
  def self.rl_disable_texture()
    Rlgl.rlDisableTexture()
  end
  def self.rl_enable_texture_cubemap(p0)
    Rlgl.rlEnableTextureCubemap(p0)
  end
  def self.rl_disable_texture_cubemap()
    Rlgl.rlDisableTextureCubemap()
  end
  def self.rl_texture_parameters(p0, p1, p2)
    Rlgl.rlTextureParameters(p0, p1, p2)
  end
  def self.rl_cubemap_parameters(p0, p1, p2)
    Rlgl.rlCubemapParameters(p0, p1, p2)
  end
  def self.rl_enable_shader(p0)
    Rlgl.rlEnableShader(p0)
  end
  def self.rl_disable_shader()
    Rlgl.rlDisableShader()
  end
  def self.rl_enable_framebuffer(p0)
    Rlgl.rlEnableFramebuffer(p0)
  end
  def self.rl_disable_framebuffer()
    Rlgl.rlDisableFramebuffer()
  end
  def self.rl_get_active_framebuffer()
    Rlgl.rlGetActiveFramebuffer()
  end
  def self.rl_active_draw_buffers(p0)
    Rlgl.rlActiveDrawBuffers(p0)
  end
  def self.rl_blit_framebuffer(p0, p1, p2, p3, p4, p5, p6, p7, p8)
    Rlgl.rlBlitFramebuffer(p0, p1, p2, p3, p4, p5, p6, p7, p8)
  end
  def self.rl_bind_framebuffer(p0, p1)
    Rlgl.rlBindFramebuffer(p0, p1)
  end
  def self.rl_enable_color_blend()
    Rlgl.rlEnableColorBlend()
  end
  def self.rl_disable_color_blend()
    Rlgl.rlDisableColorBlend()
  end
  def self.rl_enable_depth_test()
    Rlgl.rlEnableDepthTest()
  end
  def self.rl_disable_depth_test()
    Rlgl.rlDisableDepthTest()
  end
  def self.rl_enable_depth_mask()
    Rlgl.rlEnableDepthMask()
  end
  def self.rl_disable_depth_mask()
    Rlgl.rlDisableDepthMask()
  end
  def self.rl_enable_backface_culling()
    Rlgl.rlEnableBackfaceCulling()
  end
  def self.rl_disable_backface_culling()
    Rlgl.rlDisableBackfaceCulling()
  end
  def self.rl_color_mask(p0, p1, p2, p3)
    Rlgl.rlColorMask(p0, p1, p2, p3)
  end
  def self.rl_set_cull_face(p0)
    Rlgl.rlSetCullFace(p0)
  end
  def self.rl_enable_scissor_test()
    Rlgl.rlEnableScissorTest()
  end
  def self.rl_disable_scissor_test()
    Rlgl.rlDisableScissorTest()
  end
  def self.rl_scissor(p0, p1, p2, p3)
    Rlgl.rlScissor(p0, p1, p2, p3)
  end
  def self.rl_enable_point_mode()
    Rlgl.rlEnablePointMode()
  end
  def self.rl_disable_point_mode()
    Rlgl.rlDisablePointMode()
  end
  def self.rl_set_point_size(p0)
    Rlgl.rlSetPointSize(p0)
  end
  def self.rl_get_point_size()
    Rlgl.rlGetPointSize()
  end
  def self.rl_enable_wire_mode()
    Rlgl.rlEnableWireMode()
  end
  def self.rl_disable_wire_mode()
    Rlgl.rlDisableWireMode()
  end
  def self.rl_set_line_width(p0)
    Rlgl.rlSetLineWidth(p0)
  end
  def self.rl_get_line_width()
    Rlgl.rlGetLineWidth()
  end
  def self.rl_enable_smooth_lines()
    Rlgl.rlEnableSmoothLines()
  end
  def self.rl_disable_smooth_lines()
    Rlgl.rlDisableSmoothLines()
  end
  def self.rl_enable_stereo_render()
    Rlgl.rlEnableStereoRender()
  end
  def self.rl_disable_stereo_render()
    Rlgl.rlDisableStereoRender()
  end
  def self.rl_is_stereo_render_enabled()
    Rlgl.rlIsStereoRenderEnabled()
  end
  def self.rl_clear_color(p0, p1, p2, p3)
    Rlgl.rlClearColor(p0, p1, p2, p3)
  end
  def self.rl_clear_screen_buffers()
    Rlgl.rlClearScreenBuffers()
  end
  def self.rl_check_errors()
    Rlgl.rlCheckErrors()
  end
  def self.rl_set_blend_mode(p0)
    Rlgl.rlSetBlendMode(p0)
  end
  def self.rl_set_blend_factors(p0, p1, p2)
    Rlgl.rlSetBlendFactors(p0, p1, p2)
  end
  def self.rl_set_blend_factors_separate(p0, p1, p2, p3, p4, p5)
    Rlgl.rlSetBlendFactorsSeparate(p0, p1, p2, p3, p4, p5)
  end
  def self.rlgl_init(p0, p1)
    Rlgl.rlglInit(p0, p1)
  end
  def self.rlgl_close()
    Rlgl.rlglClose()
  end
  def self.rl_load_extensions(p0)
    Rlgl.rlLoadExtensions(p0)
  end
  def self.rl_get_proc_address(p0)
    Rlgl.rlGetProcAddress(p0)
  end
  def self.rl_get_version()
    Rlgl.rlGetVersion()
  end
  def self.rl_set_framebuffer_width(p0)
    Rlgl.rlSetFramebufferWidth(p0)
  end
  def self.rl_get_framebuffer_width()
    Rlgl.rlGetFramebufferWidth()
  end
  def self.rl_set_framebuffer_height(p0)
    Rlgl.rlSetFramebufferHeight(p0)
  end
  def self.rl_get_framebuffer_height()
    Rlgl.rlGetFramebufferHeight()
  end
  def self.rl_get_texture_id_default()
    Rlgl.rlGetTextureIdDefault()
  end
  def self.rl_get_shader_id_default()
    Rlgl.rlGetShaderIdDefault()
  end
  def self.rl_get_shader_locs_default()
    Rlgl.rlGetShaderLocsDefault()
  end
  def self.rl_load_render_batch(p0, p1)
    Rlgl.rlLoadRenderBatch(p0, p1)
  end
  def self.rl_draw_render_batch(p0)
    Rlgl.rlDrawRenderBatch(p0)
  end
  def self.rl_set_render_batch_active(p0)
    Rlgl.rlSetRenderBatchActive(p0)
  end
  def self.rl_draw_render_batch_active()
    Rlgl.rlDrawRenderBatchActive()
  end
  def self.rl_check_render_batch_limit(p0)
    Rlgl.rlCheckRenderBatchLimit(p0)
  end
  def self.rl_set_texture(p0)
    Rlgl.rlSetTexture(p0)
  end
  def self.rl_load_vertex_array()
    Rlgl.rlLoadVertexArray()
  end
  def self.rl_load_vertex_buffer(p0, p1, p2)
    Rlgl.rlLoadVertexBuffer(p0, p1, p2)
  end
  def self.rl_load_vertex_buffer_element(p0, p1, p2)
    Rlgl.rlLoadVertexBufferElement(p0, p1, p2)
  end
  def self.rl_update_vertex_buffer(p0, p1, p2, p3)
    Rlgl.rlUpdateVertexBuffer(p0, p1, p2, p3)
  end
  def self.rl_update_vertex_buffer_elements(p0, p1, p2, p3)
    Rlgl.rlUpdateVertexBufferElements(p0, p1, p2, p3)
  end
  def self.rl_unload_vertex_array(p0)
    Rlgl.rlUnloadVertexArray(p0)
  end
  def self.rl_unload_vertex_buffer(p0)
    Rlgl.rlUnloadVertexBuffer(p0)
  end
  def self.rl_set_vertex_attribute(p0, p1, p2, p3, p4, p5)
    Rlgl.rlSetVertexAttribute(p0, p1, p2, p3, p4, p5)
  end
  def self.rl_set_vertex_attribute_divisor(p0, p1)
    Rlgl.rlSetVertexAttributeDivisor(p0, p1)
  end
  def self.rl_set_vertex_attribute_default(p0, p1, p2, p3)
    Rlgl.rlSetVertexAttributeDefault(p0, p1, p2, p3)
  end
  def self.rl_draw_vertex_array(p0, p1)
    Rlgl.rlDrawVertexArray(p0, p1)
  end
  def self.rl_draw_vertex_array_elements(p0, p1, p2)
    Rlgl.rlDrawVertexArrayElements(p0, p1, p2)
  end
  def self.rl_draw_vertex_array_instanced(p0, p1, p2)
    Rlgl.rlDrawVertexArrayInstanced(p0, p1, p2)
  end
  def self.rl_draw_vertex_array_elements_instanced(p0, p1, p2, p3)
    Rlgl.rlDrawVertexArrayElementsInstanced(p0, p1, p2, p3)
  end
  def self.rl_load_texture(p0, p1, p2, p3, p4)
    Rlgl.rlLoadTexture(p0, p1, p2, p3, p4)
  end
  def self.rl_load_texture_depth(p0, p1, p2)
    Rlgl.rlLoadTextureDepth(p0, p1, p2)
  end
  def self.rl_load_texture_cubemap(p0, p1, p2, p3)
    Rlgl.rlLoadTextureCubemap(p0, p1, p2, p3)
  end
  def self.rl_update_texture(p0, p1, p2, p3, p4, p5, p6)
    Rlgl.rlUpdateTexture(p0, p1, p2, p3, p4, p5, p6)
  end
  def self.rl_get_gl_texture_formats(p0, p1, p2, p3)
    Rlgl.rlGetGlTextureFormats(p0, p1, p2, p3)
  end
  def self.rl_get_pixel_format_name(p0)
    Rlgl.rlGetPixelFormatName(p0)
  end
  def self.rl_unload_texture(p0)
    Rlgl.rlUnloadTexture(p0)
  end
  def self.rl_gen_texture_mipmaps(p0, p1, p2, p3, p4)
    Rlgl.rlGenTextureMipmaps(p0, p1, p2, p3, p4)
  end
  def self.rl_read_texture_pixels(p0, p1, p2, p3)
    Rlgl.rlReadTexturePixels(p0, p1, p2, p3)
  end
  def self.rl_read_screen_pixels(p0, p1)
    Rlgl.rlReadScreenPixels(p0, p1)
  end
  def self.rl_load_framebuffer()
    Rlgl.rlLoadFramebuffer()
  end
  def self.rl_framebuffer_attach(p0, p1, p2, p3, p4)
    Rlgl.rlFramebufferAttach(p0, p1, p2, p3, p4)
  end
  def self.rl_framebuffer_complete(p0)
    Rlgl.rlFramebufferComplete(p0)
  end
  def self.rl_unload_framebuffer(p0)
    Rlgl.rlUnloadFramebuffer(p0)
  end
  def self.rl_copy_framebuffer(p0, p1, p2, p3, p4, p5)
    Rlgl.rlCopyFramebuffer(p0, p1, p2, p3, p4, p5)
  end
  def self.rl_resize_framebuffer(p0, p1)
    Rlgl.rlResizeFramebuffer(p0, p1)
  end
  def self.rl_load_shader(p0, p1)
    Rlgl.rlLoadShader(p0, p1)
  end
  def self.rl_load_shader_program(p0, p1)
    Rlgl.rlLoadShaderProgram(p0, p1)
  end
  def self.rl_load_shader_program_ex(p0, p1)
    Rlgl.rlLoadShaderProgramEx(p0, p1)
  end
  def self.rl_load_shader_program_compute(p0)
    Rlgl.rlLoadShaderProgramCompute(p0)
  end
  def self.rl_unload_shader(p0)
    Rlgl.rlUnloadShader(p0)
  end
  def self.rl_unload_shader_program(p0)
    Rlgl.rlUnloadShaderProgram(p0)
  end
  def self.rl_get_location_uniform(p0, p1)
    Rlgl.rlGetLocationUniform(p0, p1)
  end
  def self.rl_get_location_attrib(p0, p1)
    Rlgl.rlGetLocationAttrib(p0, p1)
  end
  def self.rl_set_uniform(p0, p1, p2, p3)
    Rlgl.rlSetUniform(p0, p1, p2, p3)
  end
  def self.rl_set_uniform_matrices(p0, p1, p2)
    Rlgl.rlSetUniformMatrices(p0, p1, p2)
  end
  def self.rl_set_uniform_sampler(p0, p1)
    Rlgl.rlSetUniformSampler(p0, p1)
  end
  def self.rl_set_shader(p0, p1)
    Rlgl.rlSetShader(p0, p1)
  end
  def self.rl_compute_shader_dispatch(p0, p1, p2)
    Rlgl.rlComputeShaderDispatch(p0, p1, p2)
  end
  def self.rl_load_shader_buffer(p0, p1, p2)
    Rlgl.rlLoadShaderBuffer(p0, p1, p2)
  end
  def self.rl_unload_shader_buffer(p0)
    Rlgl.rlUnloadShaderBuffer(p0)
  end
  def self.rl_update_shader_buffer(p0, p1, p2, p3)
    Rlgl.rlUpdateShaderBuffer(p0, p1, p2, p3)
  end
  def self.rl_bind_shader_buffer(p0, p1)
    Rlgl.rlBindShaderBuffer(p0, p1)
  end
  def self.rl_read_shader_buffer(p0, p1, p2, p3)
    Rlgl.rlReadShaderBuffer(p0, p1, p2, p3)
  end
  def self.rl_copy_shader_buffer(p0, p1, p2, p3, p4)
    Rlgl.rlCopyShaderBuffer(p0, p1, p2, p3, p4)
  end
  def self.rl_get_shader_buffer_size(p0)
    Rlgl.rlGetShaderBufferSize(p0)
  end
  def self.rl_bind_image_texture(p0, p1, p2, p3)
    Rlgl.rlBindImageTexture(p0, p1, p2, p3)
  end
  def self.rl_load_draw_cube()
    Rlgl.rlLoadDrawCube()
  end
  def self.rl_load_draw_quad()
    Rlgl.rlLoadDrawQuad()
  end
  class << self
    alias_method :rl_unload_render_batch, :rlUnloadRenderBatch
    alias_method :rl_set_uniform_matrix, :rlSetUniformMatrix
    alias_method :rl_get_matrix_modelview, :rlGetMatrixModelview
    alias_method :rl_get_matrix_projection, :rlGetMatrixProjection
    alias_method :rl_get_matrix_transform, :rlGetMatrixTransform
    alias_method :rl_get_matrix_projection_stereo, :rlGetMatrixProjectionStereo
    alias_method :rl_get_matrix_view_offset_stereo, :rlGetMatrixViewOffsetStereo
    alias_method :rl_set_matrix_projection, :rlSetMatrixProjection
    alias_method :rl_set_matrix_modelview, :rlSetMatrixModelview
    alias_method :rl_set_matrix_projection_stereo, :rlSetMatrixProjectionStereo
    alias_method :rl_set_matrix_view_offset_stereo, :rlSetMatrixViewOffsetStereo
  end
  end
