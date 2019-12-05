require_relative '../lib/ruby_rtl'
include RubyRTL

class Test < Circuit
  def initialize

    typedef :complex => Record(:real => :int32,:imag => :int32)

    input  :a  => :bit
    output :f1 => :uint8
    output :f2 => :complex

    wire :w1 => :bit
    wire :w2 => :int
    wire :wc => :complex

    assign(w1 <= a)
    assign(w2 <= 42 + a)
    assign(wc[:real] <= w2)
    assign(f2 <= wc)
  end
end


circuit=Test.new

compiler=Compiler.new
compiler.compile(circuit)
