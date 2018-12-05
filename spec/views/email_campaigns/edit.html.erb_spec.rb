require 'spec_helper'

describe 'email_campaigns/edit.html.erb' do
  before(:each) do
    @email_campaign = assign(:email_campaign, stub_model(EmailCampaign,
                                                         description: 'MyText'))
  end

  it 'renders the edit email_campaign form' do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'form', action: email_campaign_path(@email_campaign), method: 'post' do
      assert_select 'textarea#email_campaign_description', name: 'email_campaign[description]'
    end
  end
end
