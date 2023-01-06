# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  layout proc { |controller| controller.request.xhr? ? false : 'application' }
  # Need to find a way to not call these before_actions on certain controllers, or maybe these should just be on the controllers with urls a customer might hit.
  before_action :check_admin_mode, except: [:maintenance]
  before_action :find_cart
  before_action :set_users_referrer_code
  before_action :prepare_exception_notifier
  # before_action :set_locale #Don't need this yet
  # before_action :configure_permitted_parameters, if: :devise_controller?
  #
  # protected
  #
  # def configure_permitted_parameters
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  # end

  private

  def prepare_exception_notifier
    return unless current_user&.guid

    request.env['exception_notifier.exception_data'] = {
      current_user: current_user.guid
    }
  end

  # This is used on the admin side to get all categories for product and subcategory forms
  def assign_categories_for_admin
    categories = Category.all
    @categories = []
    categories.each { |category| @categories << [category.name, category.id] }
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
    # meaning it's not true or false, and is the ID of the guest
    return User.find(guest_id) if guest_id.is_a?(Integer)

    nil
  end

  def current_customer
    return current_user if current_user
    return current_guest if current_guest
  end

  def check_admin_mode
    redirect_to controller: :static, action: :maintenance if admin_mode? && controller_name != 'sessions' && controller_name != 'products' && !current_radmin
  end

  def admin_mode?
    Rails.env == 'test' ? false : Switch.maintenance_mode.on?
  end

  def find_cart
    @cart = Cart.where('id=?', session[:cart_id]).last
    if @cart
      # This cart is good to go
      return if @cart.user_id?

      use_older_cart_or_update_existing_cart if current_customer
    elsif current_customer
      # When a user has logged in, try to pick up a previous cart. Maybe they didn't finish shopping
      # before getting timed out
      use_older_cart_if_available
    end
  end

  def use_older_cart_or_update_existing_cart
    # Only look for an older cart if the current one is empty
    use_older_cart_if_available if @cart.empty?
    # The cart would only have a user ID now if an older cart was found
    update_cart_with_user unless @cart.user_id?
  end

  def update_cart_with_user
    @cart.user_id = current_customer.id
    @cart.save
  end

  def use_older_cart_if_available
    cart = Cart.users_most_recent_cart(current_customer.id)
    return unless cart

    # Delete the old cart so it doesn't end up abandoned by the code
    @cart&.destroy
    @cart = cart
    session[:cart_id] = @cart.id
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
    session[:referrer_code] = params[:referrer_code] if session[:referrer_code].blank? && params[:referrer_code]
  end

  # for declaring 404s
  def not_found
    render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false
  end
end
