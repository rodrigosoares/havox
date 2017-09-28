FactoryGirl.define do
  factory :node, class: Havox::Node do
    name 'n1'
    type 'any'
    ip   '10.0.0.1'
    mac  '00:00:00:00:00:01'
    id   '1'

    initialize_with { new(name, type: type, ip: ip, mac: mac, id: id) }

    trait :host do
      name 'h1'
      type 'host'
    end

    trait :switch do
      name 's1'
      type 'switch'
    end
  end
end
