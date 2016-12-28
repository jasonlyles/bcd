require "spec_helper"

describe UpdatesController do
  describe "routing" do

    it "recognizes and generates #index" do
      expect({ :get => "/updates" }).to route_to(:controller => "updates", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "/updates/new" }).to route_to(:controller => "updates", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "/updates/1" }).to route_to(:controller => "updates", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "/updates/1/edit" }).to route_to(:controller => "updates", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "/updates" }).to route_to(:controller => "updates", :action => "create")
    end

    it "recognizes and generates #update" do
      expect({ :put => "/updates/1" }).to route_to(:controller => "updates", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "/updates/1" }).to route_to(:controller => "updates", :action => "destroy", :id => "1")
    end

  end
end
