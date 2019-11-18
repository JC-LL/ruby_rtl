require_relative 'ast_builder'
# reopen native class
class Integer
  def accept(visitor, arg=nil)
    name = "Integer"
    visitor.send("visit#{name}".to_sym, self ,arg) # Metaprograming !
  end
end

module RubyRTL

  class Ast
    def accept(visitor, arg=nil)
      name = self.class.name.split(/::/)[1]
      visitor.send("visit#{name}".to_sym, self ,arg) # Metaprograming !
    end
  end

  class Circuit < ASTBuilder
    attr_accessor :has_sequential_statements
  end

  class Comment < Ast
    attr_accessor :str
    def initialize str
      @str=str
    end
  end

  # further defined in dsl.rb
  # attributes :
  # - type
  # - subscript_of
  class Sig < Ast
  end

  class Port < Sig
  end

  class Input < Port
  end

  class Output < Port
  end

  class TypeDecl < Ast
    attr_accessor :name,:definition
    def initialize name,definition
      @name,@definition=name,definition
    end
  end

  class SigDecl < Ast
    attr_accessor :name,:sig
    def initialize name,sig
      @name,@sig=name,sig
    end
  end

  class CompDecl < Ast
    attr_accessor :name,:comp
    def initialize name,comp
      @name,@comp=name,comp
    end
  end

  class CircuitPart < Ast
    attr_accessor :label,:block
    def initialize label,ast
      @label=label
      @ast=ast
    end
  end

  class Combinatorial < CircuitPart
  end

  class Sequential < CircuitPart
  end

  # === statements ===
  class Statement  < Ast
  end

  class Assign < Statement
    attr_accessor :lhs,:rhs
    def initialize lhs,rhs
      @lhs,@rhs=lhs,rhs
    end
  end

  class If < Statement
    def initialize cond, ast
      @cond=cond
      @body=ast
    end
  end

  class Else < Statement
    def initialize statements=[]
      @statements=statements
    end
  end

  class Elsif < Statement
    def initialize cond, statements=[]
      @cond,@statements=cond,statements
    end
  end


  # === expressions ===
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

  # ====== types =====
  class Type < Ast
  end

  class Bit < Type
  end

  class BitVector < Type
    attr_accessor :size
    def initialize size
      @size=size
    end
  end

  class Int < Type
    def initialize nbits
      @nb_bits=nbits
    end
  end

  class Uint < Type
    def initialize nbits
      @nb_bits=nbits
    end
  end

  class Record < Type
    attr_accessor :hash
    def initialize h
      @hash=h
    end
  end

end
