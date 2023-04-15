# frozen_string_literal: true

require 'spec_helper'

describe Image do
  before do
    @product = FactoryBot.create(:product_with_associations, etsy_listing_id: '12345')
  end

  describe 'destroy' do
    context 'with an associated etsy listing image id' do
      it 'should call out to Etsy to delete the image' do
        image = FactoryBot.create(:image, etsy_listing_image_id: 1234)
        expect_any_instance_of(Etsy::Client).to receive(:delete_image)

        image.destroy
      end
    end

    context 'with no associated etsy listing image id' do
      it 'should not call out to Etsy' do
        image = FactoryBot.create(:image)
        expect_any_instance_of(Etsy::Client).to receive(:delete_image).never

        image.destroy
      end
    end
  end
end
