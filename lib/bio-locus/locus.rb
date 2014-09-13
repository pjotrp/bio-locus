
module BioLocus
  module Keys
    @@in_list = {}

    def Keys::each_key(line,options)
      use_alt = (options[:alt] == :include or options[:alt] == :only)
      use_pos = (options[:alt] == :include or options[:alt] == :exclude)

      if line =~ /^[[:alnum:]]+/
        fields = nil
        # The default layout (VCF) may or may not work. Critically
        # chr,pos and alt are expected in positions 0,1,4 respectively.
        chr,pos,id,no_use,alt,rest = line.split(/\t/,6)[0..-1]
        if options[:in_format] or options[:eval_chr] or options[:eval_pos] or options[:eval_alt]
          fields = line.split(/\t/)
          field = fields
          case options[:in_format]
            when :tab then
              # chr,pos,ref,alt
              alt = field[3].strip.split(/,/)[0] if field[3]
            when :snv then
              alt = field[2].split(/\//)[1] if field[2]
            when :cosmic then
              # COSMIC tsv files, either in field 17 (COSMICv70)
              locus_field = field[17]
              locus_field = field[13] if locus_field !~ /:/
              if field[15] !~ /delet/i and locus_field =~ /:/
                chr = /^([^:]+)/.match(locus_field)[1]
                a = /:(\d+)-(\d+)/.match(locus_field)
                pos = a[1] if a[1]==a[2]
              end
          end
          # Override parsing with
          if options[:eval_chr]
            chr = eval(options[:eval_chr])
          end
          if options[:eval_pos] 
            pos = eval(options[:eval_pos])
          end
          if options[:eval_alt] 
            alt = eval(options[:eval_alt])
          end
        end
        # p [:debug,chr,pos,alt] if options[:debug]

        # If we have a position emit it
        if pos =~ /^\d+$/ and chr and chr != ''
          alts = if use_pos
                   ['']  
                 else
                   []
                 end
          alts += alt.split(/,/) if use_alt and alt
          alts.each do | nuc |
            key = chr+"\t"+pos
            key += "\t"+nuc if nuc != ''
            if options[:once]
              # check we haven't already sent this out in this run
              return if @@in_list[key]
              @@in_list[key] = true
            end
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
