class InstantPaymentNotificationsController < ApplicationController
  before_filter :authenticate_radmin!, except: [:create]
  before_action :set_instant_payment_notification, only: [:show]
  skip_before_filter :find_cart
  layout 'admin'

  # GET /instant_payment_notifications
  def index
    @instant_payment_notifications = InstantPaymentNotification.all.page(params[:page]).per(100)
  end

  # GET /instant_payment_notifications/1
  def show
  end

  # POST /instant_payment_notifications
  def create
    # All I need to do in here is save the params to an IPN and pass the ID to the job
    begin
      ipn = InstantPaymentNotification.create(params: params.except('controller','action'))
      InstantPaymentNotificationJob.create(ipn_id: ipn.id)
    rescue => e
      ExceptionNotifier.notify_exception(ActiveRecord::ActiveRecordError.new(self), :env => request.env, :data => {:message => e.message})
    end
    return render :nothing => true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_instant_payment_notification
      @instant_payment_notification = InstantPaymentNotification.find(params[:id])
    end

end