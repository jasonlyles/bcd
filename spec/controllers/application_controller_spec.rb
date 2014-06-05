require 'spec_helper'

describe ApplicationController do
  describe "set_new_cart" do
    it "sets the cart user_id to current_user.id if there is a current_user" do
      @user = FactoryGirl.create(:user)
      sign_in @user
      controller.send(:set_new_cart)

      assigns(:cart).user_id.should eq(@user.id)
    end
  end

  describe "find_cart" do
    it "should find the cart by session ID" do
      cart = FactoryGirl.create(:cart)
      session[:cart_id] = cart.id
      Cart.should_receive(:find).with(session[:cart_id]).and_return(cart)
      controller.send(:find_cart)

      cart.should == assigns(:cart)
    end

    it "should assign a cart in session to a current user if there is a current user" do
      @user = FactoryGirl.create(:user)
      cart = FactoryGirl.create(:cart)
      sign_in @user
      session[:cart_id] = cart.id
      Cart.should_receive(:find).with(session[:cart_id]).and_return(cart)
      controller.send(:find_cart)

      assigns(:cart).user_id.should == @user.id
    end

    it "should find cart for the current user if there is none in session and there is one in the database" do
      @user = FactoryGirl.create(:user)
      cart = FactoryGirl.create(:cart, :user_id => @user.id)
      sign_in @user
      controller.send(:find_cart)

      assigns(:cart).id.should == cart.id
      session[:cart_id].should == cart.id
    end

    it "should create a cart in session and database for a current user if there is no cart in session or db" do
      @user = FactoryGirl.create(:user)
      sign_in @user
      Cart.should_receive(:users_most_recent_cart).and_return(nil)
      controller.send(:find_cart)

      assigns(:cart).user_id.should == @user.id
    end

    it "should create a cart in session if there isn't one and there is no current user" do
      assigns(:cart).should be_nil
      session[:cart_id].should be_nil

      controller.send(:find_cart)

      assigns(:cart).should_not be_nil
      session[:cart_id].should_not be_nil
    end
  end

  describe "get_categories" do
    it "should get live categories" do
      FactoryGirl.create(:category)
      controller.send(:get_categories)

      assigns(:categories).should_not be_nil
    end
  end

  describe 'get_categories_for_admin' do
    it "should populate @categories" do
      FactoryGirl.create(:category)
      controller.send(:get_categories_for_admin)

      assigns(:categories).should == [["City", 1]]
    end
  end

  describe "set_users_referrer_code" do
    it "should set the users referrer code" do
      controller.params[:referrer_code] = 'blar'
      controller.send(:set_users_referrer_code)

      session[:referrer_code].should == 'blar'
    end
  end

  describe "not_found" do
    it "should return a 404 page" do
      controller.should_receive(:render).with(:file => "#{Rails.root}/public/404.html", :status => :not_found, :layout => false)

      controller.send(:not_found)
    end
  end

  describe "set_guest_status" do
    it 'should set session[:guest] to true' do
      session[:guest].should be_nil
      controller.send(:set_guest_status)

      session[:guest].should eq(true)
    end
  end

  describe "clean_up_guest" do
    it "should update the cart by setting user_id to nil" do
      @user = FactoryGirl.create(:user)
      @cart = FactoryGirl.create(:cart, :user_id => @user.id)
      session[:guest] = @user.id
      controller.send(:clean_up_guest)

      @cart.reload
      @cart.user_id.should eq(nil)
    end

    it "should destroy the user record associated with the guest" do
      @user = FactoryGirl.create(:user)
      @cart = FactoryGirl.create(:cart, :user_id => @user.id)
      session[:guest] = @user.id
      controller.send(:clean_up_guest)

      expect{User.find(@user.id)}.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should delete guest from session" do
      @user = FactoryGirl.create(:user)
      @cart = FactoryGirl.create(:cart, :user_id => @user.id)
      session[:guest] = @user.id
      controller.send(:clean_up_guest)

      session[:guest].should be_nil
    end
  end
end