# Read about factories at http://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :subcategory do
    name { 'Vehicles' }
    category_id { 1 }
    code { 'CV' }
    description { 'City Vehicles are awesome' }
    ready_for_public { 't' }
  end

  factory :subcategory_with_products, parent: :subcategory do |subcategory|
    subcategory.after(:create) { |product| FactoryBot.create(:product, subcategory: product) }
  end
end
