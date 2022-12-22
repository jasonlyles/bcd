require 'spec_helper'

describe EmailCampaignsController do
  describe 'register_click_through_and_redirect' do
    it 'should update the click_through count for an email campaign and redirect to the email campaigns redirect link' do
      @email_campaign = FactoryGirl.create(:email_campaign, redirect_link: '/faq', click_throughs: 0)
      get :register_click_through_and_redirect, params: { guid: @email_campaign.guid }

      @email_campaign.reload
      expect(@email_campaign.click_throughs).to eq 1
      expect(response).to redirect_to '/faq'
    end

    it 'should just redirect to / since it could not find an email_campaign' do
      @email_campaign = FactoryGirl.create(:email_campaign, redirect_link: '/faq', click_throughs: 0)
      get :register_click_through_and_redirect, params: { guid: '1234' }

      @email_campaign.reload
      expect(@email_campaign.click_throughs).to eq 0
      expect(response).to redirect_to '/'
    end
  end
end
