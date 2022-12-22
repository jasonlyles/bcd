require "spec_helper"

describe MarketingMailer do
  before do
    @product = FactoryGirl.create(:product_with_associations)
    @user = FactoryGirl.create(:user)
    @email_campaign = FactoryGirl.create(:email_campaign)
  end

  describe "sending a new product notification email to a user" do
    it "should send user an email about the product" do
      @mail = MarketingMailer.new_product_notification(@product, @product.product_type.name, @product.main_image, @user, 'Test')
      expect(@mail.subject).to eq("New Product!")
      expect(@mail.to).to eq([@user.email])
      expect(@mail.from).to eq(["sales@brickcitydepot.com"])
    end
  end

  describe "sending a new marketing email to a user" do
    it "should send user a sweet marketing email" do
      @mail = MarketingMailer.new_marketing_notification(@email_campaign, @user)
      expect(@mail.subject).to eq('Sweet Email')
      expect(@mail.to).to eq([@user.email])
      expect(@mail.from).to eq(["sales@brickcitydepot.com"])
    end
  end
end
