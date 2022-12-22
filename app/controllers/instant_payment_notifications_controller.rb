# frozen_string_literal: true

class InstantPaymentNotificationsController < ApplicationController
  skip_before_action :find_cart

  # POST /instant_payment_notifications
  def create
    # All I need to do in here is save the params to an IPN and pass the ID to the job
    begin
      ipn = InstantPaymentNotification.create(params: paypal_params)
      InstantPaymentNotificationJob.perform_later(ipn_id: ipn.id)
    rescue StandardError => e
      ExceptionNotifier.notify_exception(e, env: request.env, data: { message: e.message })
    ensure
      return head :no_content
    end
  end

  private

  def paypal_params
    params.require(:instant_payment_notification).permit(:payment_status, :notify_version, :custom, :verify_sign, :payer_email, :txn_id)
  end
end
