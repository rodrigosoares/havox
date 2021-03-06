module Havox
  class Route
    attr_reader :network, :via, :interface, :protocol, :best, :fib, :raw,
      :timestamp, :router, :recursive_via, :parsed

    IP_REGEX = /([0-9]{1,3}\.){3}[0-9]{1,3}/
    TYPE_CHAR_REGEX = /^[\w\s]/

    ROUTE_REGEX = %r(^
      (?<flags>[A-Z>\*\s]{3})\s*
      (?<network>#{IP_REGEX}\/[0-9]{1,2})?\s
      (\[\d*\/\d*\])?\s?
      (via\s(?<via>([0-9]{1,3}\.){3}[0-9]{1,3})|is\sdirectly\sconnected)
      (,\s(?<interface>\w+)|\s\(recursive\svia\s(?<recursive_via>#{IP_REGEX})\))
      (,\s(?<timestamp>\d\d:\d\d:\d\d))?
    )x

    TYPE_HASH = {
      'O' => :ospf, 'B' => :bgp, 'C' => :connected, 'S' => :static,
      'R' => :rip, 'I' => :isis, 'A' => :babel, 'K' => :kernel
    }

    def initialize(raw, router, opts = {})
      @router = router
      @opts = opts
      @raw = raw
      @parsed = false
      parse_raw_entry
    end

    def to_s
      connection = @via.nil? ? 'direct' : "via #{@via}"
      "#{@protocol.upcase}: to #{@network} #{connection} in " \
      "#{@interface || @recursive_via}#{', BEST' if @best}" \
      "#{', FIB route' if @fib}"
    rescue
      "RAW: #{@raw}"
    end

    def inspect
      "Route #{object_id.to_s(16)}, router #{@router}, #{to_s}"
    end

    def to_h
      { router: @router, protocol: @protocol, network: @network, via: @via,
        recursive_via: @recursive_via, interface: @interface,
        timestamp: @timestamp, best: @best, fib: @fib }
    end

    def direct?
      @via.nil?
    end

    def bgp?
      @protocol.eql?(:bgp)
    end

    def ospf?
      @protocol.eql?(:ospf)
    end

    private

    def parse_raw_entry
      parsed_entry = @raw.match(ROUTE_REGEX)
      if !parsed_entry.nil?
        evaluate_protocol(parsed_entry[:flags])
        evaluate_route_attributes(parsed_entry)
        @parsed = true
      end
    end

    def evaluate_protocol(flags_str)
      type_char = flags_str.scan(TYPE_CHAR_REGEX).first
      @protocol = TYPE_HASH[type_char] || :unknown
    end

    def evaluate_route_attributes(parsed_entry)
      @network       = parsed_entry[:network]&.to_s
      @via           = parsed_entry[:via]&.to_s
      @interface     = parsed_entry[:interface]&.to_s
      @timestamp     = parsed_entry[:timestamp]&.to_s
      @best          = parsed_entry[:flags].include?('>')
      @fib           = parsed_entry[:flags].include?('*')
      @recursive_via = parsed_entry[:recursive_via]&.to_s
    end
  end
end
