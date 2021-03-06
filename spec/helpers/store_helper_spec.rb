require 'spec_helper'

describe StoreHelper do
  before do
    @product_type = FactoryGirl.create(:product_type)
  end
  describe "errant_cart_item?" do
    it "return true if the item passed in is errant" do
      @user = FactoryGirl.create(:user)
      sign_in @user
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product, :category_id => @category.id, :subcategory_id => @subcategory.id)
      session[:errant_cart_items] = [['blar',@product.product_code]]

      expect(helper.errant_cart_item?(@product.product_code)).to be_truthy
    end

    it "return false if the item passed in is not errant" do
      @category = FactoryGirl.create(:category)
      @subcategory = FactoryGirl.create(:subcategory)
      @product = FactoryGirl.create(:product, :category_id => @category.id, :subcategory_id => @subcategory.id)
      session[:errant_cart_items] = [['blar',@product.product_code]]

      expect(helper.errant_cart_item?('squatch')).to be_falsey
    end
  end
end
