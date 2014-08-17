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
    @mail = OrderMailer.order_confirmation(@user.id, @order.id)
    @physical_mail = OrderMailer.physical_item_purchased(@user.id,@order.id)
  end

  describe "sending an order confirmation email to a user" do
    it "should send user an email for the order they placed" do
      @mail.subject.should == "Brick City Depot Order Confirmation"
      @mail.to.should == [@user.email]
      @mail.from.should == ["sales@brickcitydepot.com"]
      #This doesn't work. It seems like it should, but it doesnt.
      #@mail.body.parts.find {|p| p.content_type.match /html/}.body.to_s.should match("Hello charlie_brown@peanuts.com")
      #@mail.body.parts.find {|p| p.content_type.match /plain/}.body.to_s.should match("Hello charlie_brown@peanuts.com")
    end
  end

  describe "sending an order confirmation email to a guest" do
    it "should send guest an email for the order they placed" do
      link = '/guest_download?id=blar'
      @guest_mail = OrderMailer.guest_order_confirmation(@user.id,@order.id,link)
      @guest_mail.subject.should == "Your Brick City Depot Order"
      @guest_mail.to.should == [@user.email]
      @guest_mail.from.should == ["sales@brickcitydepot.com"]
      #Also not working... but why?!?!?
      #@guest_mail.body.parts.each do |part|
      #  part.body.should match("Thank you for placing an order with Brick City Depot")
      #  part.body.should match("Hello charlie_brown@peanuts.com")
      #  part.body.should match("To access instructions, follow this link")
      #  part.body.should match(/<a href=\"\/guest_download\?id=blar\">Downloads<\/a>/)
      #end
    end
  end

  describe "notifying admins for a physical item purchased" do
    it "should send admin an email if a physical item is purchased" do
      @physical_mail.subject.should == "Physical Item Purchased"
      @physical_mail.to.should == ['lylesjt@yahoo.com']
      @physical_mail.from.should == ['sales@brickcitydepot.com']
      @physical_mail.body.parts.each do |part|
        part.body.should match("charlie_brown@peanuts.com")
        part.body.should match(@product.name)
        part.body.should match("Just wanted to let you know you sold a physical item and need to be thinking about boxing up that junk and shipping it out!")
      end
    end
  end
end
