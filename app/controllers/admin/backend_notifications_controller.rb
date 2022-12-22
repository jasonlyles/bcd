# frozen_string_literal: true

class Admin::BackendNotificationsController < AdminController
  def index
    @backend_notifications = BackendNotification.active_notifications
  end

  def dismiss
    @backend_notification = BackendNotification.find(params[:id])
    @backend_notification.dismissed_by = current_radmin
    @backend_notification.save

    respond_to do |format|
      format.js
    end
  end
end
