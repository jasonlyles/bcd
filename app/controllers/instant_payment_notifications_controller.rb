class InstantPaymentNotificationsController < ApplicationController
  before_filter :authenticate_radmin!, except: [:create]
  before_action :set_instant_payment_notification, only: [:show]
  skip_before_filter :find_cart
  layout 'admin'

  # GET /instant_payment_notifications
  def index
    @q = InstantPaymentNotification.ransack(params[:q])
    @instant_payment_notifications = @q.result.page(params[:page]).per(100)
  end

  # GET /instant_payment_notifications/1
  def show
  end

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
  # Use callbacks to share common setup or constraints between actions.
  def set_instant_payment_notification
    @instant_payment_notification = InstantPaymentNotification.find(params[:id])
  end

  def paypal_params
    params.except('controller','action')
  end
end
