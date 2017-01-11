require "spec_helper"

describe CategoriesController do
  describe "routing" do

    it "recognizes and generates #index" do
      expect({ :get => "/categories" }).to route_to(:controller => "categories", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "/categories/new" }).to route_to(:controller => "categories", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "/categories/1" }).to route_to(:controller => "categories", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "/categories/1/edit" }).to route_to(:controller => "categories", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "/categories" }).to route_to(:controller => "categories", :action => "create")
    end

    it "recognizes and generates #update" do
      expect({ :put => "/categories/1" }).to route_to(:controller => "categories", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "/categories/1" }).to route_to(:controller => "categories", :action => "destroy", :id => "1")
    end

  end
end
