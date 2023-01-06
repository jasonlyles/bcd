require "#{Rails.root}/lib/config/paypal_config.rb"

PaypalConfig.configure do |config|
  config.business_email = Rails.application.credentials.paypal.email
  config.return_url = Rails.application.credentials.paypal.return_url
  config.host = Rails.application.credentials.paypal.host
  config.notify_url = Rails.application.credentials.paypal.notify_url
end
