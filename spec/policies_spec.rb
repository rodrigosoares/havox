require 'spec_helper'

describe Havox::Policy do
  let(:rule) { FactoryGirl.build(:rule, ipv4_dst: IPAddr.new('200.156.0.0').to_i) }
  let(:outbound_rule) { FactoryGirl.build(:rule, :outbound) }

  let :options do
    { merlin_topology: '/path/to/topology.dot', merlin_policy: '/path/to/policy.mln',
      syntax: :trema, force: true }
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

    it 'appends destination MAC address actions to outbound rules' do
      pending 'Refactor code and write this test'
      new_policy = Havox::Policy.new(options)
      expect(new_policy.rules).to include(outbound_rule)
      expect(true).to be(false)
    end

    context 'when the reachable networks list is not empty' do
      before :each do
        allow(Havox::Network).to receive(:reachable).and_return(['200.156.0.0/16'])
        policy = Havox::Policy.new(options)
        @sample_rule = policy.rules.sample
      end

      it 'switches IP address matches by their masked networks' do
        expect(@sample_rule.matches).to include(destination_ip_address: '200.156.0.0/16')
      end

      it 'discards invalid Merlin host address matches' do
        expect(@sample_rule.matches).not_to have_key(:source_ip_address)
      end
    end
  end

  describe '#to_json' do
    it 'formats the encapsulated rules into a JSON object' do
      new_policy = Havox::Policy.new(options)
      expect(new_policy.to_json).to include(rule.to_h.to_json)
    end
  end
end
