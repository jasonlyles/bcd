require "spec_helper"

describe SubcategoriesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/subcategories" }.should route_to(:controller => "subcategories", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/subcategories/new" }.should route_to(:controller => "subcategories", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/subcategories/1" }.should route_to(:controller => "subcategories", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/subcategories/1/edit" }.should route_to(:controller => "subcategories", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/subcategories" }.should route_to(:controller => "subcategories", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/subcategories/1" }.should route_to(:controller => "subcategories", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/subcategories/1" }.should route_to(:controller => "subcategories", :action => "destroy", :id => "1")
    end

    it "recognizes and generates #model_code" do
      {:get => "/subcategories/1/model_code"}.should route_to(:controller => "subcategories", :action => "model_code", :id => '1')
    end
  end
end
