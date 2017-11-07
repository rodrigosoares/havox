module Havox
  module Network
    @directives = []
    @devices    = {}
    @rib        = nil
    @topology   = nil

    def self.directives; @directives end
    def self.rib; @rib end
    def self.devices; @devices end
    def self.topology; @topology end
    def self.topology=(topo); @topology = topo end

    def self.define(&block)
      reset!
      directive_proxy = Havox::DSL::DirectiveProxy.new
      directive_proxy.instance_eval(&block)
      @rib = Havox::RIB.new
      evaluate_topology
    end

    def self.transcompile(opts = {})
      @directives.map do |d|
        src_hosts = @topology.host_names - @topology.switch_hosts[d.switch.to_s]
        dst_hosts = @topology.switch_hosts[d.switch.to_s]
        d.to_block(src_hosts, dst_hosts, opts[:qos])
      end
    end

    def self.reachable(protocol = :bgp)
      @rib.nil? ? [] : @rib.network_list(protocol)
    end

    def self.reset!
      @directives = []
      @devices    = {}
      @rib        = nil
      @topology   = nil
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
    end
  end
end
