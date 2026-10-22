#!/usr/bin/env ruby
# frozen_string_literal: true

# gem_compat_audit.rb — MRI raylib-bindings surface vs raylib-spinel's.
#
# The compatibility contract is the *installed MRI gem* (entry tables + struct
# layouts + helper methods) at the raylib version the gem bundles. This audit
# diffs that contract against what raylib-spinel exposes, beyond bare name
# coverage (tools/coverage_audit.py):
#
#   1. functions: name coverage + a signature-shape verdict
#      (ok / shim-only / arity-gap / missing), where "shim-only" means callers
#      must reach for `Raylib.rl_*` and marshal pointers themselves;
#   2. structs: gem classes and their fields vs our `native_struct` classes and
#      `native_method` accessors (aliases resolved);
#   3. helpers: the gem's Ruby helper layer (create/copy_from/to_a, Model#*,
#      ModelAnimations, Transform#t/r/s, module helpers) vs ours;
#   4. constants: gem enum/define names vs our constants.
#
# Reports: reference/reports/gem_compat.md (+ .json worklist).
# Usage: ruby tools/gem_compat_audit.rb [--gem DIR] [--json OUT] [--md OUT]
#
# Ported from tools/gem_compat_audit.py on 2026-10-22 (same logic and output).

require 'json'
require 'fileutils'
require 'set'

ROOT = File.expand_path('..', __dir__)
LIB = File.join(ROOT, 'lib')
REPORTS = File.join(ROOT, 'reference', 'reports')

LIBS = {
  'raylib' => 'raylib_main.rb',
  'raymath' => 'raymath.rb',
  'rlgl' => 'rlgl.rb',
  'physac' => 'physac.rb',
  'rcamera' => 'rcamera.rb',
  'raygui' => 'raygui_main.rb'
}.freeze

FFI_FILES = %w[raylib_ffi.rb raymath_ffi.rb rlgl_ffi.rb physac_ffi.rb
               rcamera_ffi.rb raygui_ffi.rb raylib_ruby.rb].freeze

ENTRY_RE = /^\s*\[:(\w+), :(\w+), \[([^\]]*)\], ([\w.:]+)\]/

def option(name)
  i = ARGV.index(name)
  i ? ARGV[i + 1] : nil
end

def gem_lib_dir(explicit = nil)
  return explicit if explicit

  gemdir = begin
    `gem env gemdir`.strip
  rescue StandardError
    return nil
  end
  return nil if gemdir.empty?

  cands = (Dir.glob(File.join(gemdir, 'raylib-bindings-*', 'lib')) +
           Dir.glob(File.join(gemdir, 'gems', 'raylib-bindings-*', 'lib'))).sort
  cands.last
end

# {lib: {name: [param_types, ret]}} from the installed gem's entry tables.
def gem_entries(gem)
  out = {}
  LIBS.each do |lib, fname|
    path = File.join(gem, fname)
    out[lib] = {}
    next unless File.exist?(path)

    File.read(path).scan(ENTRY_RE) do |name, _entry, params, ret|
      out[lib][name] = [params.split(',').map(&:strip).reject(&:empty?), ret]
    end
  end
  out
end

def our_sources
  out = {}
  FFI_FILES.each do |f|
    path = File.join(LIB, f)
    next unless File.exist?(path)

    # strip comments so commented-out declarations are not counted
    out[f] = File.readlines(path).reject { |l| l =~ /^\s*#/ }.join("\n")
  end
  out
end

def our_surface(src)
  text = src.values.join("\n")
  wrappers = Set.new
  wrapper_args = {}
  text.scan(/def self\.([A-Za-z_]\w*)\(([^)]*)\)/) do |name, args|
    wrappers << name
    wrapper_args[name] ||= args.strip
  end
  arityless = Set.new(text.scan(/def self\.([A-Za-z_]\w*)\b(?!\()/).flatten)
  aliases = Set.new
  alias_targets = Set.new
  text.scan(/alias_method\s+:(\w+),\s*:(\w+)/) do |_a, b|
    aliases << b
    alias_targets << b
  end
  ffi_counts = {}
  text.scan(/ffi_func\s+:(\w+),\s*(?:%i\[([^\]]*)\]|\[([^\]]*)\])/) do |name, pct, brackets|
    args = pct || brackets
    ffi_counts[name] = args.split(',').map(&:strip).reject(&:empty?).length
  end
  shim = Set.new(ffi_counts.keys.select { |n| n.start_with?('rl_') })
  direct = Set.new(ffi_counts.keys) - shim

  # native struct classes and their field accessors
  structs = {}
  cur = nil
  text.each_line do |line|
    if (m = line.match(/^\s*native_struct\s+"(\w+)"/))
      cur = m[1]
      structs[cur] ||= Set.new
      next
    end
    if (m = line.match(/^\s*native_method\s+:(\w+?)=?\s*,/)) && cur
      structs[cur] << m[1]
    end
  end

  { wrappers: wrappers | arityless, wrapper_args: wrapper_args,
    aliases: aliases, alias_targets: alias_targets, ffi: direct,
    ffi_counts: ffi_counts, shim: shim, structs: structs, text: text }
