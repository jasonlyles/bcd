# frozen_string_literal: true

class AdminMailer < ActionMailer::Base
  default from: 'Brick City Depot <sales@brickcitydepot.com>'
  default to: EmailConfig.config.contact
  layout 'admin_email'

  def active_notifications_email(notification_count)
    @host = Rails.application.config.web_host
    @notification_count = notification_count

    mail(subject: "#{@notification_count} Active Notifications on Brick City Depot")
  end

  # :nocov:
  def queue_name
    'mailer'
  end
  # :nocov:
end

# :nocov:
if Rails.env.development?
  class AdminMailer::Preview < MailView
    def new_contact_email
      AdminMailer.active_notifications_email
    end
  end
end
# :nocov:
