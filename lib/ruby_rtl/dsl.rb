require_relative 'ast'
require_relative 'ast_builder'

module RubyRTL

  class Sig < Ast
    attr_accessor :type
    attr_accessor :subscript_of

    def initialize arg=:bit
      @type=build_type(arg)
    end

    def build_type arg
      case arg
      when Symbol
        case sym=arg.to_s
        when "bit"
          return Bit.new
        when "byte"
          return Uint.new(8)
        when /\Abv(\d+)/
          return BitVector.new($1.to_i)
        when /\Auint(\d+)/
          return Uint.new($1.to_i)
        when /\Aint(\d+)/
          return Int.new($1.to_i)
        else
          if type=$typedefs[arg] # global var !
            return type.definition
          end
          raise "DSL syntax error : unknow type '#{sym}'"
        end
      when Integer
        val=arg
        return Bit.new if val==1
        return BitVector.new(val)
      when Record
        return arg
      end
      :undef
    end

    def |(other)
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
      p type
      case type
      when Integer
        value=type
        (0..value-1).each do |i|
          @subsignals << sig=Sig.new(1)
          sig.subscript_of=self
        end
      when BitVector
        bitv=type
        value=bitv.size
        (0..value-1).each do |i|
          @subsignals << sig=Sig.new(1)
          sig.subscript_of=self
        end
      when Record
      else
        raise "DSL syntax error : no index [#{index}] for signal '#{self}'"
      end
      return @subsignals[index]
    end

  end

  def Record hash
    Record.new(hash)
  end



end
