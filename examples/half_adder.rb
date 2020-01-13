require 'ruby_rtl'

include RubyRTL

class HalfAdder < Circuit
  def initialize
    input  :a,:b
    output :sum
    output :cout

    assign(sum  <= a ^ b) #xor
    assign(cout <= a & b) #cout

  end
end

if $PROGRAM_NAME == __FILE__
  pp ha=HalfAdder.new
  Compiler.new.compile(ha)
end
