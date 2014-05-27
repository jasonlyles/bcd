require 'spec_helper'

describe Partner do
  describe "destroy" do   
    it "should not destroy the partner (or its advertising campaigns) if it has an advertising campaign that's been used" do
      @partner = FactoryGirl.create(:partner)
      @advertising_campaign = FactoryGirl.create(:advertising_campaign, :partner_id => @partner.id)
      @user = FactoryGirl.create(:user, :referrer_code => @advertising_campaign.reference_code)

      lambda { @partner.destroy }.should_not change(Partner, :count)
      AdvertisingCampaign.count.should == 1
    end

    it "should not destroy the partner if it has an advertising campaign that's been used and another campaign that has not been used" do
      @partner = FactoryGirl.create(:partner)
      @advertising_campaign1 = FactoryGirl.create(:advertising_campaign, :partner_id => @partner.id)
      @advertising_campaign2 = FactoryGirl.create(:advertising_campaign, :partner_id => @partner.id, :reference_code => '987654321N')
      @user = FactoryGirl.create(:user, :referrer_code => @advertising_campaign1.reference_code)

      lambda { @partner.destroy }.should_not change(Partner, :count)
      AdvertisingCampaign.count.should == 2
    end
    
    it "should destroy the partner and related advertising campaigns if it has an advertising campaign thats NOT been used" do
      @partner = FactoryGirl.create(:partner)
      @advertising_campaign = FactoryGirl.create(:advertising_campaign, :partner_id => @partner.id)

      lambda { @partner.destroy }.should change(Partner, :count)
      AdvertisingCampaign.count.should == 0
    end
    
    it "should destroy the partner if it doesn't have an advertising campaign" do
      @partner = FactoryGirl.create(:partner)

      lambda { @partner.destroy }.should change(Partner, :count)
    end
  end
end
