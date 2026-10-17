#!/usr/bin/env ruby
# frozen_string_literal: true

# fix_audio_struct_shims.rb -- unwrap audio struct *views* in the adapter shims.
#
# The generated raylib shims for the audio API take `void *stream` / `void *sound`
# and hand raylib `*(AudioStream *)stream`. The Ruby surface passes an rl_AudioStream
# (WAVE/SOUND/ASTREAM/MUSIC) *view* -- a GC object whose first bytes are
# cls_id/p/owner -- so that cast hands raylib the view's bookkeeping as if it were
# the struct: `buffer` becomes garbage and the next call into raudio segfaults.
#
#   rl_IsAudioStreamProcessed(void *stream)          -> view cast  -> SIGSEGV
#   _Bool rl_IsAudioStreamProcessed(void * stream) {
#     return IsAudioStreamProcessed(*(AudioStream *)stream);       // WRONG
#   }
#
# The fix is the same unwrap the `rl_audio_*` shims already use:
#
#     return IsAudioStreamProcessed(*RL_ASTREAM(stream));
#
# Every caller in the Ruby surface passes a view, so this is unconditional (it is
# the shim invariant from AGENTS section 3). This is a post-processor: the block
# is machine-generated, so the fix has to survive regeneration (`--check` in
# `make check`).
#
# Usage: ruby tools/fix_audio_struct_shims.rb [--check]
# Exit status: 0 when every shim already unwraps (or after a rewrite), 1 when
# `--check` finds one that does not.

ROOT = File.expand_path("..", __dir__)
PATHS = Dir[File.join(ROOT, "lib", "*.c")].sort

# C struct -> view unwrap macro
MACROS = {
  "Wave" => "RL_WAVE",
  "Sound" => "RL_SOUND",
  "AudioStream" => "RL_ASTREAM",
  "Music" => "RL_MUSIC",
}.freeze

PATTERN = /\*\((#{MACROS.keys.join("|")}) \*\)(\w+)/

check_only = ARGV.include?("--check")
changed = []
found = []

PATHS.each do |path|
  text = File.read(path)
  next unless text.match?(PATTERN)

  out = text.gsub(PATTERN) do
    type, name = Regexp.last_match(1), Regexp.last_match(2)
    found << "#{File.basename(path)}: #{type} #{name}"
    "*#{MACROS[type]}(#{name})"
  end

  next if out == text

  if check_only
    changed << path
  else
    File.write(path, out)
    changed << path
  end
end

if check_only
  if changed.empty?
    puts "fix_audio_struct_shims: every audio struct parameter is unwrapped"
    exit 0
  end
  warn "fix_audio_struct_shims: #{found.size} view cast(s) left in #{changed.map { |p| File.basename(p) }.join(", ")}:"
  xfound = found.first(10)
  xfound.each { |f| warn "  #{f}" }
  warn "  ... and #{found.size - xfound.size} more" if found.size > xfound.size
  warn "Run: ruby tools/fix_audio_struct_shims.rb"
  exit 1
end

puts "fix_audio_struct_shims: unwrapped #{found.size} audio struct parameter(s) in #{changed.map { |p| File.basename(p) }.join(", ")}"
