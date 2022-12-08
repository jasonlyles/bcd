module PartsListInteractions
  class SwapParts < BasePartsListInteraction
    class CustomErrorBelongingToThisClass < StandardError; end
    attr_accessor :affected_parts_lists_ids
    # This run method should be the only public method
    def run
      old_part_name = @options[:old_part_name]
      new_part_name = @options[:new_part_name]

      old_part = Part.find_by(name: old_part_name)
      new_part = Part.find_by(name: new_part_name)

      if old_part.blank? || new_part.blank?
        self.error = "Couldn't find one of the submitted parts. Please report to admin."
        Rails.logger.error("PartsListInteractions::SwapParts Could not find #{old_part_name} or #{new_part_name}")
        return
      end

      old_elements = Element.includes(:color).where(part_id: old_part.id)
      parts_list_ids = []
      old_elements.each do |old_element|
        new_element = Element.find_by(part_id: new_part.id, color_id: old_element.color_id)

        # Update all lots pointing to the old element ID to point them to the new element ID.
        lots = Lot.where(element_id: old_element.id)
        parts_list_ids << lots.map(&:parts_list_id)
        Rails.logger.info("PartsListInteractions::SwapParts Old Element ID: #{old_element.id} New Element ID: #{new_element.id} Lots being updated: #{lots.map(&:id)}")
        lots.each do |lot|
          lot.update(element_id: new_element.id)
        end
      end

      self.affected_parts_lists_ids = PartsList.includes(:product).where(id: parts_list_ids.flatten.uniq).map(&:id)
      Rails.logger.info("PartsListInteractions::SwapParts Parts lists being updated: #{self.affected_parts_lists_ids}")
    rescue StandardError => e
      self.error = 'Unexpected Error'
      Rails.logger.error("PartsListInteractions::SwapParts Old Name: #{old_part_name} New Name: #{new_part_name} Some unexpected error: #{e.message}")
    end
  end
end
