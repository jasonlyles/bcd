# Read about factories at http://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :pinterest_board do
    topic { 'base_product' }
    pinterest_native_id { '123123123' }
  end
end
