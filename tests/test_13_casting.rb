require_relative '/home/jcll/JCLL/dev/EDA-ESL/ruby_rtl/lib/ruby_rtl.rb'

include RubyRTL

class TestCast < Circuit
  def initialize
    output  :outb => :byte

    wire :count => :uint8

    sequential(:counter){
      assign(count <= count+1)
    }

    assign(outb <= count)
  end
end

circuit=TestCast.new

VhdlGenerator.new.generate(circuit)
