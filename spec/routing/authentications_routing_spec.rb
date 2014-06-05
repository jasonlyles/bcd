require "spec_helper"

describe AuthenticationsController do
  describe "routing" do
    it "recognizes and generates clear_authentications" do
      {:post => "/authentications/clear_authentications"}.should route_to(:controller => "authentications", :action => "clear_authentications")
    end

    it "recognizes and generates create" do
      {:post => "/authentications"}.should route_to(:controller => "authentications", :action => "create")
    end

    it "recognizes and generates destroy" do
      {:delete => "/authentications/1"}.should route_to(:controller => "authentications", :action => "destroy", :id => '1')
    end
  end
end