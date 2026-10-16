# A native class with no native_method at all: the struct and the constructor
# are C, every accessor is to be monkey-patched in Ruby.
module ThingLib
  native_struct "Thing", "sp_Thing"
  native_new [:int], "sp_Thing_new"

  # module-level FFI (documented), what the Ruby methods below call
  ffi_func :sp_Thing_value, [:ptr], :int
end
