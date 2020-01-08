require_relative '../lib/ruby_rtl'

include RubyRTL

require_relative 'test_3_full_adder'

class Adder < Circuit

  def initialize nbits
    input  :a    => nbits
    input  :b    => nbits
    output :sum  => nbits
    output :cout

    # create  components
    adders=[]
    for i in 0..nbits-1
      adders << component("fa_#{i}" => FullAdder)
    end

    # connect everything
    for i in 0..nbits-1
      assign(adders[i].a <= a[i])
      assign(adders[i].b <= b[i])
      if i==0
        #assign(adders[0].cin <= Bit(0)) # no carry in for FA_0
        assign(adders[0].cin <= 0)       # even better.
      else
        assign(adders[i].cin <= adders[i-1].cout)
      end
      # final sum
      assign(sum[i]        <= adders[i].sum)
    end
  end
end

if $PROGRAM_NAME==__FILE__
  pp adder=Adder.new(8)
end
