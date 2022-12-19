class Part < ActiveRecord::Base
  has_many :elements, dependent: :restrict_with_error
  has_many :colors, through: :elements

  attr_accessible :name, :ldraw_id, :bl_id, :lego_id, :check_bricklink, :check_rebrickable,
    :alternate_nos, :is_obsolete, :year_from, :year_to, :brickowl_ids, :is_lsynth

  validates :name, presence: true
  validates :name, uniqueness: { scope: :ldraw_id }

  def self.find_or_create_via_external(part_key)
    part_id = part_key.split('_').first
    part = Part.find_or_create_by(ldraw_id: part_id)

    PartInteractions::UpdateFromBricklink.run(part: part) if part.check_bricklink?
    PartInteractions::UpdateFromRebrickable.run(part: part) if part.check_rebrickable?

    part
  end

  ransacker :alternate_nos do |parent|
    Arel::Nodes::InfixOperation.new('->>', parent.table[:alternate_nos], Arel::Nodes.build_quoted('alternates'))
  end

  def images
    elements.map(&:image)
  end

  def name_and_ids
    "#{name} (#{bl_id}/#{ldraw_id})"
  end
end
