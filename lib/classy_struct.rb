class ClassyStruct
  def self.new
    Class.new(ClassyStructClass)
  end

  class ClassyStructClass
    def initialize(hash=hil)
      if hash
        hash.each_pair do |k,v|
          if v.is_a?(Hash)
            v = node_class(k).new(v)
          end

          send("#{k}=", v)
        end
      end
    end

    def node_class(name)
      @@__node_classes ||= {}
      @@__node_classes[name.to_sym] ||= ClassyStruct.new
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
