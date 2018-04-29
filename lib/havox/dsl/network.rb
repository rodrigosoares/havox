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
      infer_associations_by_ospf
    end

    def self.transcompile(opts = {})
      @directives.map { |d| d.render(@topology, opts[:qos]) }
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

      def infer_associations_by_ospf
        direct_ospf_routes = @rib.routes.select { |r| r.ospf? && r.direct? }
        grouped_routes = direct_ospf_routes.group_by(&:network)
        @topology.ips_by_switch.each do |switch_name, switch_ip|
          associate_routers(grouped_routes, switch_name, switch_ip)
        end
      end

      def associate_routers(grouped_routes, switch_name, switch_ip)
        grouped_routes.each do |network_str, routes|
          network = IPAddr.new(network_str)
          router_name = routes.last.router
          if network.include?(switch_ip) && @devices[router_name].nil?
            @devices[router_name] = switch_name
            break
          end
        end
      end
    end
  end
end