end

# {class: {fields:Set, alias_of:str|None}} from the installed gem.
def gem_structs(gem)
  text = File.read(File.join(gem, 'raylib_main.rb'))
  structs = {}
  cur = nil
  text.each_line do |line|
    if (m = line.match(/^\s*class (\w+) < FFI::Struct/))
      cur = m[1]
      structs[cur] = Set.new
      next
    end
    next unless cur
    next if line =~ /^\s*end\s*$/

    structs[cur] << m[1] if (m = line.match(/^\s*:(\w+),/))
  end
  aliases = {}
  text.scan(/^\s*(\w+) = (\w+)\s*$/) do |alias_name, target|
    next unless structs.key?(target)

    structs[alias_name] = structs[target]
    aliases[alias_name] = target
  end
  [structs, aliases]
end

# [[receiver, name, kind]] from the gem's Ruby helper layer.
def gem_helpers(gem)
  text = File.read(File.join(gem, 'raylib_helper.rb'))
  out = []
  cur = nil
  text.each_line do |line|
    if (m = line.match(/^  class (\w+)/))
      cur = m[1]
      next
    end
    if line =~ /^  end\s*$/
      cur = nil
      next
    end
    if (m = line.match(/^    def self\.(\w+)/))
      out << [(cur || 'Raylib'), m[1], 'class']
      next
    end
    if (m = line.match(/^    def (\w+)/))
      out << [(cur || 'Raylib'), m[1], 'instance']
      next
    end
    out << ['Raylib', m[1], 'module'] if (m = line.match(/^  def (\w+)/))
  end
  out.uniq
end

# Constant names the installed gem actually defines (module level).
def gem_constants(gem)
  names = Set.new
  LIBS.each_value do |fname|
    path = File.join(gem, fname)
    next unless File.exist?(path)

    File.foreach(path) do |line|
      names << Regexp.last_match(1) if line =~ /^\s*([A-Z][A-Z0-9_]{2,})\s*=/
    end
  end
  names
end

def our_constants(text)
  Set.new(text.scan(/ffi_const\s+:(\w+)/).flatten) |
    Set.new(text.scan(/^\s{2,}([A-Z][A-Z0-9_]{2,})\s*=/).flatten)
end

def required_arity(argtext)
  return [0, 0] if argtext.nil? || argtext.empty?

  parts = argtext.split(',').map(&:strip).reject(&:empty?)
  required = parts.count { |p| !p.include?('=') && !p.start_with?('*') }
  has_rest = parts.any? { |p| p.start_with?('*') }
  [required, has_rest ? -1 : parts.length]
end

gem = gem_lib_dir(option('--gem'))
abort 'gem_compat_audit: raylib-bindings gem not found' unless gem && File.directory?(gem)

entries = gem_entries(gem)
surf = our_surface(our_sources)
gstructs, galiases = gem_structs(gem)
ghelpers = gem_helpers(gem)
gconsts = gem_constants(gem)
oconsts = our_constants(surf[:text])

report = { 'gem' => gem, 'libs' => {}, 'structs' => {}, 'helpers' => {},
           'constants' => {} }
worklist = { 'missing' => [], 'shim_only' => [], 'arity_gap' => [],
             'struct_missing' => [], 'struct_fields' => [],
             'helper_missing' => [], 'const_missing' => [] }

