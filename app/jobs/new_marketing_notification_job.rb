class NewMarketingNotificationJob < BaseJob
  @queue = :batchmailer

  def perform
    email_campaign = EmailCampaign.find(options['email_campaign'])
    users = options['preview_only'] ? Radmin.pluck(:email, :sign_in_count, :failed_attempts) : User.who_get_all_emails
    recipient = Struct.new(:email, :guid, :unsubscribe_token)
    total = users.count
    actual_sent = 0
    users.each_with_index do |user, index|
      at(index+1,total,"At #{index+1} of #{total}")
      MarketingMailer.new_marketing_notification(email_campaign, recipient.new(user[0],user[1],user[2])).deliver
      actual_sent += 1
      #Trying a simple throttle to make sure I'm not sending more than 5 emails/second so I don't run afoul
      # of my Amazon SES limits
      sleep 0.2
    end
  ensure
    unless options['preview_only']
      if actual_sent > 0
        email_campaign.emails_sent = actual_sent
        email_campaign.save
      end
    end
  end
end