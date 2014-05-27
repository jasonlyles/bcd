class ApplicationController < ActionController::Base
  protect_from_forgery
  layout proc{ |c| c.request.xhr? ? false : "application" }
  #Need to find a way to not call these before_filters on certain controllers, or maybe these should just be on the controllers with urls a customer might hit.
  before_filter :check_admin_mode, :except => [:maintenance]
  before_filter :find_cart
  before_filter :get_categories
  before_filter :set_users_referrer_code
  before_filter :set_locale

  private

  def set_locale
    hal = HttpAcceptLanguage::Parser.new(request.env['HTTP_ACCEPT_LANGUAGE'])
    I18n.locale = hal.language_region_compatible_from(SUPPORTED_LOCALES) || I18n.default_locale
  end

  def set_guest_status
    session[:guest] ||= true
  end

  def clean_up_guest
    @cart = Cart.find_by_user_id(session[:guest])
    @cart.user_id = nil
    @cart.save
    User.destroy(session[:guest])
    session.delete(:guest)
  end

  def current_guest
    if session[:guest] && session[:guest].is_a?(Integer)#meaning it's not true or false, and is the ID of the guest
      return User.find(session[:guest])
    end
    nil
  end

  def current_customer
    return current_user if current_user
    return current_guest if current_guest
  end

  def check_admin_mode
    if admin_mode? && controller_name != 'sessions' && controller_name != 'products' && !current_radmin
      redirect_to :controller => :static, :action => :maintenance
    end
  end

  def admin_mode?
    Rails.env == 'test' ? false : Switch.maintenance_mode.on?
  end

  #Might want to do a little bit of refactoring here, since some of the same code gets called in all 3 main blocks
  def find_cart
    #instead of throwing all my product objects into the session[:cart], I want to create a Cart here (if one doesn't exist) and save it to the database, and then get the Cart ID into the session[:cart_id]
    #First look for a cart in the session"
    if session[:cart_id]
      begin
        @cart = Cart.find(session[:cart_id])
      rescue ActiveRecord::RecordNotFound
        #Do nothing
      end
      if @cart && @cart.user_id.nil? && current_customer #if cart is in session, but doesn't belong to a user, this will assign a user to the cart if there is a current_user
        @cart.user_id = current_customer.id
        @cart.save
      elsif @cart.nil?
        set_new_cart
      end
    #if no cart, look for a current_user
    elsif current_customer
      begin
        @cart = Cart.users_most_recent_cart(current_customer.id) #Get the users most recent cart. This can come in handy in case sessions got cleared out, but there was still a saved cart for the user
      rescue
        #Nothing
      end
      if @cart.nil?
        @cart = Cart.new
        @cart.user_id = current_customer.id
        @cart.save
      end
      session[:cart_id] = @cart.id
    #if neither cart in session nor current_user, then create a cart and add to session
    else
      set_new_cart
    end
  end

  def string_to_snake_case(string)
    x = string.downcase
    x = x.gsub(' ','_')
    x
  end

  def set_new_cart
    @cart = Cart.new
    if current_customer
      @cart.user_id = current_customer.id
    end
    @cart.save
    session[:cart_id] = @cart.id
  end

  def get_categories
    @categories = Category.find_live_categories
    @alternatives = Product.alternative_builds
    @price_groups = Product.sort_by_price
  end

  def set_users_referrer_code
    if session[:referrer_code].blank? && params[:referrer_code]
      session[:referrer_code] = params[:referrer_code]
    end
  end

  #for declaring 404s
  def not_found
    render :file => "#{Rails.root}/public/404.html", :status => :not_found, :layout => false
  end
end
