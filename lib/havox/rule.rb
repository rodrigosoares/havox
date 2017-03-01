module Havox
  class Rule
    attr_reader :matches, :action, :raw

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
      @raw = raw
    end

    private

    def parsed_matches(raw_rule)
      ok_matches = {}
      raw_matches = raw_rule.split('->').first.split('and')
      raw_matches = raw_matches.map { |str| str.tr('()*', '').strip }
      raw_matches = raw_matches.reject(&:empty?)
      raw_matches.each do |raw_match|
        stmt = raw_match.split(/\s?=\s?/)
        ok_matches[DIC[stmt.first].to_sym] = stmt.last
      end
      ok_matches
    end

    def parsed_action(raw_rule)
      raw_rule.split('->').last.strip
    end
  end
end
