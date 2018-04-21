FactoryGirl.define do
  factory :directive, class: Havox::DSL::Directive do
    type     :exit
    switches [:s1]
    attrs    { Hash[destination_port: 80] }

    initialize_with { new(type, switches, attrs) }

    trait :exit do
      type :exit
    end
  end
end
