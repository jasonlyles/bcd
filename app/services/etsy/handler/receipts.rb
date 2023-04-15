# frozen_string_literal: true

module Etsy
  module Handler
    class Receipts
      def initialize(receipts)
        @receipts = receipts
      end
      # For testing:
      # sr = Etsy::Api::Receipt.new.shop_receipts((Time.now - 2.weeks).to_i); ehr = Etsy::Handler::Receipts.new(sr); ehr.handle

      def handle
        # Loop through every receipt in the results and determine what to do with them
        @receipts['results'].each do |receipt|
          # First, if there's not been a change in a couple days, just skip it:
          next if updated_timestamp_stale?(receipt)

          # It's not a couple days old yet. Try to find it, and if we can find it, skip
          # it if the status is 'complete', as there's nothing left to do.
          tpr = ThirdPartyReceipt.where(source: 'etsy', third_party_receipt_identifier: receipt['receipt_id']).first
          next if tpr.present? && tpr.third_party_order_status.downcase == 'completed'

          user = ThirdParty::User.find_or_create_user('etsy', receipt['buyer_email'], receipt['buyer_user_id'])

          order = if tpr.present?
                    handle_existing_order(tpr, receipt)
                  else
                    handle_new_order(user, receipt)
                  end

          # If the order is complete, deliver the user their email.
          order.reload
          OrderMailer.third_party_guest_order_confirmation(order.id).deliver_later if order.status.upcase == 'COMPLETED'
        end
      end

      private

      def updated_timestamp_stale?(receipt)
        receipt['updated_timestamp'].present? && Time.at(receipt['updated_timestamp']) < 2.days.ago
      end

      def message_from_buyer(receipt)
        receipt['message_from_buyer']
      end

      def handle_new_order(user, receipt)
        etsy_receipt_handler = Etsy::Handler::Receipt.new(receipt)
        order = etsy_receipt_handler.create_order_and_line_items(user.id)
        # If we get a message from the buyer, email it to us so we can see it.
        OrderMailer.pass_along_buyer_message('etsy', order.id, receipt['buyer_email'], message_from_buyer(receipt)).deliver_later if message_from_buyer(receipt).present?
        # After the BCD order is created, create a ThirdPartyReceipt record with the raw respone body in it for reference.
        ThirdPartyReceipt.create_from_source('etsy', order.id, receipt['receipt_id'], receipt['status'], receipt['is_paid'], Time.at(receipt['created_timestamp']), Time.at(receipt['updated_timestamp']), receipt.to_json)

        order
      end

      def handle_existing_order(tpr, receipt)
        order = tpr.order
        # If this has already been marked in a final state via the admin
        # backend or otherwise, update the TPR and be done.

        if Order::FINAL_ORDER_STATUSES.include?(order.status)
          tpr.update(third_party_order_status: 'completed')
          return order
        end

        # Determine latest status
        receipt_handler = Etsy::Handler::Receipt.new(receipt)
        latest_status = receipt_handler.determine_order_status
        # There's been no change in order status, we're done for now.
        return order if latest_status.upcase == order.status

        # There's been a change in order status:
        order.update(status: latest_status)
        update_third_party_receipt(order, receipt, receipt_handler)

        order
      end

      def update_third_party_receipt(order, receipt, receipt_handler)
        third_party_receipt = order.third_party_receipt
        order_status = receipt_handler.third_party_order_status
        is_paid = receipt_handler.paid?

        third_party_receipt.update(third_party_order_status: order_status, third_party_is_paid: is_paid, raw_response_body: receipt.to_json)
      end
    end
  end
end
