# frozen_string_literal: true

# The audio structs (Wave, AudioStream, Sound, Music) as view classes, plus the
# shims for the audio functions raylib takes/returns by value. Hand-written:
# regenerating raylib_ffi.rb cannot drop it, and tools/wrap_audio.rb reshapes the
# generated wrappers onto these shims.
module Raylib
  native_struct "Wave", "rl_Wave"
  native_new [], "rl_Wave_new"
  native_new [:any, :any], "rl_Wave_view"
  native_method :frameCount, [], :int, "rl_m_Wave_frameCount"
  native_method :frameCount=, [:int], :int, "rl_m_Wave_set_frameCount"
  native_method :sampleRate, [], :int, "rl_m_Wave_sampleRate"
  native_method :sampleRate=, [:int], :int, "rl_m_Wave_set_sampleRate"
  native_method :sampleSize, [], :int, "rl_m_Wave_sampleSize"
  native_method :sampleSize=, [:int], :int, "rl_m_Wave_set_sampleSize"
  native_method :channels, [], :int, "rl_m_Wave_channels"
  native_method :channels=, [:int], :int, "rl_m_Wave_set_channels"
  ffi_func :rl_m_Wave_data, [:ptr], :long
  native_method :data=, [:any], :void, "rl_Wave_set_data"

  native_struct "AudioStream", "rl_AudioStream"
  native_new [], "rl_AudioStream_new"
  native_new [:any, :any], "rl_AudioStream_view"
  ffi_func :rl_m_AudioStream_buffer, [:ptr], :long
  native_method :buffer=, [:any], :void, "rl_AudioStream_set_buffer"
  ffi_func :rl_m_AudioStream_processor, [:ptr], :long
  native_method :processor=, [:any], :void, "rl_AudioStream_set_processor"
  native_method :sampleRate, [], :int, "rl_m_AudioStream_sampleRate"
  native_method :sampleRate=, [:int], :int, "rl_m_AudioStream_set_sampleRate"
  native_method :sampleSize, [], :int, "rl_m_AudioStream_sampleSize"
  native_method :sampleSize=, [:int], :int, "rl_m_AudioStream_set_sampleSize"
  native_method :channels, [], :int, "rl_m_AudioStream_channels"
  native_method :channels=, [:int], :int, "rl_m_AudioStream_set_channels"

  native_struct "Sound", "rl_Sound"
  native_new [], "rl_Sound_new"
  native_new [:any, :any], "rl_Sound_view"
  native_method :frameCount, [], :int, "rl_m_Sound_frameCount"
  native_method :frameCount=, [:int], :int, "rl_m_Sound_set_frameCount"
  ffi_func :rl_Sound_stream, [:ptr, :ptr], :void
  native_method :stream=, [:any], :void, "rl_Sound_set_stream"

  native_struct "Music", "rl_Music"
  native_new [], "rl_Music_new"
  native_new [:any, :any], "rl_Music_view"
  native_method :frameCount, [], :int, "rl_m_Music_frameCount"
  native_method :frameCount=, [:int], :int, "rl_m_Music_set_frameCount"
  native_method :looping, [], :bool, "rl_m_Music_looping"
  native_method :looping=, [:bool], :bool, "rl_m_Music_set_looping"
  native_method :ctxType, [], :int, "rl_m_Music_ctxType"
  native_method :ctxType=, [:int], :int, "rl_m_Music_set_ctxType"
  ffi_func :rl_m_Music_ctxData, [:ptr], :long
  native_method :ctxData=, [:any], :void, "rl_Music_set_ctxData"
  ffi_func :rl_Music_stream, [:ptr, :ptr], :void
  native_method :stream=, [:any], :void, "rl_Music_set_stream"

  # function shims (raylib takes/returns these structs by value)
  ffi_func :rl_audio_LoadWaveFromMemory, [:str, :str, :int], :ptr
  ffi_func :rl_audio_IsWaveValid, [:ptr], :int
  ffi_func :rl_audio_UnloadWave, [:ptr], :void
  ffi_func :rl_audio_LoadSoundFromWave, [:ptr], :ptr
  ffi_func :rl_audio_LoadSound, [:str], :ptr
  ffi_func :rl_audio_IsSoundValid, [:ptr], :int
  ffi_func :rl_audio_PlaySound, [:ptr], :void
  ffi_func :rl_audio_StopSound, [:ptr], :void
  ffi_func :rl_audio_IsSoundPlaying, [:ptr], :int
  ffi_func :rl_audio_SetSoundVolume, [:ptr, :float], :void
  ffi_func :rl_audio_SetSoundPitch, [:ptr, :float], :void
  ffi_func :rl_audio_UnloadSound, [:ptr], :void
  ffi_func :rl_audio_LoadAudioStream, [:uint32, :uint32, :uint32], :ptr
  ffi_func :rl_audio_IsAudioStreamValid, [:ptr], :int
  ffi_func :rl_audio_IsAudioStreamPlaying, [:ptr], :int
  ffi_func :rl_audio_PlayAudioStream, [:ptr], :void
  ffi_func :rl_audio_StopAudioStream, [:ptr], :void
  ffi_func :rl_audio_UpdateAudioStream, [:ptr, :long, :int], :void
  ffi_func :rl_audio_UnloadAudioStream, [:ptr], :void
  ffi_func :rl_audio_IsMusicValid, [:ptr], :int
  ffi_func :rl_MemAllocAddr, [:int], :long
  ffi_func :rl_MemFreeAddr, [:long], :void

  # field readers that hand over an address, and the embedded-stream views
  class Wave
    def pointer = self
    def data = Ptr.new(Raylib.rl_m_Wave_data(self))
  end

  class AudioStream
    def pointer = self
    def buffer = Ptr.new(Raylib.rl_m_AudioStream_buffer(self))
    def processor = Ptr.new(Raylib.rl_m_AudioStream_processor(self))
  end

  class Sound
    def pointer = self

    def stream
      a = AudioStream.new
      Raylib.rl_Sound_stream(self, a)
      a
    end
  end

  class Music
    def pointer = self

    def stream
      a = AudioStream.new
      Raylib.rl_Music_stream(self, a)
      a
    end

    def ctxData = Ptr.new(Raylib.rl_m_Music_ctxData(self))
  end
end
