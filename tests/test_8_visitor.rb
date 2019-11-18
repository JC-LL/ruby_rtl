require_relative '/home/jcll/JCLL/dev/EDA-ESL/ruby_rtl/lib/ruby_rtl.rb'
require_relative 'test_1_and.rb'

include RubyRTL

pp circuit=And.new

visitor=Visitor.new

visitor.visit(circuit)
