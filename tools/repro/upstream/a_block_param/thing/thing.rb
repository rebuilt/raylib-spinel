# The native class, declared the way spinel's bundled packages do it: the
# declarations sit at the module level (they *are* the class), then the class is
# reopened for plain Ruby methods.
module ThingLib
  native_struct "Thing", "sp_Thing"
  native_new [:int], "sp_Thing_new"
  native_method :value, [], :int, "sp_Thing_value"

  class Thing
    def doubled = value * 2
  end
end
