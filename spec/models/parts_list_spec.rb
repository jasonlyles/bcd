# frozen_string_literal: true

require 'spec_helper'

describe PartsList do
  before do
    @product = FactoryBot.create(:product_with_associations)
    @parts_list = FactoryBot.create(:xml_parts_list, product: @product)
    @part = FactoryBot.create(:part)
    @color1 = FactoryBot.create(:color, name: 'red')
    @color2 = FactoryBot.create(:color, name: 'blue')
    @color3 = FactoryBot.create(:color, name: 'black')
    @element1 = FactoryBot.create(:element, part: @part, color: @color1)
    @element2 = FactoryBot.create(:element, part: @part, color: @color2)
    @element3 = FactoryBot.create(:element, part: @part, color: @color3)
  end

  describe 'product_name' do
    it 'should return the name of the associated product' do
      expect(@parts_list.product_name).to eq('Colonial Revival House')
    end
  end

  describe 'parts_quantity' do
    it 'should sum up the quantities of all associated lots' do
      FactoryBot.create(:lot, parts_list_id: @parts_list.id, element: @element1, quantity: 4)
      FactoryBot.create(:lot, parts_list_id: @parts_list.id, element: @element2, quantity: 1)
      FactoryBot.create(:lot, parts_list_id: @parts_list.id, element: @element3, quantity: 16)
      @parts_list.reload

      expect(@parts_list.parts_quantity).to eq(21)
    end
  end

  describe 'has_obsolete_part?' do
    it 'should return true if any of the associated lots are for an obsolete part' do
      part = FactoryBot.create(:part, name: '1 x 8 Brick', is_obsolete: true)
      element = FactoryBot.create(:element, part:, color: @color1)
      FactoryBot.create(:lot, parts_list_id: @parts_list.id, element:, quantity: 2)
      @parts_list.reload
      expect(@parts_list.has_obsolete_part?).to eq(true)
    end

    it 'should return false if none of the associated lots are for an obsolete part' do
      expect(@parts_list.has_obsolete_part?).to eq(false)
    end
  end
end
