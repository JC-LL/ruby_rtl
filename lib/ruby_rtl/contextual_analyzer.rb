require_relative 'code'
require_relative 'visitor'

module RubyRTL

  class ContextualAnalyzer < Visitor

    def check circuit
      puts "[+] contextual analysis"
      root=circuit.ast
      root.ios.each{|io| io.accept(self)}
      root.decls.each{|decl| decl.accept(self)}
      root.body.accept(self)
    end

    def visitBody body,args=nil
      #reconnect Else/Elsifs objects to their parent If
      reconnectElseParts(body)
      body.stmts.each{|stmt| stmt.accept(self,args)}
    end

    def reconnectElseParts body
      ifs=body.select{|stmt| stmt.is_a? If}
      to_delete=[]
      ifs.each do |if_|
        index_if=body.stmts.index(if_)
        do_iterate=true
        index=index_if
        while do_iterate
          case elsei=body.stmts[index+1]
          when Else
            if_.else=elsei
            to_delete << elsei
            elsei.accept(self) # dont forget to visit it
          when Elsif
            if_.elsifs << elsei
            to_delete << elsei
            elsei.accept(self)
          else
            do_iterate=false
          end
          index+=1
        end
      end
      to_delete.each{|stmt| body.stmts.delete(stmt)}
    end

    def visitFsm fsm,args=nil
      @current=fsm
      puts " |-[+] visiting fsm '#{fsm.name}'"
      # default assignements
      fsm.default_assigns=fsm.body.select{|e| e.is_a? Assign}
      # build a state hash : state_name => state
      states_nodes=fsm.body.select{|e| e.is_a? State}
      fsm.states=states_nodes.inject({}){|hash,state| hash.merge!( state.name=> state)}
      fsm.states.each{|_,state| state.accept(self)}
    end

    def visitNext next_,args=nil
      puts "visitNext"
      # enforce 'next' belongs to a whole FSM
      next_.of_state="#{@current.name}_state_c"
    end

  end
end
