require_relative '../lib/ruby_rtl'

include RubyRTL

class And < Circuit
  def initialize
    input :a => :bit # optional type for single :bit
    input  :b         # default is :bit
    output 'f'        # alternative syntax

    comment("simple assignment")
    assign(f <= a & b)

  end
end

if $PROGRAM_NAME==__FILE__
  pp circuit=And.new
end
