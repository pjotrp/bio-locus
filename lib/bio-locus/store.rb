module BioLocus

  require 'moneta'

  module Store
    def Store.run(options)
      store = Moneta.new(:LocalMemCache, file: options[:db])
      count = count_new = 0 
      STDIN.each_line do | line |
        if line =~ /^[[:alnum:]]+/
          chr,pos,rest = line.split(/\t/,3)[0..1]
          if pos =~ /^\d+$/
            key = chr+"\t"+pos
            if not store[key]
              count_new += 1 
              store[key] = true
            end
            count += 1
          end
        end
      end
      store.close
      $stderr.print "Stored #{count_new} positions out of #{count} in #{options[:db]}\n" if !options[:quiet]
    end
  end
end
