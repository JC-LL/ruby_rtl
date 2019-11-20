require_relative '../lib/ruby_rtl.rb'

include RubyRTL

class FSM1 < Circuit
  def initialize
    input :go,:b
    output :f => :bv2

    fsm(:simple){

      assign(f <= 0)

      state(:s0){
        assign(f <= 1)
        If(go==1){
          next_state :s1
        }
      }

      state(:s1){
        assign(f <= 2)
        next_state :s2
      }

      state(:s2){
        assign(f <= 3)
        next_state :s0
      }
    }
  end
end

circuit=FSM1.new

compiler=Compiler.new
compiler.compile(circuit)
#compiler.generate(circuit)
