require 'spec_helper'

describe Part do
  describe 'Part.find_or_create_via_external' do
    context 'name is already present on the part' do
      it 'should return the record' do
        part = FactoryGirl.create(:part, ldraw_id: 3001, name: '2x2 Brick')
        part_key = '3001_0'
        expect(PartInteractions::UpdateFromBricklink).not_to receive(:run)
        expect(PartInteractions::UpdateFromRebrickable).not_to receive(:run)
        returned_part = Part.find_or_create_via_external(part_key)

        expect(part.id).to eq(returned_part.id)
      end
    end

    context 'part does not yet exist' do
      it 'should create and return the part' do
        part_key = '4000_0'
        part = nil
        expect(PartInteractions::UpdateFromBricklink).to receive(:run)
        expect(PartInteractions::UpdateFromRebrickable).to receive(:run)
        expect {
          part = Part.find_or_create_via_external(part_key)
        }.to change(Part, :count).by(1)
        expect(part).not_to be_nil
      end
    end
  end
end
