# frozen_string_literal: true

class LdrParser
  LSYNTH = YAML.load_file("#{Rails.root}/config/lsynth.yml")

  attr_accessor :submodels, :lsynthed_parts

  def initialize(ldr)
    @ldr = ldr
    @line_break = @ldr.match("\r\n") ? "\r\n" : "\n"
    @lines = @ldr.split(@line_break)
    @submodels = []
    @lsynthed_parts = []
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def parse
    # TODO: Try to convert lsynth parts, maybe flag parts that are troublesome for manual editing,
    # look up to see if I've stored a conversion from ldraw ID to Bricklink ID,
    # convert Ldraw color IDs to BL color IDs, etc.
    parts = {}
    temp_parts = []

    @lines.each_with_index do |line, i|
      # This will stop getting parts for the base model once a submodel is reached
      break if line.match(/0 FILE/) && i > 15

      @submodels << line.match(/\w+\.ldr/).to_s.downcase if line.match(/^1/) && line.match(/\.ldr$/)
      @lsynthed_parts << line.gsub('0 SYNTH BEGIN', '').split if line =~ /^0 SYNTH BEGIN/
      next unless line.match(/^1/) && line.match(/.dat$/)

      part = line.match(/\w+\.dat/).to_s.gsub!('.dat', '')
      next if lsynth_part?(part)

      color = line.match(/^1\s\d+/).to_s.gsub!('1 ', '')
      bl_part = get_bl_part_number(part)
      temp_parts << [bl_part, color, part]
    end

    # Now go through all submodels to determine the parts belonging to the submodels
    temp_parts = handle_submodels(temp_parts)

    # Not yet functional
    # handle_lsynthed_parts(temp_parts)

    temp_parts.each do |info|
      if parts.key?("#{info[0]}_#{info[1]}")
        parts["#{info[0]}_#{info[1]}"]['quantity'] += 1
      else
        parts["#{info[0]}_#{info[1]}"] = {}
        parts["#{info[0]}_#{info[1]}"]['quantity'] = 1
        parts["#{info[0]}_#{info[1]}"]['ldraw_part_num'] = info[2]
      end
    end

    parts
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  private

  def translate_lsynth_part(name)
    LSYNTH['lsynth']['translations'][name]
  end

  def lsynth_part?(part)
    lsynth_parts = LSYNTH['lsynth']['parts']
    lsynth_parts.include?(part.to_s)
  end

  def get_bl_part_number(part)
    Part.find_by_ldraw_id(part)&.bl_id || part
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def handle_submodels(temp_parts)
    @submodels.each do |submodel|
      count = 0
      store_lines = false

      @lines.each_with_index do |line, i|
        store_lines = true if (line.downcase == "0 file #{submodel.downcase}#{@line_break}" || line.downcase == "0 file #{submodel.downcase}") && i > 5
        next unless store_lines == true

        @submodels << line.match(/\w+\.ldr/).to_s.downcase if line.match(/^1/) && (line.match(/\.ldr#{@line_break}$/) || line.match(/\.ldr$/))
        @lsynthed_parts << line.gsub('0 SYNTH BEGIN', '').split if line =~ /^0 SYNTH BEGIN/
        break if line.match(/0 FILE/) && i > 5	&& (line.downcase != "0 file #{submodel.downcase}#{@line_break}" && line.downcase != "0 file #{submodel.downcase}")
        next unless line.match(/^1/) && (line.match(/.dat#{@line_break}$/) || line.match(/.dat$/))

        count += 1
        part = line.match(/\w+\.dat/).to_s.gsub!('.dat', '')
        next if lsynth_part?(part)

        color = line.match(/^1\s\d+/).to_s.gsub!('1 ', '')
        bl_part = get_bl_part_number(part)
        temp_parts << [bl_part, color, part]
      end
      # puts "#{submodel} has #{count} parts"
    end

    temp_parts
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  # TODO
  # def handle_lsynthed_parts(temp_parts)
  #  @lsynthed_parts.each do |lp|
  #    puts "LSYNTHED PART: #{lp.inspect}"
  #    tp = translate_lsynth_part(lp[0])
  #    if tp.nil?
  #      puts "Translated lsynth part coming back nil for #{lp[0]}. Trying to select from list."
  #      # TODO: Mark the part as needing some help, which will show up after the upload, when
  #      # the user has the chance to fix parts.
  #      tp = select_part_from_list(lp[0], lp[1])
  #      puts "Still can't find a match for #{lp[0]}. Abandoning all hope." if tp.nil?
  #    end
  #    temp_parts << [tp, lp[1], tp] unless tp.nil?
  #  end
  #  temp_parts
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
  #
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
