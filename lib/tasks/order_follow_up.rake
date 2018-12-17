namespace :order_follow_up do
  task send_emails: :environment do
    puts 'Sending order follow up emails'
    ipns = InstantPaymentNotification.where('DATE(updated_at)=? and processed=true', BCD_DAYS_TIL_ORDER_FOLLOW_UP.days.ago)
    # For testing locally:
    # ipns = InstantPaymentNotification.where('DATE(updated_at)=?', 1.days.ago)

    ipns.each do |ipn|
      OrderMailer.follow_up(ipn.order_id).deliver if ipn.order && (ipn.order.user.email_preference == 'all_emails')
    end
  end
end
