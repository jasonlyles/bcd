class Part < ActiveRecord::Base
  has_many :elements, dependent: :destroy
  has_many :colors, through: :elements

  def self.find_or_create_via_external(part_key)
    part_id = part_key.split('_').first
    part = Part.find_or_create_by(ldraw_id: part_id)
    unless part.name.present?
      interaction = PartInteractions::UpdateFromBricklink.run(part: part)
      interaction = PartInteractions::UpdateFromRebrickable.run(part: part)
      part.save!
    end
    part
  end
end
