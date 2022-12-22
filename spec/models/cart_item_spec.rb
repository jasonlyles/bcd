require 'spec_helper'

describe CartItem do
  before do
    @product_type = FactoryGirl.create(:product_type)
    @category = FactoryGirl.create(:category)
    @subcategory = FactoryGirl.create(:subcategory)
    @product = FactoryGirl.create(:product, price: 5.0)
  end

  describe "price" do
    it "should return price based on product price only" do
      cart = FactoryGirl.create(:cart)
      cart_item = FactoryGirl.create(:cart_item, quantity: 5, product: @product, cart: cart)

      expect(cart_item.price).to eq(5.0)
    end
  end

  describe "increment_quantity" do
    it "should increment the quantity when told to" do
      cart = FactoryGirl.create(:cart)
      cart_item = FactoryGirl.create(:cart_item, quantity: 2, cart: cart, product: @product)

      expect(lambda{cart_item.increment_quantity}).to change(cart_item, :quantity).from(2).to(3)
    end
  end
end
