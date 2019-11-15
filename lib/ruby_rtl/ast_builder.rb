module RubyRTL

  class ASTBuilder

    attr_accessor :ast

    # no initialize :
    #  - @ast is not initialized here
    #  - this allows to avoid calling "super" in every circuit.
    #
    # Instead, (@ast||=[]) is used when needed.
    #   - Dont forget the parenthesis !

    def input *arg
      process_sig_decl(:input,*arg)
    end

    def output *arg
      process_sig_decl(:output,*arg)
    end

    def wire *arg
      process_sig_decl(:wire,*arg)
    end

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
            decl_sig(kind,vname=arg.to_sym,type=:bit)
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
      when Hash
        arg.each do |vname,type|
          case vname
          when String
            vname=vname.to_sym
          when Symbol
          else
            raise "DSL syntax ERROR : #{vname} instead of String | Symbol"
          end
          decl_sig(:input,vname=arg,type)
        end
      else
        raise "ERROR : wrong input declaration '#{arg}'"
      end
    end

    def decl_sig kind,vname_sym,type=:bit
      klass=Object.const_get(kind.capitalize)
      io=klass.new(type)
      vname="@#{vname_sym}"
      instance_variable_set(vname, io)
      port=instance_variable_get(vname)
      self.class.__send__(:attr_accessor, vname_sym)
      (@ast||=[]) << SigDecl.new(vname,port)
    end

    def comment str
      @ast << Comment.new(str)
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
      (@ast||=[]) << CompDecl.new(comp_name,comp)
      comp
    end


    # syntax : ASSIGN( y <= e), instead of ASSIGN(y,e)
    def assign(var_expr_leq)
      var,expr=var_expr_leq.lhs,var_expr_leq.rhs
      (@ast||=[]) << assign=Assign.new(var,expr)
      assign
    end

    def IF(cond,&block)
      @ast << If.new(cond,&block)
    end

    def ELSIF(cond,&block)
      @ast << Elsif.new(cond,&block)
    end

    def ELSE(&block)
      @ast << Else.new(&block)
    end

    # here, we need a trick to evaluate the block.
    # we ask the current ast builder object to evaluate
    # the block, in its current context.
    # We then try to find the difference between ast before and after
    # the evaluation.
    def combinatorial(label=nil,&block)
      old_ast=@ast.clone
      instance_eval(&block)
      diff=@ast-old_ast
      @ast=@ast-diff
      @ast << Combinatorial.new(label,diff)
    end

    alias :comb :combinatorial

    def sequential(label=nil,&block)
      old_ast=@ast.clone
      instance_eval(&block)
      diff=@ast-old_ast
      @ast=@ast-diff
      @ast << Sequential.new(label,diff)
    end

    alias :seq :sequential

  end
end
