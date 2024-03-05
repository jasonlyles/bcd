# frozen_string_literal: true

class ThirdPartyReceipt < ApplicationRecord
  audited except: %i[created_at updated_at raw_response_body]

  belongs_to :order
  validates :source, :third_party_receipt_identifier, :third_party_order_status, presence: true

  enum source: Rails.application.config.sales_sources - [:brick_city_depot]

  # rubocop:disable Metrics/ParameterLists
  def self.create_from_source(source, order_id, third_party_receipt_identifier, status, is_paid, created_at, updated_at, raw_response)
    ThirdPartyReceipt.create!(
      source:,
      order_id:,
      third_party_receipt_identifier:,
      third_party_order_status: status,
      third_party_is_paid: is_paid,
      third_party_created_at: created_at,
      third_party_updated_at: updated_at,
      raw_response_body: raw_response
    )
  end
  # rubocop:enable Metrics/ParameterLists
end
