require 'spec_helper'

describe InstantPaymentNotification, type: :model do
  before do
    FactoryBot.create(:product_with_associations)
  end

  describe 'valid_ipn?' do
    it 'should return true if everything is valid' do
      ipn = InstantPaymentNotification.new({})
      expect(ipn).to receive(:valid_ipn_url?).and_return(true)
      expect(ipn).to receive(:valid_amount?).and_return(true)
      expect(ipn).to receive(:valid_currency?).and_return(true)
      expect(ipn).to receive(:valid_business_value?).and_return(true)
      expect(ipn).to receive(:valid_payment_status?).and_return(true)

      expect(ipn.valid_ipn?).to eq(true)
    end

    it 'should return false if even one thing is invalid' do
      ipn = InstantPaymentNotification.new({})
      expect(ipn).to receive(:valid_ipn_url?).and_return(true)
      expect(ipn).to receive(:valid_amount?).and_return(false)

      expect(ipn.valid_ipn?).to eq(false)
    end
  end

  describe 'valid_payment_status?' do
    it 'should return true for a valid payment status' do
      ipn = InstantPaymentNotification.new({ payment_status: 'completed' })

      expect(ipn.valid_payment_status?).to eq(true)
    end

    it 'should return false for an invalid payment status' do
      ipn = InstantPaymentNotification.new({ payment_status: 'ralph' })

      expect(ipn.valid_payment_status?).to eq(false)
    end
  end

  describe 'valid_amount?' do
    it 'should return true for a valid amount' do
      order = FactoryBot.create(:order_with_line_items)
      ipn = InstantPaymentNotification.new({ order_id: order.id, params: { mc_gross: '10.0' } })

      expect(ipn.valid_amount?).to eq(true)
    end

    it 'should return false for an invalid amount' do
      order = FactoryBot.create(:order_with_line_items)
      ipn = InstantPaymentNotification.new({ order:, params: { mc_gross: '0.25' } })

      expect(ipn.valid_amount?).to eq(false)
    end
  end

  describe 'valid_currency?' do
    it 'should return true for a valid currency' do
      ipn = InstantPaymentNotification.new({ params: { mc_currency: 'USD' } })

      expect(ipn.valid_currency?).to eq(true)
    end

    it 'should return false for an invalid currency' do
      ipn = InstantPaymentNotification.new({ params: { mc_currency: 'BitCoins' } })

      expect(ipn.valid_currency?).to eq(false)
    end
  end

  describe 'valid_business_value?' do
    it 'should return true for a valid business value' do
      ipn = InstantPaymentNotification.new({ params: { business: Rails.application.credentials.paypal.email } })

      expect(ipn.valid_business_value?).to eq(true)
    end

    it 'should return false for an invalid business value' do
      ipn = InstantPaymentNotification.new({ params: { business: 'Old Dominion Kayaks' } })

      expect(ipn.valid_business_value?).to eq(false)
    end
  end

  describe 'valid_ipn?' do
    it 'should return true for a valid ipn' do
      expect_any_instance_of(Net::HTTP).to receive(:post).with('/cgi-bin/webscr', 'cmd=_notify-validate&x=y').and_return(Net::HTTPResponse.new('1.0', '200', 'OK'))
      expect_any_instance_of(Net::HTTPResponse).to receive(:body).and_return('VERIFIED')
      ipn = InstantPaymentNotification.new(params: { 'x' => 'y' })

      expect(ipn.valid_ipn_url?).to eq(true)
    end

    it 'should return false for an invalid ipn' do
      expect_any_instance_of(Net::HTTP).to receive(:post).with('/cgi-bin/webscr', 'cmd=_notify-validate&x=y').and_return(Net::HTTPResponse.new('1.0', '500', 'fake'))
      expect_any_instance_of(Net::HTTPResponse).to receive(:body).at_least(1).times.and_return('fake')
      expect_any_instance_of(Net::HTTPResponse).to receive(:code).at_least(1).times.and_return('500')
      ipn = InstantPaymentNotification.new(params: { 'x' => 'y' })

      expect(ipn.valid_ipn_url?).to eq(false)
    end
  end
end
