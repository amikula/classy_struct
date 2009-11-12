class ClassyStruct
  def self.new
    Class.new(ClassyStructClass)
  end

  class ClassyStructClass
    def initialize(hash=hil)
      if hash
        hash.each_pair do |k,v|
          if v.is_a?(Hash)
            v = self.class.node_class(k).new(v)
          elsif v.is_a?(Array)
            v = ClassyStructClass.map_array(k, v)
          end

          send("#{k}=", v)
        end
      end
    end

    def self.node_class(name)
      @__node_classes ||= {}
      @__node_classes[name.to_sym] ||= ClassyStruct.new
    end

    def self.map_array(key, ary)
      klass = node_class(key)

      ary.map do |e|
        case e
        when Hash
          klass.new(e)
        else
          e
        end
      end
    end

    def new_child(key)
      self.send("#{key}=", self.class.node_class(key).new)
    end

    def method_missing(name, *args)
      base = (name.to_s =~ /=$/) ? name.to_s[0..-2] : name

      self.class.class_eval <<-EOF
        def #{base}
          @#{base}
        end

        def #{base}=(val)
          @#{base} = val
        end
      EOF

      send(name, *args)
    end
  end
end
