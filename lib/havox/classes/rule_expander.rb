module Havox
  class RuleExpander
    attr_reader :expanded_rules

    SET_VLAN_REGEX    = /SetField\(vlan,\s?(<none>|\d+)\)/
    SET_VLAN_ID_REGEX = /SetField\(vlan,\s?(?<vlan_id>\d+)\)/
    VLAN_MATCH_REGEX  = /vlanId\s?=\s?(?<vlan_id>\d+)/
    PREDICATE_REGEX   = /\(switch\s?=\s?\d+\s?and(?<pred>.+)\)/

    def initialize(raw_rules)
      @raw_rules = raw_rules
      @vlan_predicates = {}
      @expanded_rules = []
      scan_vlan_predicates
      expand
    end

    private

    def expand
      @raw_rules.each do |raw_rule|
        rule_str = raw_rule.gsub(SET_VLAN_REGEX, '')                            # Removes any 'SetField(vlan, x)' pattern, x being a number or '<none>'.
        @expanded_rules << sub_vlan_predicates(rule_str)                        # Substitutes 'vlanId = x' pattern for the full predicate.
      end
    end

    def sub_vlan_predicates(raw_rule)
      match_data = raw_rule.match(VLAN_MATCH_REGEX)                             # Matches 'vlanId = x' pattern.
      unless match_data.nil?
        vlan_id = match_data[:vlan_id]
        return raw_rule.gsub(VLAN_MATCH_REGEX, @vlan_predicates[vlan_id])       # Returns the substitution of the pattern for the full predicate.
      end
      raw_rule                                                                  # Returns the raw rule unmodified if there are no match pattern.
    end

    def scan_vlan_predicates
      @raw_rules.each do |raw_rule|
        match_data = raw_rule.match(SET_VLAN_ID_REGEX)                          # Matches 'SetField(vlan, x)' pattern, x being a number only.
        unless match_data.nil?
          vlan_id = match_data[:vlan_id]
          predicate = raw_rule.split('->').first.match(PREDICATE_REGEX)[:pred]  # Takes the predicate of the rule without the 'switch = x' substring.
          @vlan_predicates[vlan_id] = predicate                                 # Associates the predicate to its VLAN id.
        end
      end
    end
  end
end
