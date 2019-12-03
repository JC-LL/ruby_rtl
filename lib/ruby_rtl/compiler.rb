require_relative 'ast_printer'
require_relative 'dsl_printer'
require_relative 'contextual_analyzer'
require_relative 'type_checker'
require_relative 'vhdl_generator'

module RubyRTL

  class Compiler

    def initialize
      header
      @printer=DSLPrinter.new
      @dot_printer=ASTPrinter.new
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
      print_dsl(circuit)
      type_check(circuit)
      print_dsl(circuit)
      generate(circuit)
    end

    def print_dsl circuit
      @printer.print circuit
    end

    def print_ast circuit,file_suffix=""
      @dot_printer.run(circuit,file_suffix)
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
