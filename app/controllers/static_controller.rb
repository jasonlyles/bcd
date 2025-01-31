# frozen_string_literal: true

class StaticController < ApplicationController
  def index
    # session.delete(:guest_has_arrived_for_downloads)
    # session.delete(:guest) #for testing
    # reset_session #for testing
    @product_type = ProductType.where(name: 'Instructions').first
    # TODO: Sticking with pagination for now, even though the per is greater than the
    # actual number of products. I'm still interested in looking at maybe doing
    # infinite scroll for the products.
    @products = Product.where('product_type_id=?', @product_type.id).ready_instructions_without_includes.order(Arel.sql('popularity_order ASC NULLS LAST')).includes([:images]).page(params[:page]).per(80)
    @updates = Update.live_updates
  end

  def contact
    @email = Email.new
  end

  def maintenance
    return unless Switch.maintenance_mode.off?

    redirect_to '/', notice: 'Done with maintenance!'
  end

  # This exists only to confirm that my exception notification delivery is working.
  # /exception_notification_test
  def test_exception_notification_delivery
    1 / 0
  end

  def test_email_delivery
    order = if Rails.env.production?
              # This is an order that belongs to me
              Order.find(5379)
            else
              Order.last
            end
    if order.user.account_status == 'G'
      OrderMailer.guest_order_confirmation(order.user_id, order.id, order.retrieve_link_to_downloads).deliver_later
    else
      OrderMailer.order_confirmation(order.user_id, order.id).deliver_later
    end
    redirect_to '/', notice: 'Email sent'
  end

  def send_contact_email
    # Adding this as a simple honeypot to try and stop spambots sending emails
    # through the contact form.
    if params.dig(:email, :contact_info).present? || params.dig(:email, :body).blank?
      flash[:notice] = "Thanks for your email. We'll get back with you shortly."
      redirect_to :contact
      return
    end

    @email = Email.new(params[:email])

    if @email.valid?
      # begin
      ContactMailer.new_contact_email(@email.name, @email.email_address, @email.body).deliver_later
      # @email = nil
      flash[:notice] = "Thanks for your email. We'll get back with you shortly."
      redirect_to :contact
      # rescue => e

      # flash[:alert] = "Something went wrong. Please wait a moment and try again."
      # render :contact
      # end
    else
      flash[:alert] = 'Uh oh. Look below to see what you need to fix.'
      render :contact
    end
  end
end
