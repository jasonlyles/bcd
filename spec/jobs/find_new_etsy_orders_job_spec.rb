# frozen_string_literal: true

require 'spec_helper'

describe FindNewEtsyOrdersJob do
  describe 'perform' do
    it 'should get a count of receipts from Etsy and loop the appropriate number of times' do
      expect_any_instance_of(Etsy::Api::Receipt).to receive(:shop_receipts).exactly(8).times.and_return({ 'count' => 752 })
      allow_any_instance_of(Etsy::Handler::Receipts).to receive(:handle)

      FindNewEtsyOrdersJob.perform_sync
    end
  end
end
