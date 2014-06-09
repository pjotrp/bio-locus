
module BioLocus
  module Keys
    def Keys::each_key(line,options)
      if line =~ /^[[:alnum:]]+/
        fields = nil
        # The default layout (VCF) may or may not work
        chr,pos,id,no_use,alt,rest = line.split(/\t/,6)[0..-1]
        case options[:in_format]
          when :snv then
            fields ||= line.split(/\t/)
            field = fields
            alt = field[2].split(/\//)[1]
        end
        # Override parsing with
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
        if options[:eval_alt] 
          fields ||= line.split(/\t/)
          field = fields
          alt = eval(options[:eval_alt])
        end
        p [:debug,chr,pos,alt] if options[:debug]

        # If we have a position emit it
        if pos =~ /^\d+$/ and chr and chr != ''
          alts = ['']  # position only
          alts += alt.split(/,/) if options[:include_alt]
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
