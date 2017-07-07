module Havox
  class Route
    attr_reader :network, :via, :interface, :protocol, :best, :fib, :raw,
      :timestamp

    ROUTE_REGEX = %r(^
      (?<flags>[OKCSRIBA>\*\s]{3})\s
      *(?<network>([0-9]{1,3}\.){3}[0-9]{1,3}\/[0-9]{1,2})?\s
      (\[\d*\/\d*\])?\s?
      (via\s(?<via>([0-9]{1,3}\.){3}[0-9]{1,3})|is\sdirectly\sconnected),\s
      (?<interface>\w+)
      (,\s(?<timestamp>\d\d:\d\d:\d\d))?
    )x

    TYPE_CHAR_REGEX = /^[\w\s]/
    TYPE_HASH = {
      'O' => :ospf, 'B' => :bgp, 'C' => :connected, 'S' => :static,
      'R' => :rip, 'I' => :isis, 'A' => :babel, 'K' => :kernel
    }

    def initialize(raw, opts = {})
      @opts = opts
      @raw = raw
      parse_raw_entry
    end

    def to_s
      connection = @via.nil? ? 'direct' : "via #{@via}"
      "#{@protocol.upcase}: to #{@network} #{connection} in #{@interface}" \
      "#{', BEST' if @best}#{', FIB route' if @fib}"
    end

    def inspect
      "Route #{object_id.to_s(16)}, #{to_s}"
    end

    def to_h
      { protocol: @protocol, network: @network, via: @via,
        interface: @interface, timestamp: @timestamp, best: @best, fib: @fib }
    end

    private

    def parse_raw_entry
      puts @raw
      parsed_entry = @raw.match(ROUTE_REGEX)
      evaluate_protocol(parsed_entry[:flags])
      evaluate_route_attributes(parsed_entry)
    end

    def evaluate_protocol(flags_str)
      type_char = flags_str.scan(TYPE_CHAR_REGEX).first
      @protocol = TYPE_HASH[type_char] || :unknown
    end

    def evaluate_route_attributes(parsed_entry)
      @network   = parsed_entry[:network]
      @via       = parsed_entry[:via]
      @interface = parsed_entry[:interface]
      @timestamp = parsed_entry[:timestamp]
      @best      = parsed_entry[:flags].include?('>')
      @fib       = parsed_entry[:flags].include?('*')
    end
  end
end
