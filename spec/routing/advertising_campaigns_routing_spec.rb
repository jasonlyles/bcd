require "spec_helper"

describe AdvertisingCampaignsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/advertising_campaigns" }.should route_to(:controller => "advertising_campaigns", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/advertising_campaigns/new" }.should route_to(:controller => "advertising_campaigns", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/advertising_campaigns/1" }.should route_to(:controller => "advertising_campaigns", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/advertising_campaigns/1/edit" }.should route_to(:controller => "advertising_campaigns", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/advertising_campaigns" }.should route_to(:controller => "advertising_campaigns", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/advertising_campaigns/1" }.should route_to(:controller => "advertising_campaigns", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/advertising_campaigns/1" }.should route_to(:controller => "advertising_campaigns", :action => "destroy", :id => "1")
    end

  end
end
