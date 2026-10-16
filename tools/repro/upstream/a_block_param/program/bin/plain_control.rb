# Control: a plain Ruby class in a block works (and runs under CRuby too).
class Plain
  def value = 7
end

[Plain.new, Plain.new].each { |p| puts "plain class from block: #{p.value}" }
