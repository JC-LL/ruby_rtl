require_relative '../lib/ruby_rtl'

include RubyRTL

class Simple < Circuit
  def initialize
    input  :a
    input  :b => :bv8
    output :f1,:f2

    wire :w1 => :bv8
    wire :w2 => :bit
    wire :w3 => :int8

    typedef :complex => Record(:re => :int16, :im => :int16)

    assign(f1 <= a)     # bit <= bit    ~~> bit <= bit
    assign(f2 <= 1)     # bit <= ruint1   ~~> bit <= bit
    assign(b[2] <= 1)   # bit <= ruint1   ~~> bit <= bit
    assign(b <= 1)      # bit <= ruint1   ~~> bit <= bit

    If(a==1){           # bit == ruint1   ~~> bit == bit
      assign(f1 <= 42)  # bit <= ruint6   ~~> ERROR
    }

    assign(w1 <= 1)
    assign(w1 <= 0b10101010)
    assign(w1 <= 1 + 0b10101010)
    assign(w1 <= a + 1) # bv8  <= bit + ruint1    ~~> bv8 <= resize(bit,8)
    assign(w2 <= a + 1) # bit  <= bit + ruint1    ~~> ERROR
    assign(w2 <= 1 + a) # bit  <= ruint1 + bit    ~~> ERROR
    assign(w2 <= 1 + 1) # bit  <= ruint2  !!!     ~~> ERROR
    assign(w3 <= a + 5) # int8 <= bit + ruint3    ~~> int8 <= signed(resize(ruint3))

  end
end

circuit=Simple.new

compiler=Compiler.new
compiler.analyze(circuit)
compiler.print_dsl(circuit)
compiler.type_check(circuit)
