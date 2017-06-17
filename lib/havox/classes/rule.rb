module Havox
  class Rule
    attr_reader :matches, :actions, :dp_id, :raw

    def initialize(raw, opts = {})
      @opts = opts
      @syntax = @opts[:syntax] || :trema
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

    def to_h
      { dp_id: @dp_id, matches: @matches, actions: @actions }
    end

    private

    def parsed_matches(raw_rule)
      ok_matches = {}
      raw_matches = raw_rule.split('->').first.split('and')                     # Parses each match field in the 1st part.
      raw_matches = raw_matches.map { |str| str.tr('()*', '').strip }           # Removes unwanted characters.
      raw_matches = raw_matches.reject(&:empty?)                                # Rejects resulting empty match fields.
      raw_matches.each do |raw_match|                                           # Parses and adds each match based on the dictionary.
        stmt = raw_match.split(/\s?=\s?/)                                       # Splits the statement by '='.
        field = translate.fields_to(@syntax)[stmt.first]                        # Gets the right field by the raw field name.
        ok_matches[field] = stmt.last unless already_set?(ok_matches, stmt)
      end
      translate.matches_to(@syntax, ok_matches)
    end

    def parsed_actions(raw_rule)
      ok_actions = []
      raw_actions = raw_rule.split('->').last.strip                             # Parses the actions in the 2nd part.
      raw_actions = raw_actions.split(/(?<=\))\s+(?=\w)/)                       # Splits the string into single raw actions.
      raw_actions.each do |raw_action|
        regex = /(?<action>\w+)\((?<arg_a>[\w<>]+)[,\s]*(?<arg_b>[\w<>]*)\)/    # Matches raw actions in the format 'Action(x, y)'.
        ok_actions << hashed(raw_action.match(regex))                           # Adds the structured action to the returning array.
      end
      translate.actions_to(@syntax, ok_actions, @opts)
    end

    def hashed(match_data)
      Hash[match_data.names.map(&:to_sym).zip(match_data.captures)]             # Converts the match data to a hash object.
    end

    def translate
      Havox::Translator.instance
    end

    def already_set?(matches_hash, stmt)
      field = translate.fields_to(@syntax)[stmt.first]
      unless matches_hash[field].nil? || matches_hash[field].eql?(stmt.last)
        return ignore_conflict?(field, matches_hash[field], stmt.last)
      end
      false
    end

    def ignore_conflict?(field, old_value, new_value)
      unless @opts[:force]
        raise Havox::Merlin::FieldConflict,
          "Attempted to define field '#{field}' with #{new_value}, but it is " \
          "already defined with #{old_value}"
      end
      true
    end
  end
end
