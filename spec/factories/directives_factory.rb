FactoryGirl.define do
  factory :directive, class: Havox::DSL::Directive do
    type     :exit
    switches [:s1]
    attrs    { Hash[destination_port: 80] }

    initialize_with { new(type, switches, attrs) }

    trait :exit do
      type :exit
    end

    trait :tunnel do
      type     :tunnel
      switches [:s1, :s2]
    end

    trait :circuit do
      type     :circuit
      switches [:s1, :s3, :s4, :s2]
    end
  end
end
