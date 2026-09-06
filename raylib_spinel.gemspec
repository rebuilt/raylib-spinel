Gem::Specification.new do |s|
  s.name        = "raylib-spinel"
  s.version     = "0.0.0"
  s.summary     = "Raylib spinel bindings"
  s.description = "Raylib spinel bindings"
  s.authors     = ["Nelson Jovel"]
  s.email       = "memoryman51@hotmail.com"
  s.files       = Dir["lib/**/*", "raylib-spinel.rb", "README.md", "LICENSE*"]
  s.require_paths = ["."]
  s.homepage    =
    "https://rubygems.org/gems/raylib-spinel"
  s.license       = "zlib"

  s.add_dependency "raylib-bindings"
  s.add_dependency "listen"
end
