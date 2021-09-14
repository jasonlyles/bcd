class Lot < ActiveRecord::Base
  belongs_to :parts_list
  belongs_to :element
  has_one :color, through: :element
  has_one :part, through: :element

  validates :element_id, uniqueness: { scope: :parts_list_id }

  def part_name
    part.name
  end

  def part_id
    part.id
  end

  def color_name
    color.name
  end

  def color_id
    color.id
  end
end
