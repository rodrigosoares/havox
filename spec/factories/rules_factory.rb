FactoryGirl.define do
  factory :rule, class: Havox::Rule do
    transient do
      dp_id    1
      in_port  0
      vlan_vid 10000
      ipv4_src '100000001'
      ipv4_dst '100000002'
      action   'Enqueue(1,1)'
    end

    raw do
      "(switch = #{dp_id} and port = #{in_port} and ipSrc = #{ipv4_src}" \
      " and ipDst = #{ipv4_dst} and vlanId = #{vlan_vid}) -> #{action}"
    end

    initialize_with { new(raw) }
  end
end
