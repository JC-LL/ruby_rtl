require_relative '../lib/ruby_rtl'

include RubyRTL

class Counter < Circuit
  def initialize
    input :tick
    output :count => :byte

    sequential(:counting){
      If(tick==1){
        If(count==255){
          assign(count <= 0)
        }
        Else{
          assign(count <= count + 1)
        }
      }
    }

  end
end

pp circuit=Counter.new
