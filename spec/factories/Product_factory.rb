# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product do
    name "Colonial Revival House"
    category_id 1
    subcategory_id 1
    product_code "CB001"
    product_type_id 1
    description "This is one of our best sellers every month and it dominates the all-time sales list. Brian wishes he could make a model as powerful and successful as this. Mwuh-ha-ha-ha-ha! Actually, I wish I could duplicate it's success."
    discount_percentage "9.00"
    price "10.00"
    ready_for_public "t"
    pdf {File.open(File.join(Rails.root, 'spec', 'support', 'pdfs', 'test.pdf'))}

    factory :physical_product do
      product_type_id 2
      pdf ''
      price "300.00"
      name "Colonial Revival House Model"
      product_code "CB001M"
    end

    factory :free_product do
      free "t"
      price "0"
    end
  end
end  
