#!/usr/bin/env ruby
# frozen_string_literal: true

# wrap_audio.rb -- reshape the generated audio wrappers onto the view-shaped
# audio shims in lib/raylib_audio_fields.rb.
#
# raylib takes and returns Wave/Sound/AudioStream/Music **by value**, so the
# generated wrappers bind the C directly with :ptr arguments: they hand a boxed
# pointer where a struct is wanted, which the AOT refuses at the call site
# ("unsupported ffi pointer argument"). The shims in the adapter
# (rl_audio_*) unwrap a view, call raylib, and malloc the by-value return; these
# wrappers build the view. Idempotent; --check reports without writing.
#
# Usage: ruby tools/wrap_audio.rb [--check]

ROOT = File.expand_path("..", __dir__)
PATH = File.join(ROOT, "lib/raylib_ffi.rb")

# function name -> body template ({0}, {1}, ... are the existing parameters)
TARGETS = {
  "LoadWaveFromMemory" => "Wave.new(Raylib.rl_audio_LoadWaveFromMemory({0}, {1}, {2}), nil)",
  "IsWaveValid" => "Raylib.rl_audio_IsWaveValid({0}) != 0",
  "UnloadWave" => "Raylib.rl_audio_UnloadWave({0})",
  "LoadSoundFromWave" => "Sound.new(Raylib.rl_audio_LoadSoundFromWave({0}), nil)",
  "IsSoundValid" => "Raylib.rl_audio_IsSoundValid({0}) != 0",
  "PlaySound" => "Raylib.rl_audio_PlaySound({0})",
  "StopSound" => "Raylib.rl_audio_StopSound({0})",
  "IsSoundPlaying" => "Raylib.rl_audio_IsSoundPlaying({0}) != 0",
  "SetSoundVolume" => "Raylib.rl_audio_SetSoundVolume({0}, {1})",
  "SetSoundPitch" => "Raylib.rl_audio_SetSoundPitch({0}, {1})",
  "UnloadSound" => "Raylib.rl_audio_UnloadSound({0})",
  "LoadAudioStream" => "AudioStream.new(Raylib.rl_audio_LoadAudioStream({0}, {1}, {2}), nil)",
  "IsAudioStreamValid" => "Raylib.rl_audio_IsAudioStreamValid({0}) != 0",
  "IsAudioStreamPlaying" => "Raylib.rl_audio_IsAudioStreamPlaying({0}) != 0",
  "PlayAudioStream" => "Raylib.rl_audio_PlayAudioStream({0})",
  "StopAudioStream" => "Raylib.rl_audio_StopAudioStream({0})",
  "UpdateAudioStream" => "Raylib.rl_audio_UpdateAudioStream({0}, {1}, {2})",
  "UnloadAudioStream" => "Raylib.rl_audio_UnloadAudioStream({0})",
  "IsMusicValid" => "Raylib.rl_audio_IsMusicValid({0}) != 0"
}.freeze

check_only = ARGV.include?("--check")
text = File.read(PATH)
changed = []

TARGETS.each do |name, template|
  re = /(    def self\.#{Regexp.escape(name)}\(([^)]*)\)\n)(.*?)(\n    end\n)/m
  m = re.match(text)
  next unless m

  params = m[2].split(",").map(&:strip)
  body = "      " + template.gsub(/\{(\d+)\}/) { params[Regexp.last_match(1).to_i] }
  next if m[3].strip == body.strip

  text = "#{text[0, m.begin(3)]}#{body}#{text[m.end(3)..]}"
  changed << name
end

changed.each { |name| puts format("%-22s %s", File.basename(PATH), name) }
puts "#{changed.size} wrapper(s) #{check_only ? 'need fixing' : 'fixed'}"
File.write(PATH, text) unless check_only || changed.empty?
exit(check_only && !changed.empty? ? 1 : 0)
