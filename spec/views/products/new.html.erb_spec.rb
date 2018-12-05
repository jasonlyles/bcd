require 'spec_helper'

describe 'products/new.html.erb' do
  before(:each) do
    assign(:product, stub_model(Product,
                                name: 'National Bank',
                                designer: 'brian_lyles',
                                product_code: 'CB002',
                                product_type_id: 1,
                                description: "This is one of our best sellers every month and it basically a bank, and that's awesome. It's not as awesome as Colonial Revival, but that's ok I suppose.",
                                price: '10.00').as_new_record)
    @product_types = []
    @categories = []
  end

  it 'renders new product form' do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'form', action: products_path, method: 'post' do
      assert_select 'input#product_name', name: 'product[name]'
      assert_select 'select#product_product_type_id', name: 'product[product_type_id]'
      assert_select 'select#product_designer', name: 'product[designer]'
      assert_select 'select#product_category_id', name: 'product[category_id]'
      assert_select 'select#product_subcategory_id', name: 'product[subcategory_id]'
      assert_select 'input#product_product_code', name: 'product[product_code]'
      assert_select 'textarea#product_description', name: 'product[description]'
      assert_select 'input#product_pdf', name: 'product[pdf]'
      assert_select 'input#product_discount_percentage', name: 'product[discount_percentage]'
      assert_select 'input#product_price', name: 'product[price]'
      assert_select 'input#product_ready_for_public', name: 'product[ready_for_public]'
    end
  end
end
