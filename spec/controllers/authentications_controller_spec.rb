require 'spec_helper'

describe AuthenticationsController do
  render_views

  describe 'failure' do
    it 'should return a helpful message about the failure' do
      get :failure, params: { strategy: 'twitter', message: 'invalid_credentials' }
      expect(flash[:notice]).to eq('Sorry, the credentials you provided were rejected by Twitter. Please try again.')

      get :failure, params: { strategy: '', message: 'invalid_credentials' }
      expect(flash[:notice]).to eq('Sorry, the authentication failed. Please try again. If it continues to fail, you can still check out as a guest.')

      get :failure, params: { strategy: 'facebook', message: 'facebook_hates_me' }
      expect(flash[:notice]).to eq('Sorry, the authentication failed. Please try again. If it continues to fail, you can still check out as a guest.')
    end

    it 'should clear authentications and redirect to the signup page' do
      skip('Add this test')
    end
  end

  describe 'create' do
    it 'should not create new user and render new template when model is invalid' do
      request.env['omniauth.auth'] = {}
      request.env['omniauth.auth']['info'] = {}
      request.env['omniauth.auth']['info']['email'] = 'snoopy@peanuts.com'
      request.env['omniauth.auth']['provider'] = 'Twitter'
      request.env['omniauth.auth']['uid'] = nil
      expect_any_instance_of(User).to receive(:tos_accepted?).and_return(true)
      post :create

      expect(flash[:notice]).to eq(I18n.t('devise.failure.additional_authentication_failure'))
      expect(response).to redirect_to '/users/sign_up'
    end

    it 'should create new user and redirect when model is valid' do
      request.env['omniauth.auth'] = {}
      request.env['omniauth.auth']['info'] = {}
      request.env['omniauth.auth']['info']['email'] = 'snoopy@peanuts.com'
      request.env['omniauth.auth']['provider'] = 'Twitter'
      request.env['omniauth.auth']['uid'] = '12345'
      expect_any_instance_of(User).to receive(:save).at_least(1).times.and_return(true)
      post :create

      expect(flash[:notice]).to eq(I18n.t('devise.sessions.signed_in'))
      expect(response).to redirect_to('/account')
    end

    it "should redirect to users/sign_up and and flash a message about TOS if TOS hasn't been accepted" do
      request.env['omniauth.auth'] = {}
      request.env['omniauth.auth']['info'] = {}
      request.env['omniauth.auth']['info']['email'] = 'snoopy@peanuts.com'
      request.env['omniauth.auth']['provider'] = 'Twitter'
      request.env['omniauth.auth']['uid'] = '12345'
      expect_any_instance_of(User).to receive(:save).at_least(1).times.and_return(false)
      expect_any_instance_of(User).to receive(:tos_accepted?).at_least(1).times.and_return(false)
      post :create

      expect(flash[:notice]).to eq('You need to accept the Terms of Service before proceeding')
      expect(response).to redirect_to('/users/sign_up')
    end

    it 'should redirect back and flash the user if they cancelled their account and they try to log in via auth provider' do
      @user = FactoryBot.create(:user, account_status: 'C')
      @authentication = FactoryBot.create(:authentication, user_id: @user.id)
      request.env['HTTP_REFERER'] = '/'
      request.env['omniauth.auth'] = {}
      request.env['omniauth.auth']['info'] = {}
      request.env['omniauth.auth']['info']['email'] = 'snoopy@peanuts.com'
      request.env['omniauth.auth']['provider'] = 'Twitter'
      request.env['omniauth.auth']['uid'] = '12345'
      post :create

      expect(flash[:notice]).to eq(I18n.t('devise.sessions.user_cancelled'))
      expect(response).to redirect_to('/')
    end

    it 'should redirect a user to signup page if email is blank' do
      request.env['omniauth.auth'] = {}
      request.env['omniauth.auth']['info'] = {}
      request.env['omniauth.auth']['info']['email'] = nil
      request.env['omniauth.auth']['provider'] = 'Twitter'
      request.env['omniauth.auth']['uid'] = '12345'
      post :create

      expect(flash[:notice]).to eq('Was not able to retrieve your email address from Twitter. Please add an email address below.')
      expect(response).to redirect_to '/users/sign_up'
    end

    it 'should login with an existing authentication' do
      @user = FactoryBot.create(:user)
      @authentication = FactoryBot.create(:authentication, user_id: @user.id, uid: '12345')
      request.env['omniauth.auth'] = {}
      request.env['omniauth.auth']['info'] = {}
      request.env['omniauth.auth']['info']['email'] = 'snoopy@peanuts.com'
      request.env['omniauth.auth']['provider'] = 'Twitter'
      request.env['omniauth.auth']['uid'] = '12345'
      post :create

      expect(flash[:notice]).to eq('Signed in successfully.')
      expect(response).to redirect_to('/account')
    end

    it 'should create an authentication for a logged in user' do
      @user = FactoryBot.create(:user)
      sign_in @user
      request.env['omniauth.auth'] = {}
      request.env['omniauth.auth']['info'] = {}
      request.env['omniauth.auth']['info']['email'] = 'snoopy@peanuts.com'
      request.env['omniauth.auth']['provider'] = 'Twitter'
      request.env['omniauth.auth']['uid'] = '12345'
      post :create

      expect(flash[:notice]).to eq('Authentication Successful')
      expect(response).to redirect_to('/account/edit')
    end

    it 'should not create an authentication for a logged in user if another user owns that authentication' do
      @user = FactoryBot.create(:user)
      @authentication = FactoryBot.create(:authentication, user_id: @user.id)
      @user2 = FactoryBot.create(:user, email: 'ralph@ralph.mil')
      sign_in @user2
      request.env['HTTP_REFERER'] = '/account/edit'
      request.env['omniauth.auth'] = {}
      request.env['omniauth.auth']['info'] = {}
      request.env['omniauth.auth']['info']['email'] = 'snoopy@peanuts.com'
      request.env['omniauth.auth']['provider'] = 'Twitter'
      request.env['omniauth.auth']['uid'] = '12345'
      post :create

      expect(flash[:notice]).to eq("Sorry, we're not able to add Twitter authentication at this time.")
      expect(response).to redirect_to('/account/edit')
    end
  end

  describe 'destroy' do
    it 'destroy action should destroy model and redirect to index action' do
      @user ||= FactoryBot.create(:user)
      sign_in(@user)
      @authentication = FactoryBot.create(:authentication)
      delete :destroy, params: { id: @authentication }

      expect(response).to redirect_to('/account/edit')
      expect(Authentication.exists?(@authentication.id)).to be_falsey
    end

    it 'should try to talk them out of deleting an authentication if they have 1 authentication and are a omniauth-only user' do
      @user = User.new(email: 'test@test.com', tos_accepted: true)
      expect(@user).to receive(:password_required?).at_least(1).times.and_return(false)
      @user.save!
      @authentication = FactoryBot.create(:authentication, user_id: @user.id)
      sign_in @user
      delete :destroy, params: { id: @authentication }

      expect(flash[:notice]).to eq("If you delete your #{@authentication.provider} authentication, you are effectively deleting your account. If you really want to delete your account, please choose the 'Cancel my account' link at the bottom of the page.")
      expect(response).to redirect_to('/account/edit')
    end
  end

  describe 'clear_authentications' do
    it 'should delete session[:omniauth] and redirect to new user registration url' do
      @user = FactoryBot.create(:user)
      sign_in @user
      session[:omniauth] = {}
      post :clear_authentications

      expect(session[:omniauth]).to be_nil
      expect(response).to redirect_to('/users/sign_up')
    end
  end
end
