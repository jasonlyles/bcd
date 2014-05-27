class Cart < ActiveRecord::Base
  has_many :cart_items, :dependent => :destroy

  attr_accessible :user_id

  def add_product(product)
    #first, see if I already have the item in my cart
    current_item = self.cart_items.find_by_product_id(product.id)
    if current_item && current_item.product.is_digital_product?
      #Do nothing? Maybe notify the user they can only add 1 of a set of instructions?
    elsif current_item
      current_item.increment_quantity
      self.save
    else
      current_item = CartItem.new(:product_id => product.id, :quantity => 1)
      current_item.save
      cart_items << current_item
      self.save
    end
  end

  def total_price
    total = 0.0
    self.cart_items.each{|item| total += (item.price * item.quantity)}
    total
  end

  def total_quantity
    total = 0
    self.cart_items.each{|item| total += item.quantity}
    total
  end

  def remove_product(cart_item_id)
    CartItem.destroy(cart_item_id)
  end

  def update_product_quantity(cart_item_id,quantity)
    if quantity.to_i == 0
      CartItem.destroy(cart_item_id)
    else
      item = CartItem.find cart_item_id
      item.quantity = quantity
      item.save
    end
  end

  def empty?
    self.cart_items.length == 0 ? true : false
  end

  def self.users_most_recent_cart(user_id)
    Cart.where(:user_id => user_id).order("created_at desc").limit(1)[0]
  end

  def has_physical_item?
    self.cart_items.each do |item|
      if item.product.is_physical_product?
        return true
      end
    end
    return false
  end

  def has_digital_item?
    self.cart_items.each do |item|
      if item.product.is_digital_product?
        return true
      end
    end
    return false
  end
end
