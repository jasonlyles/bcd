class Color < ActiveRecord::Base
  # Don't allow color to be destroyed if it belongs to an element.
  has_many :elements, dependent: :restrict_with_error
  has_many :parts, through: :elements

  attr_accessible :name, :ldraw_id, :bl_name, :bl_id, :lego_name, :lego_id, :ldraw_rgb, :rgb

  validates :name, uniqueness: true, presence: true
end
