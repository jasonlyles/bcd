require "spec_helper"

describe EmailCampaignsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/email_campaigns" }.should route_to(:controller => "email_campaigns", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/email_campaigns/new" }.should route_to(:controller => "email_campaigns", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/email_campaigns/1" }.should route_to(:controller => "email_campaigns", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/email_campaigns/1/edit" }.should route_to(:controller => "email_campaigns", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/email_campaigns" }.should route_to(:controller => "email_campaigns", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/email_campaigns/1" }.should route_to(:controller => "email_campaigns", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/email_campaigns/1" }.should route_to(:controller => "email_campaigns", :action => "destroy", :id => "1")
    end

  end
end
