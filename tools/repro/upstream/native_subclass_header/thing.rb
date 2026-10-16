module ThingLib
  native_struct "Thing", "sp_Thing"
  native_subclass "thing.h", "sp_Thing_scan"
  native_new [:int], "sp_Thing_new"
  native_method :c_value, [], :int, "sp_Thing_value"
end
