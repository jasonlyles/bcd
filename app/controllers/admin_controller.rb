class AdminController < ApplicationController
  before_filter :authenticate_radmin!
  before_filter :arrange_products_in_a_nice_way, :only => [:update_users_download_counts, :new_product_notification]
  skip_before_filter :find_cart
  include Devise::Models::DatabaseAuthenticatable
  layout 'admin'

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
    @user = User.find_by_email(params[:user][:email])
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
    @user = User.find_by_email(user[:email])
    @user.update_attributes(:account_status => user[:account_status])
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
    queued = Resque.enqueue(ResqueJobs::NewProductNotification, email['product_id'], email['optional_message'])
    if queued.nil?
      flash[:notice] = "Couldn't queue email jobs. Check out /jobs and see what's wrong"
    else
      flash[:notice] = "Sending new product emails"
    end
    redirect_to :new_product_notification
  end

  def update_downloads_for_user
    queued = Resque.enqueue(ResqueJobs::ProductUpdateNotification, params[:user][:model], params[:user][:message])
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
