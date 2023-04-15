# frozen_string_literal: true

module Etsy
  module Api
    class Receipt < Base
      def initialize(options = {})
        @receipt_id = options[:receipt_id]
        @shop_id = Rails.application.credentials.etsy.shop_id
      end

      # This call will get receipts from our store so we can see when there are new
      # ones. We'll need to store existing ones so we can know when there are new ones,
      # and then we'll generate parts list urls and email them to the user. This uses
      # Etsy's getShopReceipts API. Not sure if I will need to also use the getShopReceipt
      # API and/or the getShopReceiptTransaction API.
      def shop_receipts(min_created, limit = 100, offset = 0)
        path = "shops/#{@shop_id}/receipts?limit=#{limit}"
        path += "&min_created=#{min_created}" if min_created.present?
        path += "&offset=#{offset}" if offset.present? && offset.positive?
        # For local testing:
        # stub_shop_receipts
        api_get(path)
      end

      # updateShopReceipt
      def update_receipt
        # May have to update the receipt to say that it was_paid. Will have to watch
        # statuses to see how they come in, if anything is ever marked completed or not.
        # Perhaps I can store the updated_at value and periodically check the getShopReceipt
        # API until the status is marked complete, at which point an email goes out.
        # Maybe I just wait until the status is paid? Idk, Etsy documentation sucks.
      end

      private

      def stub_no_shop_receipts
        { 'count' => 0, 'results' => [] }
      end

      # Actual data from shop_receipts:
      # :nocov:
      # rubocop:disable Metrics/MethodLength
      def stub_shop_receipts
        { 'count' => 253,
          'results' =>
          [{ 'receipt_id' => 2_842_756_345,
             'receipt_type' => 0,
             'seller_user_id' => 757_471_822,
             'seller_email' => 'lylesjt@gmail.com',
             'buyer_user_id' => 14_329_118,
             'buyer_email' => 'rando@yahoo.com',
             'name' => 'Rando Lyles',
             'first_line' => '123 Fake St.',
             'second_line' => '',
             'city' => 'Pittsburgh',
             'state' => 'PA',
             'zip' => '12345',
             'status' => 'Completed',
             'formatted_address' => "Rando Lyles\n123 Fake St.\nPITTSBURGH, PA 12345\nUnited States",
             'country_iso' => 'US',
             'payment_method' => 'cc',
             'payment_email' => '',
             'message_from_payment' => nil,
             'message_from_seller' => nil,
             'message_from_buyer' => 'This is a test message',
             'is_shipped' => false,
             'is_paid' => true,
             'create_timestamp' => 1_680_378_232,
             'created_timestamp' => 1_680_378_232,
             'update_timestamp' => 1_681_155_836,
             'updated_timestamp' => 1_713_204_727,
             'is_gift' => false,
             'gift_message' => '',
             'grandtotal' => { 'amount' => 300, 'divisor' => 100, 'currency_code' => 'USD' },
             'subtotal' => { 'amount' => 300, 'divisor' => 100, 'currency_code' => 'USD' },
             'total_price' => { 'amount' => 300, 'divisor' => 100, 'currency_code' => 'USD' },
             'total_shipping_cost' => { 'amount' => 0, 'divisor' => 100, 'currency_code' => 'USD' },
             'total_tax_cost' => { 'amount' => 0, 'divisor' => 100, 'currency_code' => 'USD' },
             'total_vat_cost' => { 'amount' => 0, 'divisor' => 100, 'currency_code' => 'USD' },
             'discount_amt' => { 'amount' => 0, 'divisor' => 100, 'currency_code' => 'USD' },
             'gift_wrap_price' => { 'amount' => 0, 'divisor' => 100, 'currency_code' => 'USD' },
             'shipments' => [],
             'transactions' =>
             [{ 'transaction_id' => 3_498_721_468,
                'title' => 'Custom Lego Instructions: Colonial Revival House - No Bricks Included - Please read description',
                'description' =>
                "This listing is for a link to download a PDF of instructions and access to an interactive parts list to help you gather the pieces you need to build the model. The PDF that you can download through this listing includes helpful links and email addresses to contact us. No Lego bricks are included.\n\nThe download link will be sent via email to the email address you have registered with Etsy. If you would like to use another email, please contact us to let us know.\n\nWhat you will receive:\n- You will get a link to download the instructions PDF, which you can download up to 5 times.\n- Unlimited access to an interactive parts list to help assemble the pieces you need to build the model.\n- Access to a new user tutorial and a frequently asked questions page if you&#39;re having trouble getting started.\n- We also have a contact form on our site you can use to get in direct contact with us if the new user tutorial and frequently asked questions pages aren&#39;t enough help.\n\nProduct Description:\n\nOne of our best sellers, the Colonial Revival house modeled after a real house in the Fan in Richmond, VA. This model is modular and features 2 furnished floors, a crawlspace and a porch on front and back. This model will go great in any row house neighborhood in your modular city. Building sits on a 16x32 baseplate.\n\nThis is NOT a LEGO® product. LEGO® is a trademark of the LEGO Group of companies which does not sponsor, authorize or endorse this listing.",
                'seller_user_id' => 757_105_822,
                'buyer_user_id' => 14_112_118,
                'create_timestamp' => 1_680_378_232,
                'created_timestamp' => 1_680_378_232,
                'paid_timestamp' => nil,
                'shipped_timestamp' => nil,
                'quantity' => 1,
                'listing_image_id' => 4_777_598_760,
                'receipt_id' => 2_384_119_345,
                'is_digital' => true,
                'file_data' => '1 PDF',
                'listing_id' => 1_332_911_025,
                'sku' => 'CB002',
                'product_id' => 15_983_128_302,
                'transaction_type' => 'listing',
                'price' => { 'amount' => 300, 'divisor' => 100, 'currency_code' => 'USD' },
                'shipping_cost' => { 'amount' => 0, 'divisor' => 100, 'currency_code' => 'USD' },
                'variations' => [],
                'product_data' => [],
                'shipping_profile_id' => 197_448_955_031,
                'min_processing_days' => nil,
                'max_processing_days' => nil,
                'shipping_method' => nil,
                'shipping_upgrade' => nil,
                'expected_ship_date' => nil,
                'buyer_coupon' => 0,
                'shop_coupon' => 0 }],
             'refunds' => [] }] }
      end
      # rubocop:enable Metrics/MethodLength
      # :nocov:
    end
  end
end
