class AdminController < ApplicationController
  before_filter :authenticate_radmin!
  before_filter :arrange_products_in_a_nice_way, :only => [:update_users_download_counts, :new_product_notification]
  skip_before_filter :find_cart
  skip_before_filter :check_admin_mode
  before_filter :get_categories_for_admin
  skip_before_filter :get_categories
  skip_before_filter :set_users_referrer_code
  skip_before_filter :set_locale
  #include Devise::Models::DatabaseAuthenticatable # Not sure why I was including this in here, but it seems to be
  # breaking when upgrading to Devise 3.5/10, and doesn't appear to break anything by commenting it out. Will leave as
  # comment until I'm certain commenting it out is ok.
  layout proc{ |controller| controller.request.xhr? ? false : "admin" }

  # Quick fix until I fix namespacing controller/routing
  def index
    redirect_to admin_products_path
  end

  def gift_instructions
    user_id = params['gift']['user_id']
    product_id = params['gift']['product_id']
    @user = User.find(user_id)

    @order = Order.where("user_id = ? and status = 'GIFT'", user_id).first
    @order = Order.new(user_id: user_id, status: 'GIFT', transaction_id: SecureRandom.hex(20), request_id: SecureRandom.hex(20)) if @order.blank?

    @line_item = LineItem.where("order_id = ? and product_id = ?",@order.id, product_id).first
    @line_item.destroy if @user.owns_product?(product_id)

    @order.line_items << LineItem.new(product_id: product_id, quantity: 1, total_price: 0) if @line_item.blank?
    respond_to do |format|
      if @order.save
        format.json {render json: true}
      else
        format.json {render json: false}
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
    redirect_to :action => :maintenance_mode
  end

  def become
    return unless current_radmin
    sign_in(:user, User.find(params[:id]))
    redirect_to root_path
  end

  def find_user
    @user = User.find_by_email(params[:user][:email].downcase)
    @products = Product.ready_instructions.order('category_id').order('product_code')
    respond_to do |format|
      format.js
    end
  end

  def find_order
    @order = Order.send("find_by_#{params[:order][:lookup_field]}",params[:order][:lookup_id])# find_by_(params[:order][:lookup_id])
    respond_to do |format|
      format.js
    end
  end

  def admin_profile
    @radmin = Radmin.find(params[:id])
  end

  def update_admin_profile
    @radmin = Radmin.find(params[:id])
    if !params[:radmin][:email].blank? || @radmin.is_valid_password?(params[:radmin][:current_password])
      #Deleting the current_password from the params because it's protected from mass assignment, and doesn't get saved.
      params[:radmin].delete(:current_password)
      if @radmin.update_attributes(params[:radmin])
        sign_in :radmin, @radmin, :bypass => true
        #respond_with resource, :location => after_update_path_for(resource)
        redirect_to(admin_profile_admin_url, :notice => 'Profile was successfully updated.')
      else
        render "admin_profile"
      end
    else
      @radmin.errors.add(:current_password, "is invalid.")
      render "admin_profile"
    end
  end

  #TODO: Change this action to accept users ID. Will make for a cleaner action and test.
  def change_user_status
    user = params[:user]
    @user = User.find_by_email(user[:email].downcase)
    @user.update_attributes(:account_status => user[:account_status])
    @products = Product.ready_instructions.order('category_id').order('product_code')
    respond_to do |format|
      format.js
    end
  end

  def order
    @order = Order.find(params[:id])
  end

  def update_users_download_counts
  end

  def complete_order
    @order = Order.find(params[:order][:id])
    @order.status = 'COMPLETED'
    @order.save
    flash[:notice] = "Order was marked COMPLETED"
    redirect_to :back
  end

  # Shipping status = 0 then completed
  # Shipping status = 1 then shipped
  # Shipping status = 2 then ready
  # Shipping status = 3 then pending
  def order_fulfillment
    @shipping_statuses = [['Completed',0],['Shipped',1],['Ready',2],['Pending',3]]
    @completed_orders = Order.shipping_status_complete
    @incomplete_orders = Order.shipping_status_not_complete.page(params[:page]).per(10)
  end

  def update_order_shipping_status
    @order = Order.find params['order_id']
    @order.shipping_status = params['shipping_status']
    @order.save
    flash[:notice] = 'Order updated'
    redirect_to :action => :order_fulfillment
  end

  def sales_report
    @report = SalesReport.new
  end

  def sales_report_monthly_stats
    start_date = params[:start_date]
    start_month = start_date['month']
    start_year = start_date['year']
    end_date = params[:end_date]
    @report = SalesReport.new(:start_date => start_date, :end_date => end_date)
    @report.report_date = "#{start_year}-#{start_month}-01"

    if @report.multiple_months?
      @summaries = SalesReport.get_sweet_stats(start_month,start_year,end_date['month'],end_date['year'])
    else
      report = SalesReport.find_by_report_date("#{@report.report_date}")
      if params['commit'] == "Force Regeneration"
        report.destroy if report
        report = nil
      end
      unless report
        #Can't find one, let's create one
        @report.save
        @summaries = @report.generate_sales_report
      else
        if report.completed == false
          #The sales report isn't for a complete month, so destroy all sales_summaries, and lets start fresh.
          report.sales_summaries.destroy_all
          @summaries = report.generate_sales_report
        else
          @summaries = SalesReport.get_sweet_stats(start_month,start_year,nil,nil)
        end
        @report = report
      end
      if @report.report_date < Date.today.beginning_of_month
        @report.completed = true
        @report.save
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def transactions_by_month
    date = Date.parse(params[:date])
    @transactions = Order.all_transactions_for_month(date.month,date.year)
    respond_to do |format|
      format.html
      format.csv {send_data Order.transaction_csv(@transactions), {filename: "#{date.strftime("%Y")}_#{date.strftime("%m")}_transactional_detail.csv"}}
    end
  end

  def send_new_product_notification
    email = params[:email]
    queued = NewProductNotificationJob.create({product_id: email['product_id'], message: email['optional_message']})
    if queued.nil?
      flash[:alert] = "Couldn't queue email jobs. Check out /jobs and see what's wrong"
    else
      flash[:notice] = "Sending new product emails"
    end
    redirect_to :new_product_notification
  end

  def update_downloads_for_user
    queued = ProductUpdateNotificationJob.create({product_id: params[:user][:model], message: params[:user][:message]})
    if queued.nil?
      flash[:notice] = "Couldn't queue mail jobs. Check out /jobs and see what's wrong"
    else
      flash[:notice] = "Sending product update emails"
    end
    redirect_to :update_users_download_counts
  end

  private

  def arrange_products_in_a_nice_way
    products = Product.find_products_for_sale
    @products = []
    products.each { |product| @products << ["#{product.product_code} #{product.name}", product.id] }
  end
end
