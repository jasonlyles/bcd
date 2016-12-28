require "spec_helper"

describe AdminController do
  describe "routing" do
    it "recognizes and generates #become" do
      expect({:get => "/woofay/1/become"}).to route_to(:controller => "admin", :action => "become", :id => '1')
    end

    it "recognizes and generates #find_user" do
      expect({:post => "/woofay/lylesjt@yahoo.com/find_user"}).to route_to(:controller => "admin", :action => "find_user", :email => "lylesjt@yahoo.com")
    end

    it "recognizes and generates #admin_profile" do
      expect({:get => "/woofay/1/admin_profile"}).to route_to(:controller => "admin", :action => "admin_profile", :id => '1')
    end

    it "recognizes and generates #update_admin_profile" do
      expect({:patch => "/woofay/1/update_admin_profile"}).to route_to(:controller => "admin", :action => "update_admin_profile", :id => '1')
    end

    it "recognizes and generates #change_user_status" do
      expect({:post => "/woofay/lylesjt@yahoo.com/change_user_status"}).to route_to(:controller => "admin", :action => "change_user_status", :email => "lylesjt@yahoo.com")
    end

    it "recognizes and generates #order" do
      expect({:get => "/order/1"}).to route_to(:controller => "admin", :action => "order", :id => '1')
    end

    it "recognizes and generates #update_downloads_for_user" do
      expect({:post => "/woofay/update_downloads_for_user"}).to route_to(:controller => "admin", :action => "update_downloads_for_user")
    end

    it "recognizes and generates #update_users_download_counts" do
      expect({:get => "/update_users_download_counts"}).to route_to(:controller => "admin", :action => "update_users_download_counts")
    end
  end
end