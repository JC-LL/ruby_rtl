<img src="./doc/logo.png" alt="drawing" width="200"/>

# RubyRTL : Ruby-*on-gates* !


RubyRTL is an experimental Ruby DSL that aims at :
- Describing Digital circuits in Ruby, at the RTL level
- Generating synthesizable VHDL for FPGAs or ASICs

## How to install ?
The recommanded version of RubyRTL is uploaded on RubyGems, so that can simply be installed on a Linux box, by typing (use of rvm recommended):
- gem install ruby_rtl

## How does it look ?

Let's build a introductory-level digital system : a ripple-carry adder. Using RubyRTL, we can elaborate much more complex circuits than this simple adders. At the register-transfer level, much more complex functions operating on complex data structures, are possible : imagine a video macroblocks on which several filters are applied, in a single clock cycle, or a processor pipline etc.

For the moment, let's build this adder, in a progessive manner !

### Basic signal assignments : 1-bit half adder circuit

We start by the "Hello World" of Digital Design : the Half adder. We recall that it built from  2 basic gates. That "block" can be then used in a hierarchical manner to build a 1-bit full-adder and then a classical adder operating on integers. See [wikipedia](https://en.wikipedia.org/wiki/Adder_(electronics))  if needed. This bottom-up approach is representative of Digital System Design : we can elaborate complex functions with a clever composition of such components, either hierarchically or using the intrinsic parallelism of digital circuit, or both.

~~~ruby
  require_relative 'ruby_rtl'

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
~~~

The generated code is then :

~~~vhdl
-- automatically generated by RubyRTL
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ruby_rtl;
use ruby_rtl.ruby_rtl_package.all;

library halfadder_lib;
use halfadder_lib.halfadder_package.all;

entity halfadder_c is
  port (
    a : in  std_logic;
    b : in  std_logic;
    sum : out std_logic;
    cout : out std_logic);
end halfadder_c;

architecture rtl of halfadder_c is
begin

  sum <= (a xor b);
  cout <= (a and b);

end rtl;
~~~
## Hierarchical composition : 1-bit full adder

Here, we *reuse* 1-but half adder, to elaborate a 1-bit full adder. It now has an input carry and an output carry. The example show how to call such hierarchal components and glue them together.

~~~ruby
require 'ruby_rtl'

include RubyRTL # module now visible

require_relative 'half_adder' # preceding circuit

class FullAdder < Circuit
  def initialize
    input  :a,:b,:cin
    output :sum,:cout

    component :ha1 => HalfAdder     # class...
    component :ha2 => HalfAdder.new # or ...obj

    assign(ha1.a <= a )
    assign(ha1.b <= b )
    assign(ha2.a <= cin)
    assign(ha2.b <= ha1.sum)
    assign(sum   <= ha1.sum)
    assign(cout  <= ha1.cout | ha1.cout)

  end
end
~~~

### Genericity : word-level adders
Here comes the most exiting parts of RubyRTL. We can rely on Ruby host itself, to describe the glue between components. Ruby host also allows you to make regular computations required for the configuration of your design, which can be cumbersome in classical HDLs.

~~~ruby
require_relative 'ruby_rtl'
require_relative 'full_adder' #preceding circuit

include RubyRTL

class Adder < Circuit

  def initialize nbits
    input  :a    => nbits
    input  :b    => nbits
    output :sum  => nbits
    output :cout

    # create  components
    adders=[]
    for i in 0..nbits-1
      adders << component("fa_#{i}" => FullAdder)
    end

    # connect everything
    for i in 0..nbits-1
      assign(adders[i].a <= a[i])
      assign(adders[i].b <= b[i])
      if i==0
        #assign(adders[0].cin <= Bit(0)) # no carry in for FA_0
        assign(adders[0].cin <= 0)       # even better.
      else
        assign(adders[i].cin <= adders[i-1].cout)
      end
      # final sum
      assign(sum[i]        <= adders[i].sum)
    end
  end
end
~~~

The final circuit looks like this :



## Behavioral statements : counter

All previous examples were *structural*. Hardware descriptions languages such as VHDL and Verilog also allows for so called *behavioral* descriptions (please note that this naming is historical, and still found in course books. This is not to be cofounded with modern "High-level synthesis" also called *behavioral* synthesis, that is at a higher abstraction layer than RTL). Here our DSL allows more basically to resort to statements like :
- **If..Elsif...Else**
- **Case...When ...**

RubyRTL introduces these DSL keywords, that **require upcase** (in order to avoid collision with regular Ruby host keywords).

As for VHDL or Verilog, such RubyRTL statements are also synthesizable on hardware, if used correctly.

The **important remark** is about *clocks* and *resets*. RubyRTL recognizes (via **sequential** keyword) that your design requires D (edge-triggered) flip-flops : their clocking is considered *implicit*. By default, RubyRTL works on a *single clock* and generates synchronous and asynchronous reset. This may be modified in future versions.

~~~ruby
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
~~~

## Finite state machines (FSM)

Finite state machines are essential in Digital System Design. However, VHDL and Verilog do not provide instrinsic keywords for them. Here, RubyRTL simplified the coding by providing such keywords.

~~~ruby
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
~~~


## How does this DSL works ?
RubyRTL is an *internal DSL*. We can see it as a new language, embedded in Ruby syntax. It benefits from Ruby directly. However, such embedding needs a cautious resort to metaprogramming and introspection.

More to come here. Stay tuned !

## Contact
Don't hesitate to drop me a mail if you like RubyRTL, or found a bug etc.
I will try to do my best to consolidate, maintain and enhance RubyRTL.

jean-christophe.le_lann at ensta-bretagne.fr
