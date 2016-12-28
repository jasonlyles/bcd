require "spec_helper"

describe AccountController do
  describe "routing" do
    it "recognizes and generates #order" do
      expect({:get => "account/order/1"}).to route_to(:controller => "account", :action => "order", :request_id => '1')
    end

    it "recognizes and generates #order_history" do
      expect({:get => "account/order_history"}).to route_to(:controller => "account", :action => "order_history")
    end

    it "recognizes and generates #index" do
      expect({:get => "account"}).to route_to(:controller => "account", :action => "index")
    end
  end
end