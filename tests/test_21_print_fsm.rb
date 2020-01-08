require_relative '../lib/ruby_rtl'

include RubyRTL

class FsmTest < Circuit
  def initialize
    input :reset,:go
    input :change
    output :message 

    fsm(:test){

      assign(message <= 0)

      state(:s0){
        If(go==1){
          next_state :s1
        }
      }

      state(:s1){
        If(change==1){
          next_state :s2
        }
      }

      state(:s2){
        If (reset==1){
          assign(message <= 42)
          next_state :s0
        }
        Elsif (change==1){
          next_state :s1
        }
        Else{
          next_state :s2
        }
      }
    }
  end
end

circuit=FsmTest.new
compiler=Compiler.new
compiler.compile(circuit)
