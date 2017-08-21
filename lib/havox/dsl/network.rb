module Havox
  module Network
    @snippets = []
    @routes = []
    @device_names = {}
    @topology = nil

    def self.snippets; @snippets end
    def self.routes; @routes end
    def self.device_names; @device_names end
    def self.topology; @topology end
    def self.topology=(topo); @topology = topo end

    def self.define(&block)
      clear_instance_vars
      snippet_proxy = Havox::DSL::SnippetProxy.new
      snippet_proxy.instance_eval(&block)
      @routes = Havox::RIB.new.routes
      evaluate_topology
    end

    def self.evaluate_topology
      direct_ospf_routes = @routes.select { |r| r.ospf? && r.direct? }
      grouped_routes = direct_ospf_routes.group_by(&:network)
      @topology.switch_ips.each do |switch_name, switch_ip|
        infer_device_names(grouped_routes, switch_name, switch_ip)
      end
    end

    def self.infer_device_names(grouped_routes, switch_name, switch_ip)
      grouped_routes.each do |network_str, routes|
        network = IPAddr.new(network_str)
        if network.include?(switch_ip)
          router_name = routes.last.router
          @device_names[router_name] = switch_name
          break
        end
      end
    end

    def self.transpile(opts = {})
      # code_array = @snippets.map(&:to_predicate)
    end

    def self.clear_instance_vars
      @snippets = []
      @routes = []
      @device_names = {}
      @topology = nil
    end
  end
end
