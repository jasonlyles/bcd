require "spec_helper"

describe AdminController do
  describe "routing" do
    it "recognizes and generates #become" do
      {:get => "/woofay/1/become"}.should route_to(:controller => "admin", :action => "become", :id => '1')
    end

    it "recognizes and generates #find_user" do
      {:post => "/woofay/lylesjt@yahoo.com/find_user"}.should route_to(:controller => "admin", :action => "find_user", :email => "lylesjt@yahoo.com")
    end

    it "recognizes and generates #admin_profile" do
      {:get => "/woofay/1/admin_profile"}.should route_to(:controller => "admin", :action => "admin_profile", :id => '1')
    end

    it "recognizes and generates #update_admin_profile" do
      {:patch => "/woofay/1/update_admin_profile"}.should route_to(:controller => "admin", :action => "update_admin_profile", :id => '1')
    end

    it "recognizes and generates #change_user_status" do
      {:post => "/woofay/lylesjt@yahoo.com/change_user_status"}.should route_to(:controller => "admin", :action => "change_user_status", :email => "lylesjt@yahoo.com")
    end

    it "recognizes and generates #order" do
      {:get => "/order/1"}.should route_to(:controller => "admin", :action => "order", :id => '1')
    end

    it "recognizes and generates #update_downloads_for_user" do
      {:post => "/woofay/update_downloads_for_user"}.should route_to(:controller => "admin", :action => "update_downloads_for_user")
    end

    it "recognizes and generates #update_users_download_counts" do
      {:get => "/update_users_download_counts"}.should route_to(:controller => "admin", :action => "update_users_download_counts")
    end
  end
end