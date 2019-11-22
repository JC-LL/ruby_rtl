
module RubyRTL
  class Visitor

    def visit circuit
      circuit.ast.each{|node| node.accept(self)}
    end

    def visitComment node,args=nil
    end

    def visitSig node,args=nil
    end

    def visitPort node,args=nil
    end

    def visitInput node,args=nil
    end

    def visitOutput node,args=nil
    end

    def visitTypeDecl node,args=nil
    end

    def visitSigDecl node,args=nil
    end

    def visitCompDecl node,args=nil
    end

    def visitCircuitPart node,args=nil
    end

    def visitCombinatorial comb,args=nil
      comb.body.accept(self)
    end

    def visitSequential seq,args=nil
      seq.body.accept(self)
    end

    # === statements
    def visitBody body,args=nil
      body.each{|stmt| stmt.accept(self,args)}
    end

    def visitAssign node,args=nil
      node.lhs.accept(self)
      node.rhs.accept(self)
    end

    def visitIf node,args=nil
      node.cond.accept(self)
      node.body.accept(self)
      node.elsifs.each{|elsif_| elsif_.accept(self)}
      node.else.accept(self) if node.else
    end

    def visitElse else_,args=nil
      else_.body.accept(self)
    end

    def visitElsif elsif_,args=nil
      elsif_.cond.accept(self)
      elsif_.body.accept(self)
    end

    # === fsm
    def visitFsm fsm,args=nil
      fsm.states.each do |name,state|
        state.accept(self)
      end
    end

    def visitState state,args=nil
      state.body.accept(self)
    end

    def visitNext node,args=nil
    end

    # === expr ===
    def visitExpr node,args=nil
    end

    def visitBinary node,args=nil
    end

    def visitUnary node,args=nil
    end

    # === literals ===
    def visitLiteral node,args=nil
    end

    def visitBitLit node,args=nil
    end

    def visitIntLit lit,args=nil
    end
    # === types ===
    def visitInteger int,args=nil
    end

    def visitType node,args=nil
    end

    def visitBitType node,args=nil
    end

    def visitBitVectorType node,args=nil
    end

    def visitIntType node,args=nil
    end

    def visitUintType node,args=nil
    end

    def visitRecordType node,args=nil
    end

  end
end
