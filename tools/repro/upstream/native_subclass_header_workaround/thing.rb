module ThingLib
  native_struct "Thing", "sp_Thing"
  native_subclass "thing.h", "sp_Thing_scan"
  native_new [:int], "sp_Thing_new"
  native_method :c_value, [], :int, "sp_Thing_value"
  # the workaround for the emitted #include "../thing.h": an include dir
  # one level below the package root, so ../thing.h resolves to thing.h
  ffi_cflags "-I" + __dir__ + "/include"
end
