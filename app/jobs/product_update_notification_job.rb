class ProductUpdateNotificationJob < BaseJob
  @queue = :batchmailer

  def perform
    product_id = options['product_id']
    message = options['message']
    users = Download.update_all_users_who_have_downloaded_at_least_once(product_id)
    Rails.logger.error("Updating #{users.length} users")
    if users.length > 0
      self.email_users_about_updated_instructions(users, product_id, message)
    end
  end

  def email_users_about_updated_instructions(users, product_id, message)
    total = users.count
    users.each_with_index do |user,index|
      at(index+1,total,"At #{index+1} of #{total}")
      UpdateMailer.updated_instructions(user.id, product_id, message).deliver
      #Trying a simple throttle to make sure I'm not sending more than 5 emails/second so I don't run afoul
      # of my Amazon SES limits
      sleep 0.2
    end
  end
end