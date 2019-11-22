module RubyRTL

  class ASTBuilder

    attr_accessor :ast

    # no 'initialize' :
    #  - @ast is not initialized here
    #  - this allows to avoid calling "super" in every circuit.
    #
    # Instead, (@ast||=[]) is used when needed.
    #   - Dont forget the parenthesis !

    def input *arg
      @ast||=Root.new
      process_sig_decl(:input,*arg)
    end

    def output *arg
      @ast||=Root.new
      @last=@ast
      process_sig_decl(:output,*arg)
    end

      # define a type
    def typedef h
      @ast||=Root.new
      @last=@ast
      name_sym,definition=h.first
      @ast.typedefs[name_sym] << decl=TypeDecl.new(name_sym,definition)
      @last=decl
      decl
    end

    def wire *arg
      process_sig_decl(:sig,*arg)
    end

    alias :signal :wire

    def comment str
      (@last.comments||=[]) << Comment.new(str)
    end

    def component name_obj_or_class_h
      comp_name,obj_or_klass=name_obj_or_class_h.first
      comp_name=comp_name.to_sym if comp_name.is_a? String
      case klass=comp=obj_or_klass
      when Class
        comp=klass.new # but no parameters :-(
      end
      cname="@#{comp_name}"
      instance_variable_set(cname,comp)
      self.class.__send__(:attr_accessor, comp_name)
      @ast.body << CompDecl.new(comp_name,comp)
      comp
    end

    # syntax : ASSIGN( y <= e), instead of ASSIGN(y,e)
    def assign(var_expr_leq)
      @ast||=Root.new
      var,expr=var_expr_leq.lhs,var_expr_leq.rhs
      @ast.body << Assign.new(var,expr)
    end

    def differential_ast &block
      before=@ast.body.stmts.clone
      instance_eval(&block)
      after=@ast.body.stmts
      diff=after-before
      @ast.body.stmts=before
      return diff
    end

    def If(cond,&block)
      diff=differential_ast(&block)
      @ast.body << If.new(cond,Body.new(diff))
    end

    def Elsif(cond,&block)
    diff=differential_ast(&block)
      @ast.body << Elsif.new(cond,Body.new(diff))
    end

    def Else(&block)
      diff=differential_ast(&block)
      @ast.body << Else.new(Body.new(diff))
    end

    # here, we need a trick to evaluate the block.
    # we ask the current ast builder object to evaluate
    # the block, in its current context.
    # We then try to find the difference between ast before and after
    # the evaluation.
    def combinatorial(label=nil,&block)
      diff=differential_ast(&block)
      @ast.body << Combinatorial.new(name,diff)
    end

    alias :comb :combinatorial

    def sequential(label=nil,&block)
      @has_sequential_statements=true
      diff=differential_ast(&block)
      @ast.body << Sequential.new(label,Body.new(diff))
    end

    alias :seq :sequential

    def name
      self.class.to_s
    end
    # === fsm stuff
    def fsm name, &block
      diff=differential_ast(&block)
      @ast.body << Fsm.new(name,Body.new(diff))
    end

    def state name, &block
      diff=differential_ast(&block)
      @ast.body << State.new(name,Body.new(diff))
    end

    def next_state name
      @ast.body << Next.new(name)
    end

    private
    def process_sig_decl kind,*arg
      case arg
      when String
        decl_sig(kind,vname=arg.to_sym,type=:bit)
      when Symbol
        decl_sig(kind,vname=arg,type=:bit)
      when Array
        # strange ! recursivity seems to fail
        # output(element) # FAILS.
        arg.each do |element|
          case element
          when String
            decl_sig(kind,vname=element.to_sym,type=:bit)
          when Symbol
            decl_sig(kind,vname=element,type=:bit)
          when Hash
            element.each do |vname,type|
              decl_sig(kind,vname,type)
            end
          else
            "ERROR : wrong output declaration in list : '#{arg}'"
          end
        end
      when Record
        decl_sig(:input,vname=arg,type)
      else
        raise "ERROR : wrong input declaration '#{arg}'"
      end
    end

    def decl_sig kind,vname_sym,type=:bit
      @ast||=Root.new
      klass=Object.const_get(kind.capitalize)
      io=klass.new(vname_sym,type)
      vname="@#{vname_sym}"
      instance_variable_set(vname, io)
      self.class.__send__(:attr_accessor, vname_sym)
      @ast.decls << sig=SigDecl.new(vname_sym.to_s,io)
      sig
    end

  end
end
