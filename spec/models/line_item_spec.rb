require 'spec_helper'

describe LineItem do
  describe "self.from_cart_item" do
    it "should create a line_item from a cart_item" do
      product = FactoryBot.create(:product_with_associations)
      cart = FactoryBot.create(:cart)
      cart_item = FactoryBot.create(:cart_item, product: product, cart: cart)
      line_item = LineItem.from_cart_item(cart_item)

      expect(line_item.product_id).to eq(product.id)
    end
  end
end
