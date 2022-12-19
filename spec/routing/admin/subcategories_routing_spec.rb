require "spec_helper"

describe Admin::SubcategoriesController do
  describe "routing" do

    it "recognizes and generates #index" do
      expect({ :get => "admin/subcategories" }).to route_to(:controller => "admin/subcategories", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "admin/subcategories/new" }).to route_to(:controller => "admin/subcategories", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "admin/subcategories/1" }).to route_to(:controller => "admin/subcategories", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "admin/subcategories/1/edit" }).to route_to(:controller => "admin/subcategories", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "admin/subcategories" }).to route_to(:controller => "admin/subcategories", :action => "create")
    end

    it "recognizes and generates #update" do
      expect({ :put => "admin/subcategories/1" }).to route_to(:controller => "admin/subcategories", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "admin/subcategories/1" }).to route_to(:controller => "admin/subcategories", :action => "destroy", :id => "1")
    end

    it "recognizes and generates #model_code" do
      expect({:get => "admin/subcategories/1/model_code"}).to route_to(:controller => "admin/subcategories", :action => "model_code", :id => '1')
    end
  end
end
