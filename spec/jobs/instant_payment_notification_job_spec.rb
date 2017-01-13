require 'spec_helper'

describe InstantPaymentNotificationJob do
  describe "perform" do
    it "should save address details if order includes physical item" do
      product_type = FactoryGirl.create(:product_type)
      product_type2 = FactoryGirl.create(:product_type, :name => 'Models', :digital_product => false)
      user = FactoryGirl.create(:user)
      category = FactoryGirl.create(:category)
      subcategory = FactoryGirl.create(:subcategory)
      product = FactoryGirl.create(:product)
      physical_product = FactoryGirl.create(:physical_product)
      order = FactoryGirl.create(:order, :status => '', :user_id => user.id)
      line_item = FactoryGirl.create(:line_item, :product_id => physical_product.id, :order_id => order.id)
      ipn = FactoryGirl.create(:instant_payment_notification, :params => {'address_city' => 'Richmond'})
      expect(Order).to receive(:find_by_request_id).at_least(:once).and_return(order)
      expect_any_instance_of(InstantPaymentNotification).to receive(:valid_ipn?).and_return(true)
      expect(order).to receive(:has_physical_item?).at_least(:once).and_return(true)
      expect(order).to receive(:save).at_least(1).times

      InstantPaymentNotificationJob.new('',{'ipn_id' => ipn.id}).perform

      expect(order.address_city).to eq("Richmond")
    end

    it "should not save address details if order does not include physical item" do
      user = FactoryGirl.create(:user)
      order = FactoryGirl.create(:order, :status => '', :user_id => user.id)
      ipn = FactoryGirl.create(:instant_payment_notification, :params => {'address_city' => 'Richmond'})
      expect(Order).to receive(:find_by_request_id).at_least(:once).and_return(order)
      expect_any_instance_of(InstantPaymentNotification).to receive(:valid_ipn?).and_return(true)
      expect(order).to receive(:has_physical_item?).at_least(:once).and_return(false)
      expect(order).to receive(:save).at_least(1).times

      InstantPaymentNotificationJob.new('',{'ipn_id' => ipn.id}).perform

      expect(order.address_city).to be_nil
    end

    it "should send an order confirmation email and save details to the order if the IPN is valid" do
      user = FactoryGirl.create(:user)
      order = FactoryGirl.create(:order, :status => '', :user_id => user.id)
      ipn = FactoryGirl.create(:instant_payment_notification)
      expect(Order).to receive(:find_by_request_id).at_least(:once).and_return(order)
      expect_any_instance_of(InstantPaymentNotification).to receive(:valid_ipn?).and_return(true)
      expect(order).to receive(:save).at_least(1).times
      expect(OrderMailer).to receive(:order_confirmation)

      InstantPaymentNotificationJob.new('',{'ipn_id' => ipn.id}).perform
    end

    it "should send a guest order confirmation email and save details to the order if the IPN is valid" do
      user = FactoryGirl.create(:user,:account_status => 'G')
      order = FactoryGirl.create(:order, :status => '', :user_id => user.id)
      ipn = FactoryGirl.create(:instant_payment_notification)
      expect(Order).to receive(:find_by_request_id).at_least(:once).and_return(order)
      expect_any_instance_of(InstantPaymentNotification).to receive(:valid_ipn?).and_return(true)
      expect(order).to receive(:save).at_least(1).times
      expect(OrderMailer).to receive(:guest_order_confirmation)

      InstantPaymentNotificationJob.new('',{'ipn_id' => ipn.id}).perform
    end

    it "should not send an order confirmation email, but save details to the order if the IPN is invalid" do
      order = FactoryGirl.create(:order, :status => '')
      ipn = FactoryGirl.create(:instant_payment_notification)
      expect(Order).to receive(:find_by_request_id).at_least(:once).and_return(order)
      expect_any_instance_of(InstantPaymentNotification).to receive(:valid_ipn?).and_return(false)
      expect(order).to receive(:save).at_least(1).times
      expect(OrderMailer).to_not receive(:order_confirmation)

      InstantPaymentNotificationJob.new('',{'ipn_id' => ipn.id}).perform
    end

    it "should stop processing and notify if an order can not be found by request_id" do
      order = FactoryGirl.create(:order)
      ipn = FactoryGirl.create(:instant_payment_notification, :order_id => order.id + 1)
      expect(Order).to receive(:find_by_request_id).at_least(:once).and_return(nil)
      expect(ExceptionNotifier).to receive(:notify_exception).with(InvalidIPNException, :data => {:message => "IPN #{ipn.id} cannot be associated with an Order"})

      InstantPaymentNotificationJob.new('',{'ipn_id' => ipn.id}).perform
    end

    it "should stop processing and notify if the orders status is already set as COMPLETED" do
      order = FactoryGirl.create(:order, :status => 'COMPLETED')
      ipn = FactoryGirl.create(:instant_payment_notification, :order_id => order.id)
      expect(Order).to receive(:find_by_request_id).at_least(:once).and_return(order)
      expect(ExceptionNotifier).to receive(:notify_exception).with(InvalidIPNException, :data => {:message => "IPN #{ipn.id} seems to have been sent more than once, as the Order was already marked completed."})

      InstantPaymentNotificationJob.new('',{'ipn_id' => ipn.id}).perform
    end

  end
end