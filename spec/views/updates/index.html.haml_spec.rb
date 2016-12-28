require 'spec_helper'

describe "updates/index.html.haml" do
  before(:each) do
    @updates = [
      FactoryGirl.create(:update, :title => 'Title1', :description => 'Description'),
      FactoryGirl.create(:update, :title => 'Title2', :description => 'Description')
    ]
    allow(@updates).to receive(:current_page).and_return(1)
    allow(@updates).to receive(:num_pages).and_return(1)
    allow(@updates).to receive(:limit_value).and_return(1)
    allow(@updates).to receive(:total_pages).and_return(1)
  end

  it "renders a list of updates" do
    render

    assert_select "tr>td", :text => "Title1".to_s, :count => 1
    assert_select "tr>td", :text => "Title2".to_s, :count => 1
    assert_select "tr>td", :text => "Description".to_s, :count => 2
  end
end
