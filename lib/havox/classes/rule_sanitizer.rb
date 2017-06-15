module Havox
  class RuleSanitizer
    attr_reader :sanitized_rules

    SET_VLAN_ID_REGEX = /SetField\(vlan,\s?(?<vlan_id>\d+)\)/
    VLAN_MATCH_REGEX  = /vlanId\s?=\s?(?<vlan_id>\d+)/
    SELF_VLAN_REGEX   = /\s?and\svlanId\s?=\s?65535/

    def initialize(raw_rules)
      @raw_rules = raw_rules
      @setted_vlan_ids = []
      @sanitized_rules = []
      scan_setted_vlan_ids
      sanitize
    end

    private

    # Main method which iterates over all the rules and cleans them.
    def sanitize
      @raw_rules.each do |raw_rule|
        mod_raw_rule = raw_rule.gsub(SELF_VLAN_REGEX, '')
        @sanitized_rules << mod_raw_rule if valid_vlan?(mod_raw_rule)
      end
    end

    # Determines all VLAN IDs defined by the SetField action.
    def scan_setted_vlan_ids
      @raw_rules.each do |raw_rule|
        match_data = raw_rule.match(SET_VLAN_ID_REGEX)
        @setted_vlan_ids << match_data[:vlan_id] unless match_data.nil?
      end
    end

    # The rule is valid if it does not have matches like 'vlanId = x' or, in
    # case it has, if 'x' is set by the SetField action.
    def valid_vlan?(raw_rule)
      match_data = raw_rule.match(VLAN_MATCH_REGEX)
      match_data.nil? || @setted_vlan_ids.include?(match_data[:vlan_id])
    end
  end
end
