module BioLocus

  class MonetaMapper 
    def initialize storage, dbname
      require 'moneta'
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
      require 'tokyocabinet'
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

end
