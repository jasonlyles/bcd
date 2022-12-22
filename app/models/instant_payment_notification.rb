# frozen_string_literal: true

class InvalidIPNException < StandardError;end

class InstantPaymentNotification < ApplicationRecord
  belongs_to :order, optional: true

  def valid_business_value?
    Rails.logger.debug("PAYMENT BUSINESS: #{params['business']} and EMAIL: #{PaypalConfig.config.business_email} and #{params['business'] == PaypalConfig.config.business_email}")
    params['business'] == PaypalConfig.config.business_email
  end

  def valid_currency?
    Rails.logger.debug("PAYMENT CURRENCY: #{params['mc_currency']}")
    params['mc_currency'] == 'USD'
  end

  def valid_amount?
    Rails.logger.debug("PAYMENT AMOUNT: #{params['mc_gross'].to_f} and #{order.total_price} and #{params['mc_gross'].to_f == order.total_price}")
    params['mc_gross'].to_f == order.total_price
  end

  def valid_payment_status?
    Rails.logger.debug("PAYMENT STATUS: #{payment_status.upcase}")
    payment_status.upcase == 'COMPLETED'
  end

  # Make sure IPN is valid by making a call to $config['paypal']['url']/cgi-bin/webscr? cmd=_notify_validate plus
  # all the variables that I got from paypal, in the same order I received them.
  def valid_ipn_url?
    http = Net::HTTP.new(PaypalConfig.config.host, 443)
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.use_ssl = true
    path = '/cgi-bin/webscr'
    query = 'cmd=_notify-validate'
    # Might need to URL.encode the query string
    params.each do |key, value|
      query += "&#{key}=#{value}"
    end
    response = http.post(path, query)
    Rails.logger.debug("PAYMENT PATH: #{path} AND QUERY: #{query}")
    if response && response.code == '200' && response.body == 'VERIFIED'
      Rails.logger.debug('VALID IPN')
      true
    else
      Rails.logger.debug("INVALID IPN: BODY: #{response.body} AND CODE: #{response.code}")
      ExceptionNotifier.notify_exception(InvalidIPNException.new, :data => { :message => "INVALID IPN ##{id}: BODY: #{response.body} AND CODE: #{response.code}" })
      false
    end
  end

  def valid_ipn?
    valid_ipn_url? && valid_amount? && valid_currency? && valid_business_value? && valid_payment_status?
  end
end
