# dependency-free: no native code, no gems
[2, 3].each do |n|
  a = (1..n).map { |i| "s#{i}" }.pack("p*")
  puts "n=#{n} bytesize=#{a.bytesize} (expected #{n * 8})"
end

b = ["This", "is"].pack("p*")
begin
  puts "unpack: #{b.unpack("p*").inspect}"
rescue => e
  puts "unpack: #{e.class}: #{e.message}"
end
