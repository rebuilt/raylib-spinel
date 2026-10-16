require "thing_base"
require "thing_direct"

things = [ThingLib::Thing.new(7), ThingLib::Thing.new(8)]

things.each do |t|
  begin
    x = t.direct
    puts "block (poly receiver): direct -> #{x.inspect} (expected 7)"
  rescue NoMethodError => e
    puts "block (poly receiver): direct -> #{e.class}"
  end
end

typed = ThingLib::Thing.new(9)
puts "typed receiver:        direct -> #{typed.direct} (expected 9)"
