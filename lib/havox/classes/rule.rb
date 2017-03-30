module Havox
  class Rule
    attr_reader :matches, :actions, :dp_id, :raw

    DIC = {
      'ethSrc'     => 'eth_src',
      'ethDst'     => 'eth_dst',
      'ethTyp'     => 'eth_type',                                               # https://www.iana.org/assignments/ieee-802-numbers/ieee-802-numbers.xhtml
      'ipSrc'      => 'ipv4_src',
      'ipDst'      => 'ipv4_dst',
      'ipProto'    => 'ip_proto',                                               # http://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
      'nwProto'    => 'ip_proto',
      'port'       => 'in_port',
      'switch'     => 'dp_id',
      'tcpSrcPort' => 'tcp_src',
      'tcpDstPort' => 'tcp_dst',
      'vlanId'     => 'vlan_vid',
      'vlanPcp'    => 'vlan_pcp'
    }

    def initialize(raw)
      @matches = parsed_matches(raw)
      @actions = parsed_actions(raw)
      @dp_id = @matches[:dp_id].to_i
      @raw = raw.strip
    end

    def to_s
      sep = ' AND '
      matches_str = @matches.map { |k, v| "#{k.to_s} = #{v.to_s}" }.join(sep)
      "#{matches_str} --> #{@actions.join(sep)}"
    end

    def inspect
      "Rule #{object_id.to_s(16)}: #{to_s}"
    end

    private

    def parsed_matches(raw_rule)
      ok_matches = {}
      raw_matches = raw_rule.split('->').first.split('and')                     # Parses each match field in the 1st part.
      raw_matches = raw_matches.map { |str| str.tr('()*', '').strip }           # Removes unwanted characters.
      raw_matches = raw_matches.reject(&:empty?)                                # Rejects resulting empty match fields.
      raw_matches.each do |raw_match|
        stmt = raw_match.split(/\s?=\s?/)                                       # Splits the statement by '='.
        ok_matches[DIC[stmt.first].to_sym] = stmt.last                          # Adds a treated entry based on the dictionary.
      end
      treated(ok_matches)
    end

    def parsed_actions(raw_rule)
      raw_actions = raw_rule.split('->').last.strip                             # Parses the actions in the 2nd part.
      raw_actions.split(/(?<=\))\s+(?=\w)/)                                     # Splits the string into single actions.
    end

    def treated(hash)
      hash[:ipv4_src] = parsed_ipv4(hash[:ipv4_src]) unless hash[:ipv4_src].nil?
      hash[:ipv4_dst] = parsed_ipv4(hash[:ipv4_dst]) unless hash[:ipv4_dst].nil?
      hash[:eth_type] = parsed_type(hash[:eth_type]) unless hash[:eth_type].nil?
      hash
    end

    def parsed_ipv4(ip_integer)
      bits = ip_integer.to_i.to_s(2).rjust(32, '0')                             # Transforms the string number into a 32-bit sequence.
      octets = bits.scan(/\d{8}/).map { |octet_bits| octet_bits.to_i(2) }       # Splits the sequence into decimal octets.
      octets.join('.')                                                          # Returns the joined octets.
    end

    def parsed_type(ether_type)
      "0x#{ether_type.to_i.to_s(16).rjust(4, '0')}"
    end
  end
end
