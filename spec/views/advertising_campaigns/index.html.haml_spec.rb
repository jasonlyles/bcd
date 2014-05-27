require 'spec_helper'

describe "advertising_campaigns/index.html.haml" do
  before(:each) do
    assign(:advertising_campaigns, [
      stub_model(AdvertisingCampaign,
        :partner_id => 1,
        :reference_code => "Reference Code"
      ),
      stub_model(AdvertisingCampaign,
        :partner_id => 1,
        :reference_code => "Reference Code"
      )
    ])
    partner = FactoryGirl.create(:partner)
  end

  it "renders a list of advertising_campaigns" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyString", :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Reference Code".to_s, :count => 2
  end
end