require_relative '../lib/ruby_rtl'

include RubyRTL

class Alu < Circuit
  def initialize
    typedef :complex => Record(:real => :int,:imag => :int)
    typedef :opcodes => Enum(:op_add,:op_sub,:op_mul,:op_or,:op_and,:op_xor)
    input   :opcode  => :opcodes
    input   :a       => :uint32
    input   :b       => :uint32
    output  :f       => :uint32

    sequential(:test){
      Case(opcode){
        When(:op_add){
          assign(f <= a+b)
        }
        When(:op_sub){
          assign(f <= a-b)
        }
        Else {
          assign(f <= 0)
        }
      }
    }
  end
end

circuit=Alu.new
compiler=Compiler.new
compiler.compile(circuit)
