# frozen_string_literal: true

# This just exists to convert older BL XML files into a parts hash that I
# can use to create what I need for the new parts list.
class BricklinkXmlParser
  def initialize(bricklink_xml)
    @bricklink_xml = bricklink_xml
  end

  def parse
    parts = {}
    @bricklink_xml.gsub!(/\r\n/, '')
    @bricklink_xml.gsub!(/\n/, '')
    xml_doc = Nokogiri::XML(@bricklink_xml)
    hash = Hash.from_xml(xml_doc.to_s)
    hash['INVENTORY']['ITEM'].each do |item|
      key = "#{item['ITEMID']}_#{get_ldraw_color_number(item['COLOR'])}"
      parts[key] = {}
      parts[key]['quantity'] = item['MINQTY'].to_i
      parts[key]['ldraw_part_num'] = get_ldraw_part_number(item['ITEMID'])
    end
    parts
  end

  private

  def get_ldraw_color_number(color)
    Color.find_by_bl_id(color)&.ldraw_id || color
  end

  def get_ldraw_part_number(part)
    Part.find_by_bl_id(part)&.ldraw_id || part
  end
end
