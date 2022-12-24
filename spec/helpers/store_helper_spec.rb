require 'spec_helper'

describe StoreHelper do
  before do
    @product_type = FactoryBot.create(:product_type)
  end
  describe "errant_cart_item?" do
    it "return true if the item passed in is errant" do
      @user = FactoryBot.create(:user)
      sign_in @user
      @category = FactoryBot.create(:category)
      @subcategory = FactoryBot.create(:subcategory)
      @product = FactoryBot.create(:product, :category_id => @category.id, :subcategory_id => @subcategory.id)
      session[:errant_cart_items] = [['blar',@product.product_code]]

      expect(helper.errant_cart_item?(@product.product_code)).to be_truthy
    end

    it "return false if the item passed in is not errant" do
      @category = FactoryBot.create(:category)
      @subcategory = FactoryBot.create(:subcategory)
      @product = FactoryBot.create(:product, :category_id => @category.id, :subcategory_id => @subcategory.id)
      session[:errant_cart_items] = [['blar',@product.product_code]]

      expect(helper.errant_cart_item?('squatch')).to be_falsey
    end
  end
end
