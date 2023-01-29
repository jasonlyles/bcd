# frozen_string_literal: true

class StaticController < ApplicationController
  def index
    # session.delete(:guest_has_arrived_for_downloads)
    # session.delete(:guest) #for testing
    # reset_session #for testing
    # flash[:notice] = 'This is only a test. If this had been the real thing...'
    @updates = Update.live_updates
  end

  def contact
    @email = Email.new
  end

  def maintenance
    return unless Switch.maintenance_mode.off?

    redirect_to '/', notice: 'Done with maintenance!'
  end

  # This exists only to confirm that my exception notification delivery is working. Would be nicer to perhaps hook
  # into heroku deploy to send an email through the exception notification gem to just email me during/after a deploy.
  # This will do for now.
  # /exception_notification_test
  def test_exception_notification_delivery
    1 / 0
  end

  def send_contact_email
    # Adding this as a simple honeypot to try and stop spambots sending emails
    # through the contact form.
    if params['email']['contact_info'].present?
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
