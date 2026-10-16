require "thing"

# reopening the same native class with a Ruby-defined writer
class ThingLib::Thing
  def flag=(v)
    self.value = v
  end
end

t = ThingLib::Thing.new(7)
puts "addr nonzero=#{t.addr != 0}"
puts "value=#{t.value}"
