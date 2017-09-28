FactoryGirl.define do
  factory :directive, class: Havox::DSL::Directive do
    type   :balance
    switch 's1'
    attrs  { Hash[destination_port: 80] }

    initialize_with { new(type, switch, attrs) }
  end
end
