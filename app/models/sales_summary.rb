# frozen_string_literal: true

class SalesSummary < ApplicationRecord
  belongs_to :sales_report
  belongs_to :product

  # attr_accessible :sales_report_id, :product_id, :quantity, :total_revenue
end
