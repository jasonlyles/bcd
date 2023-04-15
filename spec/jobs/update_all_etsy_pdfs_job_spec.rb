# frozen_string_literal: true

require 'spec_helper'

describe UpdateAllEtsyPdfsJob do
  before do
    @product = FactoryBot.create(:product_with_associations, etsy_listing_id: '12345')
  end

  describe 'perform' do
    it 'should send a backend notification that the job failed if it failed' do
      allow_any_instance_of(Etsy::Client).to receive(:replace_pdf).and_raise(StandardError)

      expect { UpdateAllEtsyPdfsJob.perform_sync }.to raise_error(StandardError)

      bn = BackendNotification.last
      expect(bn.message).to eq('Background Job to update all Etsy product PDFs failed')
    end

    it 'should send a backend notification about the job succeeding if the job succeeded' do
      allow_any_instance_of(Etsy::Client).to receive(:replace_pdf).and_return(true)

      UpdateAllEtsyPdfsJob.perform_sync

      bn = BackendNotification.last
      expect(bn.message).to match('Background Job to update all Etsy product PDFs completed in')
    end
  end
end
