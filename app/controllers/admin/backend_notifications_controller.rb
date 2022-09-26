class Admin::BackendNotificationsController < AdminController
  def index
    @backend_notifications = BackendNotification.active_notifications
  end

  def dismiss
    @backend_notification = BackendNotification.find(params[:id])
    @backend_notification.dismissed_by = current_radmin
    if @backend_notification.save
      flash[:notice] = 'Notification dismissed'
    else
      flash[:alert] = 'Notification could not be dismissed'
    end

    redirect_to admin_backend_notifications_path
  end
end
