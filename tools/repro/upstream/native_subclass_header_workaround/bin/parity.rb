require "thing"

class Sub < ThingLib::Thing
  def direct = c_value
end

base = ThingLib::Thing.new(1)
sub = Sub.new(2)
puts "sub.is_a?(Thing)      -> #{sub.is_a?(ThingLib::Thing)}"
puts "sub.is_a?(Sub)        -> #{sub.is_a?(Sub)}"
puts "base.is_a?(Sub)       -> #{base.is_a?(Sub)}"
puts "sub.class             -> #{sub.class}"
puts "case/when Thing       -> #{case sub when ThingLib::Thing then 'Thing arm' else 'no arm' end}"
puts "Array#map over mixed  -> #{[base, sub].map { |t| t.is_a?(ThingLib::Thing) }.inspect}"
