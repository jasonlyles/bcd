# frozen_string_literal: true

class NewMarketingNotificationJob
  include Sidekiq::Job
  sidekiq_options queue: 'mailer'

  def perform(email_campaign, preview_only = false)
    email_campaign = EmailCampaign.find(email_campaign)
    users = preview_only ? Radmin.pluck(:email, :sign_in_count, :failed_attempts) : User.who_get_all_emails
    actual_sent = 0
    users.each do |user|
      recipient = {
        email: user[0],
        guid: user[1],
        unsubscribe_token: user[2]
      }.to_json
      MarketingMailer.new_marketing_notification(email_campaign.attributes.to_json, recipient).deliver_later
      actual_sent += 1
      # Trying a simple throttle to make sure I'm not sending more than 5 emails/second so I don't run afoul
      # of my Amazon SES limits
      sleep 0.2
    end
  ensure
    unless preview_only
      email_campaign.emails_sent = actual_sent
      email_campaign.save
    end
  end
end
