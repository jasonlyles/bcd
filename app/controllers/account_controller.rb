class AccountController < ApplicationController
  before_filter :authenticate_user!, except: [:unsubscribe_from_emails]

  def index
    @products = current_user.get_product_info_for_products_owned
  end

  def order_history
    # Had been getting orders where status was not null. I think I need to get all orders on this page, good, bad and ugly.
    # An order would be nil/null if BCD had not been able to get or parse the Paypal IPN, so it's worth showing that something
    # is messed up.
    # @orders = current_user.orders.where("status not null").order('orders.created_at DESC')
    @orders = current_user.orders.order('orders.created_at DESC')
  end

  def order
    @order = Order.where('request_id=? and user_id=?', params[:request_id], current_user.id).first
    if @order.blank?
      flash[:notice] = "We couldn't find that order. Please contact us and let us know what order is giving you trouble."
      return redirect_to action: :order_history
    end
  end

  def order_issue
    OrderMailer.issue(params['order_id'], params['comment'], params['name']).deliver
    redirect_to :back, notice: "Thanks! We both should have emails in our inboxes soon. If you don't receive an email, check your junk folder, or email us directly."
  end

  def unsubscribe_from_emails
    guid = params[:id]
    token = params[:token]
    @user = User.where(['guid=? and unsubscribe_token=?', guid, token]).first
    if @user
      @user.email_preference = 0
      if @user.save
        return render :unsubscribed
      else
        logger.error("FAIL unsubscribe_from_emails couldn't save user record. ID=#{guid} TOKEN=#{token}")
      end
    else
      logger.error("FAIL unsubscribe_from_emails couldn't find user. ID=#{guid} TOKEN=#{token}")
    end

    render :still_subscribed
  end
end
