require 'spec_helper'

describe "product_types/show" do
  before(:each) do
    @product_type = assign(:product_type, stub_model(ProductType,
      :name => "Instructions",
      :description => "Awesome",
      :image => "",
      :ready_for_public => true,
      :comes_with_description => "Candy!",
      :digital_product => true
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Instructions/)
    expect(rendered).to match(/Awesome/)
    expect(rendered).to match(/true/)
    expect(rendered).to match(/Candy!/)
  end
end
