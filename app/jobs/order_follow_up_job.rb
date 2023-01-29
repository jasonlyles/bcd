# frozen_string_literal: true

class OrderFollowUpJob
  include Sidekiq::Job
  sidekiq_options queue: 'low'

  def perform
    puts 'Sending order follow up emails'
    ipns = InstantPaymentNotification.where('DATE(updated_at)=? and processed=true', Rails.application.credentials.app.days_til_order_follow_up.days.ago)
    # For testing locally:
    # ipns = InstantPaymentNotification.where('DATE(updated_at)=?', 1.days.ago)

    ipns.each do |ipn|
      OrderMailer.follow_up(ipn.order_id).deliver_later if ipn.order && (ipn.order.user.email_preference == 2)
    end
  end
end
