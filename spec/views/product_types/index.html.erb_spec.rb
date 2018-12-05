require 'spec_helper'

describe "product_types/index" do
  before(:each) do
    assign(:product_types, [
      stub_model(ProductType,
        :name => "Test1",
        :description => "",
        :image => "",
        :ready_for_public => false,
        :comes_with_title => "",
        :digital_product => false
      ),
      stub_model(ProductType,
        :name => "Test2",
        :description => "",
        :image => "",
        :ready_for_public => false,
        :comes_with_title => "",
        :digital_product => false
      )
    ])
  end

  it "renders a list of product_types" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Test1".to_s, :count => 1
    assert_select "tr>td", :text => "Test2".to_s, :count => 1
  end
end
