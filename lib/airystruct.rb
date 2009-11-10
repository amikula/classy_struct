class Airystruct
  def self.new
    Class.new(AirystructClass)
  end

  class AirystructClass
    def initialize(hash=hil)
      hash.each{|k,v| send("#{k}=", v)} if hash
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
