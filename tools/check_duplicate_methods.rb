#!/usr/bin/env ruby
# frozen_string_literal: true

# check_duplicate_methods.rb -- flag methods defined more than once.
#
# The library spreads `module Raylib` (and Rlgl/Physac) plus reopened classes
# across many files, and each method must be defined exactly once in its
# namespace. Two definitions make the AOT compiler build a *polymorphic
# dispatcher* for that name: the return type degrades (an `sp_oint` box instead
# of an int) and call sites stop compiling. That is exactly what broke gem code
# three times:
#
#   * `raygui_ffi.rb` kept stale scalar copies of GuiButton..GuiStatusBar above
#     the gem-shaped ones  -> `GuiButton(...) == 1` failed at codegen;
#   * `raygui_ffi.rb` defined RGuiSliderBar/RGuiCheckBox/... while
#     `raygui_compat.rb` (the gem-shaped helpers) defined them too
#     -> `@x, r = RGuiSliderBar(...)` failed at codegen;
#   * `Color.from_u8` / `from_u32` were defined in both raylib_ffi.rb (base) and
#     raylib_structs.rb (compat).
#
# Module functions (`def self.x`, `def X.x`, `class << self` bodies) and
# instance methods are both checked, keyed by the real parse tree (Prism), so
# same-named methods in different classes are never confused. The deliberate
# mirroring between `Raylib` module functions and the `RaylibInstanceMethods`
# instance delegates the include surface generates differs in kind, hence is
# not a duplicate.
#
# raylib_ruby.rb is skipped on purpose: it is the CRuby branch's parallel
# surface (`RUBY_ENGINE != "spinel"`), never compiled together with the
# Spinel files.
#
# Usage: ruby tools/check_duplicate_methods.rb [lib_dir]
# Exit status: 0 when every method has one definition, 1 otherwise.

begin
  require "prism"
rescue LoadError
  warn "check_duplicate_methods: prism is not available; skipping"
  exit 0
end

LIB = ARGV[0] || File.expand_path("../lib", __dir__)
SKIP = ["raylib_ruby.rb"].freeze


def visit(node, namespace, seen, file, in_singleton = false)
  case node
  when Prism::SingletonClassNode
    node.compact_child_nodes.each { |child| visit(child, namespace, seen, file, true) }
  when Prism::ClassNode, Prism::ModuleNode
    name = node.constant_path.respond_to?(:slice) ? node.constant_path.slice : nil
    inner = name ? [namespace, name].compact.join("::") : namespace
    node.compact_child_nodes.each { |child| visit(child, inner, seen, file, false) }
  when Prism::DefNode
    kind = if in_singleton || node.receiver
             :module_function
           else
             :instance
           end
    (seen[[namespace, node.name, kind]] ||= []) << "#{file}:#{node.location.start_line}"
    node.compact_child_nodes.each { |child| visit(child, namespace, seen, file, in_singleton) }
  else
    node.compact_child_nodes.each { |child| visit(child, namespace, seen, file, in_singleton) }
  end
end


seen = {}
Dir[File.join(LIB, "*.rb")].sort.each do |path|
  file = File.basename(path)
  next if SKIP.include?(file)

  visit(Prism.parse_file(path).value, nil, seen, file)
end

duplicates = seen.reject { |_key, where| where.length < 2 }
duplicates.sort_by { |(ns, name, kind), _| [ns.to_s, name.to_s, kind.to_s] }.each do |(ns, name, kind), where|
  puts format("%-46s %-15s %s", "#{ns}#{kind == :instance ? '#' : '.'}#{name}",
              kind, where.join("  "))
end

instance_count = seen.count { |(_, _, kind), _| kind == :instance }
module_count = seen.size - instance_count
puts "checked #{module_count} module functions and #{instance_count} instance methods " \
     "in #{LIB}; #{duplicates.size} duplicate(s)"
exit(duplicates.empty? ? 0 : 1)
