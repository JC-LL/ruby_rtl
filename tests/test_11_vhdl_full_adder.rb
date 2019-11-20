require_relative '/home/jcll/JCLL/dev/EDA-ESL/ruby_rtl/lib/ruby_rtl.rb'
require_relative 'test_3_full_adder.rb'

include RubyRTL

circuit=FullAdder.new
Compiler.new.compile(circuit)
