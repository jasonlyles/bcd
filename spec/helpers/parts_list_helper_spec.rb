require 'spec_helper'

describe PartsListHelper do
  describe 'assign_text_color' do
    it 'returns white for dark hex values' do
      # #000000 is black, should return white
      expect(helper.assign_text_color('#000000')).to eq('white')
      # #00008B is dark blue, should return white
      expect(helper.assign_text_color('#00008B')).to eq('white')
      # #FF0000 is red, should return white
      expect(helper.assign_text_color('#FF0000')).to eq('white')
    end

    it 'returns black for light hex values' do
      # #FFFFFF is white, should return black
      expect(helper.assign_text_color('#FFFFFF')).to eq('black')
      # #FFFF00 is yellow, should return black
      expect(helper.assign_text_color('#FFFF00')).to eq('black')
    end
  end
end
