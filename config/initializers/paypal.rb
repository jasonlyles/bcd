require "#{Rails.root}/lib/config/paypal_config.rb"

PaypalConfig.configure do |config|
  config.business_email = ENV['BCD_PAYPAL_EMAIL']
  config.return_url = ENV['BCD_PAYPAL_RETURN_URL']
  config.host = ENV['BCD_PAYPAL_HOST']
  config.notify_url = ENV['BCD_PAYPAL_NOTIFY_URL']
end