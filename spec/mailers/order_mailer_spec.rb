require "spec_helper"

describe OrderMailer do
  before do
    @product_type1 = FactoryGirl.create(:product_type)
    @product_type2 = FactoryGirl.create(:product_type, :name => 'Models', :digital_product => false)
    @category = FactoryGirl.create(:category)
    @subcategory = FactoryGirl.create(:subcategory)
    FactoryGirl.create(:product, :product_type_id => @product_type1.id, :category_id => @category.id, :subcategory_id => @subcategory.id, :product_code => 'XX111', :name => 'fake product')
    @product = FactoryGirl.create(:product, :product_type_id => @product_type2.id, :category_id => @category.id, :subcategory_id => @subcategory.id, :product_code => 'XX111M')
    @user = FactoryGirl.create(:user)
    @order = FactoryGirl.create(:order)
    @line_item = FactoryGirl.create(:line_item, :product_id => @product.id, :order_id => @order.id)
    @mail = OrderMailer.order_confirmation(@user, @order)
    @physical_mail = OrderMailer.physical_item_purchased(@user,@order)
  end

  describe "sending an order confirmation email to a user" do
    it "should send user an email for the order they placed" do
      @mail.subject.should == "Order Confirmation"
      @mail.to.should == [@user.email]
      @mail.from.should == ["no-reply@brickcitydepot.com"]
      @mail.body.should match("Thank you for placing an order with Brick City Depot")
      @mail.body.should match("Hello charlie_brown@peanuts.com")
    end
  end

  describe "sending an order confirmation email to a guest" do
    it "should send guest an email for the order they placed" do
      link = '/guest_download?id=blar'
      @guest_mail = OrderMailer.guest_order_confirmation(@user,@order,link)
      @guest_mail.subject.should == "Order Confirmation"
      @guest_mail.to.should == [@user.email]
      @guest_mail.from.should == ["no-reply@brickcitydepot.com"]
      @guest_mail.body.should match("Thank you for placing an order with Brick City Depot")
      @guest_mail.body.should match("Hello charlie_brown@peanuts.com")
      @guest_mail.body.should match("To access instructions, follow this link")
      @guest_mail.body.should match(/<a href=\"\/guest_download\?id=blar\">Downloads<\/a>/)
    end
  end

  describe "notifying admins for a physical item purchased" do
    it "should send admin an email if a physical item is purchased" do
      @physical_mail.subject.should == "Physical Item Purchased"
      @physical_mail.to.should == ['lylesjt@yahoo.com']
      @physical_mail.from.should == ['no-reply@brickcitydepot.com']
      @physical_mail.body.should match("charlie_brown@peanuts.com")
      @physical_mail.body.should match(@product.name)
      @physical_mail.body.should match("Just wanted to let you know you sold a physical item and need to be thinking about boxing up that junk and shipping it out!")
    end
  end
end
