# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :image do
    category_id "1"
    location 'categories'
    product_id "1"
    url { File.open(File.join(Rails.root, 'spec', 'fixtures', 'files', 'example.png')) }
  end
end
