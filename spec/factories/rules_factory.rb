FactoryGirl.define do
  factory :rule, class: Havox::Rule do
    transient do
      dp_id    1
      in_port  0
      vlan_vid 10000
      ipv4_src '100000001'
      ipv4_dst '100000002'
      actions  ['SetField(vlan, 1)', 'Enqueue(1,1)']
    end

    raw do
      "(switch = #{dp_id} and port = #{in_port} and ipSrc = #{ipv4_src} and " \
      "ipDst = #{ipv4_dst} and vlanId = #{vlan_vid}) -> #{actions.join(' ')}"
    end

    initialize_with { new(raw) }

    trait :two_complement do
      transient do
        ipv4_src '-1062731480'
        ipv4_dst '-1062731500'
      end
    end
  end
end
