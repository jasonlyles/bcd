require 'spec_helper'

describe NewProductNotificationJob do
  before do
    @product_type = FactoryGirl.create(:product_type)
    @category = FactoryGirl.create(:category)
    @subcategory = FactoryGirl.create(:subcategory)
    @product = FactoryGirl.create(:product)
    @image = FactoryGirl.create(:image)
  end

  describe "perform" do
    it "should send an email for each user who wants to get one" do
      expect(User).to receive(:who_get_all_emails).and_return([['user1@gmail.com','guid1','token1'],['user2@gmail.com','guid2','token2']])
      expect(MarketingMailer).to receive(:new_product_notification).twice.and_return(Mail::Message.new(from: 'fake', to: 'fake'))
      expect_any_instance_of(Mail::Message).to receive(:deliver).twice.and_return(true)
      NewProductNotificationJob.new('1234', {'product_id' => @product.id, 'message' => 'Test'}).perform
    end
  end
end