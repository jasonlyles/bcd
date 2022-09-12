class Lot < ActiveRecord::Base
  belongs_to :parts_list
  belongs_to :element
  has_one :color, through: :element
  has_one :part, through: :element

  validates :element_id, uniqueness: { scope: :parts_list_id }
  validates :parts_list_id, :element_id, :quantity, presence: true

  attr_accessible :parts_list_id, :element_id, :quantity, :_destroy

  def part_name
    part.name
  end

  def part_id
    part.id
  end

  def part_ldraw_id
    part.ldraw_id
  end

  def color_name
    color.name
  end

  def color_bl_name
    color.bl_name
  end

  def color_id
    color.id
  end

  def color_ldraw_id
    color.ldraw_id
  end

  def thumb_image
    element.image.thumb.url
  end
end
