require "spec_helper"

describe StoreController do
  describe "routing" do
    it "recognizes and generates #cart" do
      {:get => "/cart"}.should route_to(:controller => "store", :action => "cart")
    end

    it "recognizes and generates #checkout" do
      {:get => "/checkout"}.should route_to(:controller => "store", :action => "checkout")
    end

    it "recognizes and generates #index" do
      {:get => "/store"}.should route_to(:controller => "store", :action => "index")
    end

    it "recognizes and generates #categories" do
      {:get => "/store/products/Instructions/City"}.should route_to(:controller => "store", :action => "categories", :product_type_name => 'Instructions', :category_name => 'City')
    end

    it "recognizes and generates #add_to_cart" do
      {:post => "/add_to_cart/CB001"}.should route_to(:controller => "store", :action => "add_to_cart", :product_code => 'CB001')
    end

    it "recognizes and generates #remove_item_from_cart" do
      {:post => "/remove_item_from_cart/1"}.should route_to(:controller => "store", :action => "remove_item_from_cart", :id => '1')
    end

    it "recognizes and generates #submit_order" do
      {:post => "/submit_order"}.should route_to(:controller => "store", :action => "submit_order")
    end

    it "recognizes and generates #empty_cart" do
      {:post => "empty_cart"}.should route_to(:controller => "store", :action => "empty_cart")
    end

    it "recognizes and generates #product_details" do
      {:get => "/CB001/Fascist%20Popsicle%20Stand"}.should route_to(:controller => "store", :action => "product_details", :product_code => 'CB001', :product_name => 'Fascist Popsicle Stand')
    end

    it "recognizes and generates #listener" do
      {:post => "/listener"}.should route_to(:controller => "store", :action => "listener")
    end
  end
end