entries.each do |lib, entries_lib|
  rows = { 'ok' => [], 'shim_only' => [], 'arity_gap' => [], 'missing' => [] }
  entries_lib.keys.sort.each do |name|
    params, = entries_lib[name]
    if surf[:wrappers].include?(name) || surf[:ffi].include?(name)
      required, total = required_arity(surf[:wrapper_args][name])
      n = if surf[:ffi].include?(name)
            surf[:ffi_counts].fetch(name, params.length)
          else
            total >= 0 ? total : params.length
          end
      if surf[:wrappers].include?(name) && !(required <= params.length && params.length <= n)
        rows['arity_gap'] << name
      else
        rows['ok'] << name
      end
    elsif surf[:shim].include?("rl_#{name}")
      rows['shim_only'] << name
    else
      rows['missing'] << name
    end
  end
  report['libs'][lib] = { 'total' => entries_lib.length }
                         .merge(rows.transform_values(&:length))
  %w[missing shim_only arity_gap].each do |k|
    worklist[k].concat(rows[k].map { |n| "#{lib}:#{n}" })
  end
end

gstructs.keys.sort.each do |cls|
  fields = gstructs[cls]
  unless surf[:structs].key?(cls)
    worklist['struct_missing'] << cls
    next
  end
  miss = (fields - surf[:structs][cls]).sort
  worklist['struct_fields'] << "#{cls}: #{miss.join(', ')}" if miss.any?
end
report['structs'] = { 'gem_classes' => gstructs.length, 'aliases' => galiases,
                      'ours' => surf[:structs].keys.sort }

ghelpers.sort.each do |recv, name, kind|
  next if surf[:wrappers].include?(name) || surf[:aliases].include?(name) ||
          surf[:text] =~ /def #{Regexp.escape(name)}\b/

  worklist['helper_missing'] << "#{kind}:#{recv}.#{name}"
end

missing_c = (gconsts - oconsts).sort
worklist['const_missing'] = missing_c

FileUtils.mkdir_p(REPORTS)
json_out = option('--json') || File.join(REPORTS, 'gem_compat.json')
md_out = option('--md') || File.join(REPORTS, 'gem_compat.md')

File.write(json_out, JSON.pretty_generate({ 'report' => report, 'worklist' => worklist },
                                          indent: ' ', space: ' ',
                                          object_nl: "\n", array_nl: "\n"))

md = []
md << "# gem compatibility audit\n"
md << 'Baseline: installed raylib-bindings gem + generator JSONs (raylib 6.1). ' \
      "Tool: `tools/gem_compat_audit.rb`.\n"
md << "## Functions\n"
md << '| lib | total | ok | shim-only | arity-gap | missing |'
md << '| --- | --- | --- | --- | --- | --- |'
report['libs'].each do |lib, r|
  md << format('| %s | %d | %d | %d | %d | %d |', lib, r['total'], r['ok'],
               r['shim_only'], r['arity_gap'], r['missing'])
end
md << "\n### Arity/signature gaps\n"
md << "`#{worklist['arity_gap'].join('`, `')}`\n"
md << "\n### Missing functions\n"
md << "`#{worklist['missing'].join('`, `')}`\n"
md << "\n## Structs\n"
md << "Missing classes (#{worklist['struct_missing'].length}): " \
      "`#{worklist['struct_missing'].join('`, `')}`\n"
md << "Field gaps (#{worklist['struct_fields'].length}):\n"
worklist['struct_fields'].each { |row| md << "- #{row}" }
md << "\n## Helpers\n"
md << "Missing helper methods (#{worklist['helper_missing'].length}):\n"
worklist['helper_missing'].each { |row| md << "- #{row}" }
md << "\n## Constants\n"
shown = worklist['const_missing'][0, 80]
ellipsis = worklist['const_missing'].length > 80 ? ' …' : ''
md << "Missing constants (#{worklist['const_missing'].length}): " \
      "`#{shown.join('`, `')}`#{ellipsis}\n"
File.write(md_out, md.join("\n"))

puts "== gem: #{gem}"
report['libs'].each do |lib, r|
  puts format('%-8s total=%-4d ok=%-4d shim-only=%-3d arity-gap=%-3d missing=%-3d',
              lib, r['total'], r['ok'], r['shim_only'], r['arity_gap'], r['missing'])
end
puts "structs: gem=#{report['structs']['gem_classes']} " \
     "ours=#{report['structs']['ours'].length} " \
     "missing=#{worklist['struct_missing'].length} " \
     "field-gaps=#{worklist['struct_fields'].length}"
puts "helpers missing: #{worklist['helper_missing'].length}"
puts "constants missing: #{missing_c.length}"
puts
puts "worklist summary: #{worklist.transform_values(&:length)}"
puts "wrote #{json_out}"
puts "wrote #{md_out}"
