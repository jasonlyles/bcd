# frozen_string_literal: true

# TODO: All the below stuff:
#
# For v2:
# 1. Set up the tinypng API, and pass all images to it before uploading to S3. I'll have to pay for a
# $15 1 month subscription so I can convert up to 3500 images.
# 2. Come up with some code that deals specifically with the pieces that we have
# to put together in pieces, such as flowers and stems, hinge base and hinge base
# control stick, hinge plates, etc. The code should offer to combine the pieces
# into a single piece, but not force it. This can be done in part using BLs API.
# Will need to extend my usage of BL API for this, to make calls to the subset/superset calls.
# Will want to do that for each new part, check if it's part of a subset/superset.
# 3. Determine if a part is something generated by LSynth, and give Brian the option to
#    manually select the part from a select, and select the length, if appropriate.

# Workflow:
# * User submits XML or .ldr
# * Backend does a quick check to make sure it can parse the input before proceeding to generate images, etc.
# * Backend stores new part and part/color info and retrieves images from Bricklink/Rebrickable, etc.
# * User gets a confirmation page where they can edit or approve, or upload images for part/colors that couldn't get an image.
#   Confirmation page will have info about parts availability and flag anything too expensive,
#   or too rare, or obsolete. User can save progress on parts list. If something is part
#   of a subset, or can be combined into a superset, flag it.
# * User can identify primary/secondary colors for the model to see what additional colors
#   the model can be built in.
# User can see Lsynthed parts and update appropriately.
# * User will preview and approve parts list.

# Subscription user will have the ability to get an estimate for BrickOwl, and possibly for Bricklink
# Parts list user will have the ability to adjust part quality on a parts-list wide or at part/color level.

# PartsListInteractions::CreatePartsList.run(parts_list_id: 2)

module PartsListInteractions
  class CreatePartsList < BasePartsListInteraction
    attr_accessor :errors

    def initialize(options)
      super(options)
      @redis_total_key = "#{options[:jid]}_total"
      @redis_counter_key = "#{options[:jid]}_counter"
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def run
      self.errors = []
      parts_list = PartsList.find(@parts_list_id)
      parts = if parts_list.bricklink_xml.present?
                BricklinkXmlParser.new(parts_list.bricklink_xml).parse
              else
                LdrParser.new(parts_list.ldr).parse
              end
      redis = RedisClient.new
      redis.call('SET', @redis_total_key, parts.length)
      redis.call('SET', @redis_counter_key, 0)

      parts.each do |key, values|
        # TODO: In here, (or before if possible, after if necessary) assign the following values:
        # bl_part_num, part_name, color_name, image_link (OR) sprite_position
        # If I do a sprite sheet, will have to do it after this block, after images
        # have been retrieved. Don't need to save sprite position, as the css that's
        # generated will reference image by filename, so it will be pulling the guid,
        # which conveniently is already being stored for the element.
        # Not sure I'm going to do the spritesheet
        part = Part.find_or_create_via_external(key) # TODO: Pass along whether this is an LSynth part or not.
        element = Element.find_or_create_via_external(key)
        color = Color.find(element.color_id)

        parts[key]['color_name'] = color.bl_name
        parts[key]['part_name'] = part.name
        parts[key]['bl_part_num'] = part.bl_id
        parts[key]['guid'] = element.guid
        parts[key]['image_url'] = element.image.url

        Lot.create(parts_list_id: parts_list.id, element_id: element.id, quantity: values['quantity'])
        redis.call('INCR', @redis_counter_key)
      rescue StandardError => e
        self.error = e
        errors << e
        Rails.logger.error("PartsList::CreatePartsList::Part::#{@parts_list_id}\nERROR: #{e}\nBACKTRACE: #{e.backtrace}")
      end

      # TODO: By the time I get here, I should have completely assembled the parts
      # hash with all the desired keys, including names, image links, sprite sheet positions, etc.
      begin
        parts_list.parts = parts
        parts_list.save!
      rescue StandardError => e
        self.error = e
        Rails.logger.error("PartsList::CreatePartsList::Save::#{@parts_list_id}\nERROR: #{e}\nBACKTRACE: #{e.backtrace}")
      ensure
        # We're done, set jid to nil so the poller will know the job is done.
        parts_list.update(jid: nil)
        # Delete the keys as they're not needed any more.
        redis.call('DEL', @redis_total_key)
        redis.call('DEL', @redis_counter_key)
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
