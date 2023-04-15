# frozen_string_literal: true

require 'spec_helper'

describe Etsy::Handler::Receipt do
  before do
    @receipts = JSON.parse File.read('spec/fixtures/files/receipts.json')
  end

  describe 'create_order_and_line_items' do
    it 'should create an order for the given user and create line items for each transaction' do
      user = FactoryBot.create(:user, id: 1_231_312)
      product = FactoryBot.create(:product_with_associations, etsy_listing_id: 1_332_911_025, id: 123_123)
      handler = Etsy::Handler::Receipt.new(@receipts['results'].first)
      created_order = nil

      expect {
        expect {
          created_order = handler.create_order_and_line_items(user.id)
        }.to change { LineItem.count }.by(1)
      }.to change { Order.count }.by(1)

      order = Order.last
      expect(created_order).to eq(order)
      expect(order.user_id).to eq(user.id)
      expect(order.transaction_id).to be_nil
      expect(order.request_id).to be_nil
      expect(order.status).to eq('COMPLETED')
      expect(order.source).to eq('etsy')
      expect(order.third_party_order_identifier).to eq('2842756345')

      line_item = LineItem.last
      expect(line_item.order_id).to eq(order.id)
      expect(line_item.product_id).to eq(product.id)
      expect(line_item.quantity).to eq(1)
      expect(line_item.total_price.to_f).to eq(3.0)
      expect(line_item.third_party_line_item_identifier).to eq('3498721468')
      expect(line_item.third_party_line_item_paid_at.to_s).to eq('2023-04-01 19:43:52 UTC')
    end
  end

  describe 'determine_order_status' do
    context 'with a pending status' do
      it 'should return the correct order status' do
        ['paid', 'open', 'payment processing', 'processing', 'unpaid', 'unshipped'].each do |status|
          allow_any_instance_of(Etsy::Handler::Receipt).to receive(:third_party_order_status).and_return(status)

          ehr = Etsy::Handler::Receipt.new('fake')

          expect(ehr.determine_order_status).to eq('THIRD_PARTY_PENDING')
        end
      end
    end

    context 'with a canceled status' do
      it 'should return the correct order status' do
        allow_any_instance_of(Etsy::Handler::Receipt).to receive(:third_party_order_status).and_return('canceled')

        ehr = Etsy::Handler::Receipt.new('fake')

        expect(ehr.determine_order_status).to eq('THIRD_PARTY_CANCELED')
      end
    end

    context 'with a completed status' do
      context 'for a paid order' do
        it 'should return the correct order status' do
          allow_any_instance_of(Etsy::Handler::Receipt).to receive(:third_party_order_status).and_return('completed')
          allow_any_instance_of(Etsy::Handler::Receipt).to receive(:paid?).and_return(true)

          ehr = Etsy::Handler::Receipt.new('fake')

          expect(ehr.determine_order_status).to eq('COMPLETED')
        end
      end

      context 'for an unpaid order' do
        it 'should return the correct order status' do
          allow_any_instance_of(Etsy::Handler::Receipt).to receive(:third_party_order_status).and_return('completed')
          allow_any_instance_of(Etsy::Handler::Receipt).to receive(:paid?).and_return(false)

          ehr = Etsy::Handler::Receipt.new('fake')

          expect(ehr.determine_order_status).to eq('THIRD_PARTY_PENDING_PAYMENT')
        end
      end
    end
  end
end
