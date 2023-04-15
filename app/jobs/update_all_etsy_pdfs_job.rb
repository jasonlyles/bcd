# frozen_string_literal: true

class UpdateAllEtsyPdfsJob
  include Sidekiq::Job
  sidekiq_options queue: 'low', retry: false

  def perform
    start_time = Time.now
    begin
      Product.where("etsy_listing_id IS NOT NULL AND etsy_listing_id <> ''").pluck(:id).each do |product_id|
        Rails.logger.info("UpdateAllEtsyPdfsJob is updating product ID #{product_id}")
        client = Etsy::Client.new(product_id:)
        client.replace_pdf
        Rails.logger.info("UpdateAllEtsyPdfsJob has updated product ID #{product_id}")
      end
    rescue StandardError => e
      BackendNotification.create(message: 'Background Job to update all Etsy product PDFs failed')
      raise e
    end
    end_time = Time.now

    BackendNotification.create(message: "Background Job to update all Etsy product PDFs completed in #{end_time - start_time} seconds")
  end
end
