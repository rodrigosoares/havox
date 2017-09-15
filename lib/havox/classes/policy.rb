module Havox
  class Policy
    attr_reader :rules

    def initialize(opts = {})
      @opts = opts
      @rules = nil
      generate_rules
      check_ip_netmasks unless Havox::Network.reachable.nil?
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

    def check_ip_netmasks
      @rules.each do |r|
        r.matches[src_ip] = netmask_added_or_nil(r.matches[src_ip]) unless r.matches[src_ip].nil?
        r.matches[dst_ip] = netmask_added_or_nil(r.matches[dst_ip]) unless r.matches[dst_ip].nil?
        r.matches.delete(src_ip) if r.matches[src_ip].nil?
        r.matches.delete(dst_ip) if r.matches[dst_ip].nil?
      end
    end

    def src_ip
      Havox::Translator.instance.fields_to(@opts[:syntax])[MERLIN_IP_SRC]
    end

    def dst_ip
      Havox::Translator.instance.fields_to(@opts[:syntax])[MERLIN_IP_DST]
    end

    def netmask_added_or_nil(ip)
      Havox::Network.reachable.each do |network|
        return network if IPAddr.new(network).include?(ip)
      end
      nil
    end
  end
end
