# frozen_string_literal: true

class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  # attr_accessible :order_id, :product_id, :quantity, :total_price
  validates :product_id, presence: true

  def self.from_cart_item(cart_item)
    LineItem.new(
      product_id: cart_item.product.id,
      quantity: cart_item.quantity,
      total_price: cart_item.quantity * cart_item.product.price
    )
  end
end
