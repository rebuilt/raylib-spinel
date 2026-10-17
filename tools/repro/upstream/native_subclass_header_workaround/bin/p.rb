require "thing"

class Sub < ThingLib::Thing
  def direct = c_value
end

things = [Sub.new(7), Sub.new(8)]
things.each { |t| puts "block receiver: direct -> #{t.direct}" }

typed = Sub.new(9)
puts "typed receiver: direct -> #{typed.direct}"
