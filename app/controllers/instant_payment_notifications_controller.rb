# frozen_string_literal: true

class InstantPaymentNotificationsController < ApplicationController
  skip_before_action :find_cart
  skip_before_action :verify_authenticity_token, only: [:create]

  # POST /instant_payment_notifications
  def create
    # All I need to do in here is save the params to an IPN and pass the ID to the job
    ipn = InstantPaymentNotification.create(params:)
    InstantPaymentNotificationJob.perform_async(ipn.id)
  rescue StandardError => e
    ExceptionNotifier.notify_exception(e, env: request.env, data: { message: e.message })
  ensure
    head :no_content
  end
end
