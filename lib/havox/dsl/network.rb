module Havox
  module Network
    @snippets = []
    @grouped_routes = []
    @topology = nil

    def self.snippets; @snippets end
    def self.grouped_routes; @grouped_routes end
    def self.topology; @topology end


    def self.define(&block)
      clear_instance_vars
      snippet_proxy = Havox::DSL::SnippetProxy.new
      snippet_proxy.instance_eval(&block)
      read_routes
    end

    def self.read_routes(opts = {})
      routes = Havox::RIB.new(opts).routes
      # @grouped_routes = routes.select(&:bgp?).group_by(&:network)
      @grouped_routes = routes.select(&:ospf?).group_by(&:network)
    end

    def self.transpile(opts = {})
      # code_array = @snippets.map(&:to_predicate)
    end

    def self.clear_instance_vars
      @snippets = []
      @grouped_routes = []
    end
  end
end
