require_relative 'ast_builder'
# reopen native class
class Integer
  def accept(visitor, arg=nil)
    name = "Integer"
    visitor.send("visit#{name}".to_sym, self ,arg) # Metaprograming !
  end
end

module RubyRTL

  class Circuit < ASTBuilder
    attr_accessor :has_sequential_statements
  end

  class Ast
    attr_accessor :comments
    def accept(visitor, arg=nil)
      name = self.class.name.split(/::/)[1]
      visitor.send("visit#{name}".to_sym, self ,arg) # Metaprograming !
    end
  end

  class Root < Ast
    attr_accessor :ios,:decls,:body
    def initialize
      @ios,@decls,@body=[],[],Body.new
    end
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
    attr_accessor :label,:body
    def initialize label,body
      @label,@body=label,body
    end
  end

  class Combinatorial < CircuitPart
  end

  class Sequential < CircuitPart
  end

  # === statements ===
  class Body < Ast
    include Enumerable
    attr_accessor :stmts
    def initialize stmts=[]
      @stmts=stmts
    end

    def <<(e)
      @stmts << e
    end

    def each &block
      stmts.each(&block)
    end
  end

  class Statement  < Ast
  end

  class Assign < Statement
    attr_accessor :lhs,:rhs
    def initialize lhs,rhs
      @lhs,@rhs=lhs,rhs
    end
  end

  class If < Statement
    attr_accessor :cond,:body
    attr_accessor :elsifs # feeded by ContextualAnalyzer
    attr_accessor :else   # idem
    def initialize cond, body=nil
      @cond=cond
      @body=body
      @elsifs=[]
    end
  end

  class Else < Statement
    attr_accessor :body
    def initialize body=nil
      @body=body
    end
  end

  class Elsif < Statement
    attr_accessor :cond,:body
    def initialize cond, body=nil
      @cond,@body=cond,body
    end
  end

  # FSM
  class Fsm < Ast
    attr_accessor :name,:body
    attr_accessor :states # hash
    attr_accessor :default_assigns
    def initialize name,body=nil
      @name,@body=name,body
      @default_assigns=[]
    end
  end

  class State < Ast
    attr_accessor :name,:body
    def initialize name,body=nil
      @name,@body=name,body
    end
  end

  class Next < Ast
    attr_accessor :name
    attr_accessor :of_state
    def initialize name
      @name=name
    end
  end
  # === expressions ===
  class Expr < Ast
    attr_accessor :type
  end

  class Binary < Expr
    attr_accessor :lhs,:op,:rhs
    def initialize lhs,op,rhs
      @lhs,@op,@rhs=lhs,op,rhs
    end
  end

  class Unary < Expr
  end
  # ====== literals ===
  class Literal < Ast
    attr_accessor :val
    attr_accessor :type

    def initialize val,type=nil
      @val,@type=val,type
    end

    def to_s
      "[#{type}]"
    end
  end

  class BitLit < Literal
  end

  class IntLit < Literal
    def initialize val
      super(val,IntType.new)
    end

    def +(other)
      ret=Binary.new(self,"+",other)
      ret.type=@type
      ret
    end
  end
  # ====== types ======
  class Type < Ast
  end

  class BitType < Type
    def to_s
      "[bit]"
    end
  end

  class BitVectorType < Type
    attr_accessor :size
    def initialize size
      @size=size
    end
    def to_s
      "[bv #{size}]"
    end
  end

  class IntType < Type
    attr_accessor :nb_bits
    def initialize nbits=32
      @nb_bits=nbits
    end

    def to_s
      "[int 32]"
    end
  end

  class UintType < Type
    attr_accessor :nb_bits
    def initialize nbits
      @nb_bits=nbits
    end
    def to_s
      "[uint 32]"
    end
  end

  class RecordType < Type
    attr_accessor :hash
    def initialize h
      @hash=h
    end
  end

end
