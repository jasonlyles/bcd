class CreatePartsListJob < BaseJob
  LSYNTH = YAML.load_file("#{Rails.root}/config/lsynth.yml")
  @queue = :partslist

  # TODO:
  #
  # For v1:
  # 1. Set up the tinypng API, and pass all images to it before uploading to S3. I'll have to pay for a
  # $15 1 month subscription so I can convert up to 3500 images.
  # 2. Come up with some code that deals specifically with the pieces that we have
  # to put together in pieces, such as flowers and stems, hinge base and hinge base
  # control stick, hinge plates, etc. The code should offer to combine the pieces
  # into a single piece, but not force it. This can be done in part using BLs API.

  # This just exists to convert older BL XML files into a parts hash that I
  # can use to create what I need for the new parts list.
  def self.convert_bricklink_xml_to_parts_hash(bricklink_xml)
    parts = {}
    bricklink_xml.gsub!(/\r\n/, '')
    xml_doc = Nokogiri::XML(bricklink_xml)
    hash = Hash.from_xml(xml_doc.to_s)
    hash['INVENTORY']['ITEM'].each do |item|
      key = "#{item['ITEMID']}_#{item['COLOR']}"
      parts[key] = {}
      parts[key]['quantity']= item['MINQTY'].to_i
      parts[key]['ldraw_part_num'] = get_ldraw_part_number(item['ITEMID'])
    end
    parts
  end

  # TODO: Split this method up into smaller, easier to understand methods
  def self.convert_ldr_to_parts_hash(ldr)
    # TODO: Just grab all the parts and convert them to a parts hash, the same
    # as what I got back from convert_bricklink_xml_to_parts_hash
    # That still will need to do things like get everything from submodels, try to
    # convert lsynth parts, maybe flag parts that are troublesome for manual editing,
    # look up to see if I've stored a conversion from ldraw ID to Bricklink ID,
    # convert Ldraw color IDs to BL color IDs, etc.
    lines = ldr.split("\r\n")
    parts = {}
    temp_parts = []
    submodels = []
    lsynthed_parts = []

    lines.each_with_index do |line, i|
      # This will stop getting parts for the base model once a submodel is reached
      break if line.match(/0 FILE/) && i > 15
      submodels << line.match(/\w+\.ldr/).to_s.downcase if line.match(/^1/) && line.match(/\.ldr$/)
      lsynthed_parts << line.gsub('0 SYNTH BEGIN', '').split(' ') if line =~ /^0 SYNTH BEGIN/
      next unless line.match(/^1/) && line.match(/.dat$/)
      part = line.match(/\w+\.dat/).to_s.gsub!('.dat', '')
      next if lsynth_part?(part)
      color = line.match(/^1\s\d+/).to_s.gsub!('1 ', '')
      bl_part = get_bl_part_number(part)
      temp_parts << [bl_part, color, part]
    end

    # Now go through all submodels to determine the parts belonging to the submodels
    submodels.each do |submodel|
      count = 0
      store_lines = false
      lines.each_with_index do |line, i|
        store_lines = true if line.downcase == "0 file #{submodel.downcase}\r\n" && i > 5
        next unless store_lines == true
        submodels << line.match(/\w+\.ldr/).to_s.downcase if line.match(/^1/) && line.match(/\.ldr\r\n$/)
        lsynthed_parts << line.gsub('0 SYNTH BEGIN', '').split(' ') if line =~ /^0 SYNTH BEGIN/
        break if line.match(/0 FILE/) && i > 5	&& line.downcase != "0 file #{submodel.downcase}\r\n"
        next unless line.match(/^1/) && line.match(/.dat\r\n$/)
        count += 1
        part = line.match(/\w+\.dat/).to_s.gsub!('.dat', '')
        next if lsynth_part?(part)
        color = line.match(/^1\s\d+/).to_s.gsub!('1 ', '')
        bl_part = get_bl_part_number(part)
        temp_parts << [bl_part, color, part]
      end
      puts "#{submodel} has #{count} parts"
    end

    # TODO
    # lsynthed_parts.each do |lp|
    #   puts "LSYNTHED PART: #{lp.inspect}"
    #   tp = translate_lsynth_part(lp[0])
    #   if tp.nil?
    #     puts "Translated lsynth part coming back nil for #{lp[0]}. Trying to select from list."
    #     # TODO: Mark the part as needing some help, which will show up after the upload, when
    #     # the user has the chance to fix parts.
    #     tp = select_part_from_list(lp[0], lp[1])
    #     puts "Still can't find a match for #{lp[0]}. Abandoning all hope." if tp.nil?
    #   end
    #   temp_parts << [tp, lp[1], tp] unless tp.nil?
    # end

    temp_parts.each do |info|
      if parts.key?("#{info[0]}_#{info[1]}")
        parts["#{info[0]}_#{info[1]}"]['quantity'] += 1
      else
        parts["#{info[0]}_#{info[1]}"] = {}
        parts["#{info[0]}_#{info[1]}"]['quantity'] = 1
        parts["#{info[0]}_#{info[1]}"]['ldraw_part_num'] = info[2]
      end
    end

    parts_list = []
    total_parts_count = 0
    parts.each do |k, v|
      bl_part_num, color = k.split('_')
      ldraw_part_num = v['ldraw_part_num']
      bl_color, rgb, color_name, ldraw_color = get_colors(color)
      total_parts_count += v['quantity']
      parts_list << [bl_part_num, bl_color, rgb, color_name, ldraw_color, v['quantity'], ldraw_part_num]
    end

    # puts "Parts count = #{total_parts_count}"
    # xml = "<INVENTORY>\n"
    # parts_list.each do |part|
    #   xml += "<ITEM>\n<ITEMTYPE>P</ITEMTYPE>\n<ITEMID>#{part[0]}</ITEMID>\n<COLOR>#{part[1]}</COLOR>\n<MINQTY>#{part[5]}</MINQTY>\n</ITEM>\n"
    # end
    # xml += '</INVENTORY>'

    # puts 'Downloading/Generating images, if necessary...'
    # parts_list.each do |part|
    #   bl_part_num = part[0]
    #   ldraw_part_num = part[6]
    #   ldraw_color = part[4]
    #   part_object = get_part(ldraw_part_num)
    #   if part_object.nil?
    #     description = find_description("#{ldraw_part_num}.dat")
    #     part_id = create_part(bl_part_num, ldraw_part_num, description)
    #   else
    #     part_id = get_part_id(ldraw_part_num)
    #     description = part_object.name
    #   end
    #   # Now let's check for images, if we need them, download them, and if that doesn't work, generate them
    #   if part_id.nil?
    #     # Not sure yet
    #   else
    #     # Look for a elements record, and check if the image flag is set. If the image flag is not set to 1, then I need to download/create the image using the code below
    #     element = get_element(ldraw_part_num, ldraw_color)
    #     if element.nil?
    #       element = create_element(ldraw_part_num, ldraw_color)
    #       get_or_generate_image(ldraw_part_num, ldraw_color) unless element.nil?
    #     else
    #       if element.image == true
    #       # Do nothing?
    #       else
    #         get_or_generate_image(ldraw_part_num, ldraw_color)
    #       end
    #     end
    #   end
    #   part << description
    # end
    # puts 'Images taken care of'
    parts
  end

  # Workflow:
  # * User submits XML or .ldr
  # * Backend does a quick check to make sure it can parse the input before proceeding to generate images, etc.
  # * Backend stores new part and part/color info and retrieves images from Bricklink/Rebrickable, etc.
  # * User gets a confirmation page where they can edit or approve, or upload images for part/colors that couldn't get an image.
    # Confirmation page will have info about parts availability and flag anything too expensive,
    # or too rare, or obsolete. User can save progress on parts list. If something is part
    # of a subset, or can be combined into a superset, flag it.
  # * User can identify primary/secondary colors for the model to see what additional colors
    # the model can be built in.
  # * User will preview and approve parts list.

  # Subscription user will have the ability to get an estimate for BrickOwl, and possibly for Bricklink
  # Parts list user will have the ability to adjust part quality on a parts-list wide or at part/color level.

  # TODO:
  # Might not be getting all parts from .ldrs:
  # tilting_and_sliding_mechanism.ldr has 0 parts
  # over_wheel_wells_left.ldr has 0 parts
  # over_wheel_wells_right.ldr has 0 parts
  # front_grille.ldr has 0 parts
  # bed.ldr has 0 parts

  # def perform
  def self.do_it(options)
    parts_list = PartsList.find(options[:parts_list_id]) # TODO: Switch this back to stringy key

    parts = if parts_list.bricklink_xml.present?
              convert_bricklink_xml_to_parts_hash(parts_list.bricklink_xml)
            else
              convert_ldr_to_parts_hash(parts_list.ldr)
            end

    temp_count = 0
    parts.each do |key, values|
      # TODO: In here, (or before if possible, after if necessary) assign the following values:
      # bl_part_num, part_name, color_name, image_link (OR) sprite_position
      # If I do a sprite sheet, will have to do it after this block, after images
      # have been retrieved. Don't need to save sprite position, as the css that's
      # generated will reference image by filename, so it will be pulling the guid,
      # which conveniently is already being stored for the element.
      unless temp_count >= 1000 # This is temporary, just while I'm getting this figured out
        part = Part.find_or_create_via_external(key) # TODO: Pass along whether this is an LSynth part or not.
        element = Element.find_or_create_via_external(key)
        color = Color.find(element.color_id)

        parts[key]['color_name'] = color.bl_name
        parts[key]['part_name'] = part.name
        parts[key]['bl_part_num'] = part.bl_id
        parts[key]['guid'] = element.guid

        Lot.create(parts_list_id: parts_list.id, element_id: element.id, quantity: values['quantity'])
        temp_count += 1
      end
    end
