module Havox
  class Translator
    include Singleton

    def fields_to(lang)
      translation_module(lang)::Matches::FIELDS
    end

    def matches_to(lang, matches_array)
      translation_module(lang)::Matches.treat(matches_array)
    end

    def actions_to(lang, actions_array)
      translation_module(lang)::Actions.treat(actions_array)
    end

    private

    def translation_module(lang)
      case lang
      when :trema then Havox::OpenFlow10::Trema
      # when :ovs   then Havox::OpenFlow10::OVS
      else raise_unknown_translator(lang)
      end
    end

    def raise_unknown_translator(lang)
      raise Havox::UnknownTranslator, "Unknown translator '#{lang}'"
    end
  end
end
