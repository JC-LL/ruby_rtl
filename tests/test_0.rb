require_relative '../lib/ruby_rtl'

include RubyRTL

class And_v0 < Circuit
  attr_accessor :a,:b,:f
  def initialize
    super()
    @a=Input.new
    @b=Input.new
    @f=Output.new

    @comb << ASSIGN(f <= a & b)
  end
end

pp a_0=And_v0.new
