require 'spec_helper'

describe "product_types/edit" do
  before(:each) do
    @product_type = assign(:product_type, stub_model(ProductType,
      :name => "",
      :description => "",
      :image => "",
      :ready_for_public => false,
      :comes_with_description => "",
      :comes_with_title => "",
      :digital_product => false
    ))
  end

  it "renders the edit product_type form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", product_type_path(@product_type), "post" do
      assert_select "input#product_type_name[name=?]", "product_type[name]"
      assert_select "input#product_type_comes_with_title[name=?]", "product_type[comes_with_title]"
      assert_select "input#product_type_image[name=?]", "product_type[image]"
      assert_select "input#product_type_ready_for_public[name=?]", "product_type[ready_for_public]"
      assert_select "input#product_type_digital_product[name=?]", "product_type[digital_product]"
    end
  end
end
