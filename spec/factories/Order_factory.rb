# Read about factories at http://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :order do
    user_id { 1 }
    request_id { 'blar' }
    transaction_id { 'blarney' }
    status { 'COMPLETED' }
  end

  factory :order_with_line_items, parent: :order do |order|
    order.after(:create) { |line_item| FactoryBot.create(:line_item, order: line_item) }
  end
end
