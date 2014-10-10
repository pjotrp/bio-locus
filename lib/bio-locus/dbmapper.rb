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

end
