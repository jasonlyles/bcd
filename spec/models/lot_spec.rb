require 'spec_helper'

describe Lot do
  before do
    @product = FactoryBot.create(:product_with_associations)
    @part = FactoryBot.create(:part, name: '1 x 6 Brick', id: 234, ldraw_id: '3006', is_obsolete: true)
    @color = FactoryBot.create(:color, name: 'Sand Blue', id: 22, bl_name: 'Sandy Bleu', ldraw_id: 16)
    @element = FactoryBot.create(:element, part: @part, color: @color)
    @parts_list = FactoryBot.create(:parts_list, product: @product, bricklink_xml: '<XML></XML>', original_filename: 'original.xml', name: 'parts_list1')
    @lot = FactoryBot.create(:lot, element: @element)
  end

  describe 'part_name' do
    it 'should return the associated part name' do
      expect(@lot.part_name).to eq('1 x 6 Brick')
    end
  end

  describe 'part_id' do
    it 'should return the associated part id' do
      expect(@lot.part_id).to eq(234)
    end
  end

  describe 'part_ldraw_id' do
    it 'should return the associated part ldraw_id' do
      expect(@lot.part_ldraw_id).to eq('3006')
    end
  end

  describe 'part_obsolete?' do
    it 'should return the associated part obsolete flag value' do
      expect(@lot.part_obsolete?).to eq(true)
    end
  end

  describe 'color_name' do
    it 'should return the associated color name' do
      expect(@lot.color_name).to eq('Sand Blue')
    end
  end

  describe 'color_bl_name' do
    it 'should return the associated color bl_name' do
      expect(@lot.color_bl_name).to eq('Sandy Bleu')
    end
  end

  describe 'color_id' do
    it 'should return the associated color id' do
      expect(@lot.color_id).to eq(22)
    end
  end

  describe 'color_ldraw_id' do
    it 'should return the associated color ldraw_id' do
      expect(@lot.color_ldraw_id).to eq(16)
    end
  end
end
