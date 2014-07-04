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