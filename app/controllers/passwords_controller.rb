# frozen_string_literal: true

class PasswordsController < Devise::PasswordsController
  prepend_before_action :require_no_authentication, except: [:update_password]
  # POST /resource/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
    elsif resource.errors[:email].include?('not found')
      resource.errors.delete(:email)
      flash[:alert] = 'Was not able to find that email. Please make sure you entered the correct email address.'
      redirect_to '/users/password/new'
    else
      respond_with(resource)
    end
  end

  def update_password
    if current_user.update(params[:user])
      # sign_in current_user, bypass: true
      bypass_sign_in(current_user)
      flash[:notice] = 'Profile was successfully updated.'
    else
      flash[:alert] = 'Password not updated. Password may have been too short, or password confirmation may not have matched. Try again.'
    end

    redirect_to(controller: :registrations, action: :edit)
  end
end
