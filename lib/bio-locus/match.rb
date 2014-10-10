module BioLocus
  module Match
    def Match.run(options)
      do_delete = (options[:task] == :delete)
      invert_match = options[:invert_match]
      store = DbMapper.factory(options)
      lines = 0 
      count = 0
      in_header = true
      uniq_match = {}
      uniq_no_match = {}
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
          has_match = lambda { 
                               if invert_match
                                 not store[key]
                               else
                                 store[key]
                               end
                             }
          if has_match.call
            # We have a match
            $stderr.print "Matched <#{key}>\n" if options[:debug]
            count += 1
            if do_delete
              store.delete(key)
            else
              print line
              uniq_match[key] ||= true
            end
          else
            uniq_no_match[key] ||= true
          end
        end
      end
      store.close
      if do_delete
        $stderr.print "\nDeleted #{count} keys in #{options[:db]} reading #{lines} lines !\n" if not options[:quiet]
      else
        $stderr.print "\nMatched #{count} (unique #{uniq_match.keys.size}) lines out of #{lines} (unique #{uniq_no_match.keys.size+uniq_match.keys.size}) in #{options[:db]}!\n" if not options[:quiet]
      end
    end
  end
end
