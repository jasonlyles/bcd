module PartInteractions
  class UpdateFromRebrickable < BasePartInteraction
    def run
      rebrickable_part = Rebrickable.get_part(@part.ldraw_id)
      Rails.logger.info("PartInteractions::UpdateFromRebrickable::#{@part.id} Rebrickable called")
      if rebrickable_part['name'].present?
        @part.brickowl_ids = rebrickable_part['external_ids']['BrickOwl']&.first
        @part.year_to = rebrickable_part['year_to']
        # Try and pick up these values from Rebrickable if I couldn't get them from Bricklink
        @part.name = rebrickable_part['name'] unless @part.name
        @part.year_from = rebrickable_part['year_from'] unless @part.year_from
        @part.bl_id = rebrickable_part['external_ids']['BrickLink']&.first || @part.ldraw_id unless @part.bl_id

        if rebrickable_part['alternates'].present?
          if @part.alternate_nos.present? && @part.alternate_nos.keys.include?('alternates')
            @part.alternate_nos['alternates'] << rebrickable_part['alternates']
            @part.alternate_nos['alternates'].flatten!
          else
            @part.alternate_nos = { 'alternates' => rebrickable_part['alternates'] }
          end
        end

        # Checking Rebrickable was successful. Was able to retrieve the data we want.
        # Mark false so we don't check again.
        @part.check_rebrickable = false
        @part.save!
        Rails.logger.info("PartInteractions::UpdateFromRebrickable::#{@part.id} updated")
      else
        Rails.logger.error("PartInteractions::UpdateFromRebrickable::#{@part.id} Rebrickable called - Could not find Rebrickable data")
      end
    rescue StandardError => e
      self.error = "Rebrickable Update Failure. LDraw ID: #{@part.ldraw_id} ERROR: #{e.message}"
      Rails.logger.error("PartInteractions::UpdateFromRebrickable::#{@part.id} failed.\nERROR: #{e}\n#{e.backtrace}")
    end
  end
end
