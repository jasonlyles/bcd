# frozen_string_literal: true

require 'spec_helper'

describe ThirdPartyReceipt do
  before do
    @product = FactoryBot.create(:product_with_associations, etsy_listing_id: '12345')
    @order = FactoryBot.create(:order)
  end

  describe 'self.create_from_source' do
    it 'creates a third party receipt' do
      time = Time.now

      source = 'etsy'
      order_id = @order.id
      third_party_receipt_identifier = '123456'
      status = 'Completed'
      is_paid = true
      created_at = time
      updated_at = time
      raw_response = "{ json: 'json'}"

      expect {
        ThirdPartyReceipt.create_from_source(source, order_id, third_party_receipt_identifier, status, is_paid, created_at, updated_at, raw_response)
      }.to change(ThirdPartyReceipt, :count).by(1)

      tpr = ThirdPartyReceipt.last

      expect(tpr.source).to eq(source)
      expect(tpr.order_id).to eq(order_id)
      expect(tpr.third_party_receipt_identifier).to eq(third_party_receipt_identifier)
      expect(tpr.third_party_order_status).to eq(status)
      expect(tpr.third_party_is_paid).to eq(is_paid)
      expect(tpr.third_party_created_at).to eq(time)
      expect(tpr.third_party_updated_at).to eq(time)
      expect(tpr.raw_response_body).to eq(raw_response)
    end
  end
end
