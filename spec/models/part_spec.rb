require 'spec_helper'

describe Part do
  before do
    @bricklink_results = {
        "meta" => {
            "description" => "OK",
                "message" => "OK",
                   "code" => 200
        },
        "data" => {
                       "no" => "4276a",
                     "name" => "Hinge Plate 1 x 2 with 2 Fingers and Solid Studs",
                     "type" => "PART",
              "category_id" => 22,
                "image_url" => "//img.bricklink.com/PL/4276a.jpg",
            "thumbnail_url" => "//img.bricklink.com/P/9/4276a.jpg",
                   "weight" => "0.42",
                    "dim_x" => "0.00",
                    "dim_y" => "0.00",
                    "dim_z" => "0.00",
            "year_released" => 1981,
              "is_obsolete" => false
        }
    }
  end

  describe 'Part.find_or_create_via_external' do
    context 'check_bricklink and check_rebrickable are already present on the part' do
      it 'should return the record' do
        part = FactoryBot.create(:part, ldraw_id: 3001, name: '2x2 Brick', check_rebrickable: false, check_bricklink: false)
        part_key = '3001_0'
        expect(PartInteractions::UpdateFromBricklink).not_to receive(:run)
        expect(PartInteractions::UpdateFromRebrickable).not_to receive(:run)
        returned_part = Part.find_or_create_via_external(part_key)

        expect(part.id).to eq(returned_part.id)
      end
    end

    context 'part does not yet exist' do
      it 'should create the part' do
        part_key = '4276a_0'
        part = nil
        allow(Bricklink).to receive(:get_part).and_return(@bricklink_results)
        expect {
          part = Part.find_or_create_via_external(part_key)
        }.to change(Part, :count).by(1)
        expect(part).not_to be_nil
      end
    end
  end
end
