class OrderMailer < AsyncMailer
  default :from => "Brick City Depot <no-reply@brickcitydepot.com>"
  layout 'base_email', except: [:physical_item_purchased]

  def order_confirmation(user_id, order_id)
    @host = Rails.application.config.web_host
    @order = Order.find(order_id)
    @user = User.find(user_id)
    @hide_unsubscribe = true

    mail(to: @user.email, subject: 'Order Confirmation')
  end

  def guest_order_confirmation(user_id, order_id, link_to_downloads)
    @host = Rails.application.config.web_host
    @order = Order.find(order_id)
    @user = User.find(user_id)
    @link_to_downloads = link_to_downloads
    @hide_unsubscribe = true

    mail(to: @user.email, subject: 'Order Confirmation')
  end

  def physical_item_purchased(user_id, order_id)
    @host = Rails.application.config.web_host
    @order = Order.find(order_id)
    @user = User.find(user_id)

    mail(to: EmailConfig.config.physical_order, subject: 'Physical Item Purchased')
  end

  def queue_name
    "mailer"
  end
end

#:nocov:
if Rails.env.development?
  class OrderMailer::Preview < MailView
    def order_confirmation
      @user = User.first
      @order = Order.first

      OrderMailer.order_confirmation(@user.id, @order.id)
    end

    def guest_order_confirmation
      @user = User.first
      @order = Order.first
      link = "#{Rails.application.config.web_host}/guest_downloads?tx_id=#{@order.transaction_id}&conf_id=#{@order.request_id}"

      OrderMailer.guest_order_confirmation(@user.id, @order.id, link)
    end

    def physical_item_purchased
      @user = User.first
      @order = Order.first

      OrderMailer.physical_item_purchased(@user.id, @order.id)
    end
  end
end
#:nocov: