require "spec_helper"

describe MarketingMailer do
  before do
    @product_type = FactoryGirl.create(:product_type)
    @category = FactoryGirl.create(:category)
    @subcategory = FactoryGirl.create(:subcategory)
    @product = FactoryGirl.create(:product)
    @user = FactoryGirl.create(:user)

    @mail = MarketingMailer.new_product_notification(@product, @product.product_type.name, @product.main_image, @user, 'Test')
  end

  describe "sending a new product notification email to a user" do
    it "should send user an email about the product" do
      @mail.subject.should == "New Product!"
      @mail.to.should == [@user.email]
      @mail.from.should == ["no-reply@brickcitydepot.com"]
    end
  end
end
