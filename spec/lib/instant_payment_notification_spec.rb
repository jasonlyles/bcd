require 'spec_helper'

describe InstantPaymentNotification do
  describe 'valid?' do
    it "should return true if everything is valid" do
      @ipn = InstantPaymentNotification.new({})
      @ipn.should_receive(:valid_ipn?).and_return(true)
      @ipn.should_receive(:valid_amount?).and_return(true)
      @ipn.should_receive(:valid_currency?).and_return(true)
      @ipn.should_receive(:valid_business_value?).and_return(true)
      @ipn.should_receive(:valid_payment_status?).and_return(true)

      @ipn.valid?.should eq(true)
    end

    it "should return false if even one thing is invalid" do
      @ipn = InstantPaymentNotification.new({})
      @ipn.should_receive(:valid_ipn?).and_return(true)
      @ipn.should_receive(:valid_amount?).and_return(false)

      @ipn.valid?.should eq(false)
    end
  end

  describe 'unique_transaction?' do
    it "should return true for a unique transaction" do
      order = FactoryGirl.create(:order)
      @ipn = InstantPaymentNotification.new({:txn_id => 'ralph'})

      @ipn.unique_transaction?.should eq(true)
    end

    it "should return false for a non-unique transaction" do
      order = FactoryGirl.create(:order)
      @ipn = InstantPaymentNotification.new({:txn_id => order.transaction_id})

      @ipn.unique_transaction?.should eq(false)
    end
  end

  describe 'valid_payment_status?' do
    it "should return true for a valid payment status" do
      @ipn = InstantPaymentNotification.new({:payment_status => 'completed'})

      @ipn.valid_payment_status?.should eq(true)
    end

    it "should return false for an invalid payment status" do
      @ipn = InstantPaymentNotification.new({:payment_status => 'ralph'})

      @ipn.valid_payment_status?.should eq(false)
    end
  end

  describe 'valid_amount?' do
    it "should return true for a valid amount" do
      order = FactoryGirl.create(:order_with_line_items)
      Order.should_receive(:find_by_request_id).at_least(:once).and_return(order)
      @ipn = InstantPaymentNotification.new({:mc_gross => '9.99'})
      @ipn.find_order

      @ipn.valid_amount?.should eq(true)
    end

    it "should return false for an invalid amount" do
      order = FactoryGirl.create(:order_with_line_items)
      Order.should_receive(:find_by_request_id).at_least(:once).and_return(order)
      @ipn = InstantPaymentNotification.new({:mc_gross => '0.25'})
      @ipn.find_order

      @ipn.valid_amount?.should eq(false)
    end
  end

  describe 'valid_currency?' do
    it "should return true for a valid currency" do
      @ipn = InstantPaymentNotification.new({:mc_currency => 'USD'})

      @ipn.valid_currency?.should eq(true)
    end

    it "should return false for an invalid currency" do
      @ipn = InstantPaymentNotification.new({:mc_currency => 'BitCoins'})

      @ipn.valid_currency?.should eq(false)
    end
  end

  describe 'valid_business_value?' do
    it "should return true for a valid business value" do
      @ipn = InstantPaymentNotification.new({:business => ENV['BCD_PAYPAL_EMAIL']})

      @ipn.valid_business_value?.should eq(true)
    end

    it "should return false for an invalid business value" do
      @ipn = InstantPaymentNotification.new({:business => 'Old Dominion Kayaks'})

      @ipn.valid_business_value?.should eq(false)
    end
  end

  describe 'valid_ipn?' do
    it "should return true for a valid ipn" do
      Net::HTTP.any_instance.should_receive(:post).with("/cgi-bin/webscr", "cmd=_notify-validate&x=y").and_return(Net::HTTPResponse.new('1.0','200','OK'))
      Net::HTTPResponse.any_instance.should_receive(:body).and_return('VERIFIED')
      ipn = InstantPaymentNotification.new({'x' => 'y'})

      ipn.valid_ipn?.should eq(true)
    end

    it "should return false for an invalid ipn" do
      Net::HTTP.any_instance.should_receive(:post).with("/cgi-bin/webscr", "cmd=_notify-validate&x=y").and_return(Net::HTTPResponse.new('1.0','500','fake'))
      Net::HTTPResponse.any_instance.should_receive(:body).and_return('fake')
      Net::HTTPResponse.any_instance.should_receive(:code).at_least(1).times.and_return('500')
      ipn = InstantPaymentNotification.new({'x' => 'y'})

      ipn.valid_ipn?.should eq(false)
    end
  end
end