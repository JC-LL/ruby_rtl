require_relative "./lib/ruby_rtl/version"

Gem::Specification.new do |s|
  s.name        = 'ruby_rtl'
  s.version     = RubyRTL::VERSION
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.summary     = "Ruby Internal DSL for Hardware Design"
  s.description = "ruby_rtl is a simple DSL for HW(RTL) design"
  s.authors     = ["Jean-Christophe Le Lann"]
  s.email       = 'lelannje@ensta-bretagne.fr'
  s.files       = [
                    "lib/ruby_rtl/version.rb",
                    "lib/ruby_rtl/ast_builder.rb",
                    "lib/ruby_rtl/ast_printer.rb",
                    "lib/ruby_rtl/ast.rb",
                    "lib/ruby_rtl/code.rb",
                    "lib/ruby_rtl/compiler.rb",
                    "lib/ruby_rtl/contextual_analyzer.rb",
                    "lib/ruby_rtl/dsl_printer.rb",
                    "lib/ruby_rtl/dsl.rb",
                    "lib/ruby_rtl/ruby_rtl_package.vhd",
                    "lib/ruby_rtl/sexp_generator.rb",
                    "lib/ruby_rtl/type_checker.rb",
                    "lib/ruby_rtl/vhdl_generator.rb",
                    "lib/ruby_rtl/visitor.rb",
                    "lib/ruby_rtl.rb",

                    "examples/adder.rb",
                    "examples/and.rb",
                    "examples/counter.rb",
                    "examples/fsm.rb",
                    "examples/full_adder.rb",
                    "examples/gcd.rb",
                    "examples/half_adder.rb",

                ]

  s.homepage    = 'https://github.com/JC-LL/ruby_rtl'
  s.license     = 'MIT'
  s.post_install_message = "Thanks for installing ! Homepage :https://github.com/JC-LL/ruby_rtl"
  s.required_ruby_version = '>= 2.0.0'

  s.add_runtime_dependency 'distribution', '0.7.3'
  s.add_runtime_dependency 'colorize', '0.8.1'

end
