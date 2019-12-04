require_relative 'ast'
require_relative 'ast_builder'

module RubyRTL

  def build_type arg
    case arg
    when Symbol
      case sym=arg.to_s
      when "bit"
        sym="bit"
        ret=BitType.new
      when "byte"
        ret=IntType.new(8)
      when /\Abv(\d+)/
        ret=BitVectorType.new($1.to_i)
      when /\Auint(\d+)/
        ret=UintType.new($1.to_i)
      when /\Aint(\d+)?/
        nbits=($1 || 32).to_i
        ret=IntType.new(nbits)
      else
        unless ret=$typedefs[arg] # global var !
          raise "DSL syntax error : unknow type '#{sym}'"
        end
      end
      $typedefs||={}
      $typedefs[sym]||=ret
    when Integer
      val=arg
      if val==1
        name="bit"
        ret=BitType.new if val==1
      else
        name="bv#{val}"
        ret=BitVectorType.new(val)
      end
      $typedefs||={}
      $typedefs[name]||=ret
    when Hash
      ret=arg
    else
      raise "ERROR : DSL syntax error. build_type for #{arg} (#{arg.class})"
    end
    ret
  end

  class Sig < Ast
    attr_accessor :name
    attr_accessor :type
    attr_accessor :subscript_of
    attr_accessor :subsignals

    def initialize name,type=:bit
      @name=name
      @type=build_type(type)
    end

    def treat_int(other)
      case other
      when Integer
        if other >=0
          return RUintLit.new(other)
        else
          return RIntLit.new(other)
        end
      else
        return other
      end
    end

    def |(other)
      other=treat_int(other)
      Binary.new(self,"|",other)
    end

    def &(other)
      other=treat_int(other)
      Binary.new(self,"&",other)
    end

    def ^(other)
      other=treat_int(other)
      Binary.new(self,"^",other)
    end

    # comparison
    def <(other)
      other=treat_int(other)
      Binary.new(self,"<",other)
    end

    def <=(other)
      other=treat_int(other)
      Binary.new(self,"<=",other)
    end

    def >(other)
      other=treat_int(other)
      Binary.new(self,"<",other)
    end

    def >=(other)
      other=treat_int(other)
      Binary.new(self,"<=",other)
    end

    def ==(other)
      other=treat_int(other)
      Binary.new(self,"==",other)
    end
    # arith
    def +(other)
      other=treat_int(other)
      Binary.new(self,"+",other)
    end

    def -(other)
      other=treat_int(other)
      Binary.new(self,"-",other)
    end

    def *(other)
      other=treat_int(other)
      Binary.new(self,"*",other)
    end

    def /(other)
      other=treat_int(other)
      Binary.new(self,"/",other)
    end

    def !=(other)
      other=treat_int(other)
      Binary.new(self,"!=",other)
    end

    # unary expressions
    def !@
      Unary.new("!",self)
    end

    def -@
      Unary.new("-",self)
    end

    def [](index)
      @subsignals||=[]
      case type
      when Integer
        value=type
        (0..value-1).each do |i|
          name="#{self.name}(#{i})"
          @subsignals << sig=Sig.new(name,1)
          #sig.subscript_of=self
        end
      when BitVectorType,UintType,IntType
        bitv=type
        value=bitv.size
        (0..value-1).each do |i|
          name="#{self.name}[#{i}]"
          @subsignals << sig=Sig.new(name,1)
          #sig.subscript_of=self
        end
      when RecordType
        field_name=index
        type.hash.each do |field,field_type|
          name="#{self.name}.#{index}"
          @subsignals << sig=Sig.new(name,field_type)
        end
        idx=type.hash.keys.index(index)
        return @subsignals[idx]
      else
        raise "DSL syntax error : no index [#{index}] for signal '#{self}' : type is #{type}"
      end
      return @subsignals[index]
    end

    def coerce(other)
      [IntLit.new(other), self]
    end
  end

  def Memory hash
    size,type=hash.first
    Memory.new(size,type)
  end

  def Record hash
    h={}
    hash.each do |name,type|
      type||=$typedefs[type]
      type=build_type(type)
      h[name]=type
    end
    RecordType.new(h)
  end

  def Struct hash
    RecordType.new(hash)
  end

  def Bit val
    BitLit.new(val)
  end

end
