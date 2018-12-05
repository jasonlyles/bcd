require 'spec_helper'

describe AccountController do
  before do
    @user ||= FactoryGirl.create(:user)
  end

  describe 'order_history' do
    it "should return all orders in order history, even if they don't have a status" do
      order1 = FactoryGirl.create(:order)
      order2 = FactoryGirl.create(:order, status: 'INVALID')
      order3 = FactoryGirl.create(:order, status: nil)
      sign_in @user
      get :order_history

      expect(assigns(:orders).length).to eq(3)
    end
  end

  describe 'GET index' do
    it 'should redirect to login page if there is no user' do
      get :index

      expect(response).to redirect_to('/users/sign_in')
    end

    it 'should take user to index page if there is a user' do
      sign_in @user
      get :index

      expect(response).to be_success
    end

    it 'should get only completed orders for display' do
      product_type = FactoryGirl.create(:product_type)
      category = FactoryGirl.create(:category)
      subcat = FactoryGirl.create(:subcategory)
      product = FactoryGirl.create(:product)
      order1 = FactoryGirl.create(:order_with_line_items)
      order2 = FactoryGirl.create(:order, status: 'INVALID')
      sign_in @user
      get :index

      expect(assigns(:products).size).to eq(1)
    end
  end

  describe 'unsubscribe_from_emails' do
    context 'cannot find user based on guid and unsubscribe_token passed in' do
      it 'should render still_subscribed' do
        get :unsubscribe_from_emails, id: 'fake', unsubscribe_token: 'also_fake'

        expect(response).to render_template(:still_subscribed)
      end
    end

    context 'finds user based on guid and unsubscribe_token passed in' do
      context 'and user cannot be saved' do
        it 'should render still_subscribed' do
          @user = FactoryGirl.create(:user, unsubscribe_token: 'chimichangas', email_preference: 2, email: 'ralph@mil.mil', guid: 'guid')
          allow_any_instance_of(User).to receive(:save).and_return(false)
          get :unsubscribe_from_emails, id: @user.guid, token: @user.unsubscribe_token

          @user.reload
          expect(@user.email_preference).to eq(2)
          expect(response).to render_template(:still_subscribed)
        end
      end

      context 'and user can be saved' do
        it 'should render unsubscribed' do
          @user = FactoryGirl.create(:user, unsubscribe_token: 'chimichangas', email_preference: 2, email: 'mil@ralph.ralph', guid: 'guid')
          get :unsubscribe_from_emails, id: @user.guid, token: @user.unsubscribe_token

          @user.reload
          expect(@user.email_preference).to eq(0)
          expect(response).to render_template(:unsubscribed)
        end
      end
    end
  end
end
