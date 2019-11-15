require_relative 'ast_builder'

module RubyRTL

  class Ast
  end

  class Comment < Ast
    def initialize str
      @str=str
    end
  end

  class Sig < Ast
  end

  class Port < Sig
  end


  class Input < Port
    def initialize type=:bit
      @type=type
    end
  end

  class Output < Port
    def initialize type=:bit
      @type=type
    end
  end

  class Decl < Ast
    attr_accessor :name,:sig
    def initialize name,sig
      @name,@sig=name,sig
    end
  end

  class Circuit < ASTBuilder
  end

  class Assign < Ast
    def initialize lhs,rhs
      @lhs,@rhs=lhs,rhs
    end
  end

  class Expr < Ast
  end

  class Binary < Expr
    attr_accessor :lhs,:op,:rhs
    def initialize lhs,op,rhs
      @lhs,@op,@rhs=lhs,op,rhs
    end
  end

  class Unary < Expr
  end

end
