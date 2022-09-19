require "spec_helper"

describe Admin::EmailCampaignsController do
  describe "routing" do

    it "recognizes and generates #index" do
      expect({ :get => "admin/email_campaigns" }).to route_to(:controller => "admin/email_campaigns", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "admin/email_campaigns/new" }).to route_to(:controller => "admin/email_campaigns", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "admin/email_campaigns/1" }).to route_to(:controller => "admin/email_campaigns", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "admin/email_campaigns/1/edit" }).to route_to(:controller => "admin/email_campaigns", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "admin/email_campaigns" }).to route_to(:controller => "admin/email_campaigns", :action => "create")
    end

    it "recognizes and generates #update" do
      expect({ :put => "admin/email_campaigns/1" }).to route_to(:controller => "admin/email_campaigns", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "admin/email_campaigns/1" }).to route_to(:controller => "admin/email_campaigns", :action => "destroy", :id => "1")
    end

  end
end
