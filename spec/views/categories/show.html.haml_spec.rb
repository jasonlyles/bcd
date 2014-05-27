require 'spec_helper'

describe "categories/show.html.haml" do
  before(:each) do
    @category = assign(:category, stub_model(Category,
      :name => "Name",
      :description => "Description of 100 or more characters. This should get me up to 100 characters by doing things like this: blah blah blah blah etc etc.",
      :ready_for_public => 'true'
    ))
  end

  it "renders attributes in <p>" do
    render

    rendered.should match(/Name/)
    rendered.should match(/blah blah blah/)
    rendered.should match(/Ready for Public/)
  end
end
