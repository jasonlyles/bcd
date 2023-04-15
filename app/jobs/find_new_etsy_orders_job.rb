# frozen_string_literal: true

class FindNewEtsyOrdersJob
  include Sidekiq::Job
  sidekiq_options queue: 'critical'

  def perform
    # Set how far back we want to go
    min_created = (Time.now - 2.weeks).to_i
    offset = 0
    limit = 100
    etsy_receipt = Etsy::Api::Receipt.new
    shop_receipts = etsy_receipt.shop_receipts(min_created, limit, offset)
    total_count = shop_receipts['count']
    # Now that we know how many results we're getting back, figure out how many
    # requests we have to make to get all the receipts. We divide and take the floor
    # because we've already made our first request, we don't have to take the ceiling
    # to get the remainder.
    num_of_additional_requests = (total_count / limit.to_f).floor

    receipt_handler = Etsy::Handler::Receipts.new(shop_receipts)
    receipt_handler.handle

    num_of_additional_requests.times do
      offset += limit
      shop_receipts = etsy_receipt.shop_receipts(min_created, limit, offset)
      receipt_handler = Etsy::Handler::Receipts.new(shop_receipts)
      receipt_handler.handle
    end
  end
end
