require "spec_helper"

describe Admin::ProductsController do
  describe "routing" do

    it "recognizes and generates #index" do
      expect({ :get => "admin/products" }).to route_to(:controller => "admin/products", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "admin/products/new" }).to route_to(:controller => "admin/products", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "admin/products/1" }).to route_to(:controller => "admin/products", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "admin/products/1/edit" }).to route_to(:controller => "admin/products", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "admin/products" }).to route_to(:controller => "admin/products", :action => "create")
    end

    it "recognizes and generates #update" do
      expect({ :put => "admin/products/1" }).to route_to(:controller => "admin/products", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "admin/products/1" }).to route_to(:controller => "admin/products", :action => "destroy", :id => "1")
    end

  end
end
