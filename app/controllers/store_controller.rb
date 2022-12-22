# frozen_string_literal: true

class StoreController < ApplicationController
  before_action :set_return_to_checkout, only: [:checkout]
  before_action :set_guest_checkout_flag, only: [:checkout]
  before_action :authenticate_user!, only: %i[checkout submit_order], unless: :user_is_guest? # May need to ditch this for guest checkout flow
  before_action :check_users_previous_orders, only: [:checkout], unless: :user_is_guest?
  before_action :assign_users_physical_address, only: [:checkout]
  before_action :assign_address_form_data, only: %i[enter_address validate_street_address]
  skip_before_action :find_cart, only: [:thank_you_for_your_order]

  # :nocov:
  after_action :mock_paypal_call_to_listener, only: [:submit_order] if Rails.env.development?
  # :nocov:

  def products
    @product_type = ProductType.where('name=?', params[:product_type_name])[0]
    if @product_type.blank?
      # TODO: Figure out why favicon requests are coming here. But for now, just don't flash this confusing message for those requests
      flash[:notice] = "Sorry. We don't have any of those." unless params[:product_type_name] == 'favicon'
      redirect_to(root_path)
    else
      unless params[:product_type_name].casecmp('instructions').zero?
        @products = Product.where('product_type_id=?', @product_type.id).in_stock.page(params[:page]).per(12)
      else
        @top_categories = Category.find_live_categories
      end
    end
  end

  def instructions
    redirect_to action: :products, product_type_name: 'Instructions'
  end

  def cart
    item_list = check_for_errant_items if @cart
    return unless item_list

    flash[:notice] = "The following item(s) are not available in the quantities you have in your cart: #{item_list.to_sentence}. Please reduce quantities or remove the item(s) from your cart."
    render :cart
  end

  def categories
    if params[:category_name] == 'Alternatives'
      @category = Category.find_by_name('Alternative Builds')
      @products = Product.alternative_builds.page(params[:page]).per(12)
    elsif params[:category_name] == 'group_on_price'
      @category = OpenStruct.new
      if params[:price] == 'free'
        @category.name = 'Completely FREE Instructions!'
        @category.description = 'Enjoy these completely free instructions, complements of Brick City Depot!'
      else
        @category.name = "$#{format('%g', params[:price].to_f)} instructions"
        @category.description = "$#{format('%g', params[:price].to_f)} instructions"
      end
      @products = Product.find_all_by_price(params[:price]).page(params[:page]).per(12)
    else
      @category = Category.find_by_name(params[:category_name])
      if @category
        @products = @category.products.find_instructions_for_sale.order('product_code ASC').page(params[:page]).per(12)
      else
        flash[:notice] = 'Sorry. That product category does not exist.'
        redirect_to action: :index
      end
    end
  end

  def add_to_cart
    # This method can be called via a link in a new product notification email, in which case, there won't be a
    # :back that I want to use, so set the redirect to take the user to the cart. Otherwise, return to :back, as
    # 'add to cart' buttons that POST are scattered throughout the app.
    request.env['HTTP_REFERER'] = Rails.application.config.web_host if request.env['HTTP_REFERER'].blank?
    back_or_cart = request.method == 'GET' ? :cart : :back
    create_cart unless @cart
    product = Product.find_by_product_code(params[:product_code].upcase) # Doing this just to make sure a valid product is being used.
    if product.blank?
      logger.error("Attempt to access invalid product: #{params[:product_code]}")
      flash[:notice] = 'Invalid Product'
      return redirect_back(fallback_location: '/cart') if back_or_cart == :back

      return redirect_to :cart
    end
    if product.is_free?
      flash[:notice] = 'You don\'t need to add free instructions to your cart. Just go to your account page to download them.'
      return redirect_back(fallback_location: '/cart') if back_or_cart == :back

      return redirect_to :cart
    end
    @current_item = @cart.add_product(product)
    if @current_item
      flash[:notice] = 'Item added to cart.'
      return redirect_back(fallback_location: '/cart') if back_or_cart == :back

      redirect_to :cart
    else
      flash[:notice] = "You already have #{product.name} in your cart. You don't need to purchase more than 1 set of the same instructions."
      return redirect_back(fallback_location: '/cart', only_path: true) if back_or_cart == :back

      redirect_to :cart, only_path: true
    end
  end

  def remove_item_from_cart
    @cart.remove_product(params[:id])
    flash[:notice] = 'Item removed from cart'
    redirect_back(fallback_location: '/cart', only_path: true)
  rescue StandardError
    flash[:notice] = 'Item could not be removed from cart. We have been notified of this issue so it can be resolved. We apologize for the inconvenience. If you need to remove this item, you may try emptying your cart.'
    redirect_back(fallback_location: '/cart', only_path: true)
  end

  def update_item_in_cart
    # If product is available in qty requested, then add to cart, else redirect to cart and flash qty not available message.
    # Other checks for errant items should stay in place because they protect against a user putting an item in his cart,
    # someone else putting the item in their cart, and then one of them going to checkout later and finding out the item
    # is no longer available after they've checked out. With those checks staying in place, hitting the cart and checkout
    # views will always perform that check.
    product = CartItem.find(params[:cart][:item_id]).product
    if product.quantity_available?(params[:cart][:quantity].to_i)
      @cart.update_product_quantity(params[:cart][:item_id], params[:cart][:quantity])
      redirect_to :cart, notice: 'Cart Updated'
    else
      var = product.quantity == 1 ? 'is' : 'are'
      message = "Sorry. There #{var} only #{product.quantity} available for #{product.code_and_name}. Please reduce quantities or remove the item(s) from you cart."
      redirect_to :cart, notice: message
    end
  end

  def validate_street_address
    if params[:order] && params[:order][:address_submission_method] == 'form'
      params.permit!
      @order = Order.new(params[:order])
    else
      @order = Order.new
    end
    return render :enter_address unless @order.valid?

    @order = nil
    session[:address_submitted] = params[:order]
    redirect_to action: :checkout
  end

  def checkout
    return redirect_to '/cart' if @cart.nil?

    session.delete(:return_to_checkout)
    @user = current_customer
    return redirect_to controller: :sessions, action: :guest_registration unless @user

    if session[:address_submitted]
      @submission_method = session[:address_submitted][:address_submission_method]
      @order = Order.new(session[:address_submitted]) if @submission_method == 'form'
    end
    if @cart.cart_items.empty?
      redirect_to '/', notice: 'Your cart is empty.'
    else
      item_list = check_for_errant_items
      redirect_to :cart, notice: "The following item(s) are not available in the quantities you have in your cart: #{item_list.to_sentence}. Please reduce quantities or remove the item(s) from our cart." if item_list
    end
  end

  def submit_order
    return redirect_to '/cart' if @cart.nil?

    @order = Order.new(order_params)
    @order.add_line_items_from_cart(@cart)
    item_amount_string = ''
    @order.line_items.each_with_index do |item, index|
      item_amount_string += "&item_name_#{index + 1}=#{item.product.product_code} #{item.product.name}&amount_#{index + 1}=#{item.product.price.to_f}&quantity_#{index + 1}=#{item.quantity}"
    end
    @order.request_id = SecureRandom.hex(20)
    if @order.save!
      @cart.destroy
      session.delete(:cart_id)
      cookies[:show_thank_you] = true
      redirect_to URI.encode("https://#{PaypalConfig.config.host}/cgi-bin/webscr?cmd=_cart&upload=1&custom=#{@order.request_id}&business=#{PaypalConfig.config.business_email}&image_url=#{Rails.application.config.web_host}/assets/logo140x89.png&return=#{PaypalConfig.config.return_url}&notify_url=#{PaypalConfig.config.notify_url}&currency_code=USD#{item_amount_string}")
    else
      begin
        ExceptionNotifier.notify_exception(ActiveRecord::ActiveRecordError.new(self), env: request.env, data: { message: 'Failed trying to submit order.' })
      ensure
        redirect_to :cart, notice: 'Uh-oh. Something bad happened. Please try again.'
      end
    end
  end

  def empty_cart
    @cart.cart_items.destroy_all if @cart && @cart.cart_items
    redirect_to root_path, notice: 'You have emptied your cart.'
  end

  def product_details
    @product = Product.where(['product_code=?', params[:product_code].upcase]).first
    if @product
      @similar_products = @product.find_live_products_from_same_category
    else
      not_found
    end
  end

  # :nocov:
  def order_confirmation_email_test
    @order = Order.find_by_user_id 5 # Jason
    download_links = @order.retrieve_link_to_downloads
    OrderMailer.guest_order_confirmation(@order.user_id, @order.id, download_links).deliver
  end
  # :nocov:

  # :nocov:
  def physical_order_email_test
    @order = Order.find 9
    OrderMailer.physical_item_purchased(@order.user_id, @order.id).deliver
  end
  # :nocov:

  def thank_you_for_your_order
    cookies.delete :show_thank_you
    return unless session[:guest] && session[:guest].is_a?(Integer)

    @user = User.find session[:guest]
    @order = @user.orders.last
    @download_link = @order.retrieve_link_to_downloads
    session.delete(:guest)
  end

  def enter_address
    if current_user && !current_user.orders.blank? && !session[:address_submitted]
      @order = current_user.orders.where("upper(status)='COMPLETED' and address_street_1 is not null").order('updated_at DESC').first
      @order ||= Order.new
    elsif session[:address_submitted]
      @submission_method = session[:address_submitted][:address_submission_method]
      @order = if @submission_method == 'form'
                 Order.new(session[:address_submitted])
               else
                 Order.new
               end
    else
      @order = Order.new
    end
  end

  private

  # Only allow a trusted parameter "white list" through.
  def order_params
    params.require(:order).permit(:request_id, :transaction_id, :user_id, :first_name, :last_name, :address_street_1, :address_street_2, :address_city, :address_state, :address_country, :address_zip, :address_submission_method)
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
    @cart.cart_items.includes(product: :product_type).each do |item|
      next unless item.product.is_physical_product?

      errant_cart_items << [item.product.product_code, item.product.name] unless item.product.quantity_available?(item.quantity)
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

  # :nocov:
  # This action is used in dev to mock a call from paypal to the app to confirm the order was ok
  def mock_paypal_call_to_listener
    @order.transaction_id = SecureRandom.hex(20)
    @order.status = 'COMPLETED'
    @order.save
    Download.restock_for_order(@order) if @order.has_digital_item?
    if @order.user.guest?
      link_to_downloads = @order.retrieve_link_to_downloads
      OrderMailer.guest_order_confirmation(@order.user_id, @order.id, link_to_downloads).deliver
    else
      OrderMailer.order_confirmation(@order.user_id, @order.id).deliver
    end
  end
  # :nocov:

  # Making sure that the user hasn't previously purchased the same set of instructions.
  # Physical items can be purchased again.
  # Instructions with 0 downloads remaining can be purchased again.
  def check_users_previous_orders
    return if current_guest

    return redirect_to '/cart' if @cart.nil?

    orders = current_user.orders
    @products_from_previous_orders = []
    orders.each do |order|
      order.line_items.each do |line_item|
        @products_from_previous_orders << line_item.product_id if line_item.product.is_digital_product? && !order.transaction_id.blank?
      end
    end
    @products_in_cart = []
    @cart.cart_items.each do |cart_item|
      @products_in_cart << cart_item.product_id
    end
    dups = @products_from_previous_orders & @products_in_cart
    return if dups.empty?

    final_dups = []
    dups.each do |dup|
      dl = Download.find_by_user_id_and_product_id(current_user.id, dup)
      final_dups << dup if (dl && dl.remaining.positive?) || dl.nil?
    end
    return if final_dups.blank?

    nice_string = final_dups.collect { |dup| Product.find(dup).name }.join(',')
    redirect_to :cart, notice: "You've already purchased the following products before, (#{nice_string}) and you don't need to do it again. Purchasing instructions once allows you to download the files #{MAX_DOWNLOADS} times.", only_path: true
  end

  def assign_users_physical_address
    redirect_to :enter_address if @cart && @cart.has_physical_item? && session[:address_submitted].blank?
  end

  def assign_address_form_data
    @states = Array[%w[Alabama AL],
                    %w[Alaska AK],
                    ['American Samoa', 'AS'],
                    %w[Arizona AZ],
                    %w[Arkansas AR],
                    %w[California CA],
                    %w[Colorado CO],
                    %w[Connecticut CT],
                    ['District of Columbia', 'DC'],
                    %w[Delaware DE],
                    %w[Florida FL],
                    %w[Georgia GA],
                    %w[Guam GU],
                    %w[Hawaii HI],
                    %w[Idaho ID],
                    %w[Illinois IL],
                    %w[Indiana IN],
                    %w[Iowa IA],
                    %w[Kansas KS],
                    %w[Kentucky KY],
                    %w[Louisiana LA],
                    %w[Maine ME],
                    %w[Maryland MD],
                    %w[Massachusetts MA],
                    %w[Michigan MI],
                    %w[Minnesota MN],
                    %w[Mississippi MS],
                    %w[Missouri MO],
                    %w[Montana MT],
                    %w[Nebraska NE],
                    %w[Nevada NV],
                    ['New Hampshire', 'NH'],
                    ['New Jersey', 'NJ'],
                    ['New Mexico', 'NM'],
                    ['New York', 'NY'],
                    ['North Carolina', 'NC'],
                    ['North Dakota', 'ND'],
                    %w[Ohio OH],
                    %w[Oklahoma OK],
                    %w[Oregon OR],
                    %w[Pennsylvania PA],
                    ['Puerto Rico', 'PR'],
                    ['Rhode Island', 'RI'],
                    ['South Carolina', 'SC'],
                    ['South Dakota', 'SD'],
                    %w[Tennessee TN],
                    %w[Texas TX],
                    %w[Utah UT],
                    %w[Vermont VT],
                    %w[Virginia VA],
                    ['Virgin Islands', 'VI'],
                    %w[Washington WA],
                    ['West Virginia', 'WV'],
                    %w[Wisconsin WI],
                    %w[Wyoming WY]]
    @countries = [['United States', 'US']]
  end
end
