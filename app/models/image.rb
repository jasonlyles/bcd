# frozen_string_literal: true

class Image < ApplicationRecord
  belongs_to :product
  mount_uploader :url, ImageUploader, validate_integrity: true

  # attr_accessible :category_id, :location, :product_id, :url, :url_cache, :remove_url
end
