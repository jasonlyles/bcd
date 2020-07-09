class Part < ActiveRecord::Base
  # has_and_belongs_to_many :colors
  has_many :elements, dependent: :destroy
  has_many :colors, through: :elements

  def self.find_or_create_via_external(part_key)
    part_id = part_key.split('_').first
    part = Part.find_or_create_by(ldraw_id: part_id)
    unless part.name.present?
      part.update_from_bricklink(part_id)
      part.update_from_rebrickable(part_id)
      part.save!
    end
    part
  end

  def update_from_bricklink(part_id)
    bricklink_part = Bricklink.get_part(part_id)
    if bricklink_part['data'].present?
      bl_part = bricklink_part['data']
      self.bl_id = bl_part['no']
      self.name = bl_part['name']
      self.alternate_nos = bl_part['alternate_no']
      self.is_obsolete = bl_part['is_obsolete']
      self.year_from = bl_part['year_released']
      # Checking BL was successful. Was able to retrieve the data we want.
      # Mark false so we don't check again.
      self.check_bricklink = false
    end
  end

  def update_from_rebrickable(part_id)
    rebrickable_part = Rebrickable.get_part(part_id)
    if rebrickable_part['name'].present?
      self.brickowl_ids = rebrickable_part['external_ids']['BrickOwl']&.first
      self.year_to = rebrickable_part['year_to']
      # Checking Rebrickable was successful. Was able to retrieve the data we want.
      # Mark false so we don't check again.
      self.check_rebrickable = false
      # Try and pick up these values from Rebrickable if I couldn't get them from Bricklink
      self.name = rebrickable_part['name'] unless self.name
      self.alternate_nos = rebrickable_part['alternates'] unless self.alternate_nos
      self.year_from = rebrickable_part['year_from'] unless self.year_from
      self.bl_id = rebrickable_part['external_ids']['BrickLink']&.first || part_id
    end
  end
end
