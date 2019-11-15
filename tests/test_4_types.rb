require_relative '../lib/ruby_rtl'

include RubyRTL

class MyCircuit < Circuit
  def initialize
      input :a           # type Bit
      input :b => :bit   # type Bit
      input :c => :bv4   # type BitVector(4)
      input :d => :uint8 # type Uint(8)
      input :d => :int16 # type Int(8)
  end
end

pp circuit=MyCircuit.new
