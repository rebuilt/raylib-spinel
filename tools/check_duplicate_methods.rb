#!/usr/bin/env ruby
# frozen_string_literal: true

# check_duplicate_methods.rb -- flag module functions defined more than once.
#
# The library spreads `module Raylib` (and Rlgl/Physac) across many files, and
# each `def self.<name>` must be defined exactly once. Two definitions make the
# AOT compiler build a *polymorphic dispatcher* for that name: the return type
# degrades (an `sp_oint` box instead of an int) and call sites stop compiling.
# That is exactly what broke gem code twice:
#
#   * `raygui_ffi.rb` kept stale scalar copies of GuiButton..GuiStatusBar above
#     the gem-shaped ones  -> `GuiButton(...) == 1` failed at codegen;
#   * `raygui_ffi.rb` defined RGuiSliderBar/RGuiCheckBox/... while
#     `raygui_compat.rb` (the gem-shaped helpers) defined them too
#     -> `@x, r = RGuiSliderBar(...)` failed at codegen.
#
# Namespace comes from the real parse tree (Prism), so `def self.create` in
# different classes and instance methods are never confused.
#
# raylib_ruby.rb is skipped on purpose: it is the CRuby branch's parallel
# surface (`if $PROGRAM_NAME.end_with?(".rb")`), never compiled together with
# the Spinel files.
#
# Usage: ruby tools/check_duplicate_methods.rb [lib_dir]
# Exit status: 0 when every module function has one definition, 1 otherwise.

begin
  require "prism"
rescue LoadError
  warn "check_duplicate_methods: prism is not available; skipping"
  exit 0
end

LIB = ARGV[0] || File.expand_path("../lib", __dir__)
SKIP = ["raylib_ruby.rb"].freeze

def visit(node, namespace, seen, file)
  case node
  when Prism::ClassNode, Prism::ModuleNode
    name = node.constant_path.respond_to?(:slice) ? node.constant_path.slice : nil
    inner = name ? [namespace, name].compact.join("::") : namespace
    node.compact_child_nodes.each { |child| visit(child, inner, seen, file) }
  when Prism::DefNode
    if node.receiver.is_a?(Prism::SelfNode)
      (seen[[namespace, node.name]] ||= []) << "#{file}:#{node.location.start_line}"
    end
    node.compact_child_nodes.each { |child| visit(child, namespace, seen, file) }
  else
    node.compact_child_nodes.each { |child| visit(child, namespace, seen, file) }
  end
end

seen = {}
Dir[File.join(LIB, "*.rb")].sort.each do |path|
  file = File.basename(path)
  next if SKIP.include?(file)

  visit(Prism.parse_file(path).value, nil, seen, file)
end

duplicates = seen.reject { |_key, where| where.length < 2 }
duplicates.each do |(namespace, name), where|
  puts format("%-40s %s", "#{namespace}.#{name}", where.join("  "))
end

puts "checked #{seen.size} module functions in #{LIB}; #{duplicates.size} duplicate(s)"
exit(duplicates.empty? ? 0 : 1)
