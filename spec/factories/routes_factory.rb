FactoryGirl.define do
  factory :route, class: Havox::Route do
    transient do
      network   '10.0.0.0/24'
      via       '40.0.0.2'
      interface 'eth2'
      protocol  :ospf

      raw { "O>* #{network} [110/20] via #{via}, #{interface}, 03:41:18" }

      initialize_with { new(raw) }
    end
  end
end
