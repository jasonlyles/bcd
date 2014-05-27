class PasswordsController < Devise::PasswordsController
=begin
  def create
    self.resource = resource_class.send_reset_password_instructions(params[resource_name])

    if resource.errors.empty?
      set_flash_message :notice, :send_instructions
      redirect_to new_session_path(resource_name)
    elsif resource.errors[:email].include?("not found")
      resource.errors.delete(:email)
      flash[:alert] = "Was not able to find that email. Please make sure you entered the correct email address."
      render_with_scope :new
    else
      render_with_scope :new
    end
  end
=end

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
end
