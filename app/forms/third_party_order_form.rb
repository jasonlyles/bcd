# frozen_string_literal: true

class ThirdPartyOrderForm
  include ActiveModel::Model

  attr_accessor :email, :source, :third_party_order_id, :product_ids, :order

  validates :third_party_order_id, :source, :product_ids, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # rubocop:disable Metrics/MethodLength
  def submit
    return false if invalid?

    guest = Guest.find_or_initialize_by(email: @email)
    if guest.new_record?
      guest.source = @source
      guest.email_preference = 0
      guest.skip_tos_accepted = true
      guest.account_status = 'G'
      guest.save!
    end

    order = Order.new(
      user_id: guest.id,
      source: @source,
      third_party_order_identifier: @third_party_order_id,
      status: 'COMPLETED'
    )
    order.products << Product.find(@product_ids)

    if order.save
      ThirdPartyReceipt.create!(
        order_id: order.id,
        source: order.source,
        third_party_receipt_identifier: order.third_party_order_identifier,
        third_party_order_status: 'Completed',
        third_party_is_paid: true,
        third_party_created_at: Time.now,
        third_party_updated_at: Time.now,
        raw_response_body: '{}'
      )
    end

    OrderMailer.third_party_guest_order_confirmation(order.id).deliver_later
    self.order = order

    true
  end
  # rubocop:enable Metrics/MethodLength
end
