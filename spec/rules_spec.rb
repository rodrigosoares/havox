require 'spec_helper'
require 'helpers/mock_helper'

RSpec.configure { |c| c.include MockHelper }

describe Havox::Rule do
  describe '.new' do
    it 'parses a Merlin formatted OpenFlow rule' do
      rule = Havox::Rule.new(raw_rule)
      expect(rule.dp_id).to eq('1')
      expect(rule.matches[:dp_id]).to eq('1')
      expect(rule.matches[:in_port]).to eq('80')
      expect(rule.matches[:eth_type]).to eq('0x0800')
      expect(rule.matches[:ipv4_src]).to eq('10.0.0.1')
      expect(rule.matches[:ipv4_dst]).to eq('10.0.0.2')
      expect(rule.matches[:vlan_vid]).to eq('65535')
      expect(rule.action).to eq('Output(0)')
    end
  end
end
