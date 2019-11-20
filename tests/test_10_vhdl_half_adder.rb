require_relative '/home/jcll/JCLL/dev/EDA-ESL/ruby_rtl/lib/ruby_rtl.rb'
require_relative 'test_2_half_adder.rb'

include RubyRTL

circuit=HalfAdder.new
Compiler.new.compile(circuit)
