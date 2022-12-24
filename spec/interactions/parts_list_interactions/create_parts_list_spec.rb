require 'spec_helper'

describe PartsListInteractions::CreatePartsList do
  before do
    part1 = FactoryBot.create(:part, ldraw_id: '4162', bl_id: '4162', name: 'part1')
    part2 = FactoryBot.create(:part, ldraw_id: '3030', bl_id: '3030', name: 'part2')
    part3 = FactoryBot.create(:part, ldraw_id: '3065', bl_id: '3065', name: 'part3')
    color1 = FactoryBot.create(:color, ldraw_id: '4', bl_id: '5', bl_name: 'Red', name: 'Red')
    color2 = FactoryBot.create(:color, ldraw_id: '71', bl_id: '86', bl_name: 'Light Bluish Gray', name: 'Light Bluish Gray')
    color3 = FactoryBot.create(:color, ldraw_id: '40', bl_id: '13', bl_name: 'Trans-Black', name: 'Trans-Black')
    FactoryBot.create(:element, part_id: part1.id, color_id: color1.id)
    FactoryBot.create(:element, part_id: part2.id, color_id: color2.id)
    FactoryBot.create(:element, part_id: part3.id, color_id: color3.id)
    @product = FactoryBot.create(:product_with_associations)
  end

  describe 'run' do
    context 'with bricklink xml' do
      it 'should update the parts list and create lots associated with the parts list' do
        parts_list = FactoryBot.create(:parts_list, name: 'Test', product: @product, original_filename: 'test.xml', bricklink_xml: File.read(File.join(Rails.root, 'spec', 'support', 'parts_lists', 'test.xml')))
        expect(parts_list.lots.count).to eq(0)
        expect(parts_list.parts).to be_nil
        expect_any_instance_of(Element).not_to receive(:update_from_rebrickable)
        allow_any_instance_of(ImageUploader).to receive(:present?).and_return(true)

        interaction = PartsListInteractions::CreatePartsList.run(parts_list_id: parts_list.id)
        parts_list.reload

        expect(interaction.succeeded?).to be true
        expect(parts_list.lots.count).to eq(3)
        expect(parts_list.parts.keys.sort).to eq(['3030_71', '3065_40', '4162_4'])
      end
    end

    context 'with ldr' do
      it 'should update the parts list and create lots associated with the parts list' do
        parts_list = FactoryBot.create(:parts_list, name: 'Test', product: @product, original_filename: 'test.ldr', ldr: File.read(File.join(Rails.root, 'spec', 'support', 'parts_lists', 'test.ldr')))
        expect(parts_list.lots.count).to eq(0)
        expect(parts_list.parts).to be_nil
        expect_any_instance_of(Element).not_to receive(:update_from_rebrickable)
        allow_any_instance_of(ImageUploader).to receive(:present?).and_return(true)

        interaction = PartsListInteractions::CreatePartsList.run(parts_list_id: parts_list.id)
        parts_list.reload

        expect(interaction.succeeded?).to be true
        expect(parts_list.lots.count).to eq(4)
        expect(parts_list.parts.keys.sort).to eq(["3030_71", "3065_40", "4162_4", "4162_71"])
      end
    end
  end
end
