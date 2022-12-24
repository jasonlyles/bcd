require 'spec_helper'

describe NewMarketingNotificationJob do
  before do
    @product = FactoryBot.create(:product_with_associations)
    @image = FactoryBot.create(:image)
    @email_campaign = FactoryBot.create(:email_campaign)
  end

  describe "perform" do
    context 'Live emails to be sent' do
      it "should send a marketing email to each user who wants to get one" do
        expect(User).to receive(:who_get_all_emails).and_return([['user1@gmail.com','guid1','token1'],['user2@gmail.com','guid2','token2']])
        expect(MarketingMailer).to receive(:new_marketing_notification).twice.and_return(Mail::Message.new(from: 'fake', to: 'fake'))
        expect_any_instance_of(Mail::Message).to receive(:deliver).twice.and_return(true)
        NewMarketingNotificationJob.perform('email_campaign' => 1)
      end

      it "should update the email_campaign records emails_sent column" do
        expect(User).to receive(:who_get_all_emails).and_return([['user1@gmail.com','guid1','token1'],['user2@gmail.com','guid2','token2']])
        expect(MarketingMailer).to receive(:new_marketing_notification).twice.and_return(Mail::Message.new(from: 'fake', to: 'fake'))
        expect_any_instance_of(Mail::Message).to receive(:deliver).twice.and_return(true)
        NewMarketingNotificationJob.perform('email_campaign' => 1)

        @email_campaign.reload
        expect(@email_campaign.emails_sent).to eq 2
      end
    end

    context 'Preview emails are to be sent only to admins' do
      it 'should send emails only to admins if the preview_only option is set' do
        expect(Radmin).to receive(:pluck).and_return([['user1@gmail.com','guid1','token1'],['user2@gmail.com','guid2','token2']])
        expect(MarketingMailer).to receive(:new_marketing_notification).twice.and_return(Mail::Message.new(from: 'fake', to: 'fake'))
        expect_any_instance_of(Mail::Message).to receive(:deliver).twice.and_return(true)
        NewMarketingNotificationJob.perform('email_campaign' => 1, 'preview_only' => true)
      end

      it 'should not update the email campaign records emails_sent column' do
        expect(Radmin).to receive(:pluck).and_return([['user1@gmail.com','guid1','token1'],['user2@gmail.com','guid2','token2']])
        expect(MarketingMailer).to receive(:new_marketing_notification).twice.and_return(Mail::Message.new(from: 'fake', to: 'fake'))
        expect_any_instance_of(Mail::Message).to receive(:deliver).twice.and_return(true)
        NewMarketingNotificationJob.perform('email_campaign' => 1, 'preview_only' => true)

        @email_campaign.reload
        expect(@email_campaign.emails_sent).to eq 0
      end
    end
  end
end
