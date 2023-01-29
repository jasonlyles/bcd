# frozen_string_literal: true

class InvalidIPNException < StandardError; end

class InstantPaymentNotificationJob
  include Sidekiq::Job
  sidekiq_options queue: 'critical'

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  def perform(ipn_id)
    ipn = InstantPaymentNotification.find(ipn_id)
    params = ipn.params
    order = Order.find_by_request_id(params['custom'])
    ipn.update(
      payment_status: params['payment_status'],
      notify_version: params['notify_version'],
      request_id: params['custom'],
      verify_sign: params['verify_sign'],
      payer_email: params['payer_email'],
      txn_id: params['txn_id'],
      order_id: order.try(:id)
    )
    if order.blank?
      Rails.logger.debug('Order is blank')
      ExceptionNotifier.notify_exception(InvalidIPNException.new, data: { message: "IPN #{ipn.id} cannot be associated with an Order" })
      return nil
    end
    if !order.status.blank? && order.status.upcase == 'COMPLETED'
      Rails.logger.debug('Order status is already set to completed')
      ExceptionNotifier.notify_exception(InvalidIPNException.new, data: { message: "IPN #{ipn.id} seems to have been sent more than once, as the Order was already marked completed." })
      return nil
    end

    if ipn.valid_ipn?
      order.transaction_id = ipn.txn_id
      order.status = ipn.payment_status.upcase if ipn.payment_status
      if order.includes_physical_item?
        # Assuming that because the street address is blank, there is no other address info, and we can save address info
        # coming to us from paypal
        unless order.address_street1?
          order.first_name = params['first_name']
          order.last_name = params['last_name']
          order.address_city = params['address_city']
          order.address_country = params['address_country']
          order.address_name = params['address_name']
          order.address_state = params['address_state']
          order.address_street1 = params['address_street']
          order.address_zip = params['address_zip']
        end
        order.shipping_status = 3 # 3 = pending
      end
      order.save

      # Everything looks good, mark as processed.
      ipn.update(processed: true)

      Download.restock_for_order(order) if order.includes_digital_item?

      # Now that the order is validated and everything is saved, I'll email the user to let them know about it.
      begin
        if order.user.guest?
          link_to_downloads = order.retrieve_link_to_downloads
          OrderMailer.guest_order_confirmation(order.user_id, order.id, link_to_downloads).deliver_later
        else
          OrderMailer.order_confirmation(order.user_id, order.id).deliver_later
        end
      rescue StandardError => e
        Rails.logger.debug('could not send order confirmation email')
        ExceptionNotifier.notify_exception(e, data: { message: "Failed trying to send order confirmation email for #{order.to_json}: #{e.message}" })
      end

      handle_physical_items(order) if order.includes_physical_item?
    else
      Rails.logger.debug('PAYPAL IPN is invalid')
      order.transaction_id = ipn.txn_id
      order.status = ipn.payment_status
      order.save
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity

  def handle_physical_items(order)
    physical_items = []
    order.line_items.each do |item|
      next unless item.product.physical_product?

      physical_items << item
      product = Product.find(item.product.id)
      product.decrement_quantity(item.quantity)
    end
    return unless physical_items.length.positive?

    physical_items.each do |item|
      # TODO: Actually do something in here... probably?
      # add to string that gets sent in email
    end
    begin
      OrderMailer.physical_item_purchased(order.user_id, order.id).deliver_later
    rescue StandardError => e
      ExceptionNotifier.notify_exception(ActiveRecord::ActiveRecordError.new(self), env: request.env, data: { message: "Failed trying to send physical product order email for #{order.to_yaml}: #{e.message}" })
    end
  end
end
