#!/usr/bin/env ruby
# frozen_string_literal: true

# gem_surface_audit.rb -- how much of the MRI raylib-bindings surface we cover.
#
# The target is the gem's own surface, taken from three places:
#   * generator/raylib_api.json -- the structs and their fields, and every
#     function with its parameter types (which tells us which functions take a
#     given struct);
#   * lib/raylib_main.rb -- the generated FFI::Struct classes: the field readers
#     and writers the gem defines (every field gets both);
#   * lib/raylib_helper.rb -- the helper methods the gem adds to those classes
#     (Model#material, Model#material_count, ...).
#
# Our side is parsed with Prism (like tools/check_duplicate_methods.rb), so a
# name is attributed to the class it is actually defined in -- a plain grep
# produces false coverage and false gaps across the many files that reopen
# `module Raylib`.
#
# For each gem struct the report shows:
#   fields     read/write coverage (native_method declarations, Ruby defs, or a
#              generated `[]`/`[]=` field index entry)
#   helpers    the gem's helper methods
#   functions  the gem functions whose parameters or return name that struct
#   wrapper    the delegating surface of a <Name>Ref wrapper, if we define one
#
# Usage:
#   ruby tools/gem_surface_audit.rb                    # report to stdout
#   ruby tools/gem_surface_audit.rb --markdown PATH     # also write a report
#   ruby tools/gem_surface_audit.rb --write-baseline    # record current coverage
#   ruby tools/gem_surface_audit.rb --check             # fail on a regression
#
# --check compares against tools/gem_surface_baseline.json and fails only when
# something recorded as covered is no longer covered. The gaps themselves are
# reported, not gated, while they are being worked down.

require "json"

begin
  require "prism"
rescue LoadError
  warn "gem_surface_audit: prism is not available; skipping"
  exit 0
end

ROOT = File.expand_path("..", __dir__)
LIB = File.join(ROOT, "lib")
GEM_DIR = ENV["RAYLIB_BINDINGS_DIR"] || File.expand_path("../raylib-bindings", ROOT)
API_PATH = File.join(GEM_DIR, "generator/raylib_api.json")
MAIN_PATH = File.join(GEM_DIR, "lib/raylib_main.rb")
HELPER_PATH = File.join(GEM_DIR, "lib/raylib_helper.rb")
BASELINE = File.join(ROOT, "tools/gem_surface_baseline.json")
SKIP_FILES = ["raylib_ruby.rb"].freeze

# gem struct name -> our class name
ALIAS = { "Texture" => "Texture2D", "Camera3D" => "Camera" }.freeze

abort "gem surface audit: #{API_PATH} not found (set RAYLIB_BINDINGS_DIR)" unless File.exist?(API_PATH)

# ---------------------------------------------------------------- our surface

Surface = Struct.new(:methods, :writers, :indexed, :indexed_fields, :wrapper, :module_fns, :present, keyword_init: true)

def blank
  Surface.new(methods: [], writers: [], indexed: [], indexed_fields: [], wrapper: nil, module_fns: [], present: false)
end

def visit(node, namespace, ours, in_singleton = false, in_class_body = nil)
  case node
  when Prism::SingletonClassNode
    node.compact_child_nodes.each { |c| visit(c, namespace, ours, true, in_class_body) }
  when Prism::ClassNode, Prism::ModuleNode
    name = node.constant_path.respond_to?(:slice) ? node.constant_path.slice : nil
    inner = name ? [namespace, name].compact.join("::") : namespace
    leaf = inner ? inner.split("::").last : nil
    ours[leaf].present = true if leaf && node.is_a?(Prism::ClassNode)
    node.compact_child_nodes.each { |c| visit(c, inner, ours, false, leaf) }
  when Prism::DefNode
    leaf = namespace ? namespace.split("::").last : nil
    if leaf && ours.key?(leaf)
      s = ours[leaf]
      if node.receiver || in_singleton
        s.module_fns << node.name
      elsif node.name == :[]
        s.indexed << :index
      elsif node.name == :[]=
        s.indexed << :index_write
      elsif node.name.to_s.end_with?("=")
        s.writers << node.name.to_s.delete_suffix("=")
      else
        s.methods << node.name
      end
    end
    node.compact_child_nodes.each { |c| visit(c, namespace, ours, in_singleton, in_class_body) }
  when Prism::CallNode
    # DSL declarations inside a class body: native_method :name, ...
    if node.name == :native_method
      arg = node.arguments&.arguments&.first
      if arg.is_a?(Prism::SymbolNode)
        leaf = namespace ? namespace.split("::").last : nil
        if leaf && ours.key?(leaf)
          n = arg.unescaped
          if n.end_with?("=")
            ours[leaf].writers << n.delete_suffix("=")
          else
            ours[leaf].methods << n.to_sym
          end
        end
      end
    end
    node.compact_child_nodes.each { |c| visit(c, namespace, ours, in_singleton, in_class_body) }
  else
    node.compact_child_nodes.each { |c| visit(c, namespace, ours, in_singleton, in_class_body) }
  end
