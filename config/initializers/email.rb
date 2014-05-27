require "#{Rails.root}/lib/config/email_config.rb"

EmailConfig.configure do |config|
  config.error_notification = ENV['BCD_EMAIL_ERROR_NOTIFICATION']
  config.physical_order = ENV['BCD_EMAIL_PHYSICAL_ORDER']
  config.contact = ENV['BCD_EMAIL_CONTACT']
end