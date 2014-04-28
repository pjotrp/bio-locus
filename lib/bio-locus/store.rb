module BioLocus
  module Store
    def Store.run(options)
      h = {}
      STDIN.each_line do | line |
        if line =~ /^[[:alnum:]]+/
          id = line.split(/\t/,3)[0..1].join("\t")
          h[id] = true
        end
      end
      p h
    end
  end
end
