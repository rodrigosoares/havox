module Havox
  class RouteFiller
    attr_reader :filled_routes

    ROUTE_REGEX = %r(^
      (?<protocol_char>[A-Z\s]{1})[>\s]{1}[\*\s]{1}\s
      (?<network>([0-9]{1,3}\.){3}[0-9]{1,3}\/[0-9]{1,2})?.+$
    )x

    def initialize(raw_routes)
      @raw_routes = raw_routes
      @filled_routes = []
      fill_routes
    end

    private

    def fill_routes
      pivot = nil                                                               # Sets null as initial value for the pivot, since the first route is always OK.
      @raw_routes.each do |raw_route|
        match = raw_route.match(ROUTE_REGEX)                                    # Tries to match the current route to the regex.
        if match[:network].nil?                                                 # If the network match is null, the current route must be treated:
          @filled_routes << filled_route(raw_route, pivot)                      # -- Treats the current route and adds it to the returning array.
        else                                                                    # Otherwise, the current route is OK:
          pivot = raw_route                                                     # -- Sets the current route as the new pivot.
          @filled_routes << raw_route                                           # -- Adds the current route to the returning array.
        end
      end
    end

    def filled_route(raw_route, pivot)
      match = pivot.match(ROUTE_REGEX)                                          # Extracts protocol char and network from the pivot.
      network_str = "#{match[:protocol_char]} * #{match[:network]} [110/10] "   # Builds the substitution string containing the char and the network.
      treated_route = raw_route.gsub(/\s{2}\*\s+(?=via|is)/, network_str)       # Fits the substitution string to the correct place.
      raise_error(raw_route) if treated_route.eql?(raw_route)                   # Raises an error if the treated route is equal to its initial state.
      treated_route
    end

    def raise_error(raw_route)
      raise Havox::OperationError, "Failed to fill route '#{raw_route}'"
    end
  end
end
