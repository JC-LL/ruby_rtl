require_relative 'ast_printer'
require_relative 'contextual_analyzer'
require_relative 'vhdl_generator'

module RubyRTL

  class Compiler

    def initialize
      header
      @printer=ASTPrinter.new
      @checker=ContextualAnalyzer.new
      @vgen=VhdlGenerator.new
    end

    def header
      puts "RubyRTL compiler "
    end

    def compile circuit
      check(circuit)
      print_ast(circuit,"_checked")
      generate(circuit)
    end

    def print_ast circuit,file_suffix=""
      @printer.print(circuit,file_suffix)
    end

    def check circuit
      @checker.check(circuit)
    end

    def generate circuit
      @vgen.generate(circuit)
    end
  end
end