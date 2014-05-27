class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :product

  attr_accessible :cart_id, :product_id, :quantity

  #attr_reader :product, :quantity

  #def initialize(product)
  #  @product = product
  #  @quantity = 1
  #end

  def increment_quantity
    self.quantity += 1
    self.save
  end

  #def title
  #  @product.title
  #end

  def price
    self.product.price
  end
end
