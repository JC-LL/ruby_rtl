
module RubyRTL
  class Visitor
    def visit circuit
      circuit.ast.each{|node| node.accept(self)}
    end

    def visitComment comment,args=nil
    end

    def visitInput input,args=nil
      input.type.accept(self)
    end

    def visitOutput output,args=nil
    end

    def visitSigDecl decl,args=nil
      decl.name
      decl.sig.accept(self)
    end

    def visitSig sig,args=nil
      sig
    end

    def visitTypeDecl decl,args=nil
    end

    def visitAssign assign,args=nil
    end

    # types
    def visitBit bit,args=nil
    end

  end
end
