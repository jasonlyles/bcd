require "spec_helper"

describe StoreController do
  describe "routing" do
    it "recognizes and generates #cart" do
      expect({:get => "/cart"}).to route_to(:controller => "store", :action => "cart")
    end

    it "recognizes and generates #checkout" do
      expect({:get => "/checkout"}).to route_to(:controller => "store", :action => "checkout")
    end

    it "recognizes and generates #index" do
      expect({:get => "/store"}).to route_to(:controller => "store", :action => "index")
    end

    it "recognizes and generates #categories" do
      expect({:get => "/store/products/Instructions/City"}).to route_to(:controller => "store", :action => "categories", :product_type_name => 'Instructions', :category_name => 'City')
    end

    it "recognizes and generates #add_to_cart" do
      expect({:post => "/add_to_cart/CB001"}).to route_to(:controller => "store", :action => "add_to_cart", :product_code => 'CB001')
    end

    it "recognizes and generates #remove_item_from_cart" do
      expect({:post => "/remove_item_from_cart/1"}).to route_to(:controller => "store", :action => "remove_item_from_cart", :id => '1')
    end

    it "recognizes and generates #submit_order" do
      expect({:post => "/submit_order"}).to route_to(:controller => "store", :action => "submit_order")
    end

    it "recognizes and generates #empty_cart" do
      expect({:post => "empty_cart"}).to route_to(:controller => "store", :action => "empty_cart")
    end

    it "recognizes and generates #product_details" do
      expect({:get => "/CB001/Fascist%20Popsicle%20Stand"}).to route_to(:controller => "store", :action => "product_details", :product_code => 'CB001', :product_name => 'Fascist Popsicle Stand')
    end

  end
end