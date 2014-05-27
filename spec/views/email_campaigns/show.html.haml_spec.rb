require 'spec_helper'

describe "email_campaigns/show.html.haml" do
  before(:each) do
    @email_campaign = assign(:email_campaign, stub_model(EmailCampaign,
      :description => "MyText",
      :click_throughs => 1,
      :created_at => Time.now,
      :updated_at => Time.now
    ))
  end

  it "renders attributes in <p>" do
    render

    rendered.should match(/MyText/)
    rendered.should match(/1/)
  end
end
