require 'spec_helper'
require 'helpers/mock_helper'

RSpec.configure { |c| c.include MockHelper }

describe Havox::Rule do
  let(:rule) { FactoryGirl.build :rule }

  describe '.new' do
    let(:action_a) { Hash[action: :enqueue, arg_a: 0, arg_b: 2] }
    let(:action_b) { Hash[action: :output, arg_a: 0, arg_b: nil] }

    it 'parses a Merlin formatted OpenFlow rule' do
      new_rule = Havox::Rule.new(raw_rule)
      expect(new_rule.dp_id).to eq(1)
      expect(new_rule.matches[:in_port]).to eq(80)
      expect(new_rule.matches[:ether_type]).to eq(2048)
      expect(new_rule.matches[:source_ip_address]).to eq('10.0.0.1')
      expect(new_rule.matches[:destination_ip_address]).to eq('10.0.0.2')
      expect(new_rule.matches[:vlan_vid]).to eq(65535)
      expect(new_rule.actions).to match_array([action_a, action_b])
    end

    context 'when the rule is defining an attribute twice' do
      it 'uses the first parsed value by default' do
        options = { force: false }
        new_rule = Havox::Rule.new(conflicting_raw_rule, options)
        expect(new_rule.matches[:ip_protocol]).to eq(17)
      end

      it 'uses the last parsed value if forced' do
        options = { force: true }
        new_rule = Havox::Rule.new(conflicting_raw_rule, options)
        expect(new_rule.matches[:ip_protocol]).to eq(6)
      end
    end

    context 'when the rule has integer fields in two\'s complement' do
      let(:tc_rule) { FactoryGirl.build :rule, :two_complement }

      it 'parses the IP address correctly' do
        expect(tc_rule.matches[:source_ip_address]).to eq('192.168.1.40')
        expect(tc_rule.matches[:destination_ip_address]).to eq('192.168.1.20')
      end
    end
  end

  describe '#to_s' do
    it 'stringifies the rule' do
      matches_str = "in_port = #{rule.matches[:in_port]}"
      actions_str = 'enqueue(1, 1)'
      expect(rule.to_s).to include(matches_str, actions_str)
    end
  end

  describe '#inspect' do
    it 'stringifies the rule with an unique ID' do
      dp_id_str = "dp_id = #{rule.dp_id}"
      rule_id_str = "Rule #{rule.object_id.to_s(16)}"
      expect(rule.inspect).to include(rule_id_str, dp_id_str)
    end
  end

  describe '#to_h' do
    it 'formats the rule into a hash' do
      hash = { dp_id: rule.dp_id, matches: rule.matches, actions: rule.actions }
      expect(rule.to_h).to eq(hash)
    end
  end
end
