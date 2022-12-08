require 'spec_helper'

describe PartsListInteractions::CreateElementsForPartsSwap do
  describe 'run' do
    context 'old and/or new part names are blank' do
      it 'should set self.error and return early' do
        interaction = PartsListInteractions::CreateElementsForPartsSwap.run(old_part_name: 'old')

        expect(interaction.succeeded?).to be false
        expect(interaction.error).to eq('Must submit both an old and a new part')

        interaction = PartsListInteractions::CreateElementsForPartsSwap.run(new_part_name: 'new')

        expect(interaction.succeeded?).to be false
        expect(interaction.error).to eq('Must submit both an old and a new part')

        interaction = PartsListInteractions::CreateElementsForPartsSwap.run(old_part_name: 'old', new_part_name: '')

        expect(interaction.succeeded?).to be false
        expect(interaction.error).to eq('Must submit both an old and a new part')
      end
    end

    context 'old and/or new parts could not be found by name' do
      it 'should set self.error and return early' do
        interaction = PartsListInteractions::CreateElementsForPartsSwap.run(old_part_name: 'old', new_part_name: 'new')

        expect(interaction.succeeded?).to be false
        expect(interaction.error).to eq('Could not find one of the parts you submitted. Please report to admin.')

        FactoryGirl.create(:part, ldraw_id: '4162', bl_id: '4162', name: 'new')

        interaction = PartsListInteractions::CreateElementsForPartsSwap.run(old_part_name: 'old', new_part_name: 'new')

        expect(interaction.succeeded?).to be false
        expect(interaction.error).to eq('Could not find one of the parts you submitted. Please report to admin.')
      end
    end

    context 'old and new parts are found by name' do
      it 'should succeed and set affected_parts_lists' do
        part1 = FactoryGirl.create(:part, ldraw_id: '4162', bl_id: '4162', name: 'part1')
        part2 = FactoryGirl.create(:part, ldraw_id: '3030', bl_id: '3030', name: 'part2')
        part3 = FactoryGirl.create(:part, ldraw_id: '3065', bl_id: '3065', name: 'part3')
        color1 = FactoryGirl.create(:color, ldraw_id: '4', bl_id: '5', bl_name: 'Red', name: 'Red')
        color2 = FactoryGirl.create(:color, ldraw_id: '71', bl_id: '86', bl_name: 'Light Bluish Gray', name: 'Light Bluish Gray')
        color3 = FactoryGirl.create(:color, ldraw_id: '40', bl_id: '13', bl_name: 'Trans-Black', name: 'Trans-Black')
        element1 = FactoryGirl.create(:element, part_id: part1.id, color_id: color1.id)
        element2 = FactoryGirl.create(:element, part_id: part2.id, color_id: color2.id)
        element3 = FactoryGirl.create(:element, part_id: part3.id, color_id: color3.id)
        element4 = FactoryGirl.create(:element, part_id: part2.id, color_id: color1.id)
        parts_list1 = FactoryGirl.create(:parts_list, name: 'Test1', product_id: 1, original_filename: 'test.xml', bricklink_xml: File.read(File.join(Rails.root, 'spec', 'support', 'parts_lists', 'test.xml')))
        parts_list2 = FactoryGirl.create(:parts_list, name: 'Test2', product_id: 1, original_filename: 'test.xml', bricklink_xml: File.read(File.join(Rails.root, 'spec', 'support', 'parts_lists', 'test.xml')))
        parts_list3 = FactoryGirl.create(:parts_list, name: 'Test3', product_id: 1, original_filename: 'test.xml', bricklink_xml: File.read(File.join(Rails.root, 'spec', 'support', 'parts_lists', 'test.xml')))
        # Lots 1 and 2 are being associated with element1, which is an element for the old part being switched out
        lot1 = FactoryGirl.create(:lot, element_id: element1.id, parts_list_id: parts_list1.id)
        lot2 = FactoryGirl.create(:lot, element_id: element1.id, parts_list_id: parts_list2.id)
        # Lot 3 is for the element we're switching to, so its parts list won't change.
        lot3 = FactoryGirl.create(:lot, element_id: element2.id, parts_list_id: parts_list3.id)

        interaction = PartsListInteractions::CreateElementsForPartsSwap.run(old_part_name: 'part1', new_part_name: 'part2')

        expect(interaction.succeeded?).to be true
        expect(interaction.affected_parts_lists).to eq([[parts_list1.id, nil, parts_list1.name], [parts_list2.id, nil, parts_list2.name]])
      end
    end
  end
end
