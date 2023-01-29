# frozen_string_literal: true

class NewProductNotificationJob
  include Sidekiq::Job
  sidekiq_options queue: 'mailer'

  def perform(product_id, message)
    users = User.who_get_all_emails
    product = Product.find(product_id)
    product_type = product.product_type.name
    image_url = product.main_image&.medium
    users.each do |user|
      recipient = {
        email: user[0],
        guid: user[1],
        unsubscribe_token: user[2]
      }.to_json
      MarketingMailer.new_product_notification(product.attributes.to_json, product_type, image_url, recipient, message).deliver_later
      # Trying a simple throttle to make sure I'm not sending more than 5 emails/second so I don't run afoul
      # of my Amazon SES limits
      sleep 0.2
    end
  end
end
