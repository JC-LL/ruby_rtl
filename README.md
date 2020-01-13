# RubyRTL
RubyRTL is a experimental Ruby DSL that aims at :
- Describing Digital circuits in Ruby, at the RTL level
- Generating synthésizable VHDL for FPGAs or ASICs

## How to install ?
The recommanded version of RubyRTL is uploaded on RubyGems, so that can simply be installed on a Linux box, by typing (use of rvm recommended):
- gem install ruby_rtl

## How does it look ?

Let's take the Hello World of digital system design : the case of a Half Adder circuit. We recall that it is a basic (2 gates) circuit, that can be used in a hierarchical manner to build a adder operating on integer. This bottom-up approach is
representative of Digital System Design : we can elaborate complex functions with a clever composition of such components, either hierarchically or using the intrinsic parallelism of digital circuit.

Using RubyRTL, we can elaborate much more complex circuits than this simple bit-level adders. At the register-transfer level, much more complex functions operating on complex data structures, are possible : imagine a video macroblocks on which several filters are applied, in a single clock cycle, etc.

'''ruby
require_relative '../lib/ruby_rtl'

include RubyRTL

class HalfAdder < Circuit
  def initialize
    input  :a,:b
    output :sum
    output :cout

    assign(sum  <= a ^ b) #xor
    assign(cout <= a & b) #cout

  end
end

ha=HalfAdder.new

compiler=Compiler.new
compiler.compile ha # VHDL generated !
'''

## How does this DSL works ?
RubyRTL is an *internal DSL*. We can see it as a new language, embedded in Ruby syntax. It benefits from Ruby directly.
More to come here. Stay tuned !

## Contact
Don't hesitate to drop me a mail if you like RubyRTL, or found a bug etc.
I will try to do my best to consolidate, maintain and enhance RubyRTL.
