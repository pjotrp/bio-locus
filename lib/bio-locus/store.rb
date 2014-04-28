module BioLocus

  require 'moneta'

  module Store
    def Store.run(options)
      store = Moneta.new(:LocalMemCache, file: options[:db])
     
      count = 0 
      STDIN.each_line do | line |
        if line =~ /^[[:alnum:]]+/
          chr,pos,rest = line.split(/\t/,3)[0..1]
          store[chr+"\t"+pos] = true
          count += 1
        end
      end
      store.close
      $stderr.print "Stored #{count} positions\n" if !options[:quiet]
    end
  end
end
