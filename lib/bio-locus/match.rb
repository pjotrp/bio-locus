module BioLocus

  require 'moneta'

  module Match
    def Match.run(options)
      do_delete = (options[:task] == :delete)
      store = Moneta.new(:LocalMemCache, file: options[:db])
      lines = 0 
      count = 0
      in_header = true
      uniq = {}
      STDIN.each_line do | line |
        if in_header and line =~ /^#/
          # Retain comments in header (for VCF)
          print line
          next
        else
          in_header = false
        end
        lines += 1
        $stderr.print '.' if (lines % 1_000_000) == 0 if not options[:quiet]
        Keys::each_key(line,options) do | key |
          if store[key]
            $stderr.print "Matched <#{key}>\n" if options[:debug]
            count += 1
            if do_delete
              store.delete(key)
            else
              print line
              uniq[key] ||= true
            end
          end
        end
      end
      store.close
      if do_delete
        $stderr.print "\nDeleted #{count} keys in #{options[:db]} reading #{lines} lines !\n" if not options[:quiet]
      else
        $stderr.print "\nMatched #{count} (unique #{uniq.keys.size}) lines out of #{lines} in #{options[:db]}!\n" if not options[:quiet]
      end
    end
  end
end
