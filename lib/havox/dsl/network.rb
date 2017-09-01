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
      stmts = []
      exit_switches(opts).each do |switch|
        regex_path = ".* #{switch}"
        stmts += @snippets.map { |s| s.to_statement(regex_path, opts[:qos]) }
      end
      stmts
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

      def exit_switches(opts)
        return opts[:arbitrary] unless opts[:arbitrary].nil?
        switches = []
        @rib.network_list.each do |network|
          routes = @rib.routes_to(network)
          switches << elected_switch(routes, opts[:preferred])
        end
        switches
      end

      def elected_switch(routes, preferred_switches)
        switches = routes.map { |r| @devices[r.router] }
        intersection_switches = (switches & preferred_switches.to_a)
        intersection_switches.sample || switches.sample
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
