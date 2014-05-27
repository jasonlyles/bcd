class OrderMailer < ActionMailer::Base
  default :from => "no-reply@brickcitydepot.com"

  def order_confirmation(user, order)
    @host = Rails.application.config.action_mailer.default_url_options[:host] #This seems wrong, but I don't know what's right
    @order = order
    @user = user
    mail(:to => user.email, :subject => 'Order Confirmation')
  end

  def guest_order_confirmation(user, order, link_to_downloads)
    @host = Rails.application.config.web_host
    @order = order
    @user = user
    @link_to_downloads = link_to_downloads
    mail(:to => @user.email, :subject => 'Order Confirmation')
  end

  def physical_item_purchased(user, order)
    @host = Rails.application.config.action_mailer.default_url_options[:host] #This seems wrong, but I don't know what's right
    @order = order
    @user = user
    mail(:to => EmailConfig.config.physical_order, :subject => 'Physical Item Purchased')
  end
end
