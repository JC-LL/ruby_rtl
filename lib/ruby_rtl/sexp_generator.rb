require_relative 'code'

module RubyRTL

  class SexpGenerator < DSLPrinter

    def generate circuit
      puts "[+] S-exp code generation"
      root=circuit.ast
      code=Code.new
      code << "(circuit #{circuit.name}"
      code.indent=2
      root.decls.each{|decl| code << decl.accept(self)}
      code << root.body.accept(self)
      code.indent=0
      code << ")"
      puts code.finalize
    end

    def visitSigDecl sig_decl,args=nil
      name=sig_decl.name
      type=sig_decl.sig.type.accept(self)
      "(input #{name} #{type})"
    end

    # statements
    def visitBody body,args=nil
      code=Code.new
      body.each{|stmt| code << stmt.accept(self)}
      code
    end

    def visitAssign assign,args=nil
      lhs=assign.lhs.accept(self)
      rhs=assign.rhs.accept(self)
      "(assign #{lhs} #{rhs})"
    end

    def visitIf if_,args=nil
      code=Code.new
      cond=if_.cond.accept(self)
      code << "(if #{cond}"
      code.indent=2
      code << "(then"
      code.indent=4
      code << if_.body.accept(self)
      code.indent=2
      code << ")"
      code.indent=0
      code << ")"
      code
    end

    # fsm
    def visitFsm fsm,args=nil
      code=Code.new
      code << "(fsm #{fsm.name}"
      code.indent=2
      fsm.states.each{|state| code << state.accept(self)}
      code.indent=0
      code << ")"
      code
    end

    def visitState state,args=nil
      code=Code.new
      code << "(state #{state.name}"
      code.indent=2
      code << state.body.accept(self)
      code.indent=0
      code << ")"
      code
    end

    def visitNext node,args=nil
      "(next_state #{node.name})"
    end

    # === expr ===
    def visitBinary node,args=nil
      lhs=node.lhs.accept(self)
      op=node.op
      rhs=node.rhs.accept(self)
      "(#{op} #{lhs} #{rhs})"
    end

    def visitUnary node,args=nil
      expr=node.expr.accept(self)
      "(#{node.op} #{expr})"
    end

    def visitFuncCall func,args=nil
      name=func.name
      argus=func.args.collect{|arg| arg.accept(self)}.join(" ")
      "(call #{name} #{argus})"
    end

    def visitIndexed indexed,args=nil
      lhs=indexed.lhs.accept(self)
      rhs=indexed.rhs.accept(self)
      "(indexed #{lhs} #{rhs})"
    end


    def visitRecordType rec_type,args=nil
      items=[]
      rec_type.hash.each{|item,type|
        items << "#{item} => #{type}"
      }
      "Record(#{items.join(",")})"
    end

    def visitEnumType enum_type,args=nil
      "Enum(#{enum_type.items.join(",")})"
    end

    def visitMemoryType mem_type,args=nil
      typename=mem_type.type
      "Memory(#{mem_type.size},#{typename})"
    end

    def visitCase case_,args=nil
      code=Code.new
      code << "Case(){"
      code.indent=2
      code << case_.body.accept(self)
      code.indent=0
      code << "}"
      code
    end
  end
end
