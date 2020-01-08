require_relative '../lib/ruby_rtl'

include RubyRTL

class Gcd < Circuit
  def initialize
    input :go
    output :done
    input :valid_a,:valid_b
    input :a => :uint32
    input :b => :uint32
    output :f => :uint32

    wire :va => :uint32
    wire :vb => :uint32

    fsm(:gcd){
      state(:s0){
        If(go==1){
          next_state :s1
        }
      }
      state(:s1){
        If(valid_a==1){
          assign(va <= a)
          next_state :s2
        }
      }
      state(:s2){
        If(valid_b==1){
          assign(vb <= b)
          next_state :s3
        }
      }
      state(:s3){
        If(va != vb){
          If(va > vb){
            assign(va <= va - vb)
          }
          Else{
            assign(vb <= vb - va)
          }
        }
        Else{
          assign(f <= va)
          assign(done <= 1)
          next_state(:s0)
        }
      }
    }
  end
end

circuit=Gcd.new

compiler=Compiler.new
compiler.compile(circuit)
