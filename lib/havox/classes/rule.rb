module Havox
  class Rule
    attr_reader :matches, :actions, :dp_id, :raw

    MATCHES_DIC = Havox::OpenFlow10::Dictionary::MATCHES

    def initialize(raw)
      @matches = parsed_matches(raw)
      @actions = parsed_actions(raw)
      @dp_id = @matches[:dp_id].to_i
      @matches.delete(:dp_id)
      @raw = raw.strip
    end

    def to_s                                                                    # Stringifies the rule.
      sep = ' AND '
      matches_str = @matches.map { |k, v| "#{k.to_s} = #{v.to_s}" }.join(sep)
      actions_str = @actions.map do |o|
        %Q(#{o[:action]}(#{o[:arg_a]}#{", #{o[:arg_b]}" unless o[:arg_b].nil?}))
      end
      "#{matches_str} --> #{actions_str.join(sep)}"
    end

    def inspect
      "Rule #{object_id.to_s(16)}, dp_id = #{@dp_id}: #{to_s}"                  # Prints the rule when debugging or array listing.
    end

    private

    def parsed_matches(raw_rule)
      ok_matches = {}
      raw_matches = raw_rule.split('->').first.split('and')                     # Parses each match field in the 1st part.
      raw_matches = raw_matches.map { |str| str.tr('()*', '').strip }           # Removes unwanted characters.
      raw_matches = raw_matches.reject(&:empty?)                                # Rejects resulting empty match fields.
      raw_matches.each do |raw_match|
        stmt = raw_match.split(/\s?=\s?/)                                       # Splits the statement by '='.
        ok_matches[MATCHES_DIC[stmt.first]] = stmt.last                         # Adds a treated entry based on the dictionary.
      end
      fields_treated(ok_matches)
    end

    def parsed_actions(raw_rule)
      actions_ok = []
      raw_actions = raw_rule.split('->').last.strip                             # Parses the actions in the 2nd part.
      raw_actions = raw_actions.split(/(?<=\))\s+(?=\w)/)                       # Splits the string into single raw actions.
      raw_actions.each do |raw_action|
        regex = /(?<action>\w+)\((?<arg_a>[\w<>]+)[,\s]*(?<arg_b>[\w<>]*)\)/    # Matches raw actions in the format 'Action(x, y)'.
        actions_ok << hashed(raw_action.match(regex))                           # Adds the structured action to the returning array.
      end
      syntax_treated(actions_ok)
    end

    def hashed(match_data)
      Hash[match_data.names.map(&:to_sym).zip(match_data.captures)]             # Converts the match data to a hash object.
    end

    def syntax_treated(actions_array)
      Havox::OpenFlow10::Actions.syntax_treated(actions_array)
    end

    def fields_treated(hash)
      hash[:source_ip_address] = parsed_ipv4(hash[:source_ip_address]) unless hash[:source_ip_address].nil?
      hash[:destination_ip_address] = parsed_ipv4(hash[:destination_ip_address]) unless hash[:destination_ip_address].nil?
      hash[:ether_type] = parsed_type(hash[:ether_type]) unless hash[:ether_type].nil?
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
