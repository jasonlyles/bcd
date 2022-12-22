# frozen_string_literal: true

class ProductType < ApplicationRecord
  has_many :products, :dependent => :destroy # Make sure Product#destroy is getting called, and products with orders are not really getting destroyed
  has_one :image
  mount_uploader :image, ImageUploader

  # attr_accessible :name, :description, :ready_for_public, :image, :image_cache, :remove_image, :comes_with_description,
  # :comes_with_title, :digital_product

  validates :name, :uniqueness => true, :presence => true
  # validates :description, :presence => true, :length => {:maximum => 350, :minimum => 100}

  def self.find_live_product_types
    ProductType.where("ready_for_public = 't'")
  end
end
