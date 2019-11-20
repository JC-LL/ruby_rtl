require_relative '/home/jcll/JCLL/dev/EDA-ESL/ruby_rtl/lib/ruby_rtl.rb'
require_relative 'test_5_adder.rb'

include RubyRTL

circuit=Adder.new(8)
Compiler.new.compile(circuit)
