require 'spec_helper'

describe PartInteractions::UpdateFromRebrickable do
  before do
    @rebrickable_results = {
            "part_num" => "4276a",
                "name" => "Hinge Plate 1 x 2 with 2 Fingers and Solid Studs",
         "part_cat_id" => 18,
           "year_from" => 1981,
             "year_to" => 1986,
            "part_url" => "https://rebrickable.com/parts/4276a/hinge-plate-1-x-2-with-2-fingers-and-solid-studs/",
        "part_img_url" => "https://cdn.rebrickable.com/media/parts/ldraw/0/4276a.png",
              "prints" => [],
               "molds" => [
            "4276b",
            "4276"
        ],
          "alternates" => [
            "4276b",
            "upn0344"
        ],
        "external_ids" => {
            "BrickOwl" => [
                "167230"
            ]
        },
            "print_of" => nil
    }

    @part = FactoryGirl.create(:part, ldraw_id: '4276a')
  end

  describe "run" do
    it 'should update part with data from rebrickable' do
      allow(Rebrickable).to receive(:get_part).and_return(@rebrickable_results)
      interaction = PartInteractions::UpdateFromRebrickable.run(part: @part)

      expect(interaction.succeeded?).to eq(true)
      expect(@part.check_rebrickable).to eq(false)
      expect(@part.year_to).to eq('1986')
      expect(@part.brickowl_ids).to eq(167230)
      expect(@part.bl_id).to eq('4276a')
      expect(@part.alternate_nos).to eq(['4276b', 'upn0344'])
    end

    it 'should set an error when having trouble saving' do
      allow(Rebrickable).to receive(:get_part).and_return(@rebrickable_results)
      allow_any_instance_of(Part).to receive(:save!).and_raise(StandardError)
      interaction = PartInteractions::UpdateFromRebrickable.run(part: @part)

      expect(interaction.succeeded?).to eq(false)
      expect(interaction.error).to eq('Rebrickable Update Failure')
    end
  end
end
