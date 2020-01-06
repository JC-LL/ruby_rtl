require_relative 'code'
require_relative 'visitor'

module RubyRTL
  class TypeChecker < Visitor
    def initialize
      @ppr=DSLPrinter.new
    end

    def check circuit
      puts "[+] type checking"
      root=circuit.ast
      if root=circuit.ast
        #root.ios.each{|io| io.accept(self)}
        root.decls.each{|decl| decl.accept(self)}
        root.body.accept(self)
      end
    end

    def cast t1,t2
      pair=[t1.class,t2.class]
      cast=nil
      case pair
      when [BitType,BitType]
      when [BitType,UIntType]
        cast=[:to_bit,1]
      when [BitType,IntType]
        cast=[:to_bit,1]

      when [BitType,RUIntType]
        cast=[:to_bit,1]

      when [IntType,BitType]
        cast=[:to_bit,1]
      when [IntType,IntType]
        if t1.bitwidth==t2.bitwidth
          return #nothing to do
        else
          cast=[:to_int,t1.bitwidth]
        end
      when [IntType,UIntType]
        unless t1.bitwidth==t2.bitwidth
          cast=[:to_int,t1.bitwidth]
        end
      when [IntType,RUIntType]
        unless t1.bitwidth == t2.bitwidth
          cast=[:to_int,t1.bitwidth]
        end
      when [UIntType,BitType]
        cast=[:to_uint,t1.bitwidth]
      when [UIntType,RIntType]
        cast=[:to_uint,t1.bitwidth]
      when [UIntType,RUIntType]
        cast=[:to_uint,t1.bitwidth]

      when [UIntType,IntType]
        u_bw,s_bw=t1.bitwidth,t2.bitwidth
        cast=[:to_uint,u_bw]
      when [UIntType,UIntType]
        if t1.bitwidth==t2.bitwidth
          return #nothing to do
        else
          cast=[:to_uint,t1.bitwidth]
        end
      #============ bit vector =============
      when [BitVectorType,UIntType]
        cast=[:to_bv,t1.bitwidth]
      when [BitVectorType,RUIntType]
        cast=[:to_bv,t1.bitwidth]
      when [RecordType,RecordType]
      else
        raise "NIY cast #{pair}"
      end
      return cast
    end

    def visitAssign assign,args=nil
      puts "- assign : #{assign.accept(@ppr)}"
      lhs=assign.lhs.accept(self)
      rhs=assign.rhs.accept(self)
      puts "\ttypes : #{lhs.to_s} <= #{rhs.to_s}"
      cast_func=cast(lhs,rhs)
      if cast_func
        name,bw=*cast_func
        assign.rhs=FuncCall.new(name,[assign.rhs,bw])
      end
    end

    def homogenize t1,op,t2
      pair=[t1.class,t2.class]
      conv=[nil,nil,t1]
      case pair
      when [BitType,BitType]
        unless ["&","|","^"].include?(op)
          raise "illegal operation '#{op}' between 2 bits"
        end
      when [BitType,UIntType]
        conv=[["to_uint",t2.bitwidth],nil,t2]
      when [BitType,IntType]
        conv=[["to_int",t2.bitwidth],nil,t2]
      when [BitType,RIntType]
        conv=[["to_int",t2.bitwidth],nil,t2]
      when [BitType,RUIntType]
        conv=[["to_uint",t2.bitwidth],nil,t2]

      when [IntType,BitType]
        conv=[nil,["to_int",t1.bitwidth],t1]
      when [IntType,IntType]
        unless t1.bitwidth==t2.bitwidth
          max=[t1.bitwidth,t2.bitwidth].max
          if t1==max
            conv=[nil,["to_int",max],t1]
          else
            conv=[["to_int",max],nil,t2]
          end
        end
      when [IntType,UIntType]
        max=[t1.bitwidth,t2.bitwidth].max
        if t1==max
          conv=[nil,["to_int",max],t1]
        else
          conv=[["to_uint",max],nil,t2]
        end
      when [IntType,RUIntType]
        unless t1.bitwidth >= t2.bitwidth # note >=
          max=[t1.bitwidth,t2.bitwidth].max
          if t1==max
            conv=[nil,["to_int",max],t1]
          else
            conv=[["to_int",max],nil,t2]
          end
        end
      when [UIntType,BitType]
        conv=[nil,["to_uint",t1.bitwidth],t1]
      when [UIntType,IntType]
        u_bw,s_bw=t1.bitwidth,t2.bitwidth
        max=[u_bw,s_bw].max
        type=IntType.new(max)
        conv=[["to_int",max],["to_int",max],type]
      when [UIntType,UIntType]
        unless t1.bitwidth==t2.bitwidth
          max=[t1.bitwidth,t2.bitwidth].max
          if t1==max
            conv=[nil,["to_uint",max],t1]
          else
            conv=[["to_uint",max],nil,t2]
          end
        end
      when [RecordType,RecordType]
      else
        raise "NIY homogenize #{pair}"
      end
      pp conv
      return conv
    end

    def visitBinary bin,args=nil
      puts "- binary #{bin.accept(@ppr)}"
      lhs_t=bin.lhs.accept(self)
      rhs_t=bin.rhs.accept(self)
      puts "\ttypes : #{lhs_t} #{bin.op} #{rhs_t}"
      conv_funcs=homogenize(lhs_t,bin.op,rhs_t)
      pp conv_funcs
      if conv=conv_funcs[0]
        name,bitwidth=*conv
        bin.lhs=FuncCall.new(name,[bin.lhs,bitwidth])
      end
      if conv=conv_funcs[1]
        name,bitwidth=*conv
        bin.rhs=FuncCall.new(name,[bin.rhs,bitwidth])
      end
      bin.type=conv_funcs[2]
    end

    def visitSig sig,args=nil
      sig.type
    end

    def visitIndexed indexed, args=nil
      indexed.type
    end

    def visitInput input,args=nil
      input.type
    end

    def visitOutput output,args=nil
      output.type
    end

    # literals
    def visitIntLit lit,args=nil
      lit.type
    end

    def visitUIntLit lit,args=nil
      lit.type
    end

    def visitRIntLit lit,args=nil
      lit.type
    end

    def visitRUIntLit lit,args=nil
      lit.type
    end

  end
end
