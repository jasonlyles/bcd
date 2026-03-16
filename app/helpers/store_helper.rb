# frozen_string_literal: true

module StoreHelper
  def errant_cart_item?(item)
    session[:errant_cart_items].present? ? session[:errant_cart_items].flatten.include?(item) : false
  end

  def product_header(product)
    product_type = product.product_type.name.downcase == 'instructions' ? 'Instructions (Digital Download)' : product.product_type.name
    "#{product.product_code} #{product.name} #{product_type}"
  end
end
