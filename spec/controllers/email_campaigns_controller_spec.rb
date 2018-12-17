require 'spec_helper'

describe EmailCampaignsController do
  before do
    @radmin ||= FactoryGirl.create(:radmin)
  end

  before(:each) do |example|
    sign_in @radmin unless example.metadata[:skip_before]
  end

  # This should return the minimal set of attributes required to create a valid
  # EmailCampaign. As you add validations to EmailCampaign, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
      description: 'Description 1',
      subject: 'Subject 1'
    }
  end

  let(:invalid_attributes) do
    {
      description: nil,
      subject: nil
    }
  end

  describe 'register_click_through_and_redirect' do
    it 'should update the click_through count for an email campaign and redirect to the email campaigns redirect link' do
      @email_campaign = FactoryGirl.create(:email_campaign, redirect_link: '/faq', click_throughs: 0)
      get :register_click_through_and_redirect, guid: @email_campaign.guid

      @email_campaign.reload
      expect(@email_campaign.click_throughs).to eq 1
      expect(response).to redirect_to '/faq'
    end

    it 'should just redirect to / since it could not find an email_campaign' do
      @email_campaign = FactoryGirl.create(:email_campaign, redirect_link: '/faq', click_throughs: 0)
      get :register_click_through_and_redirect, guid: '1234'

      @email_campaign.reload
      expect(@email_campaign.click_throughs).to eq 0
      expect(response).to redirect_to '/'
    end
  end

  describe 'send_marketing_emails' do
    it 'should queue up a resque job if all is well' do
      @email_campaign = FactoryGirl.create(:email_campaign)
      expect(NewMarketingNotificationJob).to receive(:create).and_return('1234')
      patch :send_marketing_emails, email_campaign: { 'id' => 1 }

      expect(flash[:notice]).to eq('Sending marketing emails')
      expect(response).to redirect_to '/email_campaigns'
    end

    it 'should redirect to show and flash a message if queue could not be created' do
      @email_campaign = FactoryGirl.create(:email_campaign)
      expect(NewMarketingNotificationJob).to receive(:create).and_return(nil)
      patch :send_marketing_emails, email_campaign: { 'id' => 1 }

      expect(flash[:alert]).to eq("Couldn't queue email jobs. Check out /jobs and see what's wrong")
      expect(response).to redirect_to "/email_campaigns/#{@email_campaign.id}"
    end
  end

  describe 'send_marketing_email_preview' do
    it 'should queue up a resque job if all is well' do
      @email_campaign = FactoryGirl.create(:email_campaign)
      expect(NewMarketingNotificationJob).to receive(:create).and_return('1234')
      patch :send_marketing_email_preview, email_campaign: { 'id' => 1 }

      expect(flash[:notice]).to eq('Sending marketing email preview')
      expect(response).to redirect_to "/email_campaigns/#{@email_campaign.id}"
    end

    it 'should redirect to show and flash a message if queue could not be created' do
      @email_campaign = FactoryGirl.create(:email_campaign)
      expect(NewMarketingNotificationJob).to receive(:create).and_return(nil)
      patch :send_marketing_emails, email_campaign: { 'id' => 1 }

      expect(flash[:alert]).to eq("Couldn't queue email jobs. Check out /jobs and see what's wrong")
      expect(response).to redirect_to "/email_campaigns/#{@email_campaign.id}"
    end
  end
end
