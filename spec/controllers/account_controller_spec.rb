require 'spec_helper'

describe AccountController do

  before do
    @user ||= FactoryGirl.create(:user)
  end

  describe "order_history" do
    it "should return all orders in order history, even if they don't have a status" do
      order1 = FactoryGirl.create(:order)
      order2 = FactoryGirl.create(:order, :status => 'INVALID')
      order3 = FactoryGirl.create(:order, :status => nil)
      sign_in @user
      get :order_history

      assigns(:orders).length.should == 3
    end
  end

  describe "order" do
    it "should return an order given a request ID" do
      order = FactoryGirl.create(:order, :request_id => '1234566778', :transaction_id => '555')
      sign_in @user
      get :order, :request_id => '1234566778'

      assigns(:order).transaction_id.should == '555'
    end

    it "should set order to nil if order could not be found by request_id and user_id" do
      order = FactoryGirl.create(:order, :user_id => 3000, :request_id => '12344321')
      sign_in @user
      get :order, :request_id => '12344321'

      assigns(:order).should be_nil
    end
  end

  describe "GET index" do
    it "should redirect to login page if there is no user" do
      get :index

      response.should redirect_to('/users/sign_in')
    end

    it "should take user to index page if there is a user" do
      sign_in @user
      get :index

      response.should be_success
    end

    it "should get only completed orders for display" do
      order1 = FactoryGirl.create(:order)
      order2 = FactoryGirl.create(:order, :status => 'INVALID')
      sign_in @user
      get :index

      assigns(:orders).length.should == 1
    end
  end

  describe 'unsubscribe_from_emails' do
    context 'cannot find user based on guid and unsubscribe_token passed in' do
      it 'should render still_subscribed' do
        get :unsubscribe_from_emails, :id => 'fake', :unsubscribe_token => 'also_fake'

        response.should render_template(:still_subscribed)
      end
    end

    context 'finds user based on guid and unsubscribe_token passed in' do
      context 'and user cannot be saved' do
        it 'should render still_subscribed' do
          @user = FactoryGirl.create(:user, :unsubscribe_token => 'chimichangas', :email_preference => 2, :email => 'ralph@mil.mil', :guid => 'guid')
          User.any_instance.should_receive(:save).and_return(false)
          get :unsubscribe_from_emails, :id => @user.guid, :token => @user.unsubscribe_token

          @user.reload
          @user.email_preference.should eq(2)
          response.should render_template(:still_subscribed)
        end
      end

      context 'and user can be saved' do
        it 'should render unsubscribed' do
          @user = FactoryGirl.create(:user, :unsubscribe_token => 'chimichangas', :email_preference => 2, :email => 'mil@ralph.ralph', :guid => 'guid')
          get :unsubscribe_from_emails, :id => @user.guid, :token => @user.unsubscribe_token

          @user.reload
          @user.email_preference.should eq(0)
          response.should render_template(:unsubscribed)
        end
      end
    end
  end
end
