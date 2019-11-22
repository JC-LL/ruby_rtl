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

    def visitAssign assign,args=nil
      puts "-assign #{assign} #{assign.lhs.type} <= #{assign.rhs.type}"
    end
  end
end
