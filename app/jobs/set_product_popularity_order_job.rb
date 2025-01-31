# frozen_string_literal: true

class SetProductPopularityOrderJob
  include Sidekiq::Job
  sidekiq_options queue: 'low'

  def perform
    puts 'Setting product popularity order...'
    product_ids = LineItem.group(:product_id).count.sort_by { |_k, v| v }.reverse.map { |x| x[0] }
    product_ids.each_with_index do |product_id, i|
      Product.find(product_id).update(popularity_order: i + 1)
    end
  end
end
