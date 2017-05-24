module Havox
  class Policy
    attr_reader :rules

    def initialize(opts = {})
      @opts = opts
      @rules = nil
      generate_rules
    end

    def to_json
      @rules.map(&:to_h).to_json
    end

    private

    def generate_rules
      @rules = Havox::Merlin.compile!(
        @opts[:merlin_topology],
        @opts[:merlin_policy],
        @opts
      )
    end
  end
end
