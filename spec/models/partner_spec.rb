require 'spec_helper'

describe Partner do
  describe 'destroy' do
    it "should not destroy the partner (or its advertising campaigns) if it has an advertising campaign that's been used" do
      @partner = FactoryBot.create(:partner)
      @advertising_campaign = FactoryBot.create(:advertising_campaign, partner_id: @partner.id)
      @user = FactoryBot.create(:user, referrer_code: @advertising_campaign.reference_code)

      expect { @partner.destroy }.to_not change(Partner, :count)
      expect(AdvertisingCampaign.count).to eq(1)
    end

    it "should not destroy the partner if it has an advertising campaign that's been used and another campaign that has not been used" do
      @partner = FactoryBot.create(:partner)
      @advertising_campaign1 = FactoryBot.create(:advertising_campaign, partner_id: @partner.id)
      @advertising_campaign2 = FactoryBot.create(:advertising_campaign, partner_id: @partner.id, reference_code: '987654321N')
      @user = FactoryBot.create(:user, referrer_code: @advertising_campaign1.reference_code)

      expect { @partner.destroy }.to_not change(Partner, :count)
      expect(AdvertisingCampaign.count).to eq(2)
    end

    it 'should destroy the partner and related advertising campaigns if it has an advertising campaign thats NOT been used' do
      @partner = FactoryBot.create(:partner)
      @advertising_campaign = FactoryBot.create(:advertising_campaign, partner_id: @partner.id)

      expect { @partner.destroy }.to change(Partner, :count)
      expect(AdvertisingCampaign.count).to eq(0)
    end

    it "should destroy the partner if it doesn't have an advertising campaign" do
      @partner = FactoryBot.create(:partner)

      expect { @partner.destroy }.to change(Partner, :count)
    end
  end
end
