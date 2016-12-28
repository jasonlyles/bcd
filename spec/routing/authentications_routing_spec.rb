require "spec_helper"

describe AuthenticationsController do
  describe "routing" do
    it "recognizes and generates clear_authentications" do
      expect({:post => "/authentications/clear_authentications"}).to route_to(:controller => "authentications", :action => "clear_authentications")
    end

    it "recognizes and generates create" do
      expect({:post => "/authentications"}).to route_to(:controller => "authentications", :action => "create")
    end

    it "recognizes and generates destroy" do
      expect({:delete => "/authentications/1"}).to route_to(:controller => "authentications", :action => "destroy", :id => '1')
    end
  end
end