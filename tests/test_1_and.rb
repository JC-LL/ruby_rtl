require_relative '../lib/ruby_rtl'

include RubyRTL

class And < Circuit
  def initialize
    input  :a => :bit #optional type for single bit
    input  :b
    output :f

    comment("simple assignment")
    assign(f <= a & b)

  end
end

#pp a=And.new

# alternative syntax
class And_v2 < Circuit
  def initialize
    input  'a' => :bit
    input  :b
    output :f

    comment("simple assignment")
    assign(f <= a & b)

  end
end

#pp a=And_v2.new
