module Havox
  class Policy
    attr_reader :rules

    def initialize(opts = {})
      @opts = opts
      @rules = nil
      generate_rules
      evaluate_not_renderable_directives
      set_destination_mac_addresses
      check_ip_netmasks if Havox::Network.reachable.any?
    end

    def to_json
      @rules.map(&:to_h).to_json
    end

    private

    MERLIN_IP_SRC = 'ipSrc'
    MERLIN_IP_DST = 'ipDst'
    MERLIN_ETHERTYPE = 'ethTyp'
    ETHERTYPE_IP  = 2048

    def generate_rules
      @rules = Havox::Merlin.compile!(
        @opts[:merlin_topology],
        @opts[:merlin_policy],
        @opts
      )
    end

    def check_ip_netmasks
      @rules.each do |r|
        r.matches[src_ip] = netmasked_or_nil(r.matches[src_ip]) if r.matches.key?(src_ip)
        r.matches[dst_ip] = netmasked_or_nil(r.matches[dst_ip]) if r.matches.key?(dst_ip)
        delete_ip_match(r.matches, src_ip) if has_key_but_nil?(r.matches, src_ip)
        delete_ip_match(r.matches, dst_ip) if has_key_but_nil?(r.matches, dst_ip)
      end
    end

    def evaluate_not_renderable_directives
      Havox::Network.directives.reject(&:renderable?).each do |directive|
        add_drop_rules(directive) if directive.type.eql?(:drop)
      end
    end

    def src_ip
      Havox::Translator.instance.fields_to(@opts[:syntax])[MERLIN_IP_SRC]
    end

    def dst_ip
      Havox::Translator.instance.fields_to(@opts[:syntax])[MERLIN_IP_DST]
    end

    def ethertype
      Havox::Translator.instance.fields_to(@opts[:syntax])[MERLIN_ETHERTYPE]
    end

    def delete_ip_match(matches, target_ip_key)
      matches.delete(target_ip_key)
      matches[ethertype] = ETHERTYPE_IP unless matches.key?(ethertype)
    end

    def netmasked_or_nil(ip)
      Havox::Network.reachable.each do |network|
        return network if IPAddr.new(network).include?(ip)
      end
      nil
    end

    def add_drop_rules(directive)
      Havox::Network.topology.border_switches.each do |sw|
        @rules << Havox::Rule.new(
          "#{directive.raw_matches(sw.attributes[:id])} -> Drop(<none>)",
          @opts
        )
      end
    end

    # TODO: The action set below is compatible only with RouteFlow.
    def set_destination_mac_addresses
      @rules.select(&:outbound?).each do |rule|
        host_mac = target_host_mac(rule)
        rule.actions.unshift({
          action: :set_eth_dst,
          arg_a: host_mac,
          arg_b: nil
        }) # RouteFlow
      end
    end

    # TODO: This should be independent of the switch name and not rely on only one host.
    def target_host_name(rule)
      Havox::Network.topology.hosts_by_switch["s#{rule.dp_id}"].first
    end

    def target_host_ip(rule)
      name = target_host_name(rule)
      Havox::Network.topology
        .hosts
        .select { |host| host.name.eql?(name) }
        .first
        .attributes[:ip]
    end

    def target_host_mac(rule)
      ip = target_host_ip(rule)
      Havox::Network.rib.arp_table[ip]
    end

    def has_key_but_nil?(matches, target_key)
      matches.key?(target_key) && matches[target_key].nil?
    end
  end
end
