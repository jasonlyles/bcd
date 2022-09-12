require 'spec_helper'

describe Color do
  context 'associated with an element' do
    it "should NOT delete the color" do
      color = FactoryGirl.create(:color)
      part = FactoryGirl.create(:part)
      element = FactoryGirl.create(:element, part_id: part.id, color_id: color.id)

      expect(lambda{color.destroy}).not_to change(Color, :count)
      expect(color.errors.messages[:base][0]).to eq('Cannot delete record because dependent elements exist')
    end
  end

  context 'NOT associated with an element' do
    it "should delete the color" do
      color = FactoryGirl.create(:color)

      expect(lambda{color.destroy}).to change(Color, :count).by(-1)
    end
  end

  it "should be valid with valid attributes" do
    color = FactoryGirl.create(:color)
    expect(color).to be_valid
  end
end
