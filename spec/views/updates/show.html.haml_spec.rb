require 'spec_helper'

describe "updates/show.html.haml" do
  before(:each) do
    @update = assign(:update, stub_model(Update,
      :title => "Title",
      :description => "Description",
      :body => "MyText",
      :image => "Image"
    ))
  end

  it "renders attributes in <p>" do
    render
    rendered.should match(/Title/)
    rendered.should match(/Description/)
    rendered.should match(/MyText/)
    rendered.should match(/Image/)
  end
end
