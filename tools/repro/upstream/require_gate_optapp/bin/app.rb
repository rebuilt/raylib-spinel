require "optparse"

name = "world"
OptionParser.new do |o|
  o.banner = "usage: app [options]"
  o.on("--name NAME") { |v| name = v }
end.parse!
puts "hello #{name}"
