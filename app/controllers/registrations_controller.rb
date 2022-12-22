# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  before_action :assign_authentications, except: %i[new build_resource]
  before_action :authenticate_user!, only: %i[update destroy]

  MAX_AUTHS_ALLOWED = 2 # Right now, just Facebook and Twitter

  def edit
    @auths = @authentications.collect(&:provider)
  end

  def create
    signup_params = {}
    user_params = %w[email tos_accepted email_preference password password_confirmation]
    params['user'].each do |key, value|
      signup_params[key] = value if user_params.include?(key)
    end
    clean_up_guest if session[:guest] # If I have a guest that has a change of heart and wants to sign up, ditch the guest record
    @user = User.where('email=?', params[:user][:email]).first
    # If user has password, they've already signed up, redirect them to the login page
    return redirect_to '/users/sign_in', notice: 'This user already has an account, please login.' if @user && @user.encrypted_password?

    if @user.blank?
      build_resource(signup_params)
    else
      @user.account_status = 'A'
      save_authentication
    end

    if @user.save
      if @user.active_for_authentication?
        sign_in(resource_name, @user)
        if session[:return_to_checkout]
          redirect_to '/checkout', notice: t('devise.registrations.signed_up')
        else
          redirect_to '/', notice: t('devise.registrations.signed_up')
        end
      else
        set_flash_message :notice, :"signed_up_but_#{@user.inactive_message}" if is_navigational_format?
        expire_data_after_sign_in!
        respond_with @user, location: after_inactive_sign_up_path_for(@user)
      end
    else
      clean_up_passwords @user
      flash[:alert] = 'User not created. Please see signup form to see what you need to fix.'
      respond_with @user, location: { action: :new }
    end

    # This is in place in case a user goes to sign up via one of the auth options and doesn't add an email or check
    # the TOS box after authing with the auth provider. If the user comes through here and they made a mistake in the form,
    # I don't want to delete their omniauth data in session. If they do sign up successfully, I then want to get rid of
    # the omniauth data in session. Hence the deleting only if @user.new_record? == false
    session[:omniauth] = nil unless @user.new_record?
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    if params[:user].key?(:current_password)
      if resource.update_with_password(resource_params)
        if is_navigational_format?
          flash_key = :update_needs_confirmation if resource.respond_to?(:pending_reconfirmation?) && resource.pending_reconfirmation?
          set_flash_message :notice, flash_key || :updated
        end
        # sign_in resource_name, resource, bypass: true
        bypass_sign_in(resource)
        respond_with resource, location: after_update_path_for(resource)
      else
        flash[:alert] = 'Uh-oh. Check below to see what you need to change'
        clean_up_passwords resource
        respond_with resource
      end
    else
      # This case is for the Twitter/Facebook user who doesn't have a regular account, and hence no password.
      if resource.update_attributes(resource_params)
        if is_navigational_format?
          flash_key = :update_needs_confirmation if resource.respond_to?(:pending_reconfirmation?) && resource.pending_reconfirmation?
          set_flash_message :notice, flash_key || :updated
        end
        # sign_in resource_name, resource, bypass: true
        bypass_sign_in(resource)
        respond_with resource, location: after_update_path_for(resource)
      else
        flash[:alert] = 'Uh-oh. Check below to see what you need to change'
        clean_up_passwords resource
        respond_with resource
      end
    end
  end

  def destroy
    # Am overriding the destroy method because I don't actually want to destroy the user, I want to set them to cancelled.
    # This will come in handy if I have to restore someones account, or someone claims they accidentally deleted their
    # account and had bought a bunch of pdfs they didn't really buy. Jerks
    resource.cancel_account
    set_flash_message :notice, :destroyed
    sign_out(resource_name)
    redirect_to '/'
  end

  private

  def resource_params
    params[resource_name].permit(:password, :password_confirmation, :current_password, :email)
  end

  def build_resource(hash = nil)
    super
    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
      # @user.valid? #This seems to cause unnecessary heartache
    end
    @user.referrer_code ||= session[:referrer_code] unless session[:referrer_code].blank?
    @user
  end

  def save_authentication
    @user.apply_omniauth(session[:omniauth]) if session[:omniauth]
    @user.referrer_code ||= session[:referrer_code] unless session[:referrer_code].blank?
    @user
  end

  def assign_authentications
    @authentications = current_user.authentications if current_user
  end

  protected

  def after_update_path_for(resource)
    path = if resource.is_a? User
             '/account/edit'
           else
             '/'
           end
    path
  end

  def after_sign_up_path_for(_resource)
    '/'
  end
end
