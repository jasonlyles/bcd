# frozen_string_literal: true

require 'spec_helper'

describe Pinterest::Client do
  describe 'create_pin' do
    it 'should send a request to Pinterest to create a pin' do
      board = FactoryBot.create(:pinterest_board)
      product = FactoryBot.create(:product_with_associations, etsy_listing_url: 'https://etsy.com/listing/1234')
      image = FactoryBot.create(:image, product:)
      client = Pinterest::Client.new(product_id: product.id, board:)
      allow_any_instance_of(Pinterest::Api::Pin).to receive(:create).and_return({ 'id' => '56789' })

      expect {
        client.create_pin
      }.to change(PinterestPin, :count).by(1)

      pin = PinterestPin.last

      expect(pin.pinterest_native_id).to eq('56789')
      expect(pin.pinterest_board_id).to eq(board.id)
      expect(pin.product_id).to eq(product.id)
      expect(pin.link).to eq('https://etsy.com/listing/1234')
      expect(pin.title).to eq("Custom Lego Instructions - #{product.name}")
      expect(pin.description).to eq(product.description)
      expect(pin.image_id).to eq(image.id)
    end
  end

  describe 'create_board' do
    it 'should send a request to Pinterest to create a pin' do
      client = Pinterest::Client.new
      allow_any_instance_of(Pinterest::Api::Board).to receive(:create).and_return({ 'id' => '56789' })

      expect {
        client.create_board('Board name', 'Board description', 'Board topic')
      }.to change(PinterestBoard, :count).by(1)

      board = PinterestBoard.last

      expect(board.topic).to eq('Board topic')
      expect(board.pinterest_native_id).to eq('56789')
    end
  end
end
