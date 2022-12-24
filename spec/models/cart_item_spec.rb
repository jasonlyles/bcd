require 'spec_helper'

describe CartItem do
  before do
    @product_type = FactoryBot.create(:product_type)
    @category = FactoryBot.create(:category)
    @subcategory = FactoryBot.create(:subcategory)
    @product = FactoryBot.create(:product, price: 5.0)
  end

  describe "price" do
    it "should return price based on product price only" do
      cart = FactoryBot.create(:cart)
      cart_item = FactoryBot.create(:cart_item, quantity: 5, product: @product, cart: cart)

      expect(cart_item.price).to eq(5.0)
    end
  end

  describe "increment_quantity" do
    it "should increment the quantity when told to" do
      cart = FactoryBot.create(:cart)
      cart_item = FactoryBot.create(:cart_item, quantity: 2, cart: cart, product: @product)

      expect(lambda{cart_item.increment_quantity}).to change(cart_item, :quantity).from(2).to(3)
    end
  end
end