#binding.pry

    # TODO: By the time I get here, I should have completely assembled the parts
    # hash with all the desired keys, including names, image links, sprite sheet positions, etc.
    parts_list.parts = parts
    parts_list.save!

# TODO: Pick back up here. Both LDR and XML are returning a parts hash that's structured the same.
# Even though the structure includes bl_id and ldraw_id, make sure to go through each
# part and make sure it has the right ldraw ID and BL ID.
  #   {
  #      "3832_71" => {
  #              "quantity" => 2,
  #     "ldraw_part_num" => "3832"
  # },
  #      "3034_71" => {
  #              "quantity" => 1,
  #     "ldraw_part_num" => "3034"
  # }

    # 3. Determine if a part is something generated by LSynth, and give Brian the option to
      # manually select the part from a select, and select the length, if appropriate.
    # 4. After everything has been done in here, the user needs to be presented with a
      # form with all the parts, where they are given the option to edit part #, color, qty,
      # image, add a BL ID in the case the ldraw ID isn't used by BL. The user should
      # be able to request a new image from BL (which they might
      # want to do after correcting a part # or color #), or save a url to the
      # image here if the one displayed is not satisfactory.
  end

  def self.get_bl_part_number(part)
    PartsList::Part.find_by_ldraw_id(part)&.bl_id || part
  end

  def self.get_ldraw_part_number(part)
    PartsList::Part.find_by_bl_id(part)&.ldraw_id || part
  end

  def self.get_colors(color_id)
    color = Color.find_by_ldraw_id(color_id)
    [color.bl_id, color.ldraw_rgb, color.bl_name, color.ldraw_id]
  end

  # TODO
  # def clean_xml(text)
  #   text.match(/>\w+</).to_s.match(/\w+/).to_s
  # end
  # TODO
  # def get_element(ldraw_part_num, ldraw_color)
  #   result = DATABASE.query("select * from elements where part_id='#{ldraw_part_num}' and color_id='#{ldraw_color}'").first
  #   unless result.nil?
  #     element = Element.new
  #     element.part_id = result['part_id']
  #     element.color_id = result['color_id']
  #     element.image = result['image'] == 1
  #     element.image_url = result['image_url']
  #     element.guid = result['guid']
  #     return element
  #   end
  # end
  # TODO
  # def create_element(ldraw_part_num, ldraw_color)
  #   guid = UUIDTools::UUID.random_create.to_s
  #   begin
  #     DATABASE.query("insert into elements (part_id,color_id,guid)values('#{ldraw_part_num}','#{ldraw_color}','#{guid}')")
  #     return true
  #   rescue StandardError => e
  #     raise "ERROR CREATING ELEMENT FOR PART: #{ldraw_part_num} AND COLOR: #{ldraw_color} \nERROR: #{e}"
  #   end
  # end
  # TODO
  # def update_element_image(part_id, color, image_url)
  #   DATABASE.query("update elements set image = 1, image_url='#{image_url}' where part_id = '#{part_id}' and color_id = '#{color}'")
  #   return true
  # rescue StandardError => e
  #   raise "COULDN'T UPDATE ELEMENTS FOR PART: #{part_id} AND COLOR: #{color} \nERROR: #{e}"
  # end
  # TODO
  # def get_part(ldraw_num)
  #   result = DATABASE.query("select id, bl_id,ldraw_id,name from parts where ldraw_id='#{ldraw_num}'").first
  #
  #   if result.nil?
  #     return nil
  #   else
  #     part = Part.new
  #     part.record_id = result['id']
  #     part.bl_id = result['bl_id']
  #     part.ldraw_id = result['ldraw_id']
  #     part.name = result['name']
  #     return part
  #   end
  # end
  # TODO
  # def translate_color(ldraw_color_id)
  #   result = DATABASE.query("select name from colors where ldraw_id = '#{ldraw_color_id}'")
  # 	binding.pry
  # 	1/0
  #   if result.nil?
  #     return ldraw_color_id
  #   else
  #     return result
  #   end
  # end
  # TODO
  # def get_part_id(ldraw_id)
  #   part_id = DATABASE.query("select id from parts where ldraw_id = '#{ldraw_id}'").first['id']
  #   part_id
  # end
  # TODO
  # def create_part(bl_id, ldraw_id, name)
  #   DATABASE.query("insert into parts (bl_id,ldraw_id,name)values('#{bl_id}','#{ldraw_id}','#{name}')")
  #   part_id = DATABASE.query("select id from parts where ldraw_id = '#{ldraw_id}'").first['id']
  #   return part_id
  # rescue StandardError => e
  #   raise "ERROR CREATING PART WITH LDRAW ID #{ldraw_id}: #{e}"
  # end
  # TODO
  # def get_bl_color(color_id)
  #   color_id = DATABASE.query("select bl_id from colors where ldraw_id='#{color_id}' limit 1")
  # 	binding.pry
  # 	1/0
  #   color_id
  # end


  # TODO
  # def connect_to_amazon
  #   Aws.config = { access_key_id: $config['amazon']['access_key_id'], secret_access_key: $config['amazon']['secret_access_key'] }
  #   s3 = Aws::S3::Resource.new
  #   $bcd_bucket = s3.bucket($config['amazon']['image_bucket'])
  # end

  # TODO
  # def upload_to_amazon(part, color)
  #   element = get_element(part, color)
  #   image = "#{LDRAW_IMAGES_ROOT}/#{color}/#{part}.png"
  #   puts "About to upload to Amazon: #{color}/#{element.guid}-#{part}.png"
  #
  #   obj = $bcd_bucket.object("parts_images/#{color}/#{element.guid}-#{part}.png")
  #   obj.upload_file(image)
  #   obj.exists? # If false, it didn't upload, if true, it did
  # end

  # TODO
  # def amazon_image_url(part, color)
  #   element = get_element(part, color)
  #   "https://#{$config['amazon']['cloudfront_url']}/parts_images/#{color}/#{element.guid}-#{part}.png"
  # end

  # TODO
  # def upload_image(ldraw_part_num, ldraw_color)
  #   uploaded = upload_to_amazon(ldraw_part_num, ldraw_color)
  #   if uploaded == true
  #     image_url = amazon_image_url(ldraw_part_num, ldraw_color)
  #     update_element_image(ldraw_part_num, ldraw_color, image_url)
  #   end
  # end

  # TODO
  def self.lsynth_part?(part)
    lsynth_parts = LSYNTH['lsynth']['parts']
    lsynth_parts.include?(part.to_s) ? true : false
  end

  # TODO
  def self.translate_lsynth_part(name)
    LSYNTH['lsynth']['translations'][name]
  end

  # TODO
  # def select_part_from_list(name, color)
  #   color = translate_color(color)
  #   # For each part where there can be multiple versions based on length, present user with options (10L, 40L, etc)
  #   # In order to make this work, I'll have to have a list of options for each part
  #   part = case name
  #          when 'TECHNIC_RIBBED_HOSE'
  #            choice = 0
  #            # technic ribbed hoses come in every length from 2L to 32L
  #            until (2..32).cover?(choice)
  #              puts "Select a length for #{color} TECHNIC RIBBED HOSE:"
  #              puts 'enter 2 for 2L, 3 for 3L, etc., up to 32'
  #              choice = STDIN.gets.chomp.to_i
  #            end
  #            choice = "0#{choice}" if choice.to_s.length == 1
  #            "78c#{choice}"
  #          else
  #            puts "Not familiar with #{color} #{name}. Please update script to include this part if it's correct."
  #            nil
  #       end
  #   part
  # end
end
