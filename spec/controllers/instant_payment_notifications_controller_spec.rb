require 'spec_helper'

describe InstantPaymentNotificationsController do

  before do
    @user = FactoryBot.create(:user)
    @order = FactoryBot.create(:order, user_id: @user.id)
  end

  # This should return the minimal set of attributes required to create a valid
  # InstantPaymentNotification. As you add validations to InstantPaymentNotification, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
        payer_email: @user.email,
        notify_version: '3.8'
    }
  }

  describe "POST #create" do
    context "with valid params" do
      it "creates a new InstantPaymentNotification", :skip_before do
        allow(InstantPaymentNotificationJob).to receive(:perform_async)
        expect {
          post :create, params: { instant_payment_notification: valid_attributes }
        }.to change(InstantPaymentNotification, :count).by(1)
      end

      it "returns a 204", :skip_before do
        allow(InstantPaymentNotificationJob).to receive(:perform_async)
        post :create, params: { instant_payment_notification: valid_attributes }
        expect(response.status).to eq(204)
      end
    end
  end
end
