class AccountController < ApplicationController
  before_filter :authenticate_user!, :except => [:unsubscribe_from_emails]

  def index
    @orders = current_user.completed_orders
    #Don't give out the freebies unless user has already purchased instructions
    if @orders.length > 0
      @freebies = Product.freebies
    end
  end

  def order_history
    #Had been getting orders where status was not null. I think I need to get all orders on this page, good, bad and ugly.
    #An order would be nil/null if BCD had not been able to get or parse the Paypal IPN, so it's worth showing that something
    # is messed up.
    #@orders = current_user.orders.where("status not null").order('orders.created_at DESC')
    @orders = current_user.orders.order('orders.created_at DESC')
  end

  def order
    @order = Order.find_by_request_id(params[:request_id])
    if @order
      if current_user.id != @order.user_id
        @order = nil
        #Had been a 403, but decided to just throw a 500 so any bad guys won't realize they're just not authorized.
        raise ZeroDivisionError #Masking the real error
      end
    else
      #Throw a 500 so users won't monkey around looking for a valid request ID
      raise ZeroDivisionError #Masking the real error
    end
  end

  def unsubscribe_from_emails
    guid = params[:id]
    token = params[:token]
    user = User.where(["guid=? and unsubscribe_token=?",guid,token]).first
    error = false
    if user.nil?
      error = true
      logger.error("FAIL unsubscribe_from_emails couldn't find user. ID=#{guid} TOKEN=#{token}")
    else
      user.email_preference = 0
      if user.save
        return render :action => :unsubscribed
      else
        error = true
        logger.error("FAIL unsubscribe_from_emails couldn't save user record. ID=#{guid} TOKEN=#{token}")
      end
    end
    if error == true
      return render :action => :still_subscribed
    end
  end
end
