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
        root.ios.each{|io| io.accept(self)}
        root.decls.each{|decl| decl.accept(self)}
        root.body.accept(self)
      end
    end

    def cast t1,t2
      pair=[t1.class,t2.class]
      cast=nil
      case pair
      when [BitType,BitType]
      when [BitType,UintType]
        cast=[:to_bit]
      when [BitType,IntType]
        cast=[:to_bit]
      when [IntType,BitType]
        cast=[:to_bit]
      when [IntType,IntType]
        if t1.bitwidth==t2.bitwidth
          return #nothing to do
        else
          cast=[:to_int,t1.bitwidth]
        end
      when [IntType,UintType]
        unless t1.bitwidth==t2.bitwidth
          cast=[:to_int,t1.bitwidth]
        end
      when [UintType,BitType]
        cast=[:to_uint,t1.bitwidth]
      when [UintType,IntType]
        u_bw,s_bw=t1.bitwidth,t2.bitwidth
        cast=[:to_uint,u_bw]
      when [UintType,UintType]
        if t1.bitwidth==t2.bitwidth
          return #nothing to do
        else
          cast=[:to_uint,t1.bitwidth]
        end
      when [RecordType,RecordType]
      else
        raise "NIY homogenize #{pair}"
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


    def homogenize t1,t2
      pair=[t1.class,t2.class]
      conv=[nil,nil,t1]
      case pair
      when [BitType,BitType]
      when [BitType,UintType]
        conv=[["to_uint",t2.bitwidth],nil,t2]
      when [BitType,IntType]
        conv=[["to_int",t2.bitwidth],nil,t2]
      when [IntType,BitType]
        conv=[nil,["to_int",t1.bitwidth]]
      when [IntType,IntType]
        if t1.bitwidth==t2.bitwidth
          return #nothing to do
        else
          max=[t1.bitwidth,t2.bitwidth].max
          if t1==max
            conv=[nil,["to_int",max],t1]
          else
            conv=[["to_int",max],nil,t2]
          end
        end
      when [IntType,UintType]
        if t1.bitwidth==t2.bitwidth
          return #nothing to do
        else
          max=[t1.bitwidth,t2.bitwidth].max
          if t1==max
            conv=[nil,["to_int",max],t1]
          else
            conv=[["to_int",max],nil,t2]
          end
        end
      when [UintType,BitType]
        conv=[nil,["to_uint",t1.bitwidth],t1]
      when [UintType,IntType]
        u_bw,s_bw=t1.bitwidth,t2.bitwidth
        max=[u_bw,s_bw].max
        type=IntType.new(max)
        conv=[["to_int",max],["to_int",max],type]
      when [UintType,UintType]
        if t1.bitwidth==t2.bitwidth
          return #nothing to do
        else
          max=[t1.bitwidth,t2.bitwidth].max
          if t1==max
            conv=[nil,["to_uint",max],t1]
          else
            conv=[["to_uint",max],nil,t2]
          end
        end
      when [RecordType,RecordType]
        conv=[nil,nil]
      else
        raise "NIY homogenize #{pair}"
      end
      return conv
    end

    def visitBinary bin,args=nil
      puts "- binary #{bin.accept(@ppr)}"
      lhs_t=bin.lhs.accept(self)
      rhs_t=bin.rhs.accept(self)
      puts "\ttypes : #{lhs_t} #{bin.op} #{rhs_t}"
      conv_funcs=homogenize(lhs_t,rhs_t)
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

    def visitRIntLit lit,args=nil
      lit.type
    end

    def visitRUintLit lit,args=nil
      lit.type
    end

  end
end
