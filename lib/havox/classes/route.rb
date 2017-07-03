module Havox
  class Route
    attr_reader :network, :via, :interface, :protocol, :raw

    OSPF_ENTRY_REGEX = %r(^
      [O>\*\s]{3}
      \s*(?<network>([0-9]{1,3}\.){3}[0-9]{1,3}\/[0-9]{1,2})?
      \s(\[\d*\/\d*\])?
      \s(via\s(?<via>([0-9]{1,3}\.){3}[0-9]{1,3})|is.*),
      \s(?<interface>\w*),
      .*$
    )x

    def initialize(raw, protocol, opts = {})
      @opts = opts
      @protocol = protocol
      @raw = raw.strip
      parse_raw_entry
    end

    def to_h
      { protocol: @protocol, network: @network, via: @via,
        interface: @interface }
    end

    private

    def parse_raw_entry
      protocol_regex =
        case @protocol
        when :ospf then OSPF_ENTRY_REGEX
        else raise Havox::RouteFlow::UnknownProtocol,
          "unknown protocol '#{@protocol}'"
        end
      parsed_entry = @raw.match(protocol_regex)
      set_route_attributes(parsed_entry)
    end

    def set_route_attributes(parsed_entry)
      @network   = parsed_entry[:network]
      @via       = parsed_entry[:via]
      @interface = parsed_entry[:interface]
    end
  end
end
