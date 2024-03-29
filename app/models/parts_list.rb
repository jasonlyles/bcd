# frozen_string_literal: true

class PartsList < ApplicationRecord
  audited except: %i[created_at updated_at]
  mount_uploader :file, PartsListUploader
  belongs_to :product
  has_many :lots, dependent: :destroy
  has_many :elements, through: :lots
  has_many :user_parts_lists
  accepts_nested_attributes_for :lots, allow_destroy: true
  validates_associated :lots

  validates :name, presence: true
  validates :name, uniqueness: { scope: :product_id, message: "Don't name more than one parts list the same thing for this product" }
  validates :product_id, presence: true
  validates :bricklink_xml, presence: { if: -> { ldr.blank? } }
  validates :ldr, presence: { if: -> { bricklink_xml.blank? } }
  validates :original_filename, presence: true

  # attr_accessible :name, :product_id, :approved, :lots_attributes, :file, :file_cache, :remove_file, :original_filename, :bricklink_xml, :ldr

  def product_name
    product.name
  end

  def parts_quantity
    lots.inject(0) { |sum, p| sum + p.quantity }
  end

  # rubocop:disable Naming/PredicateName
  def has_obsolete_part?
    elements.includes(:part).map(&:part).select(&:is_obsolete?).present?
  end
  # rubocop:enable Naming/PredicateName
end
