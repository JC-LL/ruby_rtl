module RubyRTL

  class ASTPrinter

    attr_accessor :code,:nodes_decl,:nodes_cnx

    def run ast,suffix=nil
      puts "[+] printing ast in dot file"
      @verbose=false
      @nodes_decl=Code.new
      @nodes_cnx=Code.new
      @printed_cnx={} #Cosmetic ! to keep track of already printed cnx source->sink
      @code=Code.new
      code << "digraph G {"
      code.indent=2
      code << "ordering=out;"
      code << "ranksep=.4;"
      code << "bgcolor=\"lightgrey\";"
      code.newline
      code << "node [shape=box, fixedsize=false, fontsize=12, fontname=\"Helvetica-bold\", fontcolor=\"blue\""
      code << "       width=.25, height=.25, color=\"black\", fillcolor=\"white\", style=\"filled, solid, bold\"];"
      code << "edge [arrowsize=.5, color=\"black\", style=\"bold\"]"
      @visited=[]
      process(ast)
      code << @nodes_decl
      code << @nodes_cnx
      code.indent=0
      code << "}"
      clean(code)
      dot_filename="#{ast.name}_ast#{suffix}.dot"
      File.open(dot_filename,'w'){|f| f.puts code.finalize}
    end

    def process node,level=1
      kname=node.class.name.split("::")[1] || "#{node.class}"
      id=node.object_id
      indent=" "*level

      #puts indent+"processing #{node}"
      (nodes_decl << "#{id} [label=\"#{kname}\"]")
      unless @visited.include?(id)
        node.instance_variables.each{|vname|
          #puts indent+"-"+vname.to_s
          ivar=node.instance_variable_get(vname)
          vname=vname.to_s[1..-1]
          if ivar
            case ivar
            when Array
              ivar.each_with_index{|e,idx|
                sink=process(e,level+1)
                @printed_cnx[id]||=[]
                nodes_cnx << "#{id} -> #{sink} [label=\"#{vname}[#{idx}]\"]" if not @printed_cnx[id].include? sink
                @printed_cnx[id] << sink
              }
            when Symbol,Integer,String
              val=ivar.to_s
              sink="#{ivar.object_id}"
              nodes_decl << "#{sink} [label=\"#{val}\",color=\"red\"]"
              @printed_cnx[id]||=[]
              nodes_cnx << "#{id} -> #{sink} [label=\"#{vname}\"]" if not @printed_cnx[id].include? sink
              @printed_cnx[id] << sink
            else
              sink=process(ivar,level+1)
              @printed_cnx[id]||=[]
              nodes_cnx << "#{id} -> #{sink} [label=\"#{vname}\"]" if not @printed_cnx[id].include? sink
              @printed_cnx[id] << sink
            end
          end
        }
      end
      @visited << id
      return id
    end

    # suppress syndrom : name=""not correct""
    def clean code
      #puts "=> cleaning dot code"
      code.lines.each_with_index do |line,idx|
        if line=~/\"\"(.*)\"\"/
          code.lines[idx].gsub!(/\"\"(.*)\"\"/,"\"#{$1}\"")
        end
      end
    end
  end
end
