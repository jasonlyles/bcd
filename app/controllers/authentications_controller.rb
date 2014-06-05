class AuthenticationsController < ApplicationController
  before_filter :authenticate_user!, :except => [:create, :clear_authentications]

  def create
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    #This would occur in the case where a user tries to add FB/Twitter to their account, and someone else already is logged in
    # to FB/Twitter at the time. Don't want to auto login that other users account, so just tell them it's not working.
    if current_user && authentication && (authentication.user_id != current_user.id)
      flash[:notice] = "Sorry, we're not able to add #{omniauth['provider'].capitalize} authentication at this time."
      return redirect_to :back
    end
    #If the authentication exists in db, and the user cancelled their account
    if authentication && authentication.user.account_status == 'C'
      flash[:notice] = t('devise.sessions.user_cancelled')
      return redirect_to :back
    end
    #If the authentication exists in db, then login the user
    if authentication
      flash[:notice] = t('devise.sessions.signed_in')
      sign_in_and_redirect(:user, authentication.user)
    #else if there is a current user, create the authentication and assign it to the current user
    elsif current_user
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
      redirect_to '/account/edit', :notice => t('devise.registrations.additional_authentication')
    #else create a new user and assign the authentication to the new user
    else
      user = User.new
      user.apply_omniauth(omniauth)
      unless user.email?
        session[:omniauth] = omniauth.except('extra')
        return redirect_to new_user_registration_url, :notice => "Was not able to retrieve your email address from #{omniauth['provider'].capitalize}. Please add an email address below."
      end
      if user.save
        flash[:notice] = t('devise.sessions.signed_in')
        sign_in_and_redirect(:user, user)
      elsif !user.tos_accepted?
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_registration_url, :notice => "You need to accept the Terms of Service before proceeding"
      else
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_registration_url, :notice => t('devise.failure.additional_authentication_failure')
      end
    end
  end

  def destroy
    #Don't let them remove their last authentication if they don't have a regular account.
    if current_user.authentications.count == 1 && current_user.encrypted_password.blank?
      redirect_to '/account/edit', :notice => "If you delete your #{current_user.authentications.find(params[:id]).provider.titleize} authentication, you are effectively deleting your account. If you really want to delete your account, please choose the 'Cancel my account' link at the bottom of the page."
    else
      @authentication = current_user.authentications.find(params[:id])
      @authentication.destroy
      redirect_to '/account/edit', :notice => t('devise.registrations.destroyed_additional_authentication')
    end
  end

  def clear_authentications
    session[:omniauth] = nil
    redirect_to new_user_registration_url
  end
end
