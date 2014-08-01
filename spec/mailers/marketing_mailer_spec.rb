require "spec_helper"

describe MarketingMailer do
  before do
    @product_type = FactoryGirl.create(:product_type)
    @category = FactoryGirl.create(:category)
    @subcategory = FactoryGirl.create(:subcategory)
    @product = FactoryGirl.create(:product)
    @user = FactoryGirl.create(:user)
    @email_campaign = FactoryGirl.create(:email_campaign)
  end

  describe "sending a new product notification email to a user" do
    it "should send user an email about the product" do
      @mail = MarketingMailer.new_product_notification(@product, @product.product_type.name, @product.main_image, @user, 'Test')
      @mail.subject.should == "New Product!"
      @mail.to.should == [@user.email]
      @mail.from.should == ["no-reply@brickcitydepot.com"]
    end
  end

  describe "sending a new marketing email to a user" do
    it "should send user a sweet marketing email" do
      @mail = MarketingMailer.new_marketing_notification(@email_campaign, @user)
      expect(@mail.subject).to eq('Sweet Email')
      expect(@mail.to).to eq([@user.email])
      expect(@mail.from).to eq(["no-reply@brickcitydepot.com"])
    end
  end
end
