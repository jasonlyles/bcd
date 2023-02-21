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
    { 'mc_gross' => '10.00',
      'protection_eligibility' => 'Eligible',
      'address_status' => 'confirmed',
      'item_number1' => '',
      'payer_id' => 'Y3CKBE4A4UPK2',
      'address_street' => '123 Fake St.',
      'payment_date' => '05:11:47 Feb 21, 2023 PST',
      'payment_status' => 'Completed',
      'charset' => 'windows-1252',
      'address_zip' => '11111',
      'first_name' => 'Jason',
      'mc_fee' => '0.84',
      'address_country_code' => 'US',
      'address_name' => 'Jason Lyles',
      'notify_version' => '3.9',
      'custom' => 'c87ef399b359bdb25d5791264e4e6bbe783e1c72',
      'payer_status' => 'verified',
      'business' => 'sales-facilitator@brickcitydepot.com',
      'address_country' => 'United States',
      'num_cart_items' => '1',
      'address_city' => 'Richmond',
      'verify_sign' => 'A1md5xgQcc-IePSXZXW',
      'payer_email' => 'lylesjt@yahoo.com',
      'txn_id' => '79H82308EA000523D',
      'payment_type' => 'instant',
      'last_name' => 'Lyles',
      'item_name1' => 'CB002 Colonial Revival House',
      'address_state' => 'VA',
      'receiver_email' => 'sales-facilitator@brickcitydepot.com',
      'payment_fee' => '0.84',
      'shipping_discount' => '0.00',
      'quantity1' => '1',
      'insurance_amount' => '0.00',
      'receiver_id' => '5V6HAFUSQAWPC',
      'txn_type' => 'cart',
      'discount' => '0.00',
      'mc_gross_1' => '10.00',
      'mc_currency' => 'USD',
      'residence_country' => 'US',
      'test_ipn' => '1',
      'shipping_method' => 'Default',
      'transaction_subject' => '',
      'payment_gross' => '10.00',
      'ipn_track_id' => 'f2418767a467b' }
  }

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new InstantPaymentNotification', :skip_before do
        allow(InstantPaymentNotificationJob).to receive(:perform_async)
        expect {
          post :create, params: valid_attributes
        }.to change(InstantPaymentNotification, :count).by(1)
      end

      it 'returns a 204', :skip_before do
        allow(InstantPaymentNotificationJob).to receive(:perform_async)
        post :create, params: valid_attributes
        expect(response.status).to eq(204)
      end
    end
  end
end
