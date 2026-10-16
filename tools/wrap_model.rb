#!/usr/bin/env ruby
# frozen_string_literal: true

# wrap_model.rb -- the Model factories return a ModelRef, and the Model-taking
# helpers unwrap it again.
#
# Why: a Ruby method on a *native* class has no arm in a polymorphic dispatch,
# so `models.each { |model| model.material(0) }` raises NoMethodError when the
# array holds native Model views (raylib-bindings' models_mesh_generation.rb).
# A user class's methods do resolve, and can reach the native object through a
# typed ivar. lib/raylib_model_ref.rb defines the wrapper; this rewrites the
# generated wrappers in lib/raylib_ffi.rb:
#
#     def self.LoadModelFromMesh(mesh)
#       Model.new(Raylib.rl_LoadModelFromMesh(mesh), nil)
#     end
#  ->
#     def self.LoadModelFromMesh(mesh)
#       ModelRef.new(Model.new(Raylib.rl_LoadModelFromMesh(mesh), nil))
#     end
#
#     def self.DrawModel(model, position, scale, tint)
#       Raylib.rl_DrawModel(model, position, scale, tint)
#     end
#  ->
#     def self.DrawModel(model, position, scale, tint)
#       model = model.model
#       Raylib.rl_DrawModel(model, position, scale, tint)
#     end
#
# Every Model in the programs we run comes from a factory, so the unwrap
# resolves; a native Model reaching a helper would raise, loudly, rather than
# pass a wrapper to C. Idempotent; `--check` reports without writing and exits 1
# when there is something to fix.
#
# Usage: ruby tools/wrap_model.rb [PATH] [--check]

ROOT = File.expand_path("..", __dir__)

FACTORIES = %w[LoadModel LoadModelFromMesh].freeze
UNWRAP = %w[DrawModel DrawModelEx UnloadModel UpdateModelAnimation
            UpdateModelAnimationEx IsModelValid GetModelBoundingBox].freeze

check_only = ARGV.include?("--check")
path = ARGV.find { |a| !a.start_with?("--") } || File.join(ROOT, "lib/raylib_ffi.rb")
text = File.read(path)
changed = []

FACTORIES.each do |name|
  re = /(    def self\.#{Regexp.escape(name)}\([^)]*\)\n)(.*?)(\n    end\n)/m
  m = re.match(text)
  next unless m

  body = m[2].strip
  next if body.start_with?("ModelRef.new(")

  text = "#{text[0, m.begin(2)]}      ModelRef.new(#{body})#{text[m.end(2)..]}"
  changed << ["factory", name]
end

UNWRAP.each do |name|
  re = /(    def self\.#{Regexp.escape(name)}\(model[,)][^\n]*\n)/
  m = re.match(text)
  next unless m
  next if text[m.end(1), 40].to_s.lstrip.start_with?("model = model.model")

  text = "#{text[0, m.end(1)]}      model = model.model\n#{text[m.end(1)..]}"
  changed << ["unwrap", name]
end

changed.each { |kind, name| puts format("%-18s %-28s %s", File.basename(path), name, kind) }
puts "#{changed.size} wrapper(s) #{check_only ? 'need fixing' : 'fixed'}"
File.write(path, text) unless check_only || changed.empty?
exit(check_only && !changed.empty? ? 1 : 0)
