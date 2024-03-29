require "spec_helper"

describe Admin::CategoriesController do
  describe "routing" do

    it "recognizes and generates #index" do
      expect({ :get => "admin/categories" }).to route_to(:controller => "admin/categories", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "admin/categories/new" }).to route_to(:controller => "admin/categories", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "admin/categories/1" }).to route_to(:controller => "admin/categories", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "admin/categories/1/edit" }).to route_to(:controller => "admin/categories", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "admin/categories" }).to route_to(:controller => "admin/categories", :action => "create")
    end

    it "recognizes and generates #update" do
      expect({ :put => "admin/categories/1" }).to route_to(:controller => "admin/categories", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "admin/categories/1" }).to route_to(:controller => "admin/categories", :action => "destroy", :id => "1")
    end

  end
end
