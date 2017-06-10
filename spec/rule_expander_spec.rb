require 'spec_helper'

describe Havox::RuleExpander do
  let(:rule_1)    { FactoryGirl.build :rule, :vlan_setting, dp_id: 10 }
  let(:rule_2)    { FactoryGirl.build :rule, :vlan_stripping, dp_id: 20 }
  let(:rule_3)    { FactoryGirl.build :rule, :vlan_forwarding, dp_id: 30 }
  let(:raw_rules) { [rule_1.raw, rule_2.raw, rule_3.raw] }

  describe '.new' do
    subject { Havox::RuleExpander.new(raw_rules) }

    it 'expands the raw rules from VLAN-based to full predicates' do
      expect(subject.expanded_rules).to contain_exactly(
        '(switch = 10 and ipSrc = 100000001 and ipDst = 100000002) ->  Enqueue(1,1)',
        '(switch = 20 and  ipSrc = 100000001 and ipDst = 100000002) ->  Enqueue(1,1)',
        '(switch = 30 and  ipSrc = 100000001 and ipDst = 100000002) -> Enqueue(1,1)'
      )
    end
  end
end
