require_relative '../lib/ruby_rtl'

include RubyRTL

class MyCircuit < Circuit
  def initialize
    typedef :imag6 => Record(:re => :int6, :im => :int6)
    input :v => :imag6
    input :a => 8
  end
end

circuit=MyCircuit.new
pp circuit.a.type
pp circuit.v[:re].type
