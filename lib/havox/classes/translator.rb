module Havox
  class Translator
    include Singleton

    def fields_to(syntax)
      translation_module(syntax)::Matches::FIELDS
    end

    def matches_to(syntax, matches_array)
      translation_module(syntax)::Matches.treat(matches_array)
    end

    def actions_to(syntax, actions_array)
      translation_module(syntax)::Actions.treat(actions_array)
    end

    private

    def translation_module(syntax)
      case syntax
      when :trema then Havox::OpenFlow10::Trema
      when :ovs   then Havox::OpenFlow10::OVS
      else raise_unknown_translator(syntax)
      end
    end

    def raise_unknown_translator(syntax)
      raise Havox::UnknownTranslator, "Unknown translator '#{syntax}'"
    end
  end
end
