require 'spec_helper'

describe ProductUpdateNotificationJob do
  before do
    @product = FactoryBot.create(:product_with_associations)
    @image = FactoryBot.create(:image)
  end

  describe 'perform' do
    it 'should not email any users if no users have downloaded the product' do
      expect(Download).to receive(:update_all_users_who_have_downloaded_at_least_once).and_return([])
      expect_any_instance_of(ProductUpdateNotificationJob).to_not receive(:email_users_about_updated_instructions)
      ProductUpdateNotificationJob.perform_sync(@product.id, 'Test')
    end

    it 'should email users if users have previously downloaded the product' do
      expect(Download).to receive(:update_all_users_who_have_downloaded_at_least_once).and_return([FactoryBot.create(:user)])
      expect_any_instance_of(ProductUpdateNotificationJob).to receive(:email_users_about_updated_instructions)
      ProductUpdateNotificationJob.perform_sync(@product.id, 'Test')
    end
  end

  describe 'email_users_about_updated_instructions' do
    it 'should send an email to each user who wants to get one' do
      expect(Download).to receive(:update_all_users_who_have_downloaded_at_least_once).and_return([FactoryBot.create(:user)])
      expect(UpdateMailer).to receive(:updated_instructions).once.and_return(Mail::Message.new(from: 'fake', to: 'fake'))
      expect_any_instance_of(Mail::Message).to receive(:deliver_later).once.and_return(true)
      ProductUpdateNotificationJob.perform_sync(@product.id, 'Test')
    end
  end
end
