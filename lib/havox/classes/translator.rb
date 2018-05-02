module Havox
  class Translator
    # OPTIMIZE: Refactor the translation schema to be scalable.
    # Current way of selecting the syntax via multiple match and action files
    # is not DRY. Refactor the translation schema to be scalable, maybe using
    # YAML or some other better structure.

    include Singleton

    def fields_to(syntax)
      translation_module(syntax)::Matches::FIELDS
    end

    def matches_to(syntax, matches_hash)
      translation_module(syntax)::Matches.treat(matches_hash)
    end

    def actions_to(syntax, actions_array, opts = {})
      translation_module(syntax)::Actions.treat(actions_array, opts)
    end

    private

    def translation_module(syntax)
      case syntax
      when :ovs       then Havox::OpenFlow10::OVS
      when :routeflow then Havox::OpenFlow10::RouteFlow
      when :trema     then Havox::OpenFlow10::Trema
      else raise_unknown_translator(syntax)
      end
    end

    def raise_unknown_translator(syntax)
      raise Havox::UnknownTranslator, "Unknown translator '#{syntax}'"
    end
  end
end
