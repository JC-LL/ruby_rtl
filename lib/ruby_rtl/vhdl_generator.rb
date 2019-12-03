require_relative 'code'

module RubyRTL

  class VhdlGenerator < Visitor

    attr_accessor :entity
    attr_accessor :ios
    attr_accessor :archi_elements

    def generate circuit
      puts "[+] VHDL code generation"

      code=Code.new
      @circuit=circuit
      @ios,@archi_elements=[],[]
      @sigs={}
      @fsm_defs=[]
      @sequentials=[]
      @states={}
      gen_ruby_rtl_type_package
      root=circuit.ast
      return unless root


      gen_type_package()
      root.ios.each{|io| io.accept(self)}
      non_typedecls=root.decls.reject{|decl| decl.is_a? TypeDecl}
      non_typedecls.each{|decl| decl.accept(self)}

      code << gen_ieee_header()
      code << gen_ruby_rtl_package_call()
      code << gen_package_call(circuit)
      code << gen_entity(circuit)
      code.newline
      code << gen_archi(circuit)
      code=clean_vhdl(code)
      puts code.finalize
      code.save_as "#{name=circuit.name.downcase}.vhd"
    end

    def clean_vhdl(code)
      txt=code.finalize
      txt.gsub! /;(\s*)\)/,")"
      txt.gsub! /,(\s*)\)/,")"
      (code=Code.new) << txt
      return code
    end

    def gen_ruby_rtl_package_call
      code=Code.new
      code << "library ruby_rtl;"
      code << "use ruby_rtl.ruby_rtl_package.all;"
      code.newline
      code
    end

    def gen_ruby_rtl_type_package
      code=Code.new
      code << gen_ieee_header
      code << "package ruby_rtl_type_package is "
      code.newline
      code.indent=2
      $typedefs.each do |name,definition|
        case definition
        when RecordType
          code << definition_s=definition.accept(self,name)
        else
          definition_s=definition.accept(self)
          case definition
          when IntType,UintType,BitType
            header="sub"
          else
            header=""
          end
          code << "#{header}type #{name} is #{definition_s};"
        end
        code.newline
      end
      code.indent=0
      code << "end package;"
      code.save_as "ruby_rtl_type_package.vhd"
    end

    def gen_type_package
      name=@circuit.name.downcase
      return unless ast=@circuit.ast
      typdecls=ast.decls.select{|decl| decl.is_a?(TypeDecl)}
      package=Code.new
      package << "-- code automatically generated by RubyRTL compiler"
      package << "package #{name}_package is"
      package.indent=2
      typdecls.each do |decl|
        definition=decl.definition.accept(self,decl.name)
        package << definition
      end
      package.indent=0
      package << "end package;"
      puts package.finalize
      package.save_as "#{name}_package.vhd"
    end

    def gen_ieee_header
      header=Code.new
      header << "-- automatically generated by RubyRTL"
      header << "library ieee;"
      header << "use ieee.std_logic_1164.all;"
      header << "use ieee.numeric_std.all;"
      header.newline
      header
    end

    def gen_package_call circuit
      name=circuit.name.downcase
      code=Code.new
      code << "library #{name}_lib;"
      code << "use #{name}_lib.#{name}_package.all;"
      code.newline
      code
    end

    def gen_entity circuit
      entity=Code.new
      entity << "entity #{circuit.name}_c is"
      entity.indent=2
      entity << "port ("
      entity.indent=4
      if circuit.has_sequential_statements
        entity << "clk    : in std_logic;"
        entity << "sreset : in std_logic;"
      end
      ios.each{|io| entity << io}
      entity.indent=2
      entity << ");"
      entity.indent=0
      entity << "end #{circuit.name}_c;"
    end

    def gen_archi circuit
      body=circuit.ast.body
      archi_elements=body.stmts.collect{|stmt| stmt.accept(self)}
      archi=Code.new
      archi << "architecture rtl of #{circuit.name}_c is"
      archi.indent=2
      @fsm_defs.each do |decl|
        archi << decl
      end
      @sigs.each do |sig,name|
        archi << "signal #{name} : #{sig.type.accept(self)};"
      end
      archi.indent=0
      archi << "begin"
      archi.indent=2
      archi.newline
      archi_elements.each do |element|
        archi << element
      end
      archi.indent=0
      archi.newline
      archi << "end rtl;"
      archi
    end

    def visitComment comment,args=nil
      "-- #{comment.str}"
    end

    def visitInput input,args=nil
      @sigs[input] || input.name
    end

    def visitOutput output,args=nil
      @sigs[output] || output.name
    end

    def visitSigDecl decl,args=nil
      name=decl.name
      name.sub!(/@/,'')
      type=decl.sig.type.accept(self)
      case decl.sig
      when Input
        ios << "#{name} : in  #{type};"
      when Output
        ios << "#{name} : out #{type};"
      when Sig
        @sigs.merge!(decl.sig => name)
      else
        raise "ERROR : visitSigDecl : neither input ou output"
      end
    end

    def visitSig sig,args=nil
      sig.name
    end

    def visitRecordType rectype,name
      if name
        code=Code.new
        code << "type #{name} is record"
        code.indent=2
        rectype.hash.each do |name,type|
          code << "#{name} : #{type};"
        end
        code.indent=0
        code << "end record;"
        code
      else
        idx=$typedefs.values.index(rectype)
        $typedefs.keys[idx]
      end
    end
    # ====== body stuff ========
    # === statements ===
    def visitAssign assign,args=nil
      lhs=assign.lhs.accept(self)
      rhs=assign.rhs.accept(self)
      "#{lhs} <= #{rhs};"
    end

    def visitCompDecl comp_decl,args=nil
      comp=comp_decl.comp
      instance_name=comp_decl.name
      sig_decls=comp.ast.decls.select{|node| node.is_a? SigDecl}
      inputs =sig_decls.select{|decl| decl.sig.is_a? Input}.map(&:sig)
      outputs=sig_decls.select{|decl| decl.sig.is_a? Output}.map(&:sig)

      instanciation=Code.new
      instanciation << "#{instance_name} : entity work.#{comp.name}_c"
      instanciation.indent=2
      instanciation << "port map("
      instanciation.indent=4
      inputs.each do |input|
        actual_sig_name="#{instance_name}_#{input.name}"
        @sigs.merge!({input => actual_sig_name})
        instanciation << "#{input.name} => #{actual_sig_name},"
      end
      outputs.each do |output|
        actual_sig_name="#{instance_name}_#{output.name}"
        @sigs.merge!(output => actual_sig_name)
        instanciation << "#{output.name} => #{actual_sig_name},"
      end
      instanciation.indent=2
      instanciation << ");"
      instanciation.indent=0
      instanciation.newline
      instanciation
    end

    def visitSequential sequential,args=nil
      code=Code.new
      label=sequential.label
      code << "#{label} : process(clk)"
      code << "begin"
      code.indent=2
      code << "if rising_edge(clk) then"
      code.indent=4
      code << sequential.body.accept(self)
      code.indent=2
      code << "end if;"
      code.indent=0
      code << "end;"
      code
    end

    # statement
    def visitBody body,args=nil
      code=Code.new
      body.stmts.each{|stmt| code << stmt.accept(self)}
      code
    end

    def visitIf if_,args=nil
      cond=if_.cond.accept(self)
      if_body=if_.body.accept(self)
      code=Code.new
      code << "if #{cond} then"
      code.indent=2
      code << if_body
      code.indent=0
      if_.elsifs.each{|elsif_|
        code << elsif_.accept(self)
      }
      code << if_.else.accept(self) if if_.else
      code << "end if;"
      code
    end

    def visitElsif elsif_,args=nil
      cond=elsif_.cond.accept(self)
      body=elsif_.body.accept(self)
      code=Code.new
      code << "elsif #{cond} then"
      code.indent=2
      code << body
      code.indent=0
      code
    end

    def visitElse else_,args=nil
      body=else_.body.accept(self)
      code=Code.new
      code << "else "
      code.indent=2
      code << body
      code.indent=0
      code
    end

    # === FSM ===
    def visitFsm fsm,args=nil
      state_names=fsm.states.map{|state| state.name}.join(",")
      @fsm_defs << "type #{fsm.name}_state_t is (#{state_names});"
      @fsm_defs << "signal #{fsm.name}_state_r,#{fsm.name}_state_c : #{fsm.name}_state_t;"
      body=Code.new
      body << "#{fsm.name}_update : process(clk)"
      body << "begin"
      body.indent=2
      body << "if rising_edge(clk) then"
      body.indent=4
      body << "#{fsm.name}_state_r <= #{fsm.name}_state_c;"
      body.indent=2
      body << "end if;"
      body.indent=0
      body << "end process;"
      body.newline

      body << "#{fsm.name}_next_state_p : process(all)" # VHDL 2008
      body.indent=2
      #body << "variable state_v : #{fsm.name}_state_t;"
      body.indent=0
      body << "begin"
      body.indent=2
      body << "--default assignements"
      #body << "state_v := #{fsm.name}_state_r;"
      body << "state_c <= #{fsm.name}_state_r;"
      fsm.default_assigns.each do |assign|
        body << assign.accept(self)
      end
      body << state_cases(fsm)
      # body << "--signals update"
      # body << "#{fsm.name}_state_c <= state_v;"
      body.indent=0
      body << "end process;"
      body
    end

    def state_cases fsm
      code=Code.new
      code << "case state_v is"
      code.indent=2
      fsm.states.each do |state|
        code << "when #{state.name} =>"
        code.indent=4
        code << state_body(state)
        code.indent=2
      end
      code << "when others =>"
      code << "  null;"
      code.indent=0
      code << "end case;"
      code
    end

    def state_body state
      code=Code.new
      state.body.each{|stmt| code << stmt.accept(self)}
      code
    end

    def visitState state,args=nil
      code << "when #{state.name}"
      code
    end

    def visitNext next_state,args=nil
      "#{next_state.of_state} <= #{next_state.name};"
    end

    # === expressions ===
    VHDL_OP={
      "&" => "and",
      "|" => "or",
      "^" => "xor",
      "=="=> "=",
      "%" => "mod"
    }
    def visitBinary bin,args=nil
      lhs=bin.lhs.accept(self)
      op=VHDL_OP[bin.op] || bin.op
      rhs=bin.rhs.accept(self)
      "(#{lhs} #{op} #{rhs})"
    end

    def visitFuncCall func,args=nil
      name=func.name
      argus=func.args.map{|arg| arg.accept(self)}.join(',')
      "#{name}(#{argus})"
    end
    # === types
    def visitBitType bit,args=nil
      "std_logic"
    end

    def visitBitVectorType bv,args=nil
      range="#{bv.size-1} downto 0"
      "std_logic_vector(#{range})"
    end

    def visitUintType uint,args=nil
      range="#{uint.bitwidth-1} downto 0"
      "unsigned(#{range})"
    end

    def visitIntType int,args=nil
      range="#{int.bitwidth-1} downto 0"
      "signed(#{range})"
    end

    # literals
    def visitIntLit int,args=nil
      int.val
    end

    def visitBitLit bit_lit,args=nil
      "'#{bit_lit.val}'"
    end

    def visitBitVectorLit bit_lit,args=nil
      "\"#{bit_lit.val}\""
    end

  end
end
