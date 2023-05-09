# frozen_string_literal: true

# For ~750 parts, this takes a couple of minutes to run locally.
module PartInteractions
  class ObsoletePartsCheck < BasePartInteraction
    # Grab all non-obsolete parts and we'll check them in BrickLink to see if they
    # are now marked obsolete.
    def run
      # Add a counter, just to keep track of progress while watching the task
      count = 0
      could_not_find = 0
      # We want to check those parts that are not marked obsolete, the BL state is
      # 'normal', and the part is not an Lsynth part.
      Part.where("is_obsolete = '0' AND bricklink_state = '0' AND is_lsynth = '0'").find_each do |part|
        count += 1
        Rails.logger.debug "Working on part #{count}"
        # Retrieve via the BrickLink ID because we have it, and sometimes the LDraw
        # ID can differ and is marked as an alternate number, in which case it won't
        # be returned by this call.
        bricklink_part = Bricklink.get_part(part.bl_id)
        bl_part = bricklink_part['data']
        if bl_part.blank?
          could_not_find += 1
          part.update(bricklink_state: 'not_found')
          next
        end
        # If the part is obsolete, let the admins know, and go ahead and mark the
        # part obsolete in the database.
        next unless bl_part['is_obsolete']

        BackendNotification.create(message: "Via ObsoletePartsCheck, BrickLink part ##{bl_part['no']} is now marked as obsolete in BrickLink. Please update parts lists.")
        part.update(is_obsolete: true, bricklink_state: 'obsoleted')
      end

      BackendNotification.create(message: "ObsoletePartsCheck found #{could_not_find} parts it could not find in Bricklink. Check out the parts <a href=\"/admin/parts?q%5Bbricklink_state_eq%5D=1\">here</a>. Please update parts lists.") if could_not_find.positive?
    end
  end
end
