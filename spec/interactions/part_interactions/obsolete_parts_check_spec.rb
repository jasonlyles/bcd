require 'spec_helper'

describe PartInteractions::ObsoletePartsCheck do
  before do
    @good_bricklink_results = {
      'meta' => {
        'description' => 'OK',
        'message' => 'OK',
        'code' => 200
      },
      'data' => {
        'no' => '4276a',
        'name' => 'Hinge Plate 1 x 2 with 2 Fingers and Solid Studs',
        'type' => 'PART',
        'category_id' => 22,
        'image_url' => '//img.bricklink.com/PL/4276a.jpg',
        'thumbnail_url' => '//img.bricklink.com/P/9/4276a.jpg',
        'weight' => '0.42',
        'dim_x' => '0.00',
        'dim_y' => '0.00',
        'dim_z' => '0.00',
        'year_released' => 1981,
        'is_obsolete' => false
      }
    }

    @bad_bricklink_results = {
      'meta' => {
        'description' => 'OK',
        'message' => 'OK',
        'code' => 200
      },
      'data' => {
      }
    }

    @obsolete_bricklink_results = {
      'meta' => {
        'description' => 'OK',
        'message' => 'OK',
        'code' => 200
      },
      'data' => {
        'no' => '4276a',
        'name' => 'Hinge Plate 1 x 2 with 2 Fingers and Solid Studs',
        'type' => 'PART',
        'category_id' => 22,
        'image_url' => '//img.bricklink.com/PL/4276a.jpg',
        'thumbnail_url' => '//img.bricklink.com/P/9/4276a.jpg',
        'weight' => '0.42',
        'dim_x' => '0.00',
        'dim_y' => '0.00',
        'dim_z' => '0.00',
        'year_released' => 1981,
        'is_obsolete' => true
      }
    }

    @part = FactoryBot.create(:part, ldraw_id: '4276a')
  end

  describe 'run' do
    context 'part is not marked obsolete' do
      it 'should not create any BackendNotification records' do
        allow(Bricklink).to receive(:get_part).and_return(@good_bricklink_results)

        expect { PartInteractions::ObsoletePartsCheck.run({}) }.not_to change(BackendNotification, :count)
      end
    end

    context 'part is now marked obsolete' do
      it 'should create a BackendNotification record and mark the part obsolete' do
        allow(Bricklink).to receive(:get_part).and_return(@obsolete_bricklink_results)
        expect(Part.last.is_obsolete).to eq(false)

        expect { PartInteractions::ObsoletePartsCheck.run({}) }.to change(BackendNotification, :count).from(0).to(1)

        expect(Part.last.is_obsolete).to eq(true)
        expect(BackendNotification.last.message).to eq('Via ObsoletePartsCheck, BrickLink part #4276a is now marked as obsolete in BrickLink. Please update parts lists.')
      end
    end

    context 'part cannot be found in BrickLink' do
      it 'should create a BackendNotification record alerting the admin' do
        allow(Bricklink).to receive(:get_part).and_return(@bad_bricklink_results)

        expect { PartInteractions::ObsoletePartsCheck.run({}) }.to change(BackendNotification, :count).from(0).to(1)

        expect(BackendNotification.last.message).to eq('During ObsoletePartsCheck, could not find part in BrickLink by LDraw ID #4276a')
      end
    end
  end
end
