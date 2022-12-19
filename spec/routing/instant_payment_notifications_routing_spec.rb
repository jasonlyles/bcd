require "spec_helper"

RSpec.describe InstantPaymentNotificationsController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(:post => "/instant_payment_notifications").to route_to("instant_payment_notifications#create")
    end
  end
end
