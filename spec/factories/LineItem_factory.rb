# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :line_item do
    order_id 1
    product_id 1
    quantity 1
    total_price "10"
  end
end
