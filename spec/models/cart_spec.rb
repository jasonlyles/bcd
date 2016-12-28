require 'spec_helper'

describe Cart do
  before do
    @product_type = FactoryGirl.create(:product_type)
    @category = FactoryGirl.create(:category)
    @subcategory = FactoryGirl.create(:subcategory)
  end

  describe "users_most_recent_cart" do
    it "should get only the users most recent cart" do
      @user = FactoryGirl.create(:user)
      @cart = FactoryGirl.create(:cart, :user_id => @user.id, :created_at => 5.days.ago)
      @cart2 = FactoryGirl.create(:cart, :user_id => @user.id, :created_at => 2.days.ago)
      cart = Cart.users_most_recent_cart(@user.id)

      expect(cart).to eq(@cart2)
    end
  end

  describe "add_product" do
    it "should add product to the cart" do
      @cart = Cart.new

      expect(lambda{ @cart.add_product(FactoryGirl.create(:product))}).to change(CartItem, :count).from(0).to(1)
    end

    it "should NOT increment the quantity of an item if it is already in the cart and the item is instructions" do
      @cart = Cart.new
      @product = FactoryGirl.create(:product)
      @cart.add_product(@product)
      @cart.add_product(@product)
      @cart = Cart.find 1

      expect(@cart.cart_items[0].quantity).to eq(1)
    end

    it "should increment the quantity of an item if it is already in the cart and the item is NOT instructions" do
      @product_type = FactoryGirl.create(:product_type, :name => 'Books', :digital_product => false)
      @cart = Cart.new
      @product = FactoryGirl.create(:product, :product_type_id => @product_type.id)
      @cart.add_product(@product)
      @cart.add_product(@product)
      @cart = Cart.find 1

      expect(@cart.cart_items[0].quantity).to eq(2)
    end
  end

  describe "total_price" do
    it "should return a total price" do
      @cart = Cart.new
      @cart.add_product(FactoryGirl.create(:product, :price => 4.0))
      @cart.add_product(FactoryGirl.create(:product, :price => 5.0, :product_code => "XX111", :name => "Awesomeness"))

      expect(@cart.total_price).to eq(9.0)
    end
  end

  describe "total_quantity" do
    it "should return a total quantity" do
      @cart = Cart.new
      @cart.add_product(FactoryGirl.create(:product))
      @cart.add_product(FactoryGirl.create(:product, :product_code => "XX111", :name => "Awesomeness"))

      expect(@cart.total_quantity).to eq(2)
    end
  end

  describe "remove_product" do
    it "should remove product from the cart" do
      @cart = Cart.new
      @cart.add_product(FactoryGirl.create(:product))
      @cart.add_product(FactoryGirl.create(:product, :product_code => "XX111", :name => "Awesomeness"))
      @cart_item = CartItem.find 1

      expect(lambda{ @cart.remove_product(@cart_item.id)}).to change(CartItem, :count).from(2).to(1)
    end
  end

  describe "empty?" do
    it "should tell you if the cart is empty" do
      @cart = Cart.new
      expect(@cart.empty?).to eq(true)
    end
  end

  it "should delete related cart_items when it gets deleted" do
    @cart = FactoryGirl.create(:cart_with_cart_items)

    expect(lambda{@cart.destroy}).to change(CartItem, :count).from(1).to(0)
  end

  describe "update_product_quantity" do
    it "should remove item from cart if the quantity is brought down to 0" do
      @cart = FactoryGirl.create(:cart_with_cart_items_with_multiple_quantity)

      expect(lambda{@cart.update_product_quantity(1,0)}).to change(CartItem, :count).from(1).to(0)
    end

    it "should update the cart_item and update the quantity if quantity is > 0" do
      @cart = FactoryGirl.create(:cart_with_cart_items_with_multiple_quantity)

      expect(@cart.cart_items[0].quantity).to eq(2)
      expect(lambda{@cart.update_product_quantity(1,3)}).to_not change(CartItem, :count)
      @cart.reload
      expect(@cart.cart_items[0].quantity).to eq(3)
    end
  end

  describe "has_digital_item?" do
    it 'should return true if one of the items in the cart is a digital item' do
      @cart = FactoryGirl.create(:cart)
      product = FactoryGirl.create(:product)
      @cart_item = FactoryGirl.create(:cart_item)
      expect(@cart.has_digital_item?).to eq(true)
    end

    it 'should return false if no items in the cart are digital items' do
      @cart = FactoryGirl.create(:cart)
      expect(@cart.has_digital_item?).to eq(false)
    end
  end

  describe "has_physical_item?" do
    it 'should return true if one of the items in the cart is a physical item' do
      @product_type2 = FactoryGirl.create(:product_type, :name => 'Models', :digital_product => false)
      @cart = FactoryGirl.create(:cart)
      product1 = FactoryGirl.create(:product, :product_code => 'CV900')
      product2 = FactoryGirl.create(:product, :product_type_id => @product_type2.id, :product_code => 'CV900M', :name => 'Winter Village Road Salt Dome')
      @cart_item = FactoryGirl.create(:cart_item, :product_id => product2.id)
      expect(@cart.has_physical_item?).to eq(true)
    end

    it 'should return false if no items in the cart are physical items' do
      product = FactoryGirl.create(:product)
      @cart = FactoryGirl.create(:cart_with_cart_items)
      expect(@cart.has_physical_item?).to eq(false)
    end
  end
end
