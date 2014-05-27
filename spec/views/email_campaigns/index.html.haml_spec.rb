require 'spec_helper'

describe "email_campaigns/index.html.haml" do
  before(:each) do
    assign(:email_campaigns, [
      stub_model(EmailCampaign,
        :description => "MyText",
        :click_throughs => 1,
        :created_at => Time.now,
        :updated_at => Time.now
      ),
      stub_model(EmailCampaign,
        :description => "MyText",
        :click_throughs => 1,
        :created_at => Time.now,
        :updated_at => Time.now
      )
    ])
  end

  it "renders a list of email_campaigns" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
