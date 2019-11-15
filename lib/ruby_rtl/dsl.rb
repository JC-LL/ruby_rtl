require_relative 'ast'
require_relative 'ast_builder'

module RubyRTL

  class Sig < Ast
    def initialize type=:bit
      @type=type
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
