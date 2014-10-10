module BioLocus

  class SerializeMapper 
    def initialize dbname
      @dbname = dbname
      @h = {}
      if File.exist?(@dbname)
        @h = Marshal.load(File.read(@dbname))
      end
    end

    def [] key
      @h[key]
    end

    def []= key, value
      @h[key] = value
    end

    def close
      File.open(@dbname, 'w') {|f| f.write(Marshal.dump(@h)) }
    end
  end

  class MonetaMapper 
    def initialize storage, dbname
      begin
        require 'moneta'
      rescue LoadError
        $stderr.print "Error: Missing moneta. Install with command 'gem install moneta'\n"
        exit 1
      end
      @store = Moneta.new(storage, file: dbname)
    end

    def [] key
      @store[key]
    end

    def []= key, value
      @store[key] = value
    end

    def close
      @store.close
    end
  end

  class TokyoCabinetMapper 
    def initialize dbname
      begin
        require 'tokyocabinet'
      rescue LoadError
        $stderr.print "Error: Missing tokyocabinet. Install with command 'gem install tokyocabinet'\n"
        exit 1
      end
      @hdb = TokyoCabinet::HDB::new
      # open the database
      if !@hdb.open(dbname, TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT)
        ecode = @hdb.ecode
        raise sprintf("open error: %s\n", @hdb.errmsg(ecode))
      end
    end

    def [] key
      value = @hdb.get(key)
      if not value
        ecode = @hdb.ecode
        raise sprintf("get error: %s\n", @hdb.errmsg(ecode))
      end
      value
    end

    def []= key, value
      if !@hdb.put(key,value) 
        ecode = @hdb.ecode
        raise sprintf("put error: %s\n", @hdb.errmsg(ecode))
      end
    end

    def close
      if !@hdb.close
        ecode = @hdb.ecode
        raise sprintf("close error: %s\n", @hdb.errmsg(ecode))
      end
    end
  end

  module DbMapper 
    def DbMapper::factory options
      case options[:storage]
        when :tokyocabinet
          TokyoCabinetMapper.new(options[:db])
        else
          SerializeMapper.new(options[:db])
      end
    end
  end
end
