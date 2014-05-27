require 'spec_helper'

describe LineItem do
  describe "self.from_cart_item" do
    it "should create a line_item from a cart_item" do
      @product_type = FactoryGirl.create(:product_type)
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product)
      @cart_item = FactoryGirl.create(:cart_item, :product => @product)
      @line_item = LineItem.from_cart_item(@cart_item)

      @line_item.product_id.should == @product.id
    end
  end
end
