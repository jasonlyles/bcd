require "spec_helper"

describe Admin::PartnersController do
  describe "routing" do

    it "recognizes and generates #index" do
      expect({ :get => "admin/partners" }).to route_to(:controller => "admin/partners", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "admin/partners/new" }).to route_to(:controller => "admin/partners", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "admin/partners/1" }).to route_to(:controller => "admin/partners", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "admin/partners/1/edit" }).to route_to(:controller => "admin/partners", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "admin/partners" }).to route_to(:controller => "admin/partners", :action => "create")
    end

    it "recognizes and generates #update" do
      expect({ :put => "admin/partners/1" }).to route_to(:controller => "admin/partners", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "admin/partners/1" }).to route_to(:controller => "admin/partners", :action => "destroy", :id => "1")
    end

  end
end
