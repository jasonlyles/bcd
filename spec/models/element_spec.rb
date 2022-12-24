require 'spec_helper'

describe Element do
  before do
    @get_element_combo_results = {
         "part_img_url" => "https://cdn.rebrickable.com/media/parts/elements/300126.jpg",
            "year_from" => 1979,
              "year_to" => 2021,
             "num_sets" => 863,
        "num_set_parts" => 3674,
             "elements" => ["300126"]
    }

    @get_element_image_results = {
        "meta" => {
            "description" => "OK",
                "message" => "OK",
                   "code" => 200
        },
        "data" => {
                       "no" => "3001",
                     "type" => "PART",
            "thumbnail_url" => "//img.bricklink.com/P/1/3001.gif"
        }
    }
  end

  describe 'update_from_rebrickable' do
    context 'returns data' do
      it 'should update self and relevant part' do
        allow(Rebrickable).to receive(:get_element_combo).and_return(@get_element_combo_results)
        part = FactoryBot.create(:part, ldraw_id: 3001, name: '2x2 Brick', check_rebrickable: true)
        color = FactoryBot.create(:color)
        element = FactoryBot.create(:element)

        element.update_from_rebrickable(3001, 0)
        part.reload

        expect(element.original_image_url).to eq(@get_element_combo_results['part_img_url'])
        expect(part.check_rebrickable).to eq(false)
      end
    end

    context 'doesnt return data' do
      it 'should not update self or relevant part' do
        allow(Rebrickable).to receive(:get_element_combo).and_return({})
        part = FactoryBot.create(:part, ldraw_id: 3001, name: '2x2 Brick', check_rebrickable: true)
        color = FactoryBot.create(:color)
        element = FactoryBot.create(:element, original_image_url: nil)

        element.update_from_rebrickable(3001, 0)
        part.reload

        expect(element.original_image_url).to be_nil
        expect(part.check_rebrickable).to eq(true)
      end
    end
  end

  describe 'update_from_brickable' do
    context 'returns data' do
      it 'should update self and relevant part' do
        allow(Bricklink).to receive(:get_element_image).and_return(@get_element_image_results)
        part = FactoryBot.create(:part, ldraw_id: 3001, name: '2x2 Brick', check_bricklink: true)
        color = FactoryBot.create(:color)
        element = FactoryBot.create(:element)

        element.update_from_bricklink(3001, 0)
        part.reload

        expect(element.original_image_url).to eq("https:#{@get_element_image_results['data']['thumbnail_url']}")
        expect(part.check_bricklink).to eq(false)
      end
    end

    context 'doesnt return data' do
      it 'should not update self or relevant part' do
        allow(Bricklink).to receive(:get_element_image).and_return({})
        part = FactoryBot.create(:part, ldraw_id: 3001, name: '2x2 Brick', check_bricklink: true)
        color = FactoryBot.create(:color)
        element = FactoryBot.create(:element, original_image_url: nil)

        element.update_from_bricklink(3001, 0)
        part.reload

        expect(element.original_image_url).to be_nil
        expect(part.check_bricklink).to eq(true)
      end
    end
  end

  describe 'Element.find_or_create_via_external' do
    context 'element image is present' do
      it 'should return element found in db' do
        part = FactoryBot.create(:part, ldraw_id: 3000)
        color = FactoryBot.create(:color, ldraw_id: 3)
        element = FactoryBot.create(:element, image: File.open(File.join(Rails.root, 'spec', 'fixtures', 'files', 'example.png')), part_id: part.id, color_id: color.id)
        part_key = '3000_3'
        returned_element = Element.find_or_create_via_external(part_key)

        expect(returned_element.id).to eq(element.id)
      end
    end

    context 'element image is not present' do
      it 'should update via bricklink and rebrickable and store an image' do
        part = FactoryBot.create(:part, ldraw_id: 3000)
        color = FactoryBot.create(:color, ldraw_id: 3)
        element = FactoryBot.create(:element, part_id: part.id, color_id: color.id, original_image_url: nil)
        part_key = '3000_3'
        expect_any_instance_of(Element).to receive(:update_from_rebrickable)
        expect_any_instance_of(Element).to receive(:update_from_bricklink)
        expect_any_instance_of(Element).to receive(:store_image)
        expect_any_instance_of(Element).to receive(:save!)

        Element.find_or_create_via_external(part_key)
      end
    end
  end
end
