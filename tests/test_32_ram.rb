require_relative '../lib/ruby_rtl'

include RubyRTL

class Ram < Circuit
  def initialize ram_size,data_width
    type_addr = "uint#{Math.log2(ram_size).ceil}".to_sym
    type_data = "int#{data_width}".to_sym

    typedef :mem_t => Memory(ram_size,:byte)

    input  :sreset
    input  :we
    input  :address => type_addr
    input  :datain  => type_data
    output :dataout => type_data

    wire :mem => :mem_t
    wire :address_rd => type_addr

    sequential(:dff_based_ram){
      If(sreset==1){
        for i in 0..ram_size-1
          assign(mem[i] <= 0)
        end
      }
      Else{
        If(we==1){
          assign(mem[address] <= datain)
        }
        assign(address_rd <= address)
        assign(dataout    <= mem[address_rd])
      }
    }
  end
end

if $PROGRAM_NAME==__FILE__
  circuit=Ram.new(4,32)
  Compiler.new.compile(circuit)
end
