# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  after_action :kill_guest_checkout_flag, only: [:register_guest]

  # rubocop:disable Style/RedundantCondition
  def guest_registration
    if @cart.nil?
      flash[:notice] = 'Sorry. Your cart is empty. Please add something to your cart before trying to checkout.'
      return redirect_to '/'
    end
    set_guest_status
    @user = current_guest ? current_guest : Guest.new
  end
  # rubocop:enable Style/RedundantCondition

  # rubocop:disable Metrics/AbcSize
  def register_guest
    params[:guest] = params[:user] if params[:user]
    if current_guest
      @user = User.find(current_guest.id)
      @user.email = params[:guest][:email]
      @user.email_preference = params[:guest][:email_preference]
      return render :guest_registration unless @user.valid?

      @user.save!
    else
      # See if I can convert these next few lines to find_or_create_by, making sure to still
      # set account_status to 'G'. Pay attention to the block below looking to see if @user is valid
      @user = Guest.find_by_email(params[:guest][:email].downcase)
      @user ||= Guest.new(guest_params)
      # Doing the 'unless' condition so a user can't then make himself a guest and break his account
      @user.account_status = 'G' unless @user.account_status == 'A'

      unless @user.valid?
        flash[:alert] = 'You must enter a valid email and accept the terms of service before you can proceed.'
        return render :guest_registration
      end

      @user.save!
      session[:guest] = @user.id
    end
    redirect_to controller: :store, action: :checkout
  end
  # rubocop:enable Metrics/AbcSize

  def create
    clean_up_guest if session[:guest] # If I have a guest that has a change of heart and wants to sign in, ditch the guest record
    resource = warden.authenticate!(auth_options)
    case resource.account_status
    when 'C'
      redirect_to action: :destroy
    when 'A'
      set_flash_message(:notice, :signed_in) # if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with resource, location: after_sign_in_path_for(resource)
    end
  end

  private

  def guest_params
    params[:guest].permit(:email, :email_preference, :tos_accepted)
  end

  def kill_guest_checkout_flag
    session.delete(:show_guest_checkout_link) if session[:show_guest_checkout_link]
  end
end
