require 'spec_helper'

describe Color do
  context 'associated with an element' do
    it 'should NOT delete the color' do
      color = FactoryBot.create(:color)
      part = FactoryBot.create(:part)
      element = FactoryBot.create(:element, part_id: part.id, color_id: color.id)

      expect { color.destroy }.not_to change(Color, :count)
      expect(color.errors.messages[:base][0]).to eq('Cannot delete record because dependent elements exist')
    end
  end

  context 'NOT associated with an element' do
    it 'should delete the color' do
      color = FactoryBot.create(:color)

      expect { color.destroy }.to change(Color, :count).by(-1)
    end
  end

  it 'should be valid with valid attributes' do
    color = FactoryBot.create(:color)
    expect(color).to be_valid
  end
end
