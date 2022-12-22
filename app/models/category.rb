# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :subcategories, dependent: :destroy
  has_many :products
  has_one :image
  mount_uploader :image, ImageUploader

  # attr_accessible :name, :description, :ready_for_public, :image, :image_cache, :remove_image

  validates :name, uniqueness: true, presence: true
  validates :description, presence: true, length: { maximum: 350, minimum: 100 }

  def self.find_live_categories
    Category.where("ready_for_public = 't'").order('name')
  end
end
