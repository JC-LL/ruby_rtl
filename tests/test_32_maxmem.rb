require_relative '../lib/ruby_rtl'

include RubyRTL

class Maxmem < Circuit

  def initialize max_size
    p type_addr = "uint#{Math.log2(max_size)}".to_sym

    typedef :mem => Memory(max_size,:byte)

    input   :sreset
    input   :data_valid
    input   :data    => :uint32
    input   :max     => type_addr

    wire :bk
    wire :toggle
    wire :current_wr_addr => type_addr

    sequential(:write_bk_x){
      If(sreset==1){
        assign(toggle    <= 0)
        assign(bk        <= 0)
        assign(bk_x_en   <= 0)
        assign(addr_bk_x <= 0)
      }
      Else{
        assign(toggle    <= 0)
        If(data_valid==1){
          assign(bk_x_en <= 1)
          assign(data_bk_x <= data)
          If(addr_bk_x < max_size-1)
            assign(addr_bk_x <= addr_bk_x + 1)
          Else{
            assign(bk <= !bk)
            assign(toggle <= 1)
            assign(addr_bk_x <= 0)
          }
        }
        Else{
          assign(bk_x_en <= 0)
        }
      }
    }

    sequential(:read_bk_y){
      If(sreset==1){
        assign(bk_y_en   <= 0)
        assign(addr_bk_y <= 0)
        assign(searching <= 0)
      }
      Elsif(toggle==1){
        assign(searching <= 1)
        assign(addr_bk_y <= 0)
      }
      Elsif(searching==1){
        assign(addr_bk_y <= addr_bk_y + 1)
      }
    }

  end
end

circuit=Maxmem.new(4)
compiler=Compiler.new
compiler.compile(circuit)
