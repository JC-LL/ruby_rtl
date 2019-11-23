require_relative 'code'
require_relative 'visitor'

module RubyRTL
  class TypeChecker < Visitor
    def check circuit
      puts "[+] type checking"
      root=circuit.ast
      root.ios.each{|io| io.accept(self)}
      root.decls.each{|decl| decl.accept(self)}
      root.body.accept(self)
    end

    def visitSigDecl decl,args=nil
    end

    def visitAssign assign,args=nil
      puts "-"*30
      lhs=assign.lhs.accept(self)
      rhs=assign.rhs.accept(self)
      puts "-assign #{lhs} <= #{rhs}"
    end

    def visitBinary bin,args=nil
      puts "visit Binary #{bin}"
      lhs_t=bin.lhs.accept(self)
      rhs_t=bin.rhs.accept(self)
      puts "#{bin.lhs}#{lhs_t}  #{bin.op} #{rhs_t}"
    end


    def visitInput input,args=nil
      input.type
    end

  end
end
