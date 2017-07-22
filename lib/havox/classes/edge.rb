module Havox
  class Edge
    attr_reader :from, :to, :attributes

    def initialize(from, to, attributes)
      @from = from
      @to = to
      @attributes = attributes
    end
  end
end
