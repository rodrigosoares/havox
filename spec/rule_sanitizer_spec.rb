require 'spec_helper'

describe Havox::RuleSanitizer do
  let(:raw_rule_1) { 'port = 443 -> SetField(vlan, 1) Output(2)' }
  let(:raw_rule_2) { 'vlanId = 1 -> Output(2)' }
  let(:raw_rule_3) { 'vlanId = 2 -> Output(2)' }
  let(:raw_rule_4) { 'port = 80 and vlanId = 65535 -> Output(2)' }
  let(:raw_rules)  { [raw_rule_1, raw_rule_2, raw_rule_3, raw_rule_4] }

  describe '.new' do
    subject { Havox::RuleSanitizer.new(raw_rules) }

    it 'removes rules with invalid VLAN IDs' do
      expect(subject.sanitized_rules).to include(raw_rule_1, raw_rule_2)
      expect(subject.sanitized_rules).not_to include(raw_rule_3)
    end

    it 'removes the self VLAN ID match' do
      expect(subject.sanitized_rules).to include('port = 80 -> Output(2)')
      expect(subject.sanitized_rules).not_to include(raw_rule_4)
    end
  end
end
