# Read about factories at http://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :cart_item do
    cart_id 1
    product_id 1
    quantity 1

    factory :cart_item_with_quantity_greater_than_1 do
      quantity 2
    end
  end
end
