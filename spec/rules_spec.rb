require 'spec_helper'
require 'helpers/mock_helper'

RSpec.configure { |c| c.include MockHelper }

describe Havox::Rule do
  let(:rule) { FactoryGirl.build :rule }

  describe '.new' do
    let(:action_a) { Hash[action: :enqueue, arg_a: '0', arg_b: '2'] }
    let(:action_b) { Hash[action: :output, arg_a: '0', arg_b: nil] }

    it 'parses a Merlin formatted OpenFlow rule' do
      new_rule = Havox::Rule.new(raw_rule)
      expect(new_rule.dp_id).to eq(1)
      expect(new_rule.matches[:dp_id]).to eq('1')
      expect(new_rule.matches[:in_port]).to eq('80')
      expect(new_rule.matches[:eth_type]).to eq('0x0800')
      expect(new_rule.matches[:ipv4_src]).to eq('10.0.0.1')
      expect(new_rule.matches[:ipv4_dst]).to eq('10.0.0.2')
      expect(new_rule.matches[:vlan_vid]).to eq('65535')
      expect(new_rule.actions).to match_array([action_a, action_b])
    end
  end

  describe '#to_s' do
    it 'stringifies the rule' do
      dp_id_str = "dp_id = #{rule.dp_id}"
      matches_str = "in_port = #{rule.matches[:in_port]}"
      actions_str = 'enqueue(1, 1)'
      expect(rule.to_s).to include(dp_id_str, matches_str, actions_str)
    end
  end

  describe '#inspect' do
    it 'stringifies the rule with an unique ID' do
      rule_id_str = "Rule #{rule.object_id.to_s(16)}"
      expect(rule.inspect).to include(rule_id_str)
    end
  end
end
