# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = "raylib-spinel"
  s.version     = "0.1.0"
  s.summary     = "raylib bindings for the Spinel AOT compiler: raylib-bindings' API, compiled games"
  s.description = <<~DESC
    raylib-spinel is the package behind `require "raylib"` under the Spinel AOT
    compiler: FFI declarations, native struct views, and C adapters that are
    compiled together with the program. Under CRuby the same require delegates
    to raylib-bindings, so a game written for that gem runs on either engine
    unmodified.
  DESC
  s.authors     = ["rebuilt"]
  s.email       = "memoryman51@hotmail.com"

  # What the MRI channel ships. The spin channel is consumed from the git
  # clone (spin reads spin.toml and compiles the carried C), so the carried-C
  # sources (.c) and the development tree (tools/, test/, reference/) are not
  # part of the gem; lib/*.o are build artifacts of the .c files and must not
  # be shipped.
  #
  # raylib.rb is listed for completeness, not because MRI users see it: when
  # raylib-bindings is installed, activating this gem activates that one first,
  # so its lib/ lands ahead of our "." on $LOAD_PATH and `require "raylib"`
  # answers the real gem (measured with both gems installed; lib/raylib_ruby.rb
  # explains why the reverse resolution is ambiguous). The file only answers
  # where name-based loading has no RubyGems competition, i.e. a spin package
  # or a checkout on the load path, and there the delegation is the point.
  s.files = Dir[
    "lib/**/*.rb", "lib/**/*.h",
    "raylib.rb", "raylib-spinel.rb", "raylib-spinel/*.rb",
    "spin.toml", "README.md", "LICENSE*"
  ]
  s.require_paths = ["."]

  s.homepage = "https://rubygems.org/gems/raylib-spinel"
  s.license  = "Zlib"
  # The floor the dependencies already impose (raylib-bindings >= 3.0.0, ffi
  # >= 3.0); the MRI side of this package uses nothing newer.
  s.required_ruby_version = ">= 3.0"

  s.add_dependency "raylib-bindings", ">= 0.8.4"
  s.add_dependency "listen"
end
