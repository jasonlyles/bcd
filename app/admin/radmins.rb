ActiveAdmin.register Radmin do
  menu false
  config.breadcrumb = false
  permit_params :email, :password, :password_confirmation

  show do
    attributes_table do
      row :email
      row :reset_password_token
      row :reset_password_sent_at
      row :remember_created_at
      row :current_sign_in_at
      row :current_sign_in_ip
      row :last_sign_in_at
      row :last_sign_in_ip
      row :failed_attempts
      row :locked_at
    end
    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
