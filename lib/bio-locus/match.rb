module BioLocus

  require 'moneta'

  module Match
    def Match.run(options)
      store = Moneta.new(:LocalMemCache, file: options[:db])
      lines = 0 
      count = 0
      in_header = true
      STDIN.each_line do | line |
        if in_header and line =~ /^#/
          # Retain comments in header (for VCF)
          print line
          next
        else
          in_header = false
        end
        $stderr.print '.' if (lines % 1_000_000) == 0 if not options[:quiet]
        chr,pos,rest = line.split(/\t/,3)[0..1]
        if chr and pos and pos =~ /^\d+$/
          lines += 1
          if store[chr+"\t"+pos]
            count += 1
            print line
          end
        end
      end
      store.close
      $stderr.print "\nMatched #{count} out of #{lines} lines in #{options[:db]}!\n" if not options[:quiet]
    end
  end
end
