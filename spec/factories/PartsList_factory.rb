# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :parts_list do
    factory :html_parts_list do
      parts_list_type "html"
      name {File.open(File.join(Rails.root, 'spec', 'support', 'parts_lists', 'test.html'))}
      product_id 1
    end

    factory :xml_parts_list do
      parts_list_type "xml"
      name {File.open(File.join(Rails.root, 'spec', 'support', 'parts_lists', 'test.xml'))}
      product_id 1
    end
  end
end