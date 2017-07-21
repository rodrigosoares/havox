module Havox
  module DSL
    class Snippet
      attr_reader :attributes

      def initialize(action)
        @action = action
        @attributes = {}
      end

      def method_missing(name, *args, &block)
        @attributes[name] = args.first
      end
    end
  end
end