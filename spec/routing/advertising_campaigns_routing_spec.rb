require "spec_helper"

describe AdvertisingCampaignsController do
  describe "routing" do

    it "recognizes and generates #index" do
      expect({ :get => "/advertising_campaigns" }).to route_to(:controller => "advertising_campaigns", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "/advertising_campaigns/new" }).to route_to(:controller => "advertising_campaigns", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "/advertising_campaigns/1" }).to route_to(:controller => "advertising_campaigns", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "/advertising_campaigns/1/edit" }).to route_to(:controller => "advertising_campaigns", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "/advertising_campaigns" }).to route_to(:controller => "advertising_campaigns", :action => "create")
    end

    it "recognizes and generates #update" do
      expect({ :put => "/advertising_campaigns/1" }).to route_to(:controller => "advertising_campaigns", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "/advertising_campaigns/1" }).to route_to(:controller => "advertising_campaigns", :action => "destroy", :id => "1")
    end

  end
end
