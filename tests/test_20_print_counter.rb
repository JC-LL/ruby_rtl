require_relative '../lib/ruby_rtl'

include RubyRTL

class Counter < Circuit
  def initialize
    input  :do_count
    output :count => :byte
    output :test => :int16

    wire :w1 => :int16

    sequential(:strange_counting){
      If(do_count==1){
        If(count==255){
          assign(count <= 0)
        }
        Elsif(count==42){
          assign(count <= count + 42)
        }
        Else{
          assign(count <= count + 1)
        }
      }
    }

    assign(test <= 42)

    sequential(:count){
      assign(w1 <= 1 + w1)
    }
  end
end

circuit=Counter.new

compiler=Compiler.new
#compiler.analyze(circuit)
compiler.print_dsl(circuit)
