require 'spec_helper'

describe 'products/index.html.erb' do
  before(:each) do
    @product_type = FactoryGirl.create(:product_type)
    @category = FactoryGirl.create(:category)
    @subcategory = FactoryGirl.create(:subcategory)
    @product1 = FactoryGirl.create(:product, price: '5')
    @product2 = FactoryGirl.create(:product, name: 'Grader', product_code: 'WC002', description: 'Winter Village Grader... are you kidding? w00t! Plow your winter village to the ground and then flatten it out with this sweet grader', price: '5.00')
    @products = Product.all.order('name')
    allow(@products).to receive(:current_page).and_return(1)
    allow(@products).to receive(:total_pages).and_return(1)
    allow(@products).to receive(:num_pages).and_return(1)
    allow(@products).to receive(:limit_value).and_return(2)
  end

  it 'renders a list of products' do
    render

    assert_select 'tr>td', text: 'CB001 Colonial Revival House', count: 1
    assert_select 'tr>td', text: 'WC002 Grader', count: 1
    assert_select 'tr>td', text: 'Instructions', count: 2
    assert_select 'tr>td', text: '$5.00'.to_s, count: 2
  end
end
