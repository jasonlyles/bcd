class PasswordsController < Devise::PasswordsController
  prepend_before_filter :require_no_authentication, except: [:update_password]
  # POST /resource/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      respond_with({}, :location => after_sending_reset_password_instructions_path_for(resource_name))
    elsif resource.errors[:email].include?("not found")
      resource.errors.delete(:email)
      flash[:alert] = "Was not able to find that email. Please make sure you entered the correct email address."
      redirect_to '/users/password/new'
    else
      respond_with(resource)
    end
  end

  def update_password
    if current_user.update_attributes(params[:user])
      sign_in current_user, :bypass => true
      flash[:notice] = 'Profile was successfully updated.'
      redirect_to(:controller => :registrations, :action => :edit)
    else
      flash[:alert] = "Password not updated."
      redirect_to :controller => :registrations, :action => :edit
    end
  end
end
