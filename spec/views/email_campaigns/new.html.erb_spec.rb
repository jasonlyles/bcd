require 'spec_helper'

describe 'email_campaigns/new.html.erb' do
  before(:each) do
    assign(:email_campaign, stub_model(EmailCampaign,
                                       description: 'MyText').as_new_record)
  end

  it 'renders new email_campaign form' do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'form', action: email_campaigns_path, method: 'post' do
      assert_select 'textarea#email_campaign_description', name: 'email_campaign[description]'
    end
  end
end
