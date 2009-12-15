class ClassyStruct
  def self.new(&block)
    klass = Class.new(ClassyStructClass)
    klass.method_mapper = block
    klass
  end

  class ClassyStructClass
    def initialize(hash=nil)
      if hash
        hash.each_pair do |k,v|
          k = self.class.method_mapper.call(k.to_s) if self.class.method_mapper

          if v.is_a?(Hash)
            v = self.class.node_class(k).new(v)
          elsif v.is_a?(Array)
            v = self.class.map_array(k, v)
          end

          send("#{k}=", v)
        end
      end
    end

    class << self
      attr_accessor :method_mapper

      def node_class(name)
        @__node_classes ||= {}
        @__node_classes[name.to_sym] ||= ClassyStruct.new(&method_mapper)
      end

      def map_array(key, ary)
        ary.map do |e|
          case e
          when Hash
            node_class(key).new(e)
          else
            e
          end
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
