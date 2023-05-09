# frozen_string_literal: true

class Part < ApplicationRecord
  audited except: %i[created_at updated_at]
  has_many :elements, dependent: :restrict_with_error
  has_many :colors, through: :elements

  # attr_accessible :name, :ldraw_id, :bl_id, :lego_id, :check_bricklink, :check_rebrickable,
  # :alternate_nos, :is_obsolete, :year_from, :year_to, :brickowl_ids, :is_lsynth

  validates :name, presence: true
  validates :name, uniqueness: { scope: :ldraw_id }

  enum bricklink_state: %i[normal not_found obsoleted]

  before_save :reset_bricklink_state, if: :will_save_change_to_bl_id?

  def self.find_or_create_via_external(part_key)
    part_id = part_key.split('_').first
    part = Part.find_or_create_by(ldraw_id: part_id)

    PartInteractions::UpdateFromBricklink.run(part:) if part.check_bricklink?
    PartInteractions::UpdateFromRebrickable.run(part:) if part.check_rebrickable?

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

  # If the BrickLink ID is changing, assume that it's being changed to the correct
  # BrickLink ID and any states other than 'normal' are no longer correct, so we
  # reset to 'normal'.
  def reset_bricklink_state
    self.bricklink_state = 'normal'
  end
end
