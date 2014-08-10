class StoreController < ApplicationController
  before_filter :set_return_to_checkout, :only => [:checkout]
  before_filter :set_guest_checkout_flag, :only => [:checkout]
  before_filter :authenticate_user!, :only => [:checkout, :submit_order], unless: :user_is_guest? #May need to ditch this for guest checkout flow
  before_filter :check_users_previous_orders, :only => [:checkout], unless: :user_is_guest?
  before_filter :get_users_physical_address, :only => [:checkout]
  before_filter :get_address_form_data, :only => [:enter_address, :validate_street_address]
  skip_before_filter :find_cart, only: [:listener, :thank_you_for_your_order]

  #:nocov:
  if Rails.env.development?
    after_filter :mock_paypal_call_to_listener, :only => [:submit_order]
  end
  #:nocov:

  def index
    @product_types = ProductType.find_live_product_types
  end

  def products
    @product_type = ProductType.where("name=?",params[:product_type_name])[0]
    unless @product_type.blank?
      if params[:product_type_name].downcase != 'instructions'
        @products = Product.where("product_type_id=?",@product_type.id).in_stock.page(params[:page]).per(12)
      else
        @top_categories = @categories.dup
      end
    else
      return redirect_to('/store')
    end
  end

  def instructions
    redirect_to action: :products, product_type_name: 'Instructions'
  end

  def cart
    item_list = check_for_errant_items if @cart
    if item_list
      flash[:notice] = "The following item(s) are not available in the quantities you have in your cart: #{item_list.to_sentence}. Please reduce quantities or remove the item(s) from your cart."
      render :cart
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
        @products = @category.products.find_instructions_for_sale.order("product_code ASC").page(params[:page]).per(12)
      else
        flash[:notice] = "Sorry. That product category does not exist."
        return redirect_to :action => :index
      end
    end
  end

  def add_to_cart
    #This method can be called via a link in a new product notification email, in which case, there won't be a
    # :back that I want to use, so set the redirect to take the user to the cart. Otherwise, return to :back, as
    # 'add to cart' buttons that POST are scattered throughout the app.
    back_or_cart = request.method == 'GET' ? :cart : :back
    create_cart unless @cart
    product = Product.find_by_product_code(params[:product_code].upcase) #Doing this just to make sure a valid product is being used.
    if product.blank?
      logger.error("Attempt to access invalid product: #{params[:product_code]}")
      return redirect_to back_or_cart, :notice => "Invalid Product"
    end
    if product.is_free?
      return redirect_to back_or_cart, :notice => "You don't need to add free instructions to your cart. Just go to your account page to download them."
    end
    @current_item = @cart.add_product(product)
    if @current_item
      return redirect_to back_or_cart, :notice => "Item added to cart."
    else
      return redirect_to back_or_cart, :notice => "You already have #{product.name} in your cart. You don't need to purchase more than 1 set of the same instructions.", :only_path => true
    end
  end

  def remove_item_from_cart
    @cart.remove_product(params[:id])
    return redirect_to :back, :notice => "Item removed from cart"
  rescue
    return redirect_to :back, :notice => "Item could not be removed from cart. We have been notified of this issue so it can be resolved. We apologize for the inconvenience. If you need to remove this item, you may try emptying your cart. I... am so embarrassed.", :only_path => true
  end

  def update_item_in_cart
    #If product is available in qty requested, then add to cart, else redirect to cart and flash qty not available message.
    #Other checks for errant items should stay in place because they protect against a user putting an item in his cart,
    # someone else putting the item in their cart, and then one of them going to checkout later and finding out the item
    # is no longer available after they've checked out. With those checks staying in place, hitting the cart and checkout
    # views will always perform that check.
    product = CartItem.find(params[:cart][:item_id]).product
    if product.quantity_available?(params[:cart][:quantity].to_i)
      @cart.update_product_quantity(params[:cart][:item_id],params[:cart][:quantity])
      return redirect_to :cart, :notice => "Cart Updated"
    else
      var = product.quantity == 1 ? 'is' : 'are'
      message = "Sorry. There #{var} only #{product.quantity} available for #{product.code_and_name}. Please reduce quantities or remove the item(s) from you cart."
      return redirect_to :cart, notice: message
    end
  end

  def validate_street_address
    if params[:order] && params[:order][:address_submission_method] == "form"
      @order = Order.new(params[:order])
    else
      @order = Order.new
    end
    unless @order.valid?
      return render :enter_address
    else
      @order = nil
      session[:address_submitted] = params[:order]
      return redirect_to :action => :checkout
    end
  end

  def checkout
    session.delete(:return_to_checkout)
    @user = current_customer
    unless @user
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
      if item_list
        return redirect_to :cart, :notice => "The following item(s) are not available in the quantities you have in your cart: #{item_list.to_sentence}. Please reduce quantities or remove the item(s) from our cart."
      end
    end
  end

  def submit_order
    if @cart.nil?
      return redirect_to '/cart'
    end
    @order = Order.new(params[:order])
    @order.add_line_items_from_cart(@cart)
    item_amount_string = ""
    @order.line_items.each_with_index do |item,index|
      item_amount_string += "&item_name_#{index+1}=#{item.product.product_code} #{item.product.name}&amount_#{index+1}=#{item.product.price.to_f}&quantity_#{index+1}=#{item.quantity}"
    end
    @order.request_id = SecureRandom.hex(20)
    if @order.save!
      @cart.destroy
      session.delete(:cart_id)
      redirect_to URI.encode("https://#{PaypalConfig.config.host}/cgi-bin/webscr?cmd=_cart&upload=1&custom=#{@order.request_id}&business=#{PaypalConfig.config.business_email}&image_url=#{Rails.application.config.web_host}/assets/logo140x89.png&return=#{PaypalConfig.config.return_url}&notify_url=#{PaypalConfig.config.notify_url}&currency_code=USD#{item_amount_string}")
    else
      begin
        ExceptionNotifier.notify_exception(ActiveRecord::ActiveRecordError.new(self), :env => request.env, :data => {:message => "Failed trying to submit order."})
      ensure
        redirect_to :cart, :notice => "Uh-oh. Something bad happened. Please try again."
      end
    end
  end

  def empty_cart
    @cart.cart_items.destroy_all
    redirect_to :store, :notice => "You have emptied your cart."
  end

  def product_details
    @product = Product.where(["product_code=?",params[:product_code].upcase]).first || not_found
    @similar_products = @product.find_live_products_from_same_category
  end

  #This action listens for Instant Payment Notifications from Paypal. It makes sure the IPN is valid, and performs
  #several other checks to make sure everything is on the up and up.
    #Need to make
    #sure that a user's order doesn't show up in their account screen if the order hasn't been confirmed by paypal yet.
    #if IPN didn't get handled correctly? User should be able to see their order in their order history, and see if the
    #order had a problem with it. They can then contact us with their transaction ID and confirmation code (Request ID).
  def listener
    logger.debug('XXXXXXXXXXXXXXXXXXXXXXXXXX')
    logger.info("PAYPAL PARAMS: #{params.inspect}")
    @ipn = InstantPaymentNotification.new(params)
    logger.info("PAYPAL IPN: #{@ipn.inspect}")
    logger.debug("XXXXXXXXXXXXXXXXXXXXXXXXXX")
    @order = Order.find_by_request_id(@ipn.custom)
    logger.info("ORDER: #{@order.inspect}")
    logger.debug("XXXXXXXXXXXXXXXXXXXXXXXXXX")
    #If we can't find the order, or the order has already been completed, just tell paypal to forget about it
    if @order.blank? || (!@order.status.blank? && @order.status.upcase == 'COMPLETED')
      logger.debug("Order was blank or status was incorrect")
      return render :nothing => true
    end

    if @ipn.valid?
      logger.debug("PAYPAL IPN is valid")
      @order.transaction_id = @ipn.txn_id
      @order.status = @ipn.payment_status.upcase if @ipn.payment_status
      if @order.has_physical_item?
        logger.debug("Order has physical item")
        #Assuming that because the street address is blank, there is no other address info, and we can save address info
        #coming to us from paypal
        unless @order.address_street_1?
          logger.debug("No stored street address, using street address from Paypal")
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

      if @order.has_digital_item?
        restock_downloads(@order)
      end

      #Now that the order is validated and everything is saved, I'll email the user to let them know about it.
      begin
        if @order.user.guest?
          logger.debug('Sending email for Guest')
          link_to_downloads = @order.get_link_to_downloads
          OrderMailer.guest_order_confirmation(@order.user_id,@order.id,link_to_downloads).deliver
        else
          logger.debug('Sending email for User')
          OrderMailer.order_confirmation(@order.user_id,@order.id).deliver
        end
      rescue => error
        ExceptionNotifier.notify_exception(error, :env => request.env, :data => {:message => "Failed trying to send order confirmation email for #{@order.to_yaml}."})
      end
      if @order.has_physical_item?
        handle_physical_items
      end
    else
      logger.debug("PAYPAL IPN is invalid")
      @order.transaction_id = @ipn.txn_id
      @order.status = @ipn.payment_status
      @order.save
    end
    logger.debug("IPN post was successful")
    return render :nothing => true
  end

  #:nocov:
  def order_confirmation_email_test
    @order = Order.find_by_user_id 5  #Jason
    download_links = @order.get_link_to_downloads
    OrderMailer.guest_order_confirmation(@order.user_id, @order.id, download_links).deliver
  end
  #:nocov:

  #:nocov:
  def physical_order_email_test
    @order = Order.find 9
    OrderMailer.physical_item_purchased(@order.user_id, @order.id).deliver
  end
  #:nocov:

  def thank_you_for_your_order
    if session[:guest]
      @user = User.find session[:guest]
      @order = @user.orders.last
      @download_link = @order.get_link_to_downloads
      session.delete(:guest)
    end
  end

  def enter_address
    if current_user && !current_user.orders.blank? && !session[:address_submitted]
      @order = current_user.orders.where("upper(status)='COMPLETED' and address_street_1 not null").order("updated_at DESC").first
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

  def restock_downloads(order)
    items = order.get_digital_items
    items.each do |item|
      download = Download.find_by_user_id_and_product_id(order.user, item.product.id)
      #If the download record exists, user is trying to buy more downloads, so restock
      unless download.blank?
        download.restock
      end
    end
  end

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

  #:nocov:
  #This action is used in dev to mock a call from paypal to the app to confirm the order was ok
  def mock_paypal_call_to_listener
    @order.transaction_id = SecureRandom.hex(20)
    @order.status = 'COMPLETED'
    @order.save
    if @order.has_digital_item?
      restock_downloads(@order)
    end
    if @order.user.guest?
      link_to_downloads = @order.get_link_to_downloads
      OrderMailer.guest_order_confirmation(@order.user_id,@order.id,link_to_downloads).deliver
    else
      OrderMailer.order_confirmation(@order.user_id,@order.id).deliver
    end
  end
  #:nocov:

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
        OrderMailer.physical_item_purchased(@order.user_id, @order.id).deliver
      rescue
        ExceptionNotifier.notify_exception(ActiveRecord::ActiveRecordError.new(self), :env => request.env, :data => {:message => "Failed trying to send physical product order email for #{@order.to_yaml}."})
      end
    end
  end

  #Making sure that the user hasn't previously purchased the same set of instructions.
  # Physical items can be purchased again.
  # Instructions with 0 downloads remaining can be purchased again.
  def check_users_previous_orders
    unless current_guest
      if @cart.nil?
        return redirect_to '/cart'
      end
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
        final_dups = []
        dups.each do |dup|
          dl = Download.find_by_user_id_and_product_id(current_user.id, dup)
          if (dl && dl.remaining > 0) || dl.nil?
            final_dups << dup
          end
        end
        unless final_dups.blank?
          nice_string = final_dups.collect{|dup| Product.find(dup).name}.join(",")
          redirect_to :cart, :notice => "You've already purchased the following products before, (#{nice_string}) and you don't need to do it again. Purchasing instructions once allows you to download the files #{MAX_DOWNLOADS} times.", :only_path => true
        end
      end
    end
  end

  def get_users_physical_address
    if @cart.has_physical_item? && session[:address_submitted].blank?
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
