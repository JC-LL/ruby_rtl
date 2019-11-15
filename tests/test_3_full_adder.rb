require_relative '../lib/ruby_rtl'

include RubyRTL

require_relative 'test_2_half_adder'

class FullAdder < Circuit
  def initialize
    input  :a,:b,:cin
    output :sum,:cout

    component :ha1 => HalfAdder     # class...
    component :ha2 => HalfAdder.new # or ...obj

    assign(ha1.a <= a )
    assign(ha1.b <= b )
    assign(ha2.a <= cin)
    assign(ha2.b <= ha1.sum)
    assign(sum   <= ha1.sum)
    assign(cout  <= ha1.cout | ha1.cout)

  end
end

if $PROGRAM_NAME == __FILE__
  pp fa=FullAdder.new
end
