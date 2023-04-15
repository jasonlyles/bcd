# frozen_string_literal: true

require 'spec_helper'

describe Etsy::Handler::Receipts do
  before do
    @receipts = JSON.parse File.read('spec/fixtures/files/receipts.json')
  end

  describe 'handle' do
    context 'there has been no change to the order for a couple days' do
      it 'should go to the next receipt' do
        allow_any_instance_of(Etsy::Handler::Receipts).to receive(:updated_timestamp_stale?).and_return(true)
        expect(ThirdPartyReceipt).to receive(:where).never

        ehr = Etsy::Handler::Receipts.new(@receipts)
        ehr.handle
      end
    end

    context 'there has been a change to the order recently' do
      before do
        allow_any_instance_of(Etsy::Handler::Receipts).to receive(:updated_timestamp_stale?).and_return(false)
      end

      context 'there is a third party order that is already complete' do
        it 'should go to the next receipt' do
          order = FactoryBot.create(:order)
          tpr = FactoryBot.create(:third_party_receipt, source: 'etsy', third_party_receipt_identifier: '1234', third_party_order_status: 'completed', order:)
          allow(ThirdPartyReceipt).to receive(:where).and_return([tpr])
          expect(ThirdParty::User).to receive(:find_or_create_user).never

          ehr = Etsy::Handler::Receipts.new(@receipts)
          ehr.handle
        end
      end

      context 'there is an existing third party order' do
        context 'the third party order is not marked complete, but the order is' do
          it 'should mark the third party order complete' do
            order = FactoryBot.create(:order, status: 'COMPLETED')
            tpr = FactoryBot.create(:third_party_receipt, source: 'etsy', third_party_receipt_identifier: '1234', third_party_order_status: 'paid', order:)
            allow(ThirdPartyReceipt).to receive(:where).and_return([tpr])

            ehr = Etsy::Handler::Receipts.new(@receipts)
            ehr.handle

            tpr_reloaded = ThirdPartyReceipt.last
            expect(tpr_reloaded.third_party_order_status).to eq('completed')
          end
        end

        context 'the third party receipt status has not changed' do
          it 'should return the order as is' do
            order = FactoryBot.create(:order, status: 'THIRD_PARTY_PENDING', source: 'etsy', third_party_order_identifier: '1234')
            tpr = FactoryBot.create(:third_party_receipt, source: 'etsy', third_party_receipt_identifier: '1234', third_party_order_status: 'paid', order:)
            allow(ThirdPartyReceipt).to receive(:where).and_return([tpr])
            allow_any_instance_of(Etsy::Handler::Receipt).to receive(:determine_order_status).and_return('THIRD_PARTY_PENDING')
            expect_any_instance_of(Order).to receive(:update).never

            ehr = Etsy::Handler::Receipts.new(@receipts)
            ehr.handle
          end
        end

        context 'the third party receipt status has changed to completed' do
          before do
            @order = FactoryBot.create(:order, status: 'THIRD_PARTY_PENDING', source: 'etsy', third_party_order_identifier: '1234')
            @tpr = FactoryBot.create(:third_party_receipt, source: 'etsy', third_party_receipt_identifier: '1234', third_party_order_status: 'paid', order: @order)
            allow(ThirdPartyReceipt).to receive(:where).and_return([@tpr])
            allow_any_instance_of(Etsy::Handler::Receipt).to receive(:determine_order_status).and_return('COMPLETED')
          end

          it 'should update the order status' do
            ehr = Etsy::Handler::Receipts.new(@receipts)
            ehr.handle

            @order.reload
            expect(@order.status).to eq('COMPLETED')
          end

          it 'should update the third party receipt' do
            ehr = Etsy::Handler::Receipts.new(@receipts)
            ehr.handle

            @tpr.reload
            expect(@tpr.third_party_order_status).to eq('Completed')
          end

          it 'should send a confirmation email' do
            message_delivery = instance_double(ActionMailer::MessageDelivery)
            expect(OrderMailer).to receive(:third_party_guest_order_confirmation).and_return(message_delivery)
            allow(message_delivery).to receive(:deliver_later)

            ehr = Etsy::Handler::Receipts.new(@receipts)
            ehr.handle
          end
        end
      end

      context 'there is a new order' do
        context 'and the order is completed' do
          it 'should create a third party receipt and email the user' do
            product = FactoryBot.create(:product_with_associations, etsy_listing_id: 1_332_911_025)
            ehr = Etsy::Handler::Receipts.new(@receipts)
            message_delivery = instance_double(ActionMailer::MessageDelivery)
            expect(OrderMailer).to receive(:third_party_guest_order_confirmation).and_return(message_delivery)
            allow(message_delivery).to receive(:deliver_later)

            expect {
              ehr.handle
            }.to change { ThirdPartyReceipt.count }.by(1)

            tpr = ThirdPartyReceipt.last

            expect(tpr.source).to eq('etsy')
            expect(tpr.third_party_receipt_identifier).to eq('2842756345')
            expect(tpr.third_party_order_status).to eq('Completed')
            expect(tpr.third_party_is_paid).to eq(true)
            expect(tpr.raw_response_body).to_not be_nil
          end
        end

        context 'and the order is not yet completed' do
          it 'should create a third party receipt and not email the user' do
            product = FactoryBot.create(:product_with_associations, etsy_listing_id: 1_332_911_025)
            ehr = Etsy::Handler::Receipts.new(@receipts)
            allow_any_instance_of(Etsy::Handler::Receipt).to receive(:determine_order_status).and_return('THIRD_PARTY_PENDING')
            expect(OrderMailer).to receive(:third_party_guest_order_confirmation).never

            expect {
              ehr.handle
            }.to change { ThirdPartyReceipt.count }.by(1)

            tpr = ThirdPartyReceipt.last

            expect(tpr.source).to eq('etsy')
            expect(tpr.third_party_receipt_identifier).to eq('2842756345')
            expect(tpr.third_party_is_paid).to eq(true)
            expect(tpr.raw_response_body).to_not be_nil
          end
        end

        context 'with a message from the buyer' do
          it 'should send an email to admins' do
            product = FactoryBot.create(:product_with_associations, etsy_listing_id: 1_332_911_025)

            allow_any_instance_of(Etsy::Handler::Receipts).to receive(:message_from_buyer).and_return('Hi!')
            message_delivery = instance_double(ActionMailer::MessageDelivery)
            expect(OrderMailer).to receive(:pass_along_buyer_message).and_return(message_delivery)
            allow(message_delivery).to receive(:deliver_later)

            ehr = Etsy::Handler::Receipts.new(@receipts)
            ehr.handle
          end
        end

        context 'with no message from the buyer' do
          it 'should not send an email to admins' do
            product = FactoryBot.create(:product_with_associations, etsy_listing_id: 1_332_911_025)

            allow_any_instance_of(Etsy::Handler::Receipts).to receive(:message_from_buyer).and_return(nil)
            expect(OrderMailer).to receive(:pass_along_buyer_message).never

            ehr = Etsy::Handler::Receipts.new(@receipts)
            ehr.handle
          end
        end
      end
    end
  end
end
