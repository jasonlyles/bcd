# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :sales_summary do
    quantity { 1 }
    total_revenue { 10 }
  end
end
