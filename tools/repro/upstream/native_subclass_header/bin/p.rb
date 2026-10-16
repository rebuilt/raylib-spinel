require "thing"

class Sub < ThingLib::Thing
  def direct = c_value
end

things = [Sub.new(7), Sub.new(8)]

things.each do |t|
  begin
    x = t.direct
    puts "subclass block: direct -> #{x.inspect} (expected 7)"
  rescue NoMethodError
    puts "subclass block: direct -> NoMethodError"
  end
end

typed = Sub.new(9)
puts "subclass typed: direct -> #{typed.direct} (expected 9)"