end

# ------------------------------------------------------------- gem surface

api = JSON.parse(File.read(API_PATH))
gem_structs = api["structs"].to_h { |s| [s["name"], (s["fields"] || []).map { |f| f["name"] }] }

# class -> [reader, writer] method names from the generated FFI structs
def class_blocks(text, header_re)
  out = {}
  text.scan(header_re) do
    name = Regexp.last_match(1)
    start = Regexp.last_match.end(0)
    body = text[start..] || ""
    stop = body.index("\n  end\n") || body.length
    body = body[0, stop]
    out[name] = body.scan(/def ([\w?!]+)/).flatten
  end
  out
end

def class_helper_defs(text)
  out = Hash.new { |h, k| h[k] = [] }
  re = /^(?:  )?class (\w+)(?: < \w+)?\n/
  text.to_enum(:scan, re).each do
    name = Regexp.last_match(1)
    body = text[Regexp.last_match.end(0)..] || ""
    stop = body.index("\n  end\n") || body.index("\nend\n") || body.length
    body = body[0, stop]
    body.scan(/def (self\.)?([\w?!]+)/) { out[name] << [Regexp.last_match(2), !Regexp.last_match(1).nil?] }
  end
  out
end

main = File.read(MAIN_PATH)
gem_accessors = class_blocks(main, /class (\w+) < FFI::Struct\n/)
gem_helpers = class_helper_defs(File.read(HELPER_PATH))

# functions grouped by the struct their parameters or return name
gem_functions = Hash.new { |h, k| h[k] = [] }
struct_name = lambda do |type|
  t = type.to_s
  gem_structs.keys.find { |s| t == s || t.start_with?("#{s} *", "#{s}*") }
end
api["functions"].each do |f|
  params = (f["params"] || []).map { |p| struct_name.call(p["type"]) }
  subject = params.find { |s| s } || struct_name.call(f["returnType"])
  gem_functions[subject] << f["name"] if subject
end

# the generated field index: which fields `obj[:field]` answers for
def collect_indexed_fields(path, ours)
  text = File.read(path)
  text.scan(/^  class (\w+)\n(.*?)\n  end\n/m) do
    leaf = Regexp.last_match(1)
    body = Regexp.last_match(2)
    fields = body.scan(/when :(\w+)/).flatten
    next if fields.empty?

    ours[leaf].indexed << :index
    ours[leaf].indexed_fields.concat(fields)
  end
end

# our classes: every class name we know about
def collect_classes(node, namespace, ours)
  case node
  when Prism::ClassNode, Prism::ModuleNode
    name = node.constant_path.respond_to?(:slice) ? node.constant_path.slice : nil
    inner = name ? [namespace, name].compact.join("::") : namespace
    leaf = inner ? inner.split("::").last : nil
    if leaf
      ours[leaf]                      # make the key exist for modules too (Raylib)
      ours[leaf].present = true if node.is_a?(Prism::ClassNode)
    end
    node.compact_child_nodes.each { |c| collect_classes(c, inner, ours) }
  else
    node.compact_child_nodes.each { |c| collect_classes(c, namespace, ours) }
  end
end

ours = Hash.new { |h, k| h[k] = blank }
files = Dir[File.join(LIB, "*.rb")].sort.reject { |p| SKIP_FILES.include?(File.basename(p)) }
trees = files.map { |p| Prism.parse_file(p).value }
trees.each { |tree| collect_classes(tree, nil, ours) }
trees.each { |tree| visit(tree, nil, ours) }
collect_indexed_fields(File.join(LIB, "raylib_field_index.rb"), ours)

# --------------------------------------------------------------- the report

def covered?(surface, name)
  surface.methods.include?(name.to_sym) || surface.indexed_fields.include?(name.to_s)
end

def covered_write?(surface, name)
  surface.writers.include?(name.to_s) || surface.indexed_fields.include?(name.to_s)
end

raylib_module_fns = ours["Raylib"].module_fns
report = []
rows = []

