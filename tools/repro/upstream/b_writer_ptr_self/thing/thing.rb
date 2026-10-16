# A native class with a :ptr-taking helper declared the way the raylib binding
# declares interior-pointer shims (ffi_func :name, [:ptr], :long).
module ThingLib
  # the carried C provides the symbols; ffi_lib names the link line
  ffi_lib "c"
  native_struct "Thing", "sp_Thing"
  native_new [:int], "sp_Thing_new"
  native_method :value, [], :int, "sp_Thing_value"
  native_method :value=, [:int], :int, "sp_Thing_set_value"
  ffi_func :sp_Thing_addr, [:ptr], :long

  class Thing
    # works on its own: `self` is accepted in the :ptr parameter
    def addr = ThingLib.sp_Thing_addr(self)
  end
end
