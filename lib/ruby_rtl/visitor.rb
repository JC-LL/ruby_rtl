
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
      puts comb.body.class
      comb.body.accept(self)
    end

    def visitSequential seq,args=nil
      puts seq.body.class
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

    def visitCase case_,args=nil
      case_.cond.accept(self)
      case_.body.accept(self)
    end

    def visitWhen when_,args=nil
      when_.value.accept(self) unless when_.value.is_a?(Symbol)
      when_.body.accept(self)
    end

    # === fsm
    def visitFsm fsm,args=nil
      fsm.body.accept(self)
    end

    def visitState state,args=nil
      state.body.accept(self)
    end

    def visitNext node,args=nil
    end

    # === expr ===
    def visitBinary node,args=nil
      node.lhs.accept(self)
      node.rhs.accept(self)
    end

    def visitUnary node,args=nil
      node.expr.accept(self)
    end

    def visitIndexed indexed,args=nil
      lhs=indexed.lhs.accept(self)
      rhs=indexed.rhs.accept(self)
    end
    # === literals ===
    def visitLiteral node,args=nil
      node
    end

    def visitBitLit node,args=nil
      node
    end

    def visitIntLit lit,args=nil
      lit
    end

    def visitUIntLit lit,args=nil
      lit
    end

    def visitRIntLit lit,args=nil
      lit
    end

    def visitRUIntLit lit,args=nil
      lit
    end
    # === types ===
    def visitInteger int,args=nil
      int
    end

    def visitType node,args=nil
    end

    def visitBitType node,args=nil
    end

    def visitBitVectorType node,args=nil
    end

    def visitIntType node,args=nil
    end


    def visitUIntType node,args=nil
    end

    def visitRIntType node,args=nil
    end

    def visitRUintType node,args=nil
    end

    def visitRecordType node,args=nil
    end

  end
end
