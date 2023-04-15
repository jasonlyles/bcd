# frozen_string_literal: true

namespace :order_statuses do
  task upcase_status: :environment do
    Order.where("status IN ('Failed', 'Completed')").find_each do |order|
      order.update_column(:status, order.status.upcase)
    end
  end
end
