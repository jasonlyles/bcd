class LineItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product

  attr_accessible :order_id, :product_id, :quantity, :total_price

  def self.from_cart_item(cart_item)
    li = self.new
    li.product_id = cart_item.product.id
    li.quantity = cart_item.quantity
    li.total_price = cart_item.quantity * cart_item.product.price
    li
  end
end
