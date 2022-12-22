# frozen_string_literal: true

class NewMarketingNotificationJob < BaseJob
  @queue = :batchmailer

  def self.perform(options)
    email_campaign = EmailCampaign.find(options['email_campaign'])
    users = options['preview_only'] ? Radmin.pluck(:email, :sign_in_count, :failed_attempts) : User.who_get_all_emails
    recipient = Struct.new(:email, :guid, :unsubscribe_token)
    actual_sent = 0
    users.each do |user|
      MarketingMailer.new_marketing_notification(email_campaign, recipient.new(user[0], user[1], user[2])).deliver
      actual_sent += 1
      # Trying a simple throttle to make sure I'm not sending more than 5 emails/second so I don't run afoul
      # of my Amazon SES limits
      sleep 0.2
    end
  ensure
    unless options['preview_only']
      email_campaign.emails_sent = actual_sent
      email_campaign.save
    end
  end
end
