# frozen_string_literal: true

module Etsy
  module Handler
    class Receipt
      def initialize(json)
        @json = json
      end

      def create_order_and_line_items(user_id)
        order = Order.create!(
          user_id:,
          status: determine_order_status,
          source: 'etsy',
          third_party_order_identifier: @json['receipt_id']
        )

        @json['transactions'].each do |transaction|
          if transaction['seller_user_id'].to_s == Rails.application.credentials.etsy.seller_user_id.to_s
            LineItem.create!(
              order_id: order.id,
              product_id: lookup_product_id(transaction),
              quantity: transaction['quantity'],
              total_price: calculate_total_price(transaction),
              third_party_line_item_identifier: transaction['transaction_id'],
              third_party_line_item_paid_at: transaction['paid_timestamp'].present? ? Time.at(transaction['paid_timestamp']) : nil
            )
          else
            ExceptionNotifier.notify_exception(StandardError.new, data: { message: "Unknown seller_user_id from Etsy: #{transaction['seller_user_id']}" })
          end
        end

        order
      end

      # Status options, although not sure how they show up in the results:
      # paid, completed, open, payment processing or canceled
      def determine_order_status
        # Be sure to downcase status
        case third_party_order_status.downcase
        when 'paid', 'open', 'payment processing', 'processing', 'unpaid', 'unshipped'
          'THIRD_PARTY_PENDING'
        when 'canceled'
          'THIRD_PARTY_CANCELED'
        when 'completed'
          paid? == true ? 'COMPLETED' : 'THIRD_PARTY_PENDING_PAYMENT'
        else
          ExceptionNotifier.notify_exception(StandardError.new, data: { message: "Unknown order status from Etsy: #{third_party_order_status}" })
          "UNKNOWN_STATUS: #{third_party_order_status}"
        end
      end

      def third_party_order_status
        @json['status']
      end

      def paid?
        @json['is_paid']
      end

      private

      def lookup_product_id(transaction)
        product = Product.where(product_code: transaction['sku']).first
        return product.id if product.present?

        product = Product.where(etsy_listing_id: transaction['listing_id']).first
        return product.id if product.present?

        raise StandardError.new, "Etsy::Handler::Receipts#lookup_product_id could not find product by code '#{transaction['sku']}' or etsy_listing_id '#{transaction['listing_id']}'"
      end

      # TODO: Make sure I don't have to take quantity into account:
      def calculate_total_price(transaction)
        transaction['price']['amount'] / transaction['price']['divisor'].to_f
      end
    end
  end
end
