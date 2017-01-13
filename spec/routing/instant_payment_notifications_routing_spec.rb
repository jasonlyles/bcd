require "spec_helper"

RSpec.describe InstantPaymentNotificationsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/instant_payment_notifications").to route_to("instant_payment_notifications#index")
    end

    it "routes to #show" do
      expect(:get => "/instant_payment_notifications/1").to route_to("instant_payment_notifications#show", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/instant_payment_notifications").to route_to("instant_payment_notifications#create")
    end

  end
end
