module Havox
  class Rule
    attr_reader :matches, :action, :dp_id, :raw

    DIC = {
      'switch' => 'dp_id',
      'ethTyp' => 'eth_type',
      'port'   => 'in_port',
      'ipSrc'  => 'ipv4_src',
      'ipDst'  => 'ipv4_dst',
      'vlanId' => 'vlan_vid'
    }

    def initialize(raw)
      @matches = parsed_matches(raw)
      @action = parsed_action(raw)
      @dp_id = @matches[:dp_id]
      @raw = raw
    end

    def to_s
      matches_str = @matches.map { |k, v| "#{k.to_s} = #{v.to_s}" }.join(' AND ')
      "#{matches_str} --> #{@action}"
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

    def parsed_action(raw_rule)
      raw_rule.split('->').last.strip                                           # Parses the action in the 2nd part.
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
