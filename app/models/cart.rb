# frozen_string_literal: true

class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  belongs_to :user, optional: true

  # attr_accessible :user_id

  def add_product(product)
    # first, see if I already have the item in my cart
    current_item = cart_items.find_by_product_id(product.id)
    return if current_item&.product&.digital_product?

    if current_item&.product&.physical_product?
      # If the item is already in the cart and is a physical product, increment...
      current_item.increment_quantity
    else
      # ... else, add to the cart.
      current_item = CartItem.new(product_id: product.id, quantity: 1)
      current_item.save
      cart_items << current_item
    end

    save
  end

  def total_price
    total = 0.0
    cart_items.each { |item| total += (item.price * item.quantity) }
    total
  end

  def total_quantity
    total = 0
    cart_items.each { |item| total += item.quantity }
    total
  end

  def remove_product(cart_item_id)
    CartItem.destroy(cart_item_id)
  end

  def update_product_quantity(cart_item_id, quantity)
    if quantity.to_i.zero?
      CartItem.destroy(cart_item_id)
    else
      item = CartItem.find cart_item_id
      item.quantity = quantity
      item.save
    end
  end

  def empty?
    cart_items.length.zero?
  end

  def self.users_most_recent_cart(user_id)
    Cart.where(user_id:).order('created_at desc').limit(1)[0]
  end

  def includes_physical_item?
    cart_items.includes(product: :product_type).each do |item|
      return true if item.product.physical_product?
    end

    false
  end

  def includes_digital_item?
    cart_items.each do |item|
      return true if item.product.digital_product?
    end

    false
  end
end
