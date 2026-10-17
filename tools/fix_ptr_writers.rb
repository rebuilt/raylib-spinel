#!/usr/bin/env ruby
# frozen_string_literal: true

# fix_ptr_writers.rb -- unbox Raylib::Ptr in the raw-pointer field writers.
#
# Roughly forty struct fields hold a raw C pointer whose Ruby reader wraps the
# address in a Raylib::Ptr value object (`mesh.vertices`, `wave.data`,
# `stream.buffer`, `material.maps`, ...). Their [:any] writers called
# rl_h_unbox(), which for an object returns the *Ruby object pointer* -- so the
# wrapper itself is stored in the raylib struct instead of the address it holds.
# Probe, before the fix:
#
#   stream.buffer = Raylib::Ptr.new(0x1234_0000)
#   stream.buffer.address   # => 0x72d77242c030   (the Ptr object, not 0x12340000)
#
# Every `x.field = x.field` round trip and every `field = MemAlloc(n)` write is
# therefore corrupt, and it surfaces far away in a free(): audio_api_coverage's
# teardown died in UnloadAudioBuffer because init had written the wrapper address
# into AudioStream.buffer.
#
# The fix is rl_p_unbox() in raylib_adapter.c, which reads the address out of the
# wrapper. A bare Integer address keeps working, exactly as FFI accepts both.
#
# Which writers: exactly the fields whose Ruby reader returns a Ptr. The pairing
# is read from lib/*.rb (`class Mesh` + `def vertices = Ptr.new(...)`), the shim is
# found by its generated name (rl_m_Mesh_set_vertices, rl_Wave_set_data). A field
# whose reader returns a *view* (font.texture, transform.rotation) must keep
# rl_h_unbox, so deriving the list from the readers, not from C text, is what
# keeps the two classes of writer apart.
#
# Usage: ruby tools/fix_ptr_writers.rb [--check]
# Exit status: 0 when every Ptr-valued writer unwraps the address (or after a
# rewrite), 1 when --check finds one that does not.

ROOT = File.expand_path("..", __dir__)
ADAPTERS = Dir[File.join(ROOT, "lib", "*_adapter.c")].sort
RUBY_SRC = Dir[File.join(ROOT, "lib", "*.rb")].sort

# The generated shim names of every Ptr-valued field, with and without the rl_m_
# prefix, mapped to the field for reporting.
def wanted_shims
  fields = []
  RUBY_SRC.each do |path|
    current = nil
    File.foreach(path) do |line|
      case line
      when /^\s*class ([A-Z]\w*)\b/ then current = Regexp.last_match(1)
      when /^\s*def ([A-Za-z_]\w*) = Ptr\.new\(/ then fields << [current, Regexp.last_match(1)] if current
      end
    end
  end
  fields.uniq.each_with_object({}) do |(klass, field), acc|
    acc["rl_#{klass}_set_#{field}"] = "#{klass}##{field}"
    acc["rl_m_#{klass}_set_#{field}"] = "#{klass}##{field}"
  end
end

WANTED = wanted_shims.freeze
FIELDS = WANTED.values.uniq.sort.freeze

SHIM_CALL = /\b(rl_(?:m_)?\w+_set_\w+)\(/

def convert(line, changed:, missing:)
  name = line[SHIM_CALL, 1]
  return line unless name && WANTED.key?(name)

  if line.include?('rl_h_unbox(')
    changed << name
    line.sub('rl_h_unbox(', 'rl_p_unbox(')
  elsif !line.include?('rl_p_unbox(')
    missing << "#{name} (#{WANTED[name]}): neither unbox present, needs looking at"
    line
  else
    line
  end
end

check_only = ARGV.include?('--check')
changed = []
missing = []

ADAPTERS.each do |path|
  before = File.read(path)
  out = before.lines.map do |line|
    line.include?('_set_') ? convert(line, changed:, missing:) : line
  end
  next if out.join == before

  if check_only
    WANTED.each do |sym, field|
      missing << "#{sym} (#{field}): still uses rl_h_unbox" if before.match?(/^[\w \*]*\b#{sym}\(.*rl_h_unbox/)
    end
  else
    File.write(path, out.join)
  end
end

missing.uniq!
changed.uniq!

if check_only
  unless missing.empty?
    warn "fix_ptr_writers: #{missing.size} problem(s):"
    missing.first(15).each { |m| warn "  #{m}" }
    warn 'Run: ruby tools/fix_ptr_writers.rb'
    exit 1
  end
  puts "fix_ptr_writers: #{FIELDS.size} Ptr-valued field(s), every writer reads the address out of the wrapper"
  exit 0
end

shimmed = WANTED.values.uniq.count { |field| changed.any? { |sym| WANTED[sym] == field } }
puts "fix_ptr_writers: #{FIELDS.size} Ptr-valued field(s), #{shimmed} writer(s) rewritten to rl_p_unbox"
puts "fix_ptr_writers: #{missing.size} unclassified: #{missing.join(', ')}" unless missing.empty?
