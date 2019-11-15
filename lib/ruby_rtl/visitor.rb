
module RubyRTL
  class Visitor
    def visit circuit
      circuit.ast.each{|node| node.accept(self)}
    end

    def visitSigDecl decl
      decl.name
      puts decl.sig.accept(self)
    end

  end
end
