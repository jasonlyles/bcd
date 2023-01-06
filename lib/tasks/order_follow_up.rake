# frozen_string_literal: true

namespace :order_follow_up do
  task send_emails: :environment do
    puts 'Sending order follow up emails'
    ipns = InstantPaymentNotification.where('DATE(updated_at)=? and processed=true', Rails.application.credentials.app.days_til_order_follow_up.days.ago)
    # For testing locally:
    # ipns = InstantPaymentNotification.where('DATE(updated_at)=?', 1.days.ago)

    ipns.each do |ipn|
      OrderMailer.follow_up(ipn.order_id).deliver if ipn.order && (ipn.order.user.email_preference == 2)
    end
  end
end
