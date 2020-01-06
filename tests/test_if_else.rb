require_relative '../lib/ruby_rtl'

include RubyRTL

class TestIfElse < Circuit
  def initialize
    input :a,:b
    output :f => :int32

    comb(:test){
      If(a==1){
        assign(f <= 42)
      }
      Else{
        assign(f <= 666)
      }
    }
  end
end


circuit=TestIfElse.new

compiler=Compiler.new
compiler.compile(circuit)
