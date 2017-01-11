require "spec_helper"

describe SubcategoriesController do
  describe "routing" do

    it "recognizes and generates #index" do
      expect({ :get => "/subcategories" }).to route_to(:controller => "subcategories", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "/subcategories/new" }).to route_to(:controller => "subcategories", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "/subcategories/1" }).to route_to(:controller => "subcategories", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "/subcategories/1/edit" }).to route_to(:controller => "subcategories", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "/subcategories" }).to route_to(:controller => "subcategories", :action => "create")
    end

    it "recognizes and generates #update" do
      expect({ :put => "/subcategories/1" }).to route_to(:controller => "subcategories", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "/subcategories/1" }).to route_to(:controller => "subcategories", :action => "destroy", :id => "1")
    end

    it "recognizes and generates #model_code" do
      expect({:get => "/subcategories/1/model_code"}).to route_to(:controller => "subcategories", :action => "model_code", :id => '1')
    end
  end
end
