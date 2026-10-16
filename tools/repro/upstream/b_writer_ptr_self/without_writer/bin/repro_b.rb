require "thing"

t = ThingLib::Thing.new(7)
puts "addr nonzero=#{t.addr != 0}"
puts "value=#{t.value}"
