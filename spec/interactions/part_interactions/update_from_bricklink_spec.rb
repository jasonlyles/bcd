require 'spec_helper'

describe PartInteractions::UpdateFromBricklink do
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

    @part = FactoryGirl.create(:part, ldraw_id: '4276a')
  end

  describe "run" do
    it 'should update part with data from bricklink' do
      allow(Bricklink).to receive(:get_part).and_return(@bricklink_results)
      interaction = PartInteractions::UpdateFromBricklink.run(part: @part)

      expect(interaction.succeeded?).to eq(true)
      expect(@part.check_bricklink).to eq(false)
      expect(@part.year_from).to eq('1981')
      expect(@part.name).to eq('Hinge Plate 1 x 2 with 2 Fingers and Solid Studs')
      expect(@part.bl_id).to eq('4276a')
    end

    it 'should set an error when having trouble saving' do
      allow(Bricklink).to receive(:get_part).and_return(@bricklink_results)
      allow_any_instance_of(Part).to receive(:save!).and_raise(StandardError)
      interaction = PartInteractions::UpdateFromBricklink.run(part: @part)

      expect(interaction.succeeded?).to eq(false)
      expect(interaction.error).to eq("Bricklink Update Failure. LDraw ID: #{@part.ldraw_id} ERROR: StandardError")
    end
  end
end
