require 'spec_helper'

describe Admin::UsersController do
  before do
    @radmin ||= FactoryBot.create(:radmin)
    @user = FactoryBot.create(:user)
  end

  before(:each) do
    sign_in @radmin
  end

  describe 'GET #index' do
    it 'assigns all users as @users' do
      get :index

      expect(assigns(:users)).to eq([@user])
    end
  end

  describe 'GET #show' do
    it 'should return a user given the users ID' do
      sign_in @radmin
      get :show, params: { id: @user.id }

      expect(assigns(:user).id).to eq(@user.id)
    end
  end

  describe 'change_user_status' do
    it "should change user's status" do
      sign_in @radmin
      get :change_user_status, params: { id: @user.id, user: { account_status: 'C' } }, format: :js, xhr: true
      @user = User.find(@user.id)

      expect(@user.account_status).to eq('C')
    end
  end

  describe 'become' do
    it "should login the user given the user's ID" do
      sign_in @radmin
      get :become, params: { id: @user.id }

      @user = User.find(@user.id)
      expect(@user.sign_in_count).to eq(1)
    end
  end

  describe 'reset_users_downloads' do
    it 'should reset a users downloads remaining' do
      sign_in @radmin
      product = FactoryBot.create(:product_with_associations)
      download = FactoryBot.create(:download, user_id: @user.id, product_id: product.id, count: 2, remaining: 3)
      post :reset_users_downloads, params: { id: @user.id, download: { product_id: product.id } }
      download.reload

      expect(download.count).to eq(2)
      expect(download.remaining).to eq(MAX_DOWNLOADS)
    end
  end
end
