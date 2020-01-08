require_relative '../lib/ruby_rtl'

include RubyRTL

class Counter < Circuit
  def initialize
    input  :do_count
    output :count => :byte

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
  end
end

circuit=Counter.new
Compiler.new.compile(circuit)
