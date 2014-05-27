require 'spec_helper'

describe "subcategories/show.html.haml" do
  before(:each) do
    @subcategory = assign(:subcategory, stub_model(Subcategory,
      :name => "Vehicles",
      :code => "CV",
      :description => "City vehicles are awesome",
      :category_id => 1
    ))
    category = FactoryGirl.create(:category)
    @subcategory.category_id = category.id
    @subcategory.save!
  end

  it "renders attributes in <p>" do
    render
    rendered.should match(/Vehicles/)
    rendered.should match(/CV/)
    rendered.should match(/Category/)
    rendered.should match(/City vehicles are awesome/)
  end
end
