# Read about factories at https://github.com/thoughtbot/factory_bot


FactoryBot.define do
  factory :parts_list do
    factory :ldr_parts_list do
      name { 'Parts list from ldr' }
      ldr { File.open(File.join(Rails.root, 'spec', 'support', 'parts_lists', 'test.ldr')) }
      product_id { 1 }
      original_filename { 'file.ldr' }
    end

    factory :xml_parts_list do
      name { 'Parts List from xml' }
      bricklink_xml { File.open(File.join(Rails.root, 'spec', 'support', 'parts_lists', 'test.xml')) }
      product_id { 1 }
      original_filename { 'file.xml' }
    end
  end
end
