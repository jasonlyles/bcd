require 'spec_helper'

describe Admin::InstantPaymentNotificationsController do

  before do
    @radmin ||= FactoryGirl.create(:radmin)
    # @product_type = FactoryGirl.create(:product_type)
  end

  before(:each) do |example|
    unless example.metadata[:skip_before]
      sign_in @radmin
    end
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

  describe "GET #index" do
    it "assigns all instant_payment_notifications as @instant_payment_notifications" do
      instant_payment_notification = InstantPaymentNotification.create! valid_attributes
      get :index, params: {}
      expect(assigns(:instant_payment_notifications)).to eq([instant_payment_notification])
    end
  end

  describe "GET #show" do
    it "assigns the requested instant_payment_notification as @instant_payment_notification" do
      instant_payment_notification = InstantPaymentNotification.create! valid_attributes
      get :show, id: instant_payment_notification.id
      expect(assigns(:instant_payment_notification)).to eq(instant_payment_notification)
    end
  end
end
