require "spec_helper"

describe ProductsController do
  describe "routing" do

    it "recognizes and generates #index" do
      expect({ :get => "/products" }).to route_to(:controller => "products", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "/products/new" }).to route_to(:controller => "products", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "/products/1" }).to route_to(:controller => "products", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "/products/1/edit" }).to route_to(:controller => "products", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "/products" }).to route_to(:controller => "products", :action => "create")
    end

    it "recognizes and generates #update" do
      expect({ :put => "/products/1" }).to route_to(:controller => "products", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "/products/1" }).to route_to(:controller => "products", :action => "destroy", :id => "1")
    end

  end
end
