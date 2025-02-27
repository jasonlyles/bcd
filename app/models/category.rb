# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :subcategories, dependent: :destroy
  has_many :products
  has_one :image
  mount_uploader :image, ImageUploader, validate_integrity: true

  # attr_accessible :name, :description, :ready_for_public, :image, :image_cache, :remove_image

  validates :name, uniqueness: true, presence: true
  validates :description, presence: true, length: { maximum: 350, minimum: 100 }

  def self.ransackable_attributes(_auth_object = nil)
    %w[name ready_for_public]
  end

  # Nothing here yet (if ever), but ransack insists I define it.
  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def self.find_live_categories
    Category.where("ready_for_public = 't'").order('name')
  end
end
