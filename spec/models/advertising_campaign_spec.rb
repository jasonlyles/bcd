require 'spec_helper'

describe AdvertisingCampaign do
  before do
    @partner = FactoryGirl.create(:partner)
  end

  describe "destroy" do
    it "should switch the campaign_live flag to false if there are users who have signed up via that campaign" do
      @advertising_campaign = FactoryGirl.create(:advertising_campaign)
      @user = FactoryGirl.create(:user, referrer_code: @advertising_campaign.reference_code)

      expect(lambda { @advertising_campaign.destroy }).to change(@advertising_campaign, :campaign_live).from(true).to(false)
    end

    it "should not destroy the advertising campaign if there are users who have signed up via that campaign" do
      @advertising_campaign = FactoryGirl.create(:advertising_campaign)
      @user = FactoryGirl.create(:user, referrer_code: @advertising_campaign.reference_code)

      expect(lambda { @advertising_campaign.destroy }).to_not change(AdvertisingCampaign, :count)
    end

    it "should delete the advertising_campaign if there are no users who signed up via that advertising_campaign" do
      @advertising_campaign = FactoryGirl.create(:advertising_campaign)

      expect(lambda { @advertising_campaign.destroy }).to change(AdvertisingCampaign, :count)
    end
  end
end
