module QuickWrap

  class Cache

    def self.[](val)
      self.all[val]
    end

    def self.all
      @caches ||= Hash.new(QuickWrap::Cache.new)
    end

    def self.clear(type)
      self.all.values.each do |cache|
        cache.clear(type)
      end
    end

    def store
      @inst ||= Hash.new([])
    end

    def add(data, type, id=nil)
      inst = self.store

      id ||= data['id']

      obj = self.find(type, id)
      if obj
        obj[:model] = data
      else
        inst[type] << {id: id, type: type, model: data}
      end
    end

    def rebase(data, type)
      self.store[type].clear
      data.each do |obj|
        self.add(obj, type)
      end
    end

    def find(type, id)
      inst = self.store
      ret = inst[type].select {|obj|
        obj[:id] == id
      }.first
      if ret
        return ret[:model]
      else
        return nil
      end
    end

    def clear(type, id=nil)
      self.store[type].clear
    end

    def select(type, &block)
      self.store[type].collect{|obj| obj[:model]}.select(&block)
    end

  end

end
