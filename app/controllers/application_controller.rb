class ApplicationController < ActionController::Base
  protect_from_forgery
  layout proc{ |controller| controller.request.xhr? ? false : "application" }
  #Need to find a way to not call these before_filters on certain controllers, or maybe these should just be on the controllers with urls a customer might hit.
  before_filter :check_admin_mode, :except => [:maintenance]
  before_filter :find_cart
  before_filter :set_users_referrer_code
  before_filter :prepare_exception_notifier
  #before_filter :set_locale #Don't need this yet

  private

  def prepare_exception_notifier
    if current_user && current_user.guid
      request.env["exception_notifier.exception_data"] = {
          current_user: current_user.guid
      }
    end
  end

  #This is used on the admin side to get all categories for product and subcategory forms
  def get_categories_for_admin
    categories = Category.all
    @categories = []
    categories.each{|category|@categories << [category.name,category.id]}
  end

  def set_locale
    hal = HttpAcceptLanguage::Parser.new(request.env['HTTP_ACCEPT_LANGUAGE'])
    I18n.locale = hal.language_region_compatible_from(SUPPORTED_LOCALES) || I18n.default_locale
  end

  def set_guest_status
    session[:guest] ||= true
  end

  def clean_up_guest
    @cart = Cart.find_by_user_id(session[:guest])
    if @cart
      @cart.user_id = nil
      @cart.save
    end
    session.delete(:guest) unless session[:guest].blank?
  end

  def current_guest
    guest_id = session[:guest]
    if guest_id && guest_id.is_a?(Integer)#meaning it's not true or false, and is the ID of the guest
      return User.find(guest_id)
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

  def find_cart
    @cart = Cart.where("id=?",session[:cart_id]).last
    if @cart
      if @cart.user_id?
        return #This cart is good to go
      else
        if current_customer
          use_older_cart_or_update_existing_cart
        end
      end
    elsif current_customer
      #When a user has logged in, try to pick up a previous cart. Maybe they didn't finish shopping
      #before getting timed out
      use_older_cart_if_available
    end
  end

  def use_older_cart_or_update_existing_cart
    if @cart.empty? #Only look for an older cart if the current one is empty
      use_older_cart_if_available
    end
    update_cart_with_user unless @cart.user_id? #The cart would only have a user ID now if an older cart was found
  end

  def update_cart_with_user
    @cart.user_id = current_customer.id
    @cart.save
  end

  def use_older_cart_if_available
    cart = Cart.users_most_recent_cart(current_customer.id)
    if cart
      @cart.destroy if @cart #Delete the old cart so it doesn't end up abandoned by the code
      @cart = cart
      session[:cart_id] = @cart.id
    end
  end

  def create_cart
    @cart = Cart.new
    if current_customer
      use_older_cart_or_update_existing_cart
    else
      @cart.save
    end
    session[:cart_id] = @cart.id
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
