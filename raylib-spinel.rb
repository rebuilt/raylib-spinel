# raylib.rb — single loading point for `require "raylib"` (a spin feature).
#
# Under Spinel AOT the package's raylib_ffi.rb provides the FFI declarations and
# the spinel-side object wrappers; the carried raylib_adapter.c (auto-compiled
# and linked by spin) supplies the struct/bool shims.
#
# Under CRuby the raylib-bindings gem provides the same PascalCase surface;
# raylib_ruby.rb loads the system gem by its full path and adds the few helpers
# that mirror our spinel-side additions.
#
# The CRuby branch uses a computed require arg (File.join) so Spinel's textual
# require-splicing skips it; the Spinel branch's require_relative is a literal
# that gets spliced in. $PROGRAM_NAME is the runtime discriminator.

CANARY = 'canary'
if $PROGRAM_NAME.end_with?(".rb")
  require_relative File.join("lib","raylib_ruby")
else
  require_relative "lib/raylib_ffi"
end
