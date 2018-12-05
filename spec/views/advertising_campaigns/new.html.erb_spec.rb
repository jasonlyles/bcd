require 'spec_helper'

describe 'advertising_campaigns/new.html.erb' do
  before(:each) do
    assign(:advertising_campaign, stub_model(AdvertisingCampaign,
                                             partner_id: 1,
                                             reference_code: 'MyString').as_new_record)
    partner = FactoryGirl.create(:partner)
    @partners = []
    @partners << partner
  end

  it 'renders new advertising_campaign form' do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'form', action: advertising_campaigns_path, method: 'post' do
      assert_select 'select#advertising_campaign_partner_id', name: 'advertising_campaign[partner_id]'
      assert_select 'input#advertising_campaign_reference_code', name: 'advertising_campaign[reference_code]'
    end
  end
end
