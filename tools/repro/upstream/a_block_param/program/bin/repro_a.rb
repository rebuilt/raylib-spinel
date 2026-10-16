require "thing"

# a plain Ruby method on the native class
class ThingLib::Thing
  def doubled = 14
end

things = [ThingLib::Thing.new(7), ThingLib::Thing.new(8)]

things.each do |t|
  puts "block parameter class: #{t.class}"
  begin
    t.doubled            # expected: 14; actual (Spinel): NoMethodError
    puts "ruby method from block: 14"
  rescue NoMethodError => e
    puts "ruby method from block: #{e.class}: #{e.message}"
  end
end

typed = ThingLib::Thing.new(9)
puts "ruby method on a typed local: #{typed.doubled}"

first = things[0]
puts "ruby method on an array element: #{first.doubled}"
