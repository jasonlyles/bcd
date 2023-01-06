# frozen_string_literal: true

# For ~750 parts, this takes a couple of minutes to run locally.
module PartInteractions
  class ObsoletePartsCheck < BasePartInteraction
    # Grab all non-obsolete parts and we'll check them in BrickLink to see if they
    # are now marked obsolete.
    def run
      # Add a counter, just to keep track of progress while watching the task
      count = 0
      Part.where(is_obsolete: false).find_each do |part|
        count += 1
        Rails.logger.info "Working on part #{count}"
        bricklink_part = Bricklink.get_part(part.ldraw_id)
        bl_part = bricklink_part['data']
        if bl_part.blank?
          BackendNotification.create(message: "During ObsoletePartsCheck, could not find part in BrickLink by LDraw ID ##{part.ldraw_id}")
          next
        end
        # If the part is obsolete, let the admins know, and go ahead and mark the
        # part obsolete in the database.
        if bl_part['is_obsolete']
          BackendNotification.create(message: "Via ObsoletePartsCheck, BrickLink part ##{bl_part['no']} is now marked as obsolete in BrickLink. Please update parts lists.")
          part.is_obsolete = bl_part['is_obsolete']
          part.save!
        end
      end
    end
  end
end
