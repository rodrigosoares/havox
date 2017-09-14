module Havox
  class Policy
    attr_reader :rules

    def initialize(opts = {})
      @opts = opts
      @rules = nil
      generate_rules
      treat_rules unless Havox::Network.reachable.nil?
    end

    def to_json
      @rules.map(&:to_h).to_json
    end

    private

    MERLIN_IP_SRC = 'ipSrc'
    MERLIN_IP_DST = 'ipDst'

    def generate_rules
      @rules = Havox::Merlin.compile!(
        @opts[:merlin_topology],
        @opts[:merlin_policy],
        @opts
      )
    end

    def treat_rules
      @rules.each do |r|
        # Source IP treatment disabled because RouteFlow does not implement it yet.
        # r.matches[src_ip] = netmask_added(r.matches[src_ip]) unless r.matches[src_ip].nil?
        r.matches[dst_ip] = netmask_added(r.matches[dst_ip]) unless r.matches[dst_ip].nil?
      end
    end

    def src_ip
      Havox::Translator.instance.fields_to(@opts[:syntax])[MERLIN_IP_SRC]
    end

    def dst_ip
      Havox::Translator.instance.fields_to(@opts[:syntax])[MERLIN_IP_DST]
    end

    def netmask_added(ip)
      Havox::Network.reachable.each do |network|
        return network if IPAddr.new(network).include?(ip)
      end
      ip
    end
  end
end
