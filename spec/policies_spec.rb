require 'spec_helper'

describe Havox::Policy do
  let(:rule) { FactoryGirl.build :rule }

  let :options do
    { merlin_topology: '/path/to/topology.dot', merlin_policy: '/path/to/policy.mln' }
  end

  before :each do
    allow(Havox::Merlin).to receive(:compile!).with(
      options[:merlin_topology], options[:merlin_policy], options
    ).and_return([rule])
  end

  describe '.new' do
    it 'creates a policy object encapsulating generated rules' do
      new_policy = Havox::Policy.new(options)
      expect(new_policy.rules).to include(rule)
    end
  end

  describe '#to_json' do
    it 'formats the encapsulated rules into a JSON object' do
      new_policy = Havox::Policy.new(options)
      expect(new_policy.to_json).to include(rule.to_h.to_json)
    end
  end
end
