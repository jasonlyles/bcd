# frozen_string_literal: true

class PartsListUpdateNotificationJob < ApplicationJob
  queue_as :batchmailer

  # rubocop:disable Metrics/AbcSize
  def perform(options)
    message = options[:message]
    product_ids = options[:product_ids]
    # Translate these product_ids into a hash with product names that I can look
    # up from, and not have to keep hitting the database.
    product_hash = {}
    Product.where(id: product_ids).each { |product| product_hash.merge!(product.id => product.code_and_name) }
    # Determine which users to alert about these parts list updates.
    order_ids = LineItem.where(product_id: product_ids).pluck(:order_id)
    user_ids = Order.where(id: order_ids).pluck(:user_id)
    user_ids.uniq!
    # 1 by 1, let's update the users.
    user_ids.each do |user_id|
      user = User.find(user_id)
      if !user.cancelled? && user.gets_important_emails?
        # Trying a simple throttle to make sure I'm not sending more than 5
        # emails/second so I don't run afoul of my Amazon SES limits
        sleep 0.2
        # Get a list of product names for the customers email.
        product_names = []
        product_ids_user_owns = user.products.pluck(:id)
        product_ids_user_owns.each { |product_id| product_names << product_hash[product_id] }
        product_names.compact!

        UpdateMailer.updated_parts_lists(user.id, product_names, message).deliver
      end
    rescue StandardError => e
      message = "PartsListUpdateNotificationJob could not send an email to user #{user_id} about products #{product_ids.join(',')}"
      Rails.logger.error(message)
      ExceptionNotifier.notify_exception(e, data: { message: })
    end
  end
  # rubocop:enable Metrics/AbcSize
end
