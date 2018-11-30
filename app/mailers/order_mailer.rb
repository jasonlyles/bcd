class OrderMailer < AsyncMailer
  default from: 'Brick City Depot <sales@brickcitydepot.com>'
  layout 'base_email', except: [:physical_item_purchased]

  def order_confirmation(user_id, order_id)
    @host = Rails.application.config.web_host
    @order = Order.find(order_id)
    @user = User.find(user_id)
    @hide_unsubscribe = true

    mail(to: @user.email, subject: 'Brick City Depot Order Confirmation')
  end

  def guest_order_confirmation(user_id, order_id, link_to_downloads)
    @host = Rails.application.config.web_host
    @order = Order.find(order_id)
    @user = User.find(user_id)
    @link_to_downloads = link_to_downloads
    @hide_unsubscribe = true

    mail(to: @user.email, subject: 'Your Brick City Depot Order')
  end

  def physical_item_purchased(user_id, order_id)
    @host = Rails.application.config.web_host
    @order = Order.find(order_id)
    @user = User.find(user_id)

    mail(to: EmailConfig.config.physical_order, subject: 'Physical Item Purchased')
  end

  def follow_up(order_id)
    number_of_products = 3
    @host = Rails.application.config.web_host
    order = Order.where(['id=?', order_id]).includes(:line_items).first
    @user = order.user
    products_bought = @user.products.pluck(:product_id)
    categories = order.products.pluck(:category_id).uniq
    subcategories = order.products.pluck(:subcategory_id).uniq
    @products_to_recommend = Product.ready.where(["free != 't' and quantity >= 1 and category_id IN (?) and subcategory_id IN (?) and id NOT IN (?)", categories, subcategories, products_bought]).limit(number_of_products)
    # If there's not enough products, ditch the subcategory clause
    if @products_to_recommend.length < number_of_products
      @products_to_recommend = Product.ready.where(["free != 't' and quantity >= 1 and category_id IN (?) and id NOT IN (?)", categories, products_bought]).limit(number_of_products)
    end
    # If there's still not enough products, ditch the category clause
    if @products_to_recommend.length < number_of_products
      @products_to_recommend = Product.ready.where(["free != 't' and quantity >= 1 and id NOT IN (?)", products_bought]).limit(number_of_products)
    end

    unless @products_to_recommend.blank?
      mail(to: @user.email, subject: 'Thanks for your recent order')
    end
  end

  def issue(order_id, comment, name)
    @order = Order.where(['id=?', order_id]).first
    user = @order.user
    @comment = comment
    @name = name
    @hide_unsubscribe = true

    mail(reply_to: user.email, to: [user.email, 'service@brickcitydepot.com'], subject: "Issue with Brick City Depot Order ##{@order.request_id? ? @order.request_id : @order.transaction_id}")
  end

  #:nocov
  def queue_name
    'mailer'
  end
  #:nocov
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

    def follow_up
      @order = Order.first
      @user = @order.user

      OrderMailer.follow_up(@order.id)
    end

    def issue
      @order = Order.first
      comment = 'Something bad happened'

      OrderMailer.issue(@order.id, comment, 'Roger')
    end
  end
end
#:nocov:
