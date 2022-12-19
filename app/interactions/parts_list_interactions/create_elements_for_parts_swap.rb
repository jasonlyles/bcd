module PartsListInteractions
  class CreateElementsForPartsSwap < BasePartsListInteraction
    attr_accessor :old_part_name, :new_part_name, :elements, :affected_parts_lists

    def run
      old_part_name = @options[:old_part_name]
      new_part_name = @options[:new_part_name]

      if old_part_name.blank? || new_part_name.blank?
        self.error = 'Must submit both an old and a new part'
        return
      end

      # Strip the BL ID/Ldraw ID in parens off the end that are used to help the
      # user decide if this is the generation of the part they want.
      self.old_part_name = old_part_name.gsub(/\(\w+\/\w+\)$/, '').strip
      old_part = Part.find_by(name: self.old_part_name)

      self.new_part_name = new_part_name.gsub(/\(\w+\/\w+\)$/, '').strip
      new_part = Part.find_by(name: self.new_part_name)

      if old_part.blank? || new_part.blank?
        self.error = 'Could not find one of the parts you submitted. Please report to admin.'
        Rails.logger.error("PartsListInteractions::CreateElementsForPartsSwap Could not find #{old_part_name} or #{new_part_name}")
        return
      end

      # 1. Find all elements for old part.
      elements = Element.includes(:color).where(part_id: old_part.id)
      Rails.logger.debug("PartsListInteractions::CreateElementsForPartsSwap Found elements #{elements.map(&:id)}")
      self.elements = {}
      parts_list_ids = []
      # 2. Be sure elements exist for new part for each color. If they don't exist, create them.
      elements.each_with_index do |element, i|
        element_key = "#{new_part.ldraw_id}_#{element.color.ldraw_id}"
        new_element = Element.find_or_create_via_external(element_key)
        Rails.logger.debug("PartsListInteractions::CreateElementsForPartsSwap Old element ID: #{element.id} New element ID: #{new_element.id}")
        lots = Lot.where(element_id: element.id)
        parts_list_ids << lots.map(&:parts_list_id)

        self.elements[i] = {}
        self.elements[i]['new_element'] = new_element
        self.elements[i]['old_element'] = element
      end

      self.affected_parts_lists = PartsList.includes(:product).where(id: parts_list_ids.flatten.uniq).pluck(:id, 'products.name', :name)
    rescue StandardError => e
      self.error = 'Unexpected Error'
      Rails.logger.error("PartsListInteractions::CreateElementsForPartsSwap Old Name: #{self.old_part_name} New Name: #{self.new_part_name} Some unexpected error: #{e.message}")
    end
  end
end
