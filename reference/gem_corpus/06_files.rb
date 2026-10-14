# Gem file-text API: LoadFileText returns a pointer that reads back as text.
require "raylib-spinel"
include Raylib

path = "corpus_tmp.txt"
Raylib.SaveFileText(path, "line one\nline two")
puts "exists=#{Raylib.FileExists(path)}"
ptr = Raylib.LoadFileText(path)
puts "text=#{ptr.read_string.inspect}"
Raylib.UnloadFileText(ptr)
File.delete(path) if File.exist?(path)
File.delete(path) if File.exist?(path)
puts "cleaned=#{!File.exist?(path)}"
