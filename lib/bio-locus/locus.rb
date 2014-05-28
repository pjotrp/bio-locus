
module BioLocus
  module Keys
    def Keys::each_key(line,options)
      if line =~ /^[[:alnum:]]+/
        fields = nil
        # The default layout (VCF) may or may not work
        chr,pos,id,no_use,alt,rest = line.split(/\t/,6)[0..-1]
        if options[:eval_chr]
          fields ||= line.split(/\t/)
          field = fields
          chr = eval(options[:eval_chr])
        end
        if options[:eval_pos] 
          fields ||= line.split(/\t/)
          field = fields
          pos = eval(options[:eval_pos])
        end
        p [chr,pos] if options[:debug]

        if pos =~ /^\d+$/ and chr and chr != ''
          alts = if options[:include_alt]
                   alt.split(/,/)
                 else
                   ['']
                 end
          alts.each do | nuc |
            key = chr+"\t"+pos
            key += "\t"+nuc if nuc != ''
            yield key
          end
        else
          if options[:ignore_errors]
            $stderr.print "WARNING, skipping: ",line if not options[:quiet]
          else
            p line
            p fields
            raise "Parse error chr <#{chr}> pos <#{pos}>\n"
          end
        end
      end
    end
  end

end
