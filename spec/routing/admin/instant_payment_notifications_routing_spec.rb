require "spec_helper"

RSpec.describe Admin::InstantPaymentNotificationsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "admin/instant_payment_notifications").to route_to("admin/instant_payment_notifications#index")
    end

    it "routes to #show" do
      expect(:get => "admin/instant_payment_notifications/1").to route_to("admin/instant_payment_notifications#show", :id => "1")
    end
  end
end
