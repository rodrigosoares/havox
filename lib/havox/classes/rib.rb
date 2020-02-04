module Havox
  class RIB
    attr_reader :routes, :arp_table

    def initialize(opts = {})
      @opts = opts
      @routes = Havox::RouteFlow.ribs(vm_names, @opts)
      # NOTE: Improve
      @arp_table = Havox::RouteFlow.arp_table(vm_names, 'eth1')
    end

    def routes_to(ip, protocol = :bgp)
      @routes.select do |r|
        r.protocol.eql?(protocol) && IPAddr.new(r.network).include?(ip)
      end
    end

    def network_list(protocol = :bgp)
      @routes.select { |r| r.protocol.eql?(protocol) }.map(&:network).uniq
    end

    # NOTE: Improve
    # def arp_table(interface)
    #   Havox::RouteFlow.arp_table(vm_names, interface)
    # end

    private

    def vm_names
      case @opts[:vm_names]
      when Array then @opts[:vm_names]
      when String then @opts[:vm_names].split(',').map(&:strip)
      else Havox.configuration.rf_lxc_names
      end
    end
  end
end
