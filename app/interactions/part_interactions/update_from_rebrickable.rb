module PartInteractions
  class UpdateFromRebrickable < BasePartInteraction
    def run
      rebrickable_part = Rebrickable.get_part(@part.ldraw_id)
      Rails.logger.info("PartInteractions::UpdateFromRebrickable::#{@part.id} Rebrickable called")
      if rebrickable_part['name'].present?
        @part.brickowl_ids = rebrickable_part['external_ids']['BrickOwl']&.first
        @part.year_to = rebrickable_part['year_to']
        # Checking Rebrickable was successful. Was able to retrieve the data we want.
        # Mark false so we don't check again.
        @part.check_rebrickable = false
        # Try and pick up these values from Rebrickable if I couldn't get them from Bricklink
        @part.name = rebrickable_part['name'] unless @part.name
        @part.alternate_nos = rebrickable_part['alternates'] unless @part.alternate_nos
        @part.year_from = rebrickable_part['year_from'] unless @part.year_from
        @part.bl_id = rebrickable_part['external_ids']['BrickLink']&.first || @part.ldraw_id
        @part.save!
        Rails.logger.info("PartInteractions::UpdateFromRebrickable::#{@part.id} updated")
      end
    rescue StandardError => e
      self.error = 'Rebrickable Update Failure'
      Rails.logger.error("PartInteractions::UpdateFromRebrickable::#{@part.id} failed.\nERROR: #{e}\n#{e.backtrace}")
    end
  end
end
