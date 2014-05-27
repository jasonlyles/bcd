module StoreHelper
  def errant_cart_item?(item)
    if session[:errant_cart_items]
      session[:errant_cart_items].flatten.include?(item)
    end
  end
end
