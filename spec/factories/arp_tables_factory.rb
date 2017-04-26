FactoryGirl.define do
  factory :arp_table, class: Havox::ARPTable do
    trait :populated do
      after(:build) { |table| table.learn!('00:00:00:00:00:01', 1) }
    end
  end
end
