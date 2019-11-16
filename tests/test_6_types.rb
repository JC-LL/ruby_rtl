require_relative '../lib/ruby_rtl'

include RubyRTL

class MyCircuit < Circuit
  def initialize
    typedef :imag6 => Record(:re => :int6, :im => :int6)
    input :h => :imag6
  end
end

pp circuit=MyCircuit.new
