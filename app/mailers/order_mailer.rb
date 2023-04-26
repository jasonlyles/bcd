# frozen_string_literal: true

class OrderMailer < ActionMailer::Base
  default from: 'Brick City Depot <sales@brickcitydepot.com>'
  layout 'base_email', except: %i[physical_item_purchased pass_along_buyer_message]

  def order_confirmation(user_id, order_id)
    @host = Rails.application.config.web_host
    @order = Order.find(order_id)
    @user = User.find(user_id)
    @hide_unsubscribe = true

    mail(to: @user.email, subject: 'Brick City Depot Order Confirmation')

    @order.update(confirmation_email_sent: true)
  end

  def guest_order_confirmation(user_id, order_id, link_to_downloads)
    @host = Rails.application.config.web_host
    @order = Order.find(order_id)
    @user = User.find(user_id)
    @link_to_downloads = link_to_downloads
    @hide_unsubscribe = true

    mail(to: @user.email, subject: 'Your Brick City Depot Order')

    @order.update(confirmation_email_sent: true)
  end

  def third_party_guest_order_confirmation(order_id)
    @host = Rails.application.config.web_host
    @order = Order.find(order_id)
    @user = @order.user
    @link_to_downloads = @order.retrieve_link_to_downloads
    # If a customer exists in the database already as an active user, email
    # them to welcome them back and tell them to go to their
    # account, but also give them a guest link in case they can't get back
    # into their account, or don't want to.
    @active_user = @user.active?
    @hide_unsubscribe = true

    mail(to: @user.email, subject: "Your #{@order.source.capitalize} Order with Brick City Depot")

    @order.update(confirmation_email_sent: true)
  end

  def physical_item_purchased(user_id, order_id)
    @host = Rails.application.config.web_host
    @order = Order.find(order_id)
    @user = User.find(user_id)

    mail(to: EmailConfig.config.physical_order, subject: 'Physical Item Purchased')
  end

  # rubocop:disable Metrics/AbcSize
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
    @products_to_recommend = Product.ready.where(["free != 't' and quantity >= 1 and category_id IN (?) and id NOT IN (?)", categories, products_bought]).limit(number_of_products) if @products_to_recommend.length < number_of_products
    # If there's still not enough products, ditch the category clause
    @products_to_recommend = Product.ready.where(["free != 't' and quantity >= 1 and id NOT IN (?)", products_bought]).limit(number_of_products) if @products_to_recommend.length < number_of_products

    mail(to: @user.email, subject: 'Thanks for your recent order') unless @products_to_recommend.blank?
  end
  # rubocop:enable Metrics/AbcSize

  def pass_along_buyer_message(source, order_id, user_email, buyer_message)
    @host = Rails.application.config.web_host
    @source = source
    @order_id = order_id
    @user_email = user_email
    @buyer_message = buyer_message
    @hide_unsubscribe = true

    mail(to: EmailConfig.config.physical_order, subject: "Brick City Depot message from #{source.capitalize} buyer")
  end

  def issue(order_id, comment, name)
    @order = Order.where(['id=?', order_id]).first
    @third_party_receipt = @order.third_party_receipt
    user = @order.user
    @comment = comment
    @name = name
    @hide_unsubscribe = true
    subject = if @third_party_receipt.present?
                "Issue with Brick City Depot #{@third_party_receipt.source.capitalize} Order##{@third_party_receipt.third_party_receipt_identifier}"
              else
                "Issue with Brick City Depot Order ##{@order.request_id? ? @order.request_id : @order.transaction_id}"
              end

    mail(reply_to: user.email, to: [user.email, 'sales@brickcitydepot.com'], subject:)
  end

  # :nocov:
  def queue_name
    'mailer'
  end
  # :nocov:
end

# :nocov:
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
# :nocov:
