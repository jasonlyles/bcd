require 'spec_helper'

describe ResqueJobs::NewProductNotification do
  before do
    @product_type = FactoryGirl.create(:product_type)
    @category = FactoryGirl.create(:category)
    @subcategory = FactoryGirl.create(:subcategory)
    @product = FactoryGirl.create(:product)
    @image = FactoryGirl.create(:image)
  end

  describe "self.perform" do
    it "should send an email for each user who wants to get one" do
      User.should_receive(:who_get_all_emails).and_return([['user1@gmail.com','guid1','token1'],['user2@gmail.com','guid2','token2']])
      MarketingMailer.should_receive(:new_product_notification).twice.and_return(Mail::Message.new(from: 'fake', to: 'fake'))
      Mail::Message.any_instance.should_receive(:deliver).twice.and_return(true)
      ResqueJobs::NewProductNotification.perform(@product.id,'Test')
    end
  end
end

describe ResqueJobs::ProductUpdateNotification do
  before do
    @product_type = FactoryGirl.create(:product_type)
    @category = FactoryGirl.create(:category)
    @subcategory = FactoryGirl.create(:subcategory)
    @product = FactoryGirl.create(:product)
    @image = FactoryGirl.create(:image)
  end

  describe "self.perform" do
    it "should not email any users if no users have downloaded the product" do
      Download.should_receive(:update_all_users_who_have_downloaded_at_least_once).and_return([])
      ResqueJobs::ProductUpdateNotification.should_not_receive(:email_users_about_updated_instructions)
      ResqueJobs::ProductUpdateNotification.perform(@product.id,'Test')
    end

    it 'should email users if users have previously downloaded the product' do
      Download.should_receive(:update_all_users_who_have_downloaded_at_least_once).and_return([FactoryGirl.create(:user)])
      ResqueJobs::ProductUpdateNotification.should_receive(:email_users_about_updated_instructions)
      ResqueJobs::ProductUpdateNotification.perform(@product.id,'Test')
    end
  end

  describe "self.email_users_about_updated_instructions" do
    it "should send an email to each user who wants to get one" do
      users = []
      users << FactoryGirl.create(:user)
      UpdateMailer.should_receive(:updated_instructions).once.and_return(Mail::Message.new(from: 'fake', to: 'fake'))
      Mail::Message.any_instance.should_receive(:deliver).once.and_return(true)
      ResqueJobs::ProductUpdateNotification.email_users_about_updated_instructions(users, @product.id, 'Test')
    end
  end
end
