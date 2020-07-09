module CarrierWave
  module Workers
    class ProcessAsset
      def self.queue_name
        @queue
      end
      extend TempAgency
      @queue = :carrierwave
    end
  end
end

CarrierWave::Backgrounder.configure do |c|
  c.backend :resque, queue: :carrierwave
end
