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
        expect(parts_list.parts.keys.sort).to eq(%w[3030_71 3065_40 4162_4])
      end

      context 'when a call to Part.find_or_create_via_external fails' do
        it 'should rescue, log, add the error to errors and mark the interaction a failure' do
          parts_list = FactoryBot.create(:parts_list, name: 'Test', product: @product, original_filename: 'test.xml', bricklink_xml: File.read(File.join(Rails.root, 'spec', 'support', 'parts_lists', 'test.xml')))
          allow(Part).to receive(:find_or_create_via_external).and_raise(StandardError.new('Some Error'))
          expect_any_instance_of(ActiveSupport::Logger).to receive(:error).with(/PartsList::CreatePartsList::Part::1\nERROR: Some Error\nBACKTRACE: /).exactly(3).times

          interaction = PartsListInteractions::CreatePartsList.run(parts_list_id: parts_list.id)

          expect(interaction.succeeded?).to be false
          expect(interaction.errors.length).to eq(3)
          expect(interaction.errors[0].message).to match('Some Error')
        end
      end

      context 'when a call to save! on a parts_list fails' do
        it 'should rescue, log, add the error to errors and mark the interaction a failure' do
          parts_list = FactoryBot.create(:parts_list, name: 'Test', product: @product, original_filename: 'test.xml', bricklink_xml: File.read(File.join(Rails.root, 'spec', 'support', 'parts_lists', 'test.xml')))
          allow(Part).to receive(:find_or_create_via_external).and_return(Part.first)
          allow(Element).to receive(:find_or_create_via_external).and_return(Element.first)
          allow_any_instance_of(PartsList).to receive(:save!).and_raise(StandardError.new('Some Error'))
          expect_any_instance_of(ActiveSupport::Logger).to receive(:error).with(/PartsList::CreatePartsList::Save::1\nERROR: Some Error\nBACKTRACE: /).exactly(1).time

          interaction = PartsListInteractions::CreatePartsList.run(parts_list_id: parts_list.id)

          expect(interaction.succeeded?).to be false
          expect(interaction.errors.length).to eq(0)
          expect(interaction.error.message).to match('Some Error')
        end
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
        expect(parts_list.parts.keys.sort).to eq(%w[3030_71 3065_40 4162_4 4162_71])
      end
    end
  end
end
