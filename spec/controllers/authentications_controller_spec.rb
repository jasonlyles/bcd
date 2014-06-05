require 'spec_helper'

describe AuthenticationsController do
  fixtures :all
  render_views

  describe "create" do
    it "should not create new user and render new template when model is invalid" do
      request.env["omniauth.auth"] = {}
      request.env["omniauth.auth"]["info"] = {}
      request.env["omniauth.auth"]["info"]["email"] = "snoopy@peanuts.com"
      request.env["omniauth.auth"]["provider"] = "Twitter"
      request.env["omniauth.auth"]["uid"] = nil
      User.any_instance.should_receive(:tos_accepted?).and_return(true)
      post :create

      flash[:notice].should == I18n.t('devise.failure.additional_authentication_failure')
      response.should redirect_to "/users/sign_up"
    end

    it "should create new user and redirect when model is valid" do
      request.env["omniauth.auth"] = {}
      request.env["omniauth.auth"]["info"] = {}
      request.env["omniauth.auth"]["info"]["email"] = "snoopy@peanuts.com"
      request.env["omniauth.auth"]["provider"] = "Twitter"
      request.env["omniauth.auth"]["uid"] = "12345"
      User.any_instance.should_receive(:save).at_least(1).times.and_return(true)
      post :create

      flash[:notice].should == I18n.t('devise.sessions.signed_in')
      response.should redirect_to('/')
    end

    it "should redirect to users/sign_up and and flash a message about TOS if TOS hasn't been accepted" do
      request.env["omniauth.auth"] = {}
      request.env["omniauth.auth"]["info"] = {}
      request.env["omniauth.auth"]["info"]["email"] = "snoopy@peanuts.com"
      request.env["omniauth.auth"]["provider"] = "Twitter"
      request.env["omniauth.auth"]["uid"] = "12345"
      User.any_instance.should_receive(:save).at_least(1).times.and_return(false)
      User.any_instance.should_receive(:tos_accepted?).at_least(1).times.and_return(false)
      post :create

      flash[:notice].should == 'You need to accept the Terms of Service before proceeding'
      response.should redirect_to('/users/sign_up')
    end

    it "should redirect back and flash the user if they cancelled their account and they try to log in via auth provider" do
      @user = FactoryGirl.create(:user, :account_status => 'C')
      @authentication = FactoryGirl.create(:authentication, :user_id => @user.id)
      request.env['HTTP_REFERER'] = '/'
      request.env["omniauth.auth"] = {}
      request.env["omniauth.auth"]["info"] = {}
      request.env["omniauth.auth"]["info"]["email"] = "snoopy@peanuts.com"
      request.env["omniauth.auth"]["provider"] = "Twitter"
      request.env["omniauth.auth"]["uid"] = "12345"
      post :create

      flash[:notice].should == I18n.t('devise.sessions.user_cancelled')
      response.should redirect_to('/')
    end

    it "should redirect a user to signup page if email is blank" do
      request.env["omniauth.auth"] = {}
      request.env["omniauth.auth"]["info"] = {}
      request.env["omniauth.auth"]["info"]["email"] = nil
      request.env["omniauth.auth"]["provider"] = "Twitter"
      request.env["omniauth.auth"]["uid"] = "12345"
      post :create

      flash[:notice].should == "Was not able to retrieve your email address from Twitter. Please add an email address below."
      response.should redirect_to "/users/sign_up"
    end

    it "should login with an existing authentication" do
      @user = FactoryGirl.create(:user)
      @authentication = FactoryGirl.create(:authentication, :user_id => @user.id, :uid => '12345')
      request.env["omniauth.auth"] = {}
      request.env["omniauth.auth"]["info"] = {}
      request.env["omniauth.auth"]["info"]["email"] = "snoopy@peanuts.com"
      request.env["omniauth.auth"]["provider"] = "Twitter"
      request.env["omniauth.auth"]["uid"] = "12345"
      post :create

      flash[:notice].should == "Signed in successfully."
      response.should redirect_to('/')
    end

    it "should create an authentication for a logged in user" do
      @user = FactoryGirl.create(:user)
      sign_in @user
      request.env["omniauth.auth"] = {}
      request.env["omniauth.auth"]["info"] = {}
      request.env["omniauth.auth"]["info"]["email"] = "snoopy@peanuts.com"
      request.env["omniauth.auth"]["provider"] = "Twitter"
      request.env["omniauth.auth"]["uid"] = "12345"
      post :create

      flash[:notice].should == "Authentication Successful"
      response.should redirect_to('/account/edit')
    end

    it "should not create an authentication for a logged in user if another user owns that authentication" do
      @user = FactoryGirl.create(:user)
      @authentication = FactoryGirl.create(:authentication, :user_id => @user.id)
      @user2 = FactoryGirl.create(:user, :email => 'ralph@ralph.mil')
      sign_in @user2
      request.env['HTTP_REFERER'] = '/account/edit'
      request.env["omniauth.auth"] = {}
      request.env["omniauth.auth"]["info"] = {}
      request.env["omniauth.auth"]["info"]["email"] = "snoopy@peanuts.com"
      request.env["omniauth.auth"]["provider"] = "Twitter"
      request.env["omniauth.auth"]["uid"] = "12345"
      post :create

      flash[:notice].should == "Sorry, we're not able to add Twitter authentication at this time."
      response.should redirect_to('/account/edit')
    end
  end

  describe "destroy" do
    it "destroy action should destroy model and redirect to index action" do
      @user ||= FactoryGirl.create(:user)
      sign_in :user, @user
      @authentication = FactoryGirl.create(:authentication)
      delete :destroy, :id => @authentication

      response.should redirect_to("/account/edit")
      Authentication.exists?(@authentication.id).should be_false
    end

    it "should try to talk them out of deleting an authentication if they have 1 authentication and are a omniauth-only user" do
      @user = User.new(:email => 'test@test.com', :tos_accepted => true)
      @user.should_receive(:password_required?).at_least(1).times.and_return(false)
      @user.save!
      @authentication = FactoryGirl.create(:authentication, :user_id => @user.id)
      sign_in @user
      delete :destroy, :id => @authentication

      flash[:notice].should == "If you delete your #{@authentication.provider} authentication, you are effectively deleting your account. If you really want to delete your account, please choose the 'Cancel my account' link at the bottom of the page."
      response.should redirect_to('/account/edit')
    end
  end

  describe "clear_authentications" do
    it "should delete session[:omniauth] and redirect to new user registration url" do
      @user = FactoryGirl.create(:user)
      sign_in @user
      session[:omniauth] = {}
      post :clear_authentications

      session[:omniauth].should be_nil
      response.should redirect_to('/users/sign_up')
    end
  end
end
