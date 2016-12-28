require 'spec_helper'

describe CartItem do
  describe "price" do
    it "should return price based on product price only" do
      @product_type = FactoryGirl.create(:product_type)
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      product = FactoryGirl.create(:product, :price => 5.0)
      cart_item = FactoryGirl.create(:cart_item, :quantity => 5, :product_id => product.id)

      expect(cart_item.price).to eq(5.0)
    end
  end

  describe "increment_quantity" do
    it "should increment the quantity when told to" do
      cart_item = FactoryGirl.create(:cart_item, :quantity => 2)

      expect(lambda{cart_item.increment_quantity}).to change(cart_item, :quantity).from(2).to(3)
    end
  end
end
