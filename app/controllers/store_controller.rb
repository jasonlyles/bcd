class StoreController < ApplicationController
  before_filter :set_return_to_checkout, :only => [:checkout]
  before_filter :set_guest_checkout_flag, :only => [:checkout]
  before_filter :authenticate_user!, :only => [:checkout, :submit_order], unless: :user_is_guest? #May need to ditch this for guest checkout flow
  before_filter :check_users_previous_orders, :only => [:checkout], unless: :user_is_guest?
  before_filter :get_users_physical_address, :only => [:checkout]
  before_filter :get_address_form_data, :only => [:enter_address, :validate_street_address]
  if Rails.env.development?
    after_filter :mock_paypal_call_to_listener, :only => [:submit_order]
  end

  def index
    @product_types = ProductType.find_live_product_types
  end

  def products
    begin
      @product_type = ProductType.where("name=?",params[:product_type_name])[0]
      @top_categories = @categories.dup
      @products = @product_type.products.in_stock.page(params[:page]).per(12)
    rescue NoMethodError, ActiveRecord::RecordNotFound => e
      logger.error("Failed to get store#products. ProductType Name: #{params[:product_type_name]}")
      flash[:notice] = "Sorry. We don't have any of those."
      redirect_to('/store')
    end
  end

  def cart
    item_list = check_for_errant_items
    unless item_list.nil?
      flash[:notice] = "The following item(s) are not available in the quantities you have in your cart: #{item_list.to_sentence}. Please reduce quantities or remove the item(s) from your cart."
      render :action => :cart
    end
  end

  def categories
    if params[:category_name] == "Alternatives"
      @category = Category.find_by_name("Alternative Builds")
      @products = Product.alternative_builds.page(params[:page]).per(12)
    elsif params[:category_name] == 'group_on_price'
      @category = OpenStruct.new
      if params[:price] == "free"
        @category.name = "Completely FREE Instructions!"
        @category.description = "Enjoy these completely free instructions, complements of Brick City Depot!"
      else
        @category.name = "$#{params[:price]} instructions"
        @category.description = "$#{params[:price]} instructions"
      end
      @products = Product.find_all_by_price(params[:price]).page(params[:page]).per(12)
    else
      @category = Category.find_by_name(params[:category_name])
      if @category
        @products = @category.products.find_instructions_for_sale.order("product_code DESC").page(params[:page]).per(12)
      else
        flash[:notice] = "Sorry. That product category does not exist."
        return redirect_to :action => :index
      end
    end
  end

  def add_to_cart
    product = Product.find_by_product_code(params[:product_code].upcase) #Doing this just to make sure a valid product is being used.
    if product.nil?
      logger.error("Attempt to access invalid product: #{params[:product_code]}")
      return redirect_to :back, :notice => "Invalid Product"
    end
    if product.is_free?
      return redirect_to :back, :notice => "You don't need to add free instructions to your cart. Just go to your account page to download them."
    end
    @current_item = @cart.add_product(product)
    if @current_item.nil?
      return redirect_to :back, :notice => "You already have #{product.name} in your cart. You don't need to purchase more than 1 set of the same instructions.", :only_path => true
    else
      return redirect_to :back, :notice => "Item added to cart."
    end
  end
  
  def remove_item_from_cart
    @cart.remove_product(params[:id])
    return redirect_to :back, :notice => "Item removed from cart"
  rescue
    return redirect_to :back, :notice => "Item could not be removed from cart. We have been notified of this issue so it can be resolved. We apologize for the inconvenience. If you need to remove this item, you may try emptying your cart. I... am so embarrassed.", :only_path => true
  end

  def update_item_in_cart
    @cart.update_product_quantity(params[:cart][:item_id],params[:cart][:quantity])
    return redirect_to :cart, :notice => "Cart Updated"
  end

  def validate_street_address
    if params[:order] && params[:order][:address_submission_method] == "form"
      @order = Order.new(params[:order])
    else
      @order = Order.new
    end
    unless @order.valid?
      return render :action => :enter_address
    else
      @order = nil
      session[:address_submitted] = params[:order]
      return redirect_to :action => :checkout
    end
  end

  def checkout
    session.delete(:return_to_checkout)
    @user = current_customer
    if @user.nil?
      return redirect_to :controller => :sessions, :action => :guest_registration
    end
    if session[:address_submitted]
      @submission_method = session[:address_submitted][:address_submission_method]
      if @submission_method == "form"
        @order = Order.new(session[:address_submitted])
      end
    end
    if @cart.cart_items.empty?
      redirect_to :back, :notice => "Your cart is empty."
    else
      item_list = check_for_errant_items
      unless item_list.nil?
        return redirect_to :cart, :notice => "The following item(s) are not available in the quantities you have in your cart: #{item_list.to_sentence}. Please reduce quantities or remove the item(s) from our cart."
      end
    end
  end

  def submit_order
    @order = Order.new(params[:order])
    @order.add_line_items_from_cart(@cart)
    item_amount_string = ""
    @order.line_items.each_with_index do |item,i|
      item_amount_string += "&item_name_#{i+1}=#{item.product.product_code} #{item.product.name}&amount_#{i+1}=#{item.product.price.to_f}&quantity_#{i+1}=#{item.quantity}"
    end
    @order.request_id = SecureRandom.hex(20)
    if @order.save
      #Find all carts for this user and destroy!
      carts = Cart.where("user_id=?", @cart.user_id)
      carts.each do |cart|
        cart.destroy
      end
      session[:cart_id] = nil
      redirect_to URI.encode("https://www.#{PaypalConfig.config.host}/cgi-bin/webscr?cmd=_cart&upload=1&custom=#{@order.request_id}&business=#{PaypalConfig.config.business_email}&image_url=http://brickcitydepot.com/uploads/4/8/0/4/4804115/4994570.jpg&return=#{PaypalConfig.config.return_url}&notify_url=#{PaypalConfig.config.notify_url}&currency_code=USD#{item_amount_string}")
    else
      begin
        ExceptionNotifier.notify_exception(ActiveRecord::ActiveRecordError.new(self), :env => request.env, :data => {:message => "Failed trying to submit order."})
      ensure
        redirect_to :cart, :notice => "Uh-oh. Something bad happened. Please try again."
      end
    end
  end

  def empty_cart
    carts = Cart.where("user_id=?",@cart.user_id)
    carts.each do |cart|
      cart.destroy
    end
    session[:cart_id] = nil
    redirect_to :store, :notice => "You have emptied your cart."
  end

  def product_details
    @product = Product.where(["product_code=?",params[:product_code].upcase]).first || not_found
  end

  #This action listens for Instant Payment Notifications from Paypal. It makes sure the IPN is valid, and performs
  #several other checks to make sure everything is on the up and up.
    #Need to make
    #sure that a user's order doesn't show up in their account screen if the order hasn't been confirmed by paypal yet.
    #if IPN didn't get handled correctly? User should be able to see their order in their order history, and see if the
    #order had a problem with it. They can then contact us with their transaction ID and confirmation code (Request ID).
  def listener
    logger.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX')
    logger.debug("PAYPAL PARAMS: #{params.inspect}")
    @ipn = InstantPaymentNotification.new(params)
    logger.debug("PAYPAL IPN: #{@ipn.inspect}")
    logger.debug("XXXXXXXXXXXXXXXXXXXXXXXXXX")
    @order = Order.find_by_request_id(@ipn.custom)

    #If we can't find the order, just tell paypal to forget about it
    if @order.nil?
      return render :nothing => true
    end
    #I don't want to update an order that has been completed.
    if !@order.status.blank? && @order.status.upcase == 'COMPLETED'
      return render :nothing => true
    end

    if @ipn.valid?
      @order.transaction_id = @ipn.txn_id
      @order.status = @ipn.payment_status.upcase if @ipn.payment_status
      if @order.has_physical_item?
        #Assuming that because the street address is blank, there is no other address info, and we can save address info
        #coming to us from paypal
        if @order.address_street_1.blank?
          @order.first_name = @ipn.first_name
          @order.last_name = @ipn.last_name
          @order.address_city = @ipn.address_city
          @order.address_country = @ipn.address_country
          @order.address_name = @ipn.address_name
          @order.address_state = @ipn.address_state
          @order.address_street_1 = @ipn.address_street
          @order.address_zip = @ipn.address_zip
        end
        @order.shipping_status = 3 #3 = pending
      end
      @order.save

      #Now that the order is validated and everything is saved, I'll email the user to let them know about it.
      begin
        if @order.user.guest?
          link_to_downloads = @order.get_link_to_downloads
          OrderMailer.guest_order_confirmation(@order.user,@order,link_to_downloads).deliver
        else
          OrderMailer.order_confirmation(@order.user,@order).deliver
        end
      rescue => e
        ExceptionNotifier.notify_exception(e, :env => request.env, :data => {:message => "Failed trying to send order confirmation email for #{@order.to_yaml}."})
      end
      handle_physical_items
    else
      @order.transaction_id = @ipn.txn_id
      @order.status = @ipn.payment_status
      @order.save
    end
    return render :nothing => true
  end

  def order_confirmation_email_test
    @order = Order.find_by_user_id 27  #Jason
    #@order = Order.find_by_user_id 3  #Brian
    #OrderMailer.order_confirmation(@order.user, @order).deliver
    download_links = @order.get_link_to_downloads
    OrderMailer.guest_order_confirmation(@order.user, @order, download_links).deliver
  end

  def physical_order_email_test
    @order = Order.find 9
    OrderMailer.physical_item_purchased(@order.user, @order).deliver
  end

  def thank_you_for_your_order
  end

  def enter_address
    if current_user && !current_user.orders.blank? && !session[:address_submitted]
      @order = current_user.orders.where("status='COMPLETED' and address_street_1 not null").order("updated_at DESC").first
      @order ||= Order.new
    elsif session[:address_submitted]
      @submission_method = session[:address_submitted][:address_submission_method]
      if @submission_method == "form"
        @order = Order.new(session[:address_submitted])
      else
        @order = Order.new
      end
    else
      @order = Order.new
    end
  end

  private

  def set_return_to_checkout
    session[:return_to_checkout] = true
  end

  def user_is_guest?
    session[:guest] ? true : false
  end

  def set_guest_checkout_flag
    session[:show_guest_checkout_link] = true unless session[:guest]
  end

  def check_for_errant_items
    session.delete :errant_cart_items
    errant_cart_items = []
    item_list = nil
    @cart.cart_items.each do |item|
      if item.product.is_physical_product?
        unless item.product.quantity_available?(item.quantity)
          errant_cart_items << [item.product.product_code,item.product.name]
        end
      end
    end
    unless errant_cart_items.blank?
      session[:errant_cart_items] = errant_cart_items
      item_list = []
      errant_cart_items.each do |item|
        item_list << "#{item[0]} #{item[1]}"
      end
    end
    item_list
  end

  #This action is used in dev to mock a call from paypal to the app to confirm the order was ok
  def mock_paypal_call_to_listener
    @order.transaction_id = SecureRandom.hex(20)
    @order.status = 'COMPLETED'
    @order.save
    OrderMailer.order_confirmation(@order.user,@order).deliver
  end

  def handle_physical_items
    physical_items = []
    @order.line_items.each do |item|
      if item.product.is_physical_product?
        physical_items << item
        product = Product.find(item.product.id)
        product.decrement_quantity(item.quantity)
      end
    end
    if physical_items.length > 0
      physical_items.each do |item|
         #add to string that gets sent in email
      end
      begin
        OrderMailer.physical_item_purchased(@order.user, @order).deliver
      rescue
        ExceptionNotifier.notify_exception(ActiveRecord::ActiveRecordError.new(self), :env => request.env, :data => {:message => "Failed trying to send physical product order email for #{@order.to_yaml}."})
      end
    end
  end

  #Making sure that the user hasn't previously purchased the same set of instructions. Physical items can be purchased again
  def check_users_previous_orders
    unless current_guest
      orders = current_user.orders
      @products_from_previous_orders = []
      orders.each do |order|
        order.line_items.each do |line_item|
          if line_item.product.is_digital_product? && !order.transaction_id.blank?
            @products_from_previous_orders << line_item.product_id
          end
        end
      end
      @products_in_cart = []
      @cart.cart_items.each do |cart_item|
        @products_in_cart << cart_item.product_id
      end
      dups = @products_from_previous_orders & @products_in_cart
      if !dups.empty?
        nice_string = dups.collect{|dup| Product.find(dup).name}.join(",")
        redirect_to :cart, :notice => "You've already purchased the following products before, (#{nice_string}) and you don't need to do it again. Purchasing instructions once allows you to download the files #{MAX_DOWNLOADS} times.", :only_path => true
      end
    end
  end

  def get_users_physical_address
    if @cart.has_physical_item? && session[:address_submitted].nil? #&& params[:order].nil? #&& maybe test for a condition to see if a logged in user has an address stored already. Should have a user or guest by this point, and so I'll be able to check if user has an address on file.
      redirect_to :enter_address
    end
  end

  def get_address_form_data
    @states = Array[["Alabama","AL"],
                    ["Alaska","AK"],
                    ["American Samoa","AS"],
                    ["Arizona","AZ"],
                    ["Arkansas","AR"],
                    ["California","CA"],
                    ["Colorado","CO"],
                    ["Connecticut","CT"],
                    ["District of Columbia","DC"],
                    ["Delaware","DE"],
                    ["Florida","FL"],
                    ["Georgia","GA"],
                    ["Guam","GU"],
                    ["Hawaii","HI"],
                    ["Idaho","ID"],
                    ["Illinois","IL"],
                    ["Indiana","IN"],
                    ["Iowa","IA"],
                    ["Kansas","KS"],
                    ["Kentucky","KY"],
                    ["Louisiana","LA"],
                    ["Maine","ME"],
                    ["Maryland","MD"],
                    ["Massachusetts","MA"],
                    ["Michigan","MI"],
                    ["Minnesota","MN"],
                    ["Mississippi","MS"],
                    ["Missouri","MO"],
                    ["Montana","MT"],
                    ["Nebraska","NE"],
                    ["Nevada","NV"],
                    ["New Hampshire","NH"],
                    ["New Jersey","NJ"],
                    ["New Mexico","NM"],
                    ["New York","NY"],
                    ["North Carolina","NC"],
                    ["North Dakota","ND"],
                    ["Ohio","OH"],
                    ["Oklahoma","OK"],
                    ["Oregon","OR"],
                    ["Pennsylvania","PA"],
                    ["Puerto Rico","PR"],
                    ["Rhode Island","RI"],
                    ["South Carolina","SC"],
                    ["South Dakota","SD"],
                    ["Tennessee","TN"],
                    ["Texas", "TX"],
                    ["Utah", "UT"],
                    ["Vermont","VT"],
                    ["Virginia", "VA"],
                    ["Virgin Islands","VI"],
                    ["Washington","WA"],
                    ["West Virginia","WV"],
                    ["Wisconsin","WI"],
                    ["Wyoming","WY"]]
    @countries = [["United States","US"]]
  end
end
