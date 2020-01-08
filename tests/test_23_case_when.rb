require 'ruby_rtl'

include RubyRTL

class CaseWhen < Circuit
  def initialize
    input :val => :uint2
    output :f => :uint2
    wire :next_state => :uint2

    combinatorial(){
      Case(val){
        When(1){
          assign(f <= 1)
          assign(next_state <= 2)
        }
        When(2){
          assign(f <= 2)
          assign(next_state <= 1)
        }
        Else{
          assign(f <= 4)
          If((a == 2)){
            assign(f <= 3)
          }
        }
      }
    }
  end
end


circuit=CaseWhen.new

compiler=Compiler.new
compiler.compile(circuit)
