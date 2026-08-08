# frozen_string_literal: true

class StaticController < ApplicationController
  def index
    # session.delete(:guest_has_arrived_for_downloads)
    # session.delete(:guest) #for testing
    # reset_session #for testing

    # Get some semi-random colors for the Lego buttons
    lego_button_colors = random_lego_color_combos
    top_row_position = [0, 1, 2].shuffle
    @button_colors = {
      one: lego_button_colors[top_row_position.pop],
      two: lego_button_colors[top_row_position.pop],
      three: lego_button_colors[top_row_position.pop],
      four: lego_button_colors[3]
    }

    @instruction_categories = Category.find_live_categories
    @product_counts_by_category = Product.sellable_instructions
                                         .where(category_id: @instruction_categories.map(&:id))
                                         .group(:category_id)
                                         .count

    @product_type = ProductType.where(name: 'Instructions').first
    @best_sellers = Product.where('product_type_id=?', @product_type.id)
                           .ready_instructions_without_includes
                           .order(Arel.sql('popularity_order ASC NULLS LAST'))
                           .includes([:images])
                           .limit(8)
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

  private

  def random_lego_color_combos
    [
      %w[lego-red lego-blue lego-yellow lego-green], # Classic
      %w[lego-yellow lego-orange lego-red lego-darkorange], # Sunset
      %w[lego-lime lego-darkazure lego-blue lego-darkblue], # Ocean & Ice
      %w[lego-purple lego-yellow lego-darkazure lego-darkred], # High-Energy
      %w[lego-lime lego-green lego-orange lego-darkgreen],     # Forest
      %w[lego-darkred lego-yellow lego-purple lego-darkblue] # Royal Bold
    ].sample
  end
end
