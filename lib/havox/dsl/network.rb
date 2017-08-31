module Havox
  module Network
    @rib      = []
    @snippets = []
    @devices  = {}
    @topology = nil

    def self.snippets; @snippets end
    def self.rib; @rib end
    def self.devices; @devices end
    def self.topology; @topology end
    def self.topology=(topo); @topology = topo end

    def self.define(&block)
      clear_instance_vars
      snippet_proxy = Havox::DSL::SnippetProxy.new
      snippet_proxy.instance_eval(&block)
      @rib = Havox::RIB.new
      evaluate_topology
    end

    def self.transpile(opts = {})
      # predicate_array = @snippets.map(&:to_predicate)
    end

    class << self
      private

      def evaluate_topology
        direct_ospf_routes = @rib.routes.select { |r| r.ospf? && r.direct? }
        grouped_routes = direct_ospf_routes.group_by(&:network)
        @topology.switch_ips.each do |switch_name, switch_ip|
          infer_device_names(grouped_routes, switch_name, switch_ip)
        end
      end

      def infer_device_names(grouped_routes, switch_name, switch_ip)
        grouped_routes.each do |network_str, routes|
          network = IPAddr.new(network_str)
          if network.include?(switch_ip)
            router_name = routes.last.router
            @devices[router_name] = switch_name
            break
          end
        end
      end

      def clear_instance_vars
        @rib      = []
        @snippets = []
        @devices  = {}
        @topology = nil
      end
    end
  end
end
