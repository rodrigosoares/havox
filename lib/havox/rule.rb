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
      ok_matches
    end

    def parsed_action(raw_rule)
      raw_rule.split('->').last.strip                                           # Parses the action in the 2nd part.
    end
  end
end
