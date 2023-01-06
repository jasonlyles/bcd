# Read about factories at http://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :lot do
    element_id { 1 }
    parts_list_id { 1 }
    quantity { 1 }
  end
end
