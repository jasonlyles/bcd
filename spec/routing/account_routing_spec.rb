require "spec_helper"

describe AccountController do
  describe "routing" do
    it "recognizes and generates #order" do
      {:get => "account/order/1"}.should route_to(:controller => "account", :action => "order", :request_id => '1')
    end

    it "recognizes and generates #order_history" do
      {:get => "account/order_history"}.should route_to(:controller => "account", :action => "order_history")
    end

    it "recognizes and generates #index" do
      {:get => "account"}.should route_to(:controller => "account", :action => "index")
    end
  end
end