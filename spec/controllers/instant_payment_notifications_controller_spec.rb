require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe InstantPaymentNotificationsController do

  before do
    @radmin ||= FactoryGirl.create(:radmin)
    @product_type = FactoryGirl.create(:product_type)
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
