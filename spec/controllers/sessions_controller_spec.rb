require 'spec_helper'

describe SessionsController do
  describe 'destroy' do
    it 'should destroy the cart_id in session' do
      @user = User.create!(email: 'charles@mcwoofay.net', password: 'password', tos_accepted: true)
      request.env['devise.mapping'] = Devise.mappings[:user]
      sign_in @user
      @cart = FactoryBot.create(:cart)
      session[:cart_id] = @cart.id
      get :destroy

      expect(session[:cart_id]).to be_nil
    end
  end

  describe 'create' do
    it 'should create a new session' do
      @user = User.create!(email: 'charles@mcwoofay.net', password: 'password', tos_accepted: true)
      request.env['devise.mapping'] = Devise.mappings[:user]
      post :create, params: { user: { email: 'charles@mcwoofay.net', password: 'password' } }

      expect(response).to redirect_to('/account')
      expect(flash[:notice]).to eq('Signed in successfully.')
      expect(subject.current_user).to_not be_nil
    end

    it 'should not create a new session if user is cancelled' do
      @user = User.create!(email: 'charles@mcwoofay.net', password: 'password', account_status: 'C', tos_accepted: true)
      request.env['devise.mapping'] = Devise.mappings[:user]
      post :create, params: { user: { email: 'charles@mcwoofay.net', password: 'password' } }

      expect(response).to redirect_to('/users/sign_out')
    end
  end

  describe 'kill_guest_checkout_flag' do
    it 'should delete show_guest_checkout_flag in session' do
      session[:show_guest_checkout_link] = true
      controller.send(:kill_guest_checkout_flag)
      expect(session[:show_guest_checkout_link]).to be_nil
    end
  end

  describe 'guest_registration' do
    context 'with a current_guest' do
      it 'should assign current_guest to @user' do
        current_guest = FactoryBot.create(:user, email: 'blahblah@blah.blah')
        @cart = FactoryBot.create(:cart, user_id: current_guest.id)
        expect(controller).to receive(:set_guest_status).and_return(true)
        expect(controller).to receive(:current_guest).at_least(1).times.and_return(current_guest)
        request.env['devise.mapping'] = Devise.mappings[:user]
        get :guest_registration

        expect(assigns(:user)).to eq(current_guest)
      end
    end

    context 'without a current guest' do
      it 'should assign a new Guest object to @user' do
        @cart = FactoryBot.create(:cart)
        session[:cart_id] = @cart.id
        expect(controller).to receive(:set_guest_status).and_return(true)
        request.env['devise.mapping'] = Devise.mappings[:user]
        get :guest_registration

        expect(assigns(:user)).to be_a_new(Guest)
      end
    end
  end

  describe 'register_guest' do
    context 'if current_guest' do
      context 'and user record is valid' do
        it 'should find the user record and update it' do
          user = FactoryBot.create(:user, email: 'fake@fake.fake')
          expect(controller).to receive(:current_guest).at_least(1).times.and_return(user)
          request.env['devise.mapping'] = Devise.mappings[:user]
          post :register_guest, params: { guest: { email: user.email, email_preference: 'no_emails' } }

          user.reload
          expect(user.email_preference).to eq('no_emails')
          expect(response).to redirect_to('/checkout')
        end
      end

      context 'and user record is not valid' do
        it 'should render guest_registration' do
          user = FactoryBot.create(:user, email: 'blar@blar.blar')
          expect(controller).to receive(:current_guest).at_least(1).times.and_return(user)
          request.env['devise.mapping'] = Devise.mappings[:user]
          expect_any_instance_of(User).to receive(:valid?).and_return(false)
          post :register_guest, params: { guest: { email: user.email, email_preference: 'no_emails' } }

          expect(response).to render_template(:guest_registration)
        end
      end
    end

    context 'if no current_guest' do
      it 'should create a new guest record if no guest record could be found by email' do
        expect(controller).to receive(:current_guest).at_least(1).times.and_return(nil)
        request.env['devise.mapping'] = Devise.mappings[:user]
        expect_any_instance_of(User).to receive(:valid?).at_least(1).times.and_return(true)

        expect { post :register_guest, params: { guest: { email: 'blar2@blar.blar', email_preference: 'all_emails' } } }.to change(User, :count).by(1)
      end

      it 'should not create a new guest record if a guest record could be found by email' do
        user = FactoryBot.create(:user, email: 'blar3@blar.blar')
        expect(controller).to receive(:current_guest).at_least(1).times.and_return(nil)
        request.env['devise.mapping'] = Devise.mappings[:user]
        expect_any_instance_of(User).to receive(:valid?).at_least(1).times.and_return(true)
        expect(Guest).to receive(:find_by_email).and_return(user)

        expect { post :register_guest, params: { guest: { email: user.email, email_preference: 'all_emails' } } }.to_not change(User, :count)
      end

      context 'and user record is valid' do
        it 'should save the user' do
          user = FactoryBot.create(:user, email: 'blar4@blar.blar', account_status: '')
          expect(controller).to receive(:current_guest).at_least(1).times.and_return(nil)
          request.env['devise.mapping'] = Devise.mappings[:user]
          expect_any_instance_of(User).to receive(:valid?).at_least(1).times.and_return(true)
          post :register_guest, params: { guest: { email: user.email, email_preference: 'all_emails' } }

          user.reload
          expect(user.account_status).to eq('G')
        end

        it 'should set session[:guest] to the user ID' do
          user = FactoryBot.create(:user, email: 'blar5@blar.blar')
          expect(controller).to receive(:current_guest).at_least(1).times.and_return(nil)
          request.env['devise.mapping'] = Devise.mappings[:user]
          expect_any_instance_of(User).to receive(:valid?).at_least(1).times.and_return(true)
          post :register_guest, params: { guest: { email: user.email, email_preference: 'all_emails' } }

          expect(session[:guest]).to eq(user.id)
        end

        it 'should redirect to checkout' do
          user = FactoryBot.create(:user, email: 'blar6@blar.blar')
          expect(controller).to receive(:current_guest).at_least(1).times.and_return(nil)
          request.env['devise.mapping'] = Devise.mappings[:user]
          expect_any_instance_of(User).to receive(:valid?).at_least(1).times.and_return(true)
          post :register_guest, params: { guest: { email: user.email, email_preference: 'all_emails' } }

          expect(response).to redirect_to('/checkout')
        end
      end

      context 'and user record is not valid' do
        it 'should flash an alert message' do
          user = FactoryBot.create(:user, email: 'blar7@blar.blar')
          expect(controller).to receive(:current_guest).at_least(1).times.and_return(nil)
          request.env['devise.mapping'] = Devise.mappings[:user]
          expect_any_instance_of(User).to receive(:valid?).at_least(1).times.and_return(false)
          post :register_guest, params: { guest: { email: user.email, email_preference: 'all_emails' } }

          expect(flash[:alert]).to eq('You must enter a valid email and accept the terms of service before you can proceed.')
        end

        it 'should render guest_registration' do
          user = FactoryBot.create(:user, email: 'blar8@blar.blar')
          expect(controller).to receive(:current_guest).at_least(1).times.and_return(nil)
          request.env['devise.mapping'] = Devise.mappings[:user]
          expect_any_instance_of(User).to receive(:valid?).at_least(1).times.and_return(false)
          post :register_guest, params: { guest: { email: user.email, email_preference: 'all_emails' } }

          expect(response).to render_template(:guest_registration)
        end
      end
    end
  end

  describe 'third_party_guest_registration' do
    it 'should assign a source, order_id and user' do
      request.env['devise.mapping'] = Devise.mappings[:user]
      user = FactoryBot.create(:user)
      get :third_party_guest_registration, params: { source: 'etsy', order_id: '1234', u: user.guid }

      expect(assigns(:source)).to eq('etsy')
      expect(assigns(:order_id)).to eq('1234')
      expect(assigns(:user)).to eq(user)
    end
  end

  describe 'register_third_party_guest' do
    context 'someone is altering params' do
      it 'should just say it cannot find the order' do
        request.env['devise.mapping'] = Devise.mappings[:user]
        order = FactoryBot.create(:order)
        FactoryBot.create(:third_party_receipt, order:, source: 'etsy', third_party_receipt_identifier: '1234')
        user = FactoryBot.create(:user, skip_tos_accepted: true, tos_accepted: false)

        post :register_third_party_guest, params: { source: 'etsy', order_id: '123455534343', user: { id: user.id, tos_accepted: false, email_preference: 'no_emails' } }

        expect(flash[:alert]).to eq('Sorry, there was a problem finding your order. If you feel this is in error, please contact us at sales@brickcitydepot.com')
        expect(response).to render_template('third_party_guest_registration')
      end
    end

    context 'where user record is not valid' do
      it 'should render third_party_guest_registration and flash an alert' do
        request.env['devise.mapping'] = Devise.mappings[:user]
        order = FactoryBot.create(:order)
        FactoryBot.create(:third_party_receipt, order:, source: 'etsy', third_party_receipt_identifier: '1234')
        user = FactoryBot.create(:user, skip_tos_accepted: true, tos_accepted: false)

        post :register_third_party_guest, params: { source: 'etsy', order_id: '1234', user: { id: user.id, tos_accepted: false, email_preference: 'no_emails' } }

        expect(flash[:alert]).to eq('You must accept the terms of service before you can proceed.')
        expect(response).to render_template('third_party_guest_registration')
      end
    end

    context 'where user record is valid' do
      it 'should find the user record and update it' do
        request.env['devise.mapping'] = Devise.mappings[:user]
        order = FactoryBot.create(:order)
        FactoryBot.create(:third_party_receipt, order:, source: 'etsy', third_party_receipt_identifier: '1234')
        user = FactoryBot.create(:user, skip_tos_accepted: true, tos_accepted: false, email_preference: 'important_emails')

        post :register_third_party_guest, params: { source: 'etsy', order_id: '1234', user: { id: user.id, tos_accepted: true, email_preference: 'no_emails' } }

        user.reload
        expect(user.email_preference).to eq('no_emails')
        expect(user.tos_accepted).to eq(true)
        expect(response).to redirect_to("/guest_downloads?source=etsy&order_id=1234&u=#{user.guid}")
      end
    end
  end
end
