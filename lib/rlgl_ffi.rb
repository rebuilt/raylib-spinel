# rlgl_ffi.rb — FFI declarations for Spinel AOT
# Under MRI, ffi_func/ffi_lib/ffi_cflags are no-ops defined in main.rb

module Rlgl
  ffi_lib "raylib"
  ffi_cflags "-I/usr/local/include"

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
  ffi_func :sp_rlUnloadRenderBatch, [:ptr], :void
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
  ffi_func :sp_rlSetUniformMatrix, [:int, :ptr], :void
  ffi_func :rlSetUniformMatrices, [:int, :ptr, :int], :void
  ffi_func :rlSetUniformSampler, [:int, :uint], :void
  ffi_func :rlSetShader, [:uint, :ptr], :void
  ffi_func :rlComputeShaderDispatch, [:uint, :uint, :uint], :void
  ffi_func :rlLoadShaderBuffer, [:uint, :ptr, :int], :uint
  ffi_func :rlUnloadShaderBuffer, [:uint], :void
  ffi_func :rlUpdateShaderBuffer, [:uint, :ptr, :uint, :uint], :void
  ffi_func :rlBindShaderBuffer, [:uint, :uint], :void
  ffi_func :rlReadShaderBuffer, [:uint, :ptr, :uint, :uint], :void
  ffi_func :rlCopyShaderBuffer, [:uint, :uint, :uint, :uint, :uint], :void
  ffi_func :rlGetShaderBufferSize, [:uint], :uint
  ffi_func :rlBindImageTexture, [:uint, :uint, :int, :bool], :void
  ffi_func :sp_rlGetMatrixModelview, [:ptr], :void
  ffi_func :sp_rlGetMatrixProjection, [:ptr], :void
  ffi_func :sp_rlGetMatrixTransform, [:ptr], :void
  ffi_func :sp_rlGetMatrixProjectionStereo, [:int, :ptr], :void
  ffi_func :sp_rlGetMatrixViewOffsetStereo, [:int, :ptr], :void
  ffi_func :sp_rlSetMatrixProjection, [:ptr], :void
  ffi_func :sp_rlSetMatrixModelview, [:ptr], :void
  ffi_func :sp_rlSetMatrixProjectionStereo, [:ptr, :ptr], :void
  ffi_func :sp_rlSetMatrixViewOffsetStereo, [:ptr, :ptr], :void
  ffi_func :rlLoadDrawCube, [], :void
  ffi_func :rlLoadDrawQuad, [], :void
  native_struct "Vector2", "sp_Vector2"
  native_new [], "sp_Vector2_new"
  native_struct "Vector3", "sp_Vector3"
  native_new [], "sp_Vector3_new"
  native_struct "Vector4", "sp_Vector4"
  native_new [], "sp_Vector4_new"
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
  native_struct "Color", "sp_Color"
  native_new [], "sp_Color_new"
  native_struct "Rectangle", "sp_Rectangle"
  native_new [], "sp_Rectangle_new"
  native_struct "Camera2D", "sp_Camera2D"
  native_new [], "sp_Camera2D_new"
  native_struct "BoundingBox", "sp_BoundingBox"
  native_new [], "sp_BoundingBox_new"
  native_struct "Ray", "sp_Ray"
  native_new [], "sp_Ray_new"
  native_struct "RayCollision", "sp_RayCollision"
  native_new [], "sp_RayCollision_new"
  native_struct "NPatchInfo", "sp_NPatchInfo"
  native_new [], "sp_NPatchInfo_new"
  native_struct "VrDeviceInfo", "sp_VrDeviceInfo"
  native_new [], "sp_VrDeviceInfo_new"
  native_struct "VrStereoConfig", "sp_VrStereoConfig"
  native_new [], "sp_VrStereoConfig_new"

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
      Rlgl.sp_rlUnloadRenderBatch(batch)
    end
    def self.rlSetUniformMatrix(locIndex, mat)
      Rlgl.sp_rlSetUniformMatrix(locIndex, mat)
    end
    def self.rlGetMatrixModelview()
      _out = Matrix.new
      Rlgl.sp_rlGetMatrixModelview(_out)
      _out
    end
    def self.rlGetMatrixProjection()
      _out = Matrix.new
      Rlgl.sp_rlGetMatrixProjection(_out)
      _out
    end
    def self.rlGetMatrixTransform()
      _out = Matrix.new
      Rlgl.sp_rlGetMatrixTransform(_out)
      _out
    end
    def self.rlGetMatrixProjectionStereo(eye)
      _out = Matrix.new
      Rlgl.sp_rlGetMatrixProjectionStereo(eye, _out)
      _out
    end
    def self.rlGetMatrixViewOffsetStereo(eye)
      _out = Matrix.new
      Rlgl.sp_rlGetMatrixViewOffsetStereo(eye, _out)
      _out
    end
    def self.rlSetMatrixProjection(proj)
      Rlgl.sp_rlSetMatrixProjection(proj)
    end
    def self.rlSetMatrixModelview(view)
      Rlgl.sp_rlSetMatrixModelview(view)
    end
    def self.rlSetMatrixProjectionStereo(right, left)
      Rlgl.sp_rlSetMatrixProjectionStereo(right, left)
    end
    def self.rlSetMatrixViewOffsetStereo(right, left)
      Rlgl.sp_rlSetMatrixViewOffsetStereo(right, left)
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
  end
