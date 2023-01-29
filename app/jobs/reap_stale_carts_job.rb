# frozen_string_literal: true

class ReapStaleCartsJob
  include Sidekiq::Job
  sidekiq_options queue: 'low'

  def perform
    puts 'Reaping stale carts'
    Cart.where(['updated_at < ?', 2.weeks.ago]).destroy_all
  end
end
