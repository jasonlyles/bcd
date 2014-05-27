require 'spec_helper'

describe RegistrationsController do
  describe "create" do
    it "should create a new registration using one of the auth providers" do
      session[:omniauth] = {}
      session[:omniauth]['info'] = {}
      session[:omniauth]['info']['email'] = "snoopy@peanuts.com"
      session[:omniauth]['provider'] = "Twitter"
      session[:omniauth]['uid'] = "1234554321"
      request.env['devise.mapping'] = Devise.mappings[:user]
      get :create, :user => {:email => 'snoopy@peanuts.com', :tos_accepted => true}
      @user = User.where("email=?",'snoopy@peanuts.com').first

      @user.authentications[0].uid.should == '1234554321'
    end

    it "should kill session[:omniauth] after the user has been created" do
      session[:omniauth] = {}
      session[:omniauth]['info'] = {}
      session[:omniauth]['info']['email'] = "snoopy@peanuts.com"
      session[:omniauth]['provider'] = "Twitter"
      session[:omniauth]['uid'] = "1234554321"
      request.env['devise.mapping'] = Devise.mappings[:user]
      get :create, :user => {:email => 'snoopy@peanuts.com', :tos_accepted => true}

      session[:omniauth].should be_nil
    end

    context 'can find user based on email passed in' do
      it 'should set user account status to A and make a call to save authentication' do
        @user = FactoryGirl.create(:user, :account_status => 'G')
        controller.should_receive(:save_authentication)
        request.env['devise.mapping'] = Devise.mappings[:user]
        post :create, :user => {:email => @user.email}
        @user.reload

        @user.account_status.should eq('A')
      end
    end

    context 'user is saved' do
      context 'but user is not active_for_authentication' do
        it 'should set a flash message and send back to /' do
          session[:omniauth] = {}
          session[:omniauth]['info'] = {}
          session[:omniauth]['info']['email'] = "snoopy@peanuts.com"
          session[:omniauth]['provider'] = "Twitter"
          session[:omniauth]['uid'] = "1234554321"
          User.any_instance.should_receive(:save).and_return(true)
          User.any_instance.should_receive(:active_for_authentication?).and_return(false)
          request.env['devise.mapping'] = Devise.mappings[:user]
          post :create, :user => {:email => 'email@email.com', :tos_accepted => true}

          flash[:notice].should eq("You have signed up successfully. However, we could not sign you in because your account is not yet activated.")
          response.should redirect_to('/')
        end
      end
    end

    context 'user is not saved' do
      it 'should flash an alert about TOS and redirect to signup' do
        session[:omniauth] = {}
        session[:omniauth]['info'] = {}
        session[:omniauth]['info']['email'] = "snoopy@peanuts.com"
        session[:omniauth]['provider'] = "Twitter"
        session[:omniauth]['uid'] = "1234554321"
        User.any_instance.should_receive(:save).and_return(false)
        request.env['devise.mapping'] = Devise.mappings[:user]
        post :create, :user => {:email => 'email@email.com', :tos_accepted => true}

        flash[:alert].should eq("Please make sure you have accepted the Terms of Service")
        response.should redirect_to('/users/sign_up')
      end
    end
  end

  describe "update" do
    it "should update an existing registration password for an email/password user with valid params" do
      @user = FactoryGirl.create(:user, :password => 'blahblah1234')
      encrypted_password = @user.encrypted_password
      request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in @user
      put :update, :user => {:current_password => 'blahblah1234', :password => 'blahblah5678', :password_confirmation => 'blahblah5678'}
      @user = User.find(@user.id)

      @user.encrypted_password.should_not == encrypted_password
      flash[:notice].should == "You updated your account successfully."
    end

    it "should not update an existing registration for an email/password user with invalid params" do
      @user = FactoryGirl.create(:user, :password => 'blahblah1234')
      email = @user.email
      request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in @user
      put :update, :user => {:current_password => 'blahblah1234', :password => 'blahblah5678', :password_confirmation => 'blahblah5678', :email => '6'}
      @user = User.find(@user.id)

      @user.email.should == email
    end

    it "should update an existing registration for an omniauth-only user with valid params" do
      @user = User.new(:email => 'test@test.com', :tos_accepted => true)
      @user.should_receive(:password_required?).at_least(1).times.and_return(false)
      @user.save!
      email = @user.email
      request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in @user
      put :update, :user => {:email => "gunny@seargent.mil"}
      @user = User.find(@user.id)

      @user.email.should_not == email
      flash[:notice].should == "You updated your account successfully."
    end

    it "should not update an existing registration for an omniauth-only user with invalid params" do
      @user = User.new(:email => 'test@test.com', :tos_accepted => true)
      @user.should_receive(:password_required?).at_least(1).times.and_return(false)
      @user.save!
      email = @user.email
      request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in @user
      put :update, :user => {:email => "6"}
      @user = User.find(@user.id)

      @user.email.should == email
    end
  end

  describe "destroy" do
    it "should cancel an existing registration, not destroy it" do
      @user = User.create!(:email => "charles@mcwoofay.net", :password => 'password', :account_status => 'A', :tos_accepted => true)
      request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in @user
      get :destroy
      @user = User.find(@user.id)

      @user.account_status.should == 'C'
    end
  end
end
