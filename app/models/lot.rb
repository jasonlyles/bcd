class Lot < ActiveRecord::Base
  belongs_to :parts_list
  belongs_to :element

  validates :element_id, uniqueness: { scope: :parts_list_id }

  attr_accessor :part_id, :color_id

  def part_name
    element.try(:part).try(:name)
  end

  def part_id
    element.try(:part).try(:id)
  end

  def color_name
    element.try(:color).try(:name)
  end

  def color_id
    element.try(:color).try(:id)
  end
end
