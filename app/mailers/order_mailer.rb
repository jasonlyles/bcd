class OrderMailer < ActionMailer::Base
  default :from => "no-reply@brickcitydepot.com"
  layout 'base_email', except: [:physical_item_purchased]

  def order_confirmation(user, order)
    @host = Rails.application.config.web_host
    @order = order
    @user = user
    @hide_unsubscribe = true

    mail(to: user.email, subject: 'Order Confirmation')
  end

  def guest_order_confirmation(user, order, link_to_downloads)
    @host = Rails.application.config.web_host
    @order = order
    @user = user
    @link_to_downloads = link_to_downloads
    @hide_unsubscribe = true

    mail(to: @user.email, subject: 'Order Confirmation')
  end

  def physical_item_purchased(user, order)
    @host = Rails.application.config.web_host
    @order = order
    @user = user

    mail(to: EmailConfig.config.physical_order, subject: 'Physical Item Purchased')
  end
end

#:nocov:
if Rails.env.development?
  class OrderMailer::Preview < MailView
    def order_confirmation
      @user = User.first
      @order = Order.first

      OrderMailer.order_confirmation(@user, @order)
    end

    def guest_order_confirmation
      @user = User.first
      @order = Order.first
      link = "#{Rails.application.config.web_host}/guest_downloads?tx_id=#{@order.transaction_id}&conf_id=#{@order.request_id}"

      OrderMailer.guest_order_confirmation(@user, @order, link)
    end

    def physical_item_purchased
      @user = User.first
      @order = Order.first

      OrderMailer.physical_item_purchased(@user, @order)
    end
  end
end
#:nocov: