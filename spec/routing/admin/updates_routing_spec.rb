require "spec_helper"

describe Admin::UpdatesController do
  describe "routing" do

    it "recognizes and generates #index" do
      expect({ :get => "admin/updates" }).to route_to(:controller => "admin/updates", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "admin/updates/new" }).to route_to(:controller => "admin/updates", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "admin/updates/1" }).to route_to(:controller => "admin/updates", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "admin/updates/1/edit" }).to route_to(:controller => "admin/updates", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "admin/updates" }).to route_to(:controller => "admin/updates", :action => "create")
    end

    it "recognizes and generates #update" do
      expect({ :put => "admin/updates/1" }).to route_to(:controller => "admin/updates", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "admin/updates/1" }).to route_to(:controller => "admin/updates", :action => "destroy", :id => "1")
    end

  end
end
