require 'spec_helper'

describe "products/show.html.haml" do
  before(:each) do
    @product_type = FactoryGirl.create(:product_type)
    @product = assign(:product, stub_model(Product,
      :name => "National Bank",
      :product_code => "CB002",
      :product_type_id => @product_type.id,
      :description => "This is one of our best sellers every month and it basically a bank, and that's awesome. It's not as awesome as Colonial Revival, but that's ok I suppose.",
      :price => "10.00"
    ))
    category = FactoryGirl.create(:category)
    subcategory = FactoryGirl.create(:subcategory, :name => "Buildings", :code => "CB")
    @product.category = category
    @product.subcategory = subcategory
    @product.save!
  end

  it "renders attributes in <p>" do
    render

    expect(rendered).to match(/National Bank/)
    expect(rendered).to match(/Instructions/)
    expect(rendered).to match(/City/)
    expect(rendered).to match(/Buildings/)
    expect(rendered).to match(/CB002/)
    expect(rendered).to match(/basically a bank/)
    expect(rendered).to match(/10.00/)
  end
end
