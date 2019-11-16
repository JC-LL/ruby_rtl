require_relative '../lib/ruby_rtl'

include RubyRTL

class MyCircuit < Circuit
  def initialize
    input :a           # type Bit
    input :b => 1      # type bit
    input :c => :bit   # type Bit
    input :d => 8      # type BitVector(8)
    input :e => :bv4   # type BitVector(4)
    input :f => :uint8 # type Uint(8)
    input :g => :int16 # type Int(8)
  end
end

pp circuit=MyCircuit.new
