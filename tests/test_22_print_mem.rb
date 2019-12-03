require_relative '../lib/ruby_rtl'

include RubyRTL

class Test22 < Circuit
end

circuit=Test22.new

compiler=Compiler.new
compiler.compile(circuit)
