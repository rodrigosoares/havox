module Havox
  module Network
    @snippets = []

    def self.snippets
      @snippets
    end

    def self.define(&block)
      snippet_proxy = Havox::DSL::SnippetProxy.new
      snippet_proxy.instance_eval(&block)
    end

    def transpile
      # code_array = @snippets.map(&:to_predicate)
    end
  end
end
