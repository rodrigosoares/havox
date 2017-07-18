module Havox
  module Network
    @snippets = []

    def self.snippets
      @snippets
    end

    def self.define(&block)
      definition_proxy = Havox::SnippetProxy.new
      definition_proxy.instance_eval(&block)
    end
  end
end
