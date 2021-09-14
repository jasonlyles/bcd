module PartInteractions
  class UpdateFromBricklink < BasePartInteraction
    def run
      bricklink_part = Bricklink.get_part(@part.ldraw_id)
      Rails.logger.info("PartInteractions::UpdateFromBricklink::#{@part.id} Bricklink called")
      if bricklink_part['data'].present?
        bl_part = bricklink_part['data']
        @part.bl_id = bl_part['no']
        @part.name = bl_part['name']
        @part.alternate_nos = bl_part['alternate_no']
        @part.is_obsolete = bl_part['is_obsolete']
        @part.year_from = bl_part['year_released']
        # Checking BL was successful. Was able to retrieve the data we want.
        # Mark false so we don't check again.
        @part.check_bricklink = false
        @part.save!
        Rails.logger.info("PartInteractions::UpdateFromBricklink::#{@part.id} updated")
      end
    rescue StandardError => e
      self.error = 'Bricklink Update Failure'
      Rails.logger.error("PartInteractions::UpdateFromBricklink::#{@part.id} failed.\nERROR: #{e}\n#{e.backtrace}")
    end
  end
end
