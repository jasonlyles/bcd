require "spec_helper"

describe Admin::ImagesController do
  describe "routing" do

    it "recognizes and generates #index" do
      expect({ :get => "admin/images" }).to route_to(:controller => "admin/images", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "admin/images/new" }).to route_to(:controller => "admin/images", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "admin/images/1" }).to route_to(:controller => "admin/images", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "admin/images/1/edit" }).to route_to(:controller => "admin/images", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "admin/images" }).to route_to(:controller => "admin/images", :action => "create")
    end

    it "recognizes and generates #update" do
      expect({ :put => "admin/images/1" }).to route_to(:controller => "admin/images", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "admin/images/1" }).to route_to(:controller => "admin/images", :action => "destroy", :id => "1")
    end

  end
end
