require 'spec_helper'

describe NewMarketingNotificationJob do
  before do
    @product_type = FactoryGirl.create(:product_type)
    @category = FactoryGirl.create(:category)
    @subcategory = FactoryGirl.create(:subcategory)
    @product = FactoryGirl.create(:product)
    @image = FactoryGirl.create(:image)
    @email_campaign = FactoryGirl.create(:email_campaign)
  end

  describe "perform" do
    it "should send a marketing email to each user who wants to get one" do
      expect(User).to receive(:who_get_all_emails).and_return([['user1@gmail.com','guid1','token1'],['user2@gmail.com','guid2','token2']])
      expect(MarketingMailer).to receive(:new_marketing_notification).twice.and_return(Mail::Message.new(from: 'fake', to: 'fake'))
      expect_any_instance_of(Mail::Message).to receive(:deliver).twice.and_return(true)
      NewMarketingNotificationJob.new('',{'email_campaign' => 1}).perform
    end

    it "should update the email_campaign records emails_sent column" do
      expect(User).to receive(:who_get_all_emails).and_return([['user1@gmail.com','guid1','token1'],['user2@gmail.com','guid2','token2']])
      expect(MarketingMailer).to receive(:new_marketing_notification).twice.and_return(Mail::Message.new(from: 'fake', to: 'fake'))
      expect_any_instance_of(Mail::Message).to receive(:deliver).twice.and_return(true)
      NewMarketingNotificationJob.new('',{'email_campaign' => 1}).perform

      @email_campaign.reload
      expect(@email_campaign.emails_sent).to eq 2
    end
  end
end