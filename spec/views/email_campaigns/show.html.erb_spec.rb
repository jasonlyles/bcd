require 'spec_helper'

describe 'email_campaigns/show.html.erb' do
  before(:each) do
    @email_campaign = assign(:email_campaign, stub_model(EmailCampaign,
                                                         description: 'MyText',
                                                         click_throughs: 1,
                                                         created_at: Time.now,
                                                         updated_at: Time.now))
  end

  it 'renders attributes in <p>' do
    render

    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/1/)
  end
end
