require "raylib"
include Raylib

# P1a: the gem entry point must provide the full gem surface — all six
# libraries, the bundled ffi package, the module methods and the include-able
# instance methods — with the same call shapes as the MRI gem. No InitWindow
# here so the test runs headless.

puts "gem entry loaded"

# Module, instance and snake surfaces agree.
v = GetRandomValue(0, 100)
puts "GetRandomValue in range: #{v >= 0 && v <= 100}"
puts "Raylib.GetRandomValue in range: #{Raylib.GetRandomValue(0, 100) >= 0}"
puts "get_random_value in range: #{get_random_value(0, 100) >= 0}"
puts "Raylib.get_random_value in range: #{Raylib.get_random_value(0, 100) >= 0}"

puts "IsWindowReady: #{IsWindowReady()}"
puts "is_window_ready: #{is_window_ready}"
puts "Raylib.is_window_ready: #{Raylib.is_window_ready}"

# raygui is loaded by the entry, not by an explicit raylib-spinel/raygui
# require, and GuiIsLocked is a Ruby boolean like the gem's :bool entry.
puts "GuiIsLocked: #{GuiIsLocked()}"
GuiLock()
puts "GuiIsLocked after lock: #{GuiIsLocked()}"
GuiUnlock()
puts "GuiIsLocked after unlock: #{GuiIsLocked()}"

# rlgl names live on Raylib too (gem parity). rlGetVersion is state-free, so
# it is safe without InitWindow (the value is build-dependent; type is not).
puts "rlgl version is Integer: #{Raylib.rlGetVersion.is_a?(Integer)}"
puts "rlgl version (bare) is Integer: #{rl_get_version.is_a?(Integer)}"

# The gem's runtime entry idioms are accepted (no-ops under Spinel). Use the
# real soname so the MRI oracle loads a library instead of warning.
Raylib.load_lib("libraylib.so", method_naming: :snake_case)
Raylib.setup_symbols
puts "load_lib/setup_symbols ok"

# The gem loads ffi; so does the entry.
puts "ffi: #{FFI.is_a?(Module) ? 'loaded' : 'missing'}"
puts "done"
