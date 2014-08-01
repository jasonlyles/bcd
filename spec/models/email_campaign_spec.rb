require 'spec_helper'

describe EmailCampaign do
  describe 'generate_guid' do
    it 'should assign a random 40 character string to guid before an email campaign is created' do
      @email_campaign = FactoryGirl.create(:email_campaign, guid: nil)

      expect(@email_campaign.guid).to_not be_nil
      expect(@email_campaign.guid.length).to eq 40
    end
  end

  describe 'destroy' do
    it 'should not destroy if emails_sent is greater than 0' do
      @email_campaign = FactoryGirl.create(:email_campaign, emails_sent: 1)

      expect{@email_campaign.destroy}.to_not change{EmailCampaign.count}
    end

    it 'should destroy if emails_sent is 0' do
      @email_campaign = FactoryGirl.create(:email_campaign, emails_sent: 0)

      expect{@email_campaign.destroy}.to change{EmailCampaign.count}.by(-1)
    end
  end
end
