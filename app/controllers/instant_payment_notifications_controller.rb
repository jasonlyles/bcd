class InstantPaymentNotificationsController < ApplicationController
  before_filter :authenticate_radmin!, except: [:create]
  skip_before_filter :find_cart
  layout 'admin'

  # POST /instant_payment_notifications
  def create
    # All I need to do in here is save the params to an IPN and pass the ID to the job

    ipn = InstantPaymentNotification.create(params: paypal_params)
    InstantPaymentNotificationJob.create(ipn_id: ipn.id)
  rescue StandardError => e
    ExceptionNotifier.notify_exception(e, env: request.env, data: { message: e.message })
  ensure
    return render nothing: true
  end

  private

  def paypal_params
    params.except('controller', 'action')
  end
end
