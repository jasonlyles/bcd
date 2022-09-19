class InstantPaymentNotificationsController < ApplicationController
  skip_before_filter :find_cart

  # POST /instant_payment_notifications
  def create
    # All I need to do in here is save the params to an IPN and pass the ID to the job
    begin
      ipn = InstantPaymentNotification.create(params: paypal_params)
      InstantPaymentNotificationJob.create(ipn_id: ipn.id)
    rescue => e
      ExceptionNotifier.notify_exception(e, :env => request.env, :data => {:message => e.message})
    ensure
      return render :nothing => true
    end
  end

  private

  def paypal_params
    params.except('controller','action')
  end
end
