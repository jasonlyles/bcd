# frozen_string_literal: true

require 'spec_helper'

describe Etsy::Client do
  describe 'delete_image' do
    it 'should send a request to Etsy to delete the image and update the image record' do
      product = FactoryBot.create(:product_with_associations, etsy_listing_id: '1234')
      image = FactoryBot.create(:image, product:, etsy_listing_image_id: '5678')
      client = Etsy::Client.new(product_id: product.id)
      allow_any_instance_of(Etsy::Api::ListingImage).to receive(:delete)

      client.delete_image('5678')

      image.reload
      expect(image.etsy_listing_image_id).to be_nil
    end
  end

  describe 'delete_listing' do
    it 'should send a request to Etsy to delete the listing and update the product' do
      product = FactoryBot.create(:product_with_associations, etsy_listing_id: '1234', etsy_listing_file_id: '2345', etsy_listing_state: 'published', etsy_listing_url: 'https://etsy.com/listing/1234', etsy_created_at: Time.now, etsy_updated_at: Time.now)
      image = FactoryBot.create(:image, product:, etsy_listing_image_id: '5678')
      client = Etsy::Client.new(product_id: product.id)
      allow_any_instance_of(Etsy::Api::Listing).to receive(:delete)

      client.delete_listing

      product.reload
      expect(product.etsy_listing_id).to be_nil
      expect(product.etsy_listing_file_id).to be_nil
      expect(product.etsy_listing_state).to be_nil
      expect(product.etsy_listing_url).to be_nil
      expect(product.etsy_created_at).to be_nil
      expect(product.etsy_updated_at).to be_nil

      image.reload
      expect(image.etsy_listing_image_id).to be_nil
    end
  end

  describe 'replace_pdf' do
    it 'should call to Etsy to add a pdf, update the product, and call to Etsy to delete the old pdf' do
      product = FactoryBot.create(:product_with_associations, etsy_listing_id: '1234', etsy_listing_file_id: '223451')
      client = Etsy::Client.new(product_id: product.id)
      allow_any_instance_of(Etsy::Api::ListingFile).to receive(:add_pdf).and_return({ 'listing_file_id' => '987601' })
      allow_any_instance_of(Etsy::Api::ListingFile).to receive(:delete_pdf)

      client.replace_pdf

      product.reload
      expect(product.etsy_listing_file_id).to eq('987601')
      expect(product.etsy_updated_at).to_not be_nil
    end
  end

  describe 'update_listing' do
    it 'should make calls to Etsy to update the listing, the property, and images' do
      product = FactoryBot.create(:product_with_associations, etsy_listing_id: '1234')
      image = FactoryBot.create(:image, product:, etsy_listing_image_id: '5678', position: 1, updated_at: Time.now + 1.minute)
      client = Etsy::Client.new(product_id: product.id)
      allow_any_instance_of(Etsy::Api::Listing).to receive(:update).and_return({ 'url' => 'https://etsy.com/listing/fake' })
      expect_any_instance_of(Etsy::Api::Listing).to receive(:update_property)
      expect_any_instance_of(Etsy::Api::ListingImage).to receive(:delete)
      allow_any_instance_of(Etsy::Api::ListingImage).to receive(:add).and_return({ 'listing_image_id' => '987654321' })

      client.update_listing

      product.reload
      expect(product.etsy_listing_url).to eq('https://etsy.com/listing/fake')
      expect(product.etsy_updated_at).to_not be_nil
    end
  end

  describe 'create_listing' do
    it 'should make calls to create a listing, and update the product' do
      product = FactoryBot.create(:product_with_associations, etsy_listing_id: nil)
      image = FactoryBot.create(:image, product:)
      client = Etsy::Client.new(product_id: product.id)
      allow_any_instance_of(Etsy::Api::Listing).to receive(:create_draft).and_return({ 'listing_id' => '56789', 'url' => 'https://etsy.com/listing/56789' })
      allow_any_instance_of(Etsy::Api::Listing).to receive(:add_sku)
      allow_any_instance_of(Etsy::Api::ListingFile).to receive(:add_pdf).and_return({ 'listing_file_id' => '345345' })
      allow_any_instance_of(Etsy::Api::ListingImage).to receive(:add).and_return({ 'listing_image_id' => '987654321' })
      allow_any_instance_of(Etsy::Api::Listing).to receive(:activate).and_return({ 'url' => 'https://etsy.com/listing/active/56789' })

      client.create_listing

      product.reload

      expect(product.etsy_listing_id).to eq('56789')
      expect(product.etsy_listing_file_id).to eq('345345')
      expect(product.etsy_listing_state).to eq('published')
      expect(product.etsy_listing_url).to eq('https://etsy.com/listing/active/56789')
      expect(product.etsy_created_at).to_not be_nil
      expect(product.etsy_updated_at).to_not be_nil
    end
  end
end
