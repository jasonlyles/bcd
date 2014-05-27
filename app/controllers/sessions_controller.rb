class SessionsController < Devise::SessionsController
  after_filter :kill_guest_checkout_flag, :only => [:register_guest]

  def guest_registration
    set_guest_status
    if current_guest
      @user = current_guest
    else
      @user = Guest.new
    end
  end

  def register_guest
    #@user = Guest.new(:email => params[:guest][:email], :account_status => 'G', :tos_accepted => params[:guest])
    params[:guest] = params[:user] if params[:user]
    if current_guest
      @user = User.find(current_guest.id)
      @user.email = params[:guest][:email]
      @user.email_preference = params[:guest][:email_preference]
      unless @user.valid?
        return render :action => :guest_registration
      end
      @user.save!
    else
      @user = Guest.find_by_email(params[:guest][:email])
      if @user.nil?
        @user = Guest.new(params[:guest])
      end
      @user.account_status = 'G'
      unless @user.valid?
        flash[:alert] = "You must enter a valid email and accept the terms of service before you can proceed."
        return render :action => :guest_registration
      end
      @user.save!
      session[:guest] = @user.id
    end
    redirect_to :controller => :store, :action => :checkout
  end

  def new
=begin
    if request.referer.blank? || (!request.referer.match(/brickcitydepot\.com/) && !request.referer.match(/localhost/))
      @http_referer = ''
    else
      @http_referer = request.referer
    end
=end
    super
  end

  def create
    clean_up_guest if session[:guest] #If I have a guest that has a change of heart and wants to sign in, ditch the guest record
    resource = warden.authenticate!(auth_options)
    if resource.account_status == "C"
      redirect_to :action => :destroy
    elsif resource.account_status == "A"
      set_flash_message(:notice, :signed_in) # if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with resource, :location => after_sign_in_path_for(resource)
    end
  end

  private

  def kill_guest_checkout_flag
    session.delete(:show_guest_checkout_link) if session[:show_guest_checkout_link]
  end
end
