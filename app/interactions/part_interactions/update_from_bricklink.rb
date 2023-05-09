# frozen_string_literal: true

module PartInteractions
  class UpdateFromBricklink < BasePartInteraction
    # rubocop:disable Metrics/AbcSize
    def run
      # Need to try to retrieve via ldraw ID here because we don't have the BrickLink ID yet.
      bricklink_part = Bricklink.get_part(@part.ldraw_id)
      Rails.logger.info("PartInteractions::UpdateFromBricklink::#{@part.id} Bricklink called")
      if bricklink_part['data'].present?
        bl_part = bricklink_part['data']
        @part.bl_id = bl_part['no']
        @part.name = Nokogiri::HTML.parse(bl_part['name']).text
        @part.alternate_nos = { 'alternates' => bl_part['alternate_no'].split(',') } if bl_part['alternate_no'].present?
        @part.is_obsolete = bl_part['is_obsolete']
        @part.year_from = bl_part['year_released']
        # Checking BL was successful. Was able to retrieve the data we want.
        # Mark false so we don't check again.
        @part.check_bricklink = false
        @part.save!
        Rails.logger.info("PartInteractions::UpdateFromBricklink::#{@part.id} updated")
      else
        self.error = "PartInteractions::UpdateFromBricklink::#{@part.id} Bricklink called - Could not find Bricklink data"
      end
    rescue StandardError => e
      self.error = "Bricklink Update Failure. LDraw ID: #{@part.ldraw_id} ERROR: #{e.message}"
      Rails.logger.error("PartInteractions::UpdateFromBricklink::#{@part.id} failed.\nERROR: #{e}\n#{e.backtrace}")
    end
    # rubocop:enable Metrics/AbcSize
  end
end
