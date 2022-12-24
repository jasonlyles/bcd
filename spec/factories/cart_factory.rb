# Read about factories at http://github.com/thoughtbot/factory_bot
FactoryBot.define do
  factory :cart do
  end

  factory :cart_with_cart_items, parent: :cart do |cart|
    cart.after(:create){ |item| FactoryBot.create(:cart_item, cart: item) }
  end

  factory :cart_with_cart_items_with_multiple_quantity, parent: :cart do |cart|
    cart.after(:create){ |item| FactoryBot.create(:cart_item_with_quantity_greater_than_1, cart: item) }
  end
end
