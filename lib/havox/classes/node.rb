module Havox
  class Node
    attr_reader :name, :type, :attributes

    def initialize(name, attributes)
      @name = name
      @type = attributes[:type]&.to_sym
      @attributes = attributes
    end

    def host?
      @type.eql?(:host)
    end

    def switch?
      @type.eql?(:switch)
    end
  end
end
