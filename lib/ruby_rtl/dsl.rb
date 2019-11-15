require_relative 'ast'
require_relative 'ast_builder'

module RubyRTL

  class Sig < Ast
    attr_accessor :type
    attr_accessor :subscript_of

    def initialize arg=:bit
      @type=build_type(arg)
    end

    def build_type arg
      case arg
      when Integer
        val=arg
        return Bit.new if val==1
        return BitVector.new(val)
      when /uint(\d+)/
      when /int(\d+)/
      when Record
      end
    end

    def |(other)
      Binary.new(self,"|",other)
    end

    def &(other)
      Binary.new(self,"&",other)
    end

    def ^(other)
      Binary.new(self,"^",other)
    end

    def <=(other)
      Binary.new(self,"<=",other)
    end

    def !@
      Unary.new("!",self)
    end

    def -@
      Unary.new("-",self)
    end

    def [](index)
      @subsignals||=[]
      case type
      when Integer
        value=type
        (0..value-1).each do |i|
          @subsignals << sig=Sig.new(1)
          sig.subscript_of=self
        end
      when /bv(\d+)/
      when /uint(\d+)/
      when /int(\d+)/
      when Record
      else
        raise "DSL syntax error : no index [#{index}] for signal '#{self}'"
      end
      return @subsignals[index]
    end

  end

  def Record hash
  end

  class CircuitPart < ASTBuilder
    attr_accessor :label,:ast
    def initialize label,ast
      @label,@ast=label,ast
    end
  end

  class Combinatorial < CircuitPart
  end

  class Sequential < CircuitPart
  end




end
