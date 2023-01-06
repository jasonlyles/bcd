require "#{Rails.root}/lib/config/email_config.rb"

EmailConfig.configure do |config|
  config.error_notification = Rails.application.credentials.email.error_notification
  config.physical_order = Rails.application.credentials.email.physical_order
  config.contact = Rails.application.credentials.email.contact
end
