require_relative 'ast_printer'
require_relative 'contextual_analyzer'
require_relative 'type_checker'
require_relative 'vhdl_generator'

module RubyRTL

  class Compiler

    def initialize
      header
      @printer=ASTPrinter.new
      @analyzer=ContextualAnalyzer.new
      @checker=TypeChecker.new
      @vgen=VhdlGenerator.new
    end

    def header
      puts "RubyRTL compiler "
    end

    def compile circuit
      print_ast(circuit)
      analyze(circuit)
      type_check(circuit)
      generate(circuit)
    end

    def print_ast circuit,file_suffix=""
      @printer.run(circuit,file_suffix)
    end

    def analyze circuit
      @analyzer.analyze(circuit)
    end

    def type_check circuit
      @checker.check circuit
    end

    def generate circuit
      @vgen.generate(circuit)
    end
  end
end
