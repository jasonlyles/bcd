require 'spec_helper'

describe InstantPaymentNotificationsController do

  before do
    # @product_type = FactoryGirl.create(:product_type)
  end

  # This should return the minimal set of attributes required to create a valid
  # InstantPaymentNotification. As you add validations to InstantPaymentNotification, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
        payer_email: 'test@test.com',
        notify_version: '3.8'
    }
  }

  describe "POST #create" do
    context "with valid params" do
      it "creates a new InstantPaymentNotification", :skip_before do
        expect {
          post :create, params: {instant_payment_notification: valid_attributes}
        }.to change(InstantPaymentNotification, :count).by(1)
      end

      it "returns a 200", :skip_before do
        post :create, params: {instant_payment_notification: valid_attributes}
        expect(response.status).to eq(200)
      end
    end
  end
end
