# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product_type do
    name "Instructions"
    description "Instructions are awesome"
    ready_for_public true
    comes_with_title "What do instructions come with?"
    comes_with_description "All kinds of awesomeness."
    digital_product true
  end
end
