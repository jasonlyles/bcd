# frozen_string_literal: true

class Image < ApplicationRecord
  belongs_to :product
  acts_as_list scope: :product
  mount_uploader :url, ImageUploader, validate_integrity: true
  audited

  # attr_accessible :category_id, :location, :product_id, :url, :url_cache, :remove_url
  attr_accessor :from_modal

  after_destroy :delete_image_from_etsy

  def delete_image_from_etsy
    return if etsy_listing_image_id.blank?

    client = Etsy::Client.new(product_id:)
    client.delete_image(etsy_listing_image_id)
  end
end
