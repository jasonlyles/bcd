# frozen_string_literal: true

class ProductUpdateNotificationJob < BaseJob
  @queue = :batchmailer

  def self.perform(options)
    product_id = options['product_id']
    message = options['message']
    users = Download.update_all_users_who_have_downloaded_at_least_once(product_id)
    Rails.logger.error("Updating #{users.length} users")
    email_users_about_updated_instructions(users, product_id, message) if users.length.positive?
  end

  def self.email_users_about_updated_instructions(users, product_id, message)
    users.each_with_index do |user, index|
      UpdateMailer.updated_instructions(user.id, product_id, message).deliver
      # Trying a simple throttle to make sure I'm not sending more than 5 emails/second so I don't run afoul
      # of my Amazon SES limits
      sleep 0.2
    end
  end
end
