# frozen_string_literal: true

class AdminController < ApplicationController
  before_action :authenticate_radmin!
  before_action :arrange_products_in_a_nice_way, only: %i[update_users_download_counts new_product_notification]
  skip_before_action :find_cart
  skip_before_action :check_admin_mode
  before_action :assign_categories_for_admin
  skip_before_action :set_users_referrer_code
  # skip_before_action :set_locale # Don't need this yet.
  layout proc { |controller| controller.request.xhr? ? false : 'admin' }

  # Quick fix until I fix namespacing controller/routing
  def index
    redirect_to admin_products_path
  end

  def gift_instructions
    user_id = params['gift']['user_id']
    product_id = params['gift']['product_id']
    @user = User.find(user_id)

    @order = Order.where("user_id = ? and status = 'GIFT'", user_id).first
    @order = Order.new(user_id:, status: 'GIFT', transaction_id: SecureRandom.hex(20), request_id: SecureRandom.hex(20)) if @order.blank?

    @line_item = LineItem.where('order_id = ? and product_id = ?', @order.id, product_id).first
    @line_item.destroy if @user.owns_product?(product_id)

    @order.line_items << LineItem.new(product_id:, quantity: 1, total_price: 0) if @line_item.blank?
    respond_to do |format|
      if @order.save
        format.json { render json: true }
      else
        format.json { render json: false }
      end
    end
  end

  def featured_products
    @products = Product.ready.order('category_id').order('product_code')
  end

  def maintenance_mode
    @mm_switch = Switch.maintenance_mode
  end

  def switch_maintenance_mode
    @mm_switch = Switch.maintenance_mode
    @mm_switch.on? ? @mm_switch.off : @mm_switch.on
    redirect_to action: :maintenance_mode
  end

  def admin_profile
    @radmin = Radmin.find(params[:id])
  end

  def update_admin_profile
    @radmin = Radmin.find(params[:id])
    if !params[:radmin][:email].blank? || @radmin.valid_password?(params[:radmin][:current_password])
      # Deleting the current_password from the params because it's protected from mass assignment, and doesn't get saved.
      params[:radmin].delete(:current_password)
      if @radmin.update(radmin_params)
        # sign_in :radmin, @radmin, bypass: true
        bypass_sign_in(@radmin)
        # respond_with resource, location: after_update_path_for(resource)
        redirect_to(admin_profile_admin_url, notice: 'Profile was successfully updated.')
      else
        render 'admin_profile'
      end
    else
      @radmin.errors.add(:current_password, 'is invalid.')
      render 'admin_profile'
    end
  end

  def update_users_download_counts; end

  # Shipping status = 0 then completed
  # Shipping status = 1 then shipped
  # Shipping status = 2 then ready
  # Shipping status = 3 then pending
  def order_fulfillment
    @shipping_statuses = [['Completed', 0], ['Shipped', 1], ['Ready', 2], ['Pending', 3]]
    @completed_orders = Order.shipping_status_complete
    @incomplete_orders = Order.shipping_status_not_complete.page(params[:page]).per(10)
  end

  def update_order_shipping_status
    @order = Order.find params['order_id']
    @order.shipping_status = params['shipping_status']
    @order.save
    flash[:notice] = 'Order updated'
    redirect_to action: :order_fulfillment
  end

  def send_new_product_notification
    email = params[:email]
    NewProductNotificationJob.perform_async(email['product_id'], email['optional_message'])
    flash[:notice] = 'Sending new product emails'
    redirect_to :new_product_notification
  end

  def update_downloads_for_users
    ProductUpdateNotificationJob.perform_async(params[:user][:model], params[:user][:message])
    flash[:notice] = 'Sending product update emails'
    redirect_to :update_users_download_counts
  end

  private

  def arrange_products_in_a_nice_way
    products = Product.find_products_for_sale
    @products = []
    products.each { |product| @products << ["#{product.product_code} #{product.name}", product.id] }
  end

  # Only allow a trusted parameter "white list" through.
  def radmin_params
    params.require(:radmin).permit(:email, :password, :password_confirmation, :remember_me)
  end
end
