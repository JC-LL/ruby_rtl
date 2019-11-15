require_relative '../lib/ruby_rtl'

include RubyRTL

class And < Circuit
  def initialize
    input  :a => :bit
    input  :b => :bit
    output :f1,:f2
    output :f3

    wire :w1,:w2

    comment(" simple assignment")
    assign(f1 <= a | (b ^ a))

    comb(:label){
      assign(f2 <= a & b)
      assign(f3 <= a ^ b)
    }

    comb(:label2){
      assign(w1 <= a)
    }

    comb(){
      assign(w2 <= a)
    }


  end
end


pp a=And.new
