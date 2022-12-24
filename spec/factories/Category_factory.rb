# Read about factories at http://github.com/thoughtbot/factory_bot
FactoryBot.define do
  factory :category do
    name { 'City' }
    description { 'Awesome city time. The City theme is fun for all boys and girls. You should buy everything you see. If everyone does that, we\'ll be filthy rich. Whoo.' }
    ready_for_public { 't' }
  end

  factory :category_with_subcategories, parent: :category do |category|
    category.after(:create) { |subcat| FactoryBot.create(:subcategory, category: subcat) }
  end
end
