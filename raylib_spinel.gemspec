Gem::Specification.new do |s|
  s.name        = "raylib-spinel"
  s.version     = "0.1.0"
  s.summary     = "Raylib spinel bindings"
  s.description = "Raylib spinel bindings"
  s.authors     = ["rebuilt"]
  s.email       = "memoryman51@hotmail.com"
  s.files       = Dir["lib/**/*", "raylib-spinel.rb", "raylib-spinel/**/*", "README.md", "LICENSE*"]
  s.require_paths = ["."]
  s.homepage    = "https://rubygems.org/gems/raylib-spinel"
  s.license       = "Zlib"

  s.add_dependency "raylib-bindings", '>= 0.8.4'
  s.add_dependency "listen"
end
