FactoryGirl.define do
  factory :route, class: Havox::Route do
    transient do
      router    'foo_vm'
      network   '10.0.0.0/24'
      via       '40.0.0.2'
      interface 'eth2'
      protocol  :ospf
    end

    raw { "O>* #{network} [110/20] via #{via}, #{interface}, 03:41:18" }

    initialize_with { new(raw, router) }

    trait :bgp do
      transient { protocol :bgp }
      raw { "B>* #{network} [110/20] via #{via}, #{interface}, 03:41:18" }
    end

    trait :recursive do
      transient do
        interface nil
        recursive_via '50.0.0.1'
      end

      raw do
        "#{protocol.to_s[0].upcase}>* #{network} [200/0] via #{via} " \
        "(recursive via #{recursive_via}), 00:44:31"
      end
    end

    trait :direct do
      transient { via nil }
      raw { "O>* #{network} [110/20] is directly connected, #{interface}, 03:41:18" }
    end
  end
end
