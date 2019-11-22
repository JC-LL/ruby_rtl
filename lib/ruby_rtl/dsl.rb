require_relative 'ast'
require_relative 'ast_builder'

module RubyRTL

  class Sig < Ast
    attr_accessor :name
    attr_accessor :type
    attr_accessor :subscript_of
    attr_accessor :subsignals

    def initialize name,type=:bit
      @name=name
      @type=build_type(type)
    end

    def build_type arg
      case arg
      when Symbol
        case sym=arg.to_s
        when "bit"
          return BitType.new
        when "byte"
          return IntType.new(8)
        when /\Abv(\d+)/
          return BitVectorType.new($1.to_i)
        when /\Auint(\d+)/
          return UintType.new($1.to_i)
        when /\Aint(\d+)/
          return IntType.new($1.to_i)
        else
          if type=$typedefs[arg] # global var !
            return type.definition
          end
          raise "DSL syntax error : unknow type '#{sym}'"
        end
      when Integer
        val=arg
        return BitType.new if val==1
        return BitVectorType.new(val)
      when Record
        return arg
      else
        raise "ERROR : DSL syntax error. build_type for #{arg} (#{arg.class})"
      end
      :undef
    end

    def |(other)
      other=IntLit.new(other) if other.is_a? Integer
      Binary.new(self,"|",other)
    end

    def &(other)
      Binary.new(self,"&",other)
    end

    def ^(other)
      Binary.new(self,"^",other)
    end

    # comparison
    def <(other)
      Binary.new(self,"<",other)
    end

    def <=(other)
      other=IntLit.new(other) if other.is_a? Integer
      Binary.new(self,"<=",other)
    end

    def >(other)
      Binary.new(self,"<",other)
    end

    def >=(other)
      Binary.new(self,"<=",other)
    end

    def ==(other)
      Binary.new(self,"==",other)
    end
    # arith
    def +(other)
      other=IntLit.new(other) if other.is_a? Integer
      Binary.new(self,"+",other)
    end

    def -(other)
      Binary.new(self,"-",other)
    end

    def *(other)
      Binary.new(self,"*",other)
    end

    def /(other)
      Binary.new(self,"/",other)
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
          name="#{self.name}(#{i})"
          @subsignals << sig=Sig.new(name,1)
          #sig.subscript_of=self
        end
      when Record
        field_name=index
        type.hash.each do |field,field_type|
          name="#{self.name}.#{index}"
          @subsignals << sig=Sig.new(name,field_type)
          #sig.subscript_of=self
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

  def Record hash
    Record.new(hash)
  end

  def Bit val
    BitLit.new(val)
  end

end
