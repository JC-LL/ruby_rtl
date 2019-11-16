require_relative '../lib/ruby_rtl'

include RubyRTL

class HalfAdder < Circuit
  def initialize
    input  :a => :bit
    input  :b => :bit
    output :sum
    output :cout

    assign(sum <= a ^ b) #xor
    assign(sum <= a & b) #cout
  
  end
end

if $PROGRAM_NAME == __FILE__
  pp ha=HalfAdder.new
end
