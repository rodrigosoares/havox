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
  end
end