gem_structs.sort.each do |gem_name, fields|
  our_name = ALIAS[gem_name] || gem_name
  s = ours[our_name]
  next unless s.present

  read_ok = fields.select { |f| covered?(s, f) }
  write_ok = fields.select { |f| covered_write?(s, f) }
  read_missing = fields - read_ok
  write_missing = fields - write_ok

  helpers = gem_helpers[gem_name] || []
  helper_ok = helpers.select { |h, singleton| (singleton ? s.module_fns : s.methods).include?(h.to_sym) }
  helper_missing = helpers.reject { |h| helper_ok.include?(h) }

  fns = gem_functions[gem_name] || []
  fn_ok = fns.select { |f| s.module_fns.include?(f.to_sym) || raylib_module_fns.include?(f.to_sym) }
  fn_missing = fns - fn_ok

  total = read_ok.size + write_ok.size + helper_ok.size + fn_ok.size
  need = fields.size + fields.size + helpers.size + fns.size
  rows << { "gem" => gem_name, "ours" => our_name, "read" => read_ok, "write" => write_ok,
            "helpers" => helper_ok, "functions" => fn_ok }

  report << "## #{gem_name}#{our_name == gem_name ? '' : " (our #{our_name})"}"
  report << ""
  report << "    fields     read #{read_ok.size}/#{fields.size}   write #{write_ok.size}/#{fields.size}"
  report << "               missing read:  #{read_missing.join(', ')}" unless read_missing.empty?
  report << "               missing write: #{write_missing.join(', ')}" unless write_missing.empty?
  helper_names = helper_missing.map { |h, singleton| singleton ? "self.#{h}" : h }
  report << "    helpers    #{helper_ok.size}/#{helpers.size}#{helper_names.empty? ? '' : "   missing: #{helper_names.join(', ')}"}"
  report << "    functions  #{fn_ok.size}/#{fns.size}#{fn_missing.empty? ? '' : "   missing: #{fn_missing.join(', ')}"}"
  if s.wrapper
    w = s.wrapper
    need_names = (read_ok + helper_ok).map(&:to_s)
    delegated = need_names.select { |n| w.include?(n.to_sym) }
    report << "    wrapper    #{delegated.size}/#{need_names.size} of the covered surface#{need_names.empty? ? '' : "   missing: #{(need_names - delegated).join(', ')}"}"
  end
  report << "    coverage   #{total}/#{need}"
  report << ""
end

# wrapper methods: collect them in a second pass (class <Name>Ref)
wrappers = Hash.new { |h, k| h[k] = [] }
Dir[File.join(LIB, "*.rb")].sort.each do |path|
  text = File.read(path)
  text.scan(/class (\w+Ref)\n(.*?)\n  end\n/m) do
    wrappers[Regexp.last_match(1)] = Regexp.last_match(2).scan(/def ([\w?!]+)/).flatten.map(&:to_sym)
  end
end
ours.each do |name, s|
  ref = wrappers["#{name}Ref"]
  s.wrapper = ref if ref
end

# re-render with wrapper info available
if ARGV.include?("--rebuild-report")
  # (kept simple: wrapper info is attached above only when present)
end

absent = gem_structs.keys.reject { |g| ours[ALIAS[g] || g].present }

if (i = ARGV.index("--list"))
  name = ARGV[i + 1]
  s = ours[name]
  puts "#{name}: present=#{s.present}"
  puts "  methods       #{s.methods.sort.inspect}"
  puts "  writers       #{s.writers.sort.inspect}"
  puts "  indexed       #{s.indexed_fields.sort.inspect}"
  puts "  module_fns    #{s.module_fns.sort.inspect}"
  puts "  wrapper       #{s.wrapper.inspect}"
  exit 0
end

markdown = ["# MRI gem surface coverage", "",
            "Generated by tools/gem_surface_audit.rb from the gem's raylib_api.json,",
            "lib/raylib_main.rb and lib/raylib_helper.rb.", ""] + report
summary = rows.map { |r| "#{r['gem']}: #{r['read'].size + r['write'].size + r['helpers'].size + r['functions'].size}" }
markdown << "Structs with any coverage: #{rows.size}"
markdown << "Gem structs with no class of ours: #{absent.empty? ? 'none' : absent.join(', ')}"
puts markdown.join("\n")

if (i = ARGV.index("--markdown"))
  path = ARGV[i + 1]
  File.write(path, markdown.join("\n") + "\n")
  puts "\nwrote #{path}"
end

if ARGV.include?("--write-baseline")
  File.write(BASELINE, JSON.pretty_generate(rows) + "\n")
  puts "wrote #{BASELINE}"
end

if ARGV.include?("--check")
  unless File.exist?(BASELINE)
    puts "no baseline (#{BASELINE}); skipping the regression check"
    exit 0
  end
  base = JSON.parse(File.read(BASELINE))
  current = rows.to_h { |r| [r["gem"], r] }
  regressions = []
  base.each do |b|
    c = current[b["gem"]]
    if c.nil?
      regressions << "#{b['gem']}: no longer reported"
      next
    end
    %w[read write helpers functions].each do |k|
      lost = b[k] - c[k]
      regressions << "#{b['gem']} #{k}: lost #{lost.join(', ')}" unless lost.empty?
    end
  end
  if regressions.empty?
    puts "\ncoverage check: no regressions against the baseline"
    exit 0
  end
  puts "\ncoverage REGRESSIONS:"
  regressions.each { |r| puts "  #{r}" }
  exit 1
end
