
module BioLocus
  module Keys
    def Keys::each_key(line,include_alt)
      if line =~ /^[[:alnum:]]+/
        chr,pos,id,ref,alt,rest = line.split(/\t/,6)[0..-1]
        if pos =~ /^\d+$/
          alts = if include_alt
                   alt.split(/,/)
                 else
                   ['']
                 end
          alts.each do | nuc |
            key = chr+"\t"+pos
            key += "\t"+nuc if nuc != ''
            yield key
          end
        end
      end
    end
  end

end
