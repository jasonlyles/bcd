# frozen_string_literal: true

module StoreHelper
  def errant_cart_item?(item)
    session[:errant_cart_items].present? ? session[:errant_cart_items].flatten.include?(item) : false
  end
end
