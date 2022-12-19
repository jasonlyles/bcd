require "spec_helper"

describe Admin::AdvertisingCampaignsController do
  describe "routing" do

    it "recognizes and generates #index" do
      expect({ :get => "admin/advertising_campaigns" }).to route_to(:controller => "admin/advertising_campaigns", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "admin/advertising_campaigns/new" }).to route_to(:controller => "admin/advertising_campaigns", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "admin/advertising_campaigns/1" }).to route_to(:controller => "admin/advertising_campaigns", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "admin/advertising_campaigns/1/edit" }).to route_to(:controller => "admin/advertising_campaigns", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "admin/advertising_campaigns" }).to route_to(:controller => "admin/advertising_campaigns", :action => "create")
    end

    it "recognizes and generates #update" do
      expect({ :put => "admin/advertising_campaigns/1" }).to route_to(:controller => "admin/advertising_campaigns", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "admin/advertising_campaigns/1" }).to route_to(:controller => "admin/advertising_campaigns", :action => "destroy", :id => "1")
    end

  end
end
