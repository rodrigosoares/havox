FactoryGirl.define do
  factory :arp_entry, class: Havox::ARPEntry do
    mac        '00:00:00:00:00:01'
    port       1
    max_age    300

    initialize_with { new(mac, port, max_age) }
  end
end
