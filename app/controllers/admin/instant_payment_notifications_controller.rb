# frozen_string_literal: true

class Admin::InstantPaymentNotificationsController < AdminController
  before_action :set_instant_payment_notification, only: [:show]

  # GET /instant_payment_notifications
  def index
    @q = InstantPaymentNotification.ransack(params[:q])
    @instant_payment_notifications = @q.result.page(params[:page]).per(100)
  end

  # GET /instant_payment_notifications/1
  def show; end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_instant_payment_notification
    @instant_payment_notification = InstantPaymentNotification.find(params[:id])
  end
end
