require 'spec_helper'

describe NewProductNotificationJob do
  before do
    @product = FactoryBot.create(:product_with_associations)
    @image = FactoryBot.create(:image)
  end

  describe 'perform' do
    it 'should send an email for each user who wants to get one' do
      expect(User).to receive(:who_get_all_emails).and_return([['user1@gmail.com', 'guid1', 'token1'], ['user2@gmail.com', 'guid2', 'token2']])
      expect(MarketingMailer).to receive(:new_product_notification).twice.and_return(Mail::Message.new(from: 'fake', to: 'fake'))
      expect_any_instance_of(Mail::Message).to receive(:deliver_later).twice.and_return(true)
      NewProductNotificationJob.perform_sync(@product.id, 'Test')
    end
  end
end
