# frozen_string_literal: true

class WarnAboutActiveNotificationsJob
  include Sidekiq::Job
  sidekiq_options queue: 'low'

  def perform
    AdminMailer.active_notifications_email(BackendNotification.active_notifications.count).deliver_now if BackendNotification.active_notifications.present?
  end
end
