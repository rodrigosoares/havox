module Havox
  class Node
    attr_reader :name, :type, :attributes

    def initialize(name, attributes)
      @name = name
      @type = attributes[:type]&.to_sym 
      @attributes = attributes
    end
  end
end
