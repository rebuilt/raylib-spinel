require "thing"

module ThingLibExt
  ffi_func :val_ptr, [:ptr], :int, "sp_Thing_value"
end

class Sub5 < ThingLib::Thing
  def direct = ThingLibExt.val_ptr(self)
end

puts "self as :ptr -> #{Sub5.new(9).direct}"

# Outside bin/ on purpose: spin builds every bin/*.rb, and this file is refused
# at analysis (that refusal is the finding). cp it into bin/ to see:
#   spinel: bin/selfptr.rb:8: unsupported ffi pointer argument ... node 53 (SelfNode)
