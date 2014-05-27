require 'spec_helper'

describe "subcategories/new.html.haml" do
  before(:each) do
    assign(:subcategory, stub_model(Subcategory,
      :name => "Vehicles",
      :code => "CV",
      :description => "City Vehicles are awesome",
      :category_id => 1
    ).as_new_record)
    category = FactoryGirl.create(:category)
    @categories = []
    @categories << category
  end

  it "renders new subcategory form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => subcategories_path, :method => "post" do
      assert_select "input#subcategory_name", :name => "subcategory[name]"
      assert_select "input#subcategory_code", :name => "subcategory[code]"
      assert_select "select#subcategory_category_id", :name => "subcategory[category_id]"
      assert_select "textarea#subcategory_description", :name => "subcategory[description]"
    end
  end
end
