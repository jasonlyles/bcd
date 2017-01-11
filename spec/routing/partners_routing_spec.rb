require "spec_helper"

describe PartnersController do
  describe "routing" do

    it "recognizes and generates #index" do
      expect({ :get => "/partners" }).to route_to(:controller => "partners", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "/partners/new" }).to route_to(:controller => "partners", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "/partners/1" }).to route_to(:controller => "partners", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "/partners/1/edit" }).to route_to(:controller => "partners", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "/partners" }).to route_to(:controller => "partners", :action => "create")
    end

    it "recognizes and generates #update" do
      expect({ :put => "/partners/1" }).to route_to(:controller => "partners", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "/partners/1" }).to route_to(:controller => "partners", :action => "destroy", :id => "1")
    end

  end
end
