module Legit
  class Model
    class << self
      def attribute(attr, type)
        parsers[attr.to_sym] = Legit::Value.const_get(type.to_s.camelize).new
      end

      def parsers
        @_parsers ||= {}
      end

      def attribute_names
        parsers.keys
      end
    end

    def initialize(attrs={})
      @attributes = {}.tap do |h|
        self.class.parsers.each do |name, parser|
          value = attrs.delete(name)
          begin
            h[name] = parser.coerce(value)
          rescue Legit::CoerceError => e
            fail ArgumentError, ":#{name} => #{e.message}"
          end
        end
      end.freeze
      fail ArgumentError, "Unknown attributes: #{attrs}" unless attrs.empty?
    end

    attr_reader :attributes

    def method_missing(name, *args, &block)
      attributes.fetch(name.to_sym) { super }
    end

    # Equality

    def ==(o)
      o.class == self.class && o.attributes == attributes
    end
    alias_method :eql?, :==

    def hash
      attributes.hash
    end
  end
end