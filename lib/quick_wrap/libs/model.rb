module QuickWrap

  module Model

    def self.included(base)
      base.send :extend, ClassMethods
      #base.send :include, BW::KVO
      base.send :include, QuickWrap::Eventable
    end

    module ClassMethods
      def field(name, type=nil, opts={})
        name_s = name.to_s
        name_sb = name.to_sym
        properties << {name: name.to_sym, type: type, opts: opts}
        #attr_accessor name.to_sym
        define_method("#{name_s}=") do |opt|
          instance_variable_set("@#{name_s}", opt)
          if self.do_handle_events
            #trigger name_sb
            #trigger :_model_update if !self.is_handling_data
            #self.class.computed_properties[name_sb].each { |cp| trigger cp.to_sym }
          end
        end
        attr_reader name_sb

      end

      def fields(*names)
        names.each {|name| field(name)}
      end

      def properties
        @properties ||= []
      end

      def property_names
        self.properties.collect{|p| p[:name]}
      end

      def computed_properties
        @computed_properties ||= Hash.new {|hash, key| hash[key] = []}
      end

      def computed_field(name, deps, callback)
        deps.each do |dep|
          computed_properties[dep.to_sym] << name.to_sym
        end
        define_method("#{name.to_s}") do
          instance_exec(&callback)
        end
      end

    end

    attr_accessor :do_handle_events, :is_handling_data

    def initialize(data={})
      self.do_handle_events = false
      self.handle_data(data)
      self.do_handle_events = true
    end

    def handle_data(data)
      self.is_handling_data = true
      data.each do |key, val|
        prop = self.class.properties.find {|p| p[:name] == key.to_sym}
        unless prop.nil?
          if prop[:type]
            if prop[:opts][:array]
              self.send("#{key.to_s}=", val.collect{|el| prop[:type].new(el)})
            else
              self.send("#{key.to_s}=", prop[:type].new(val))
            end
          else
            self.send("#{key.to_s}=", val)
          end
        end
      end
      self.is_handling_data = false
      #trigger :_model_update
    end

    def [](field)
      self.send("#{field.to_sym}")
    end

    def to_api(fields=nil)
      fields ||= self.class.property_names
      ret = {}
      fields.each do |field|
        fv = self.send(field.to_sym)
        if fv.is_a?(Array)
          rv = fv.collect{|av| av.respond_to?(:to_api) ? av.to_api : av}
        else
          rv = fv.respond_to?(:to_api) ? fv.to_api : fv
        end
        ret[field.to_s] = rv
      end
      ret
    end

    def subscribe_to(prop, sub, &block)
      self.on(prop.to_sym, sub) do
        block.call(self.send prop)
      end
      block.call(self.send prop)
    end

    def bind_update_to(sub, method)
      self.on(:_model_update, sub) do
        sub.send method
      end
    end

    def unbind(sub)
      self.off(:all, sub)
    end

    def marked_deleted?
      @_deleted ||= false
    end

    def mark_deleted!
      @_deleted = true
    end

  end
end
