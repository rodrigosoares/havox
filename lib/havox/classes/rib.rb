module Havox
  class RIB
    attr_reader :routes

    def initialize(opts = {})
      @opts = opts
      @routes = nil
      fetch_routes
    end

    private

    def fetch_routes
      @routes = Havox::RouteFlow.ribs(vm_names, @opts)
    end

    def vm_names
      case @opts[:vm_names]
      when Array then @opts[:vm_names]
      when String then @opts[:vm_names].split(',').map(&:strip)
      else Havox.configuration.rf_lxc_names
      end
    end
  end
end
