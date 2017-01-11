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
    expect(rendered).to match(/Vehicles/)
    expect(rendered).to match(/CV/)
    expect(rendered).to match(/Category/)
    expect(rendered).to match(/City vehicles are awesome/)
  end
end
