require 'spec_helper'

describe ApplicationController do
  describe "create_cart" do
    it "calls use_older_cart_or_update_existing_cart if there is a current_user" do
      @user = FactoryGirl.create(:user)
      sign_in @user
      controller.should_receive(:use_older_cart_or_update_existing_cart)
      controller.send(:create_cart)
    end

    it "should create a new @cart with no user_id if there is no current customer" do
      controller.send(:create_cart)

      expect(assigns(:cart).user_id).to be_nil
    end
  end

  describe "find_cart" do
    it "should find the cart by session ID" do
      cart = FactoryGirl.create(:cart)
      session[:cart_id] = cart.id
      Cart.should_receive(:where).and_return([cart])
      controller.send(:find_cart)

      cart.should == assigns(:cart)
    end

    context 'and there is a user' do
      it "should get a users existing cart if the cart # in session can't be found in the database" do
        @user = FactoryGirl.create(:user)
        @cart = FactoryGirl.create(:cart, user_id: @user.id)
        sign_in @user
        session[:cart_id] = 15000 #non-existent
        Cart.should_receive(:where).and_return([nil])
        Cart.should_receive(:users_most_recent_cart).and_return(@cart)
        controller.send(:find_cart)

        expect(assigns(:cart)).not_to be_nil
        expect(session[:cart_id]).to eq(@cart.id)
      end

      it "should get a users existing cart if there is no cart # in session" do
        @user = FactoryGirl.create(:user)
        @cart = FactoryGirl.create(:cart, user_id: @user.id)
        sign_in @user
        Cart.should_receive(:where).and_return([nil])
        Cart.should_receive(:users_most_recent_cart).and_return(@cart)
        controller.send(:find_cart)

        expect(assigns(:cart)).not_to be_nil
        expect(session[:cart_id]).to eq(@cart.id)
      end

      it "should assign a cart in session to a current user" do
        @user = FactoryGirl.create(:user)
        @cart = FactoryGirl.create(:cart)
        sign_in @user
        session[:cart_id] = @cart.id
        Cart.should_receive(:where).and_return([@cart])
        Cart.should_receive(:users_most_recent_cart).and_return(nil)
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

      it "should not find a cart for a current user if there is no cart in session or db" do
        @user = FactoryGirl.create(:user)
        sign_in @user
        Cart.should_receive(:users_most_recent_cart).and_return(nil)
        controller.send(:find_cart)

        assigns(:cart).should be_nil
      end
    end

    context 'and there is no user logged in' do
      it "should not set a new cart if the cart # in session can't be found in the database and there is no user" do
        @user = FactoryGirl.create(:user)
        session[:cart_id] = 15000 #non-existent
        Cart.should_receive(:where).and_return([nil])
        controller.send(:find_cart)

        expect(assigns(:cart)).to be_nil
      end
    end

    context 'a cart that starts with no user logged in and has items in it' do
      it 'should not get an older cart belonging to the user when user logs in' do
        @user = FactoryGirl.create(:user)
        @cart = FactoryGirl.create(:cart, user_id: @user.id)
        @cart_with_items = FactoryGirl.create(:cart_with_cart_items)
        session[:cart_id] = @cart_with_items.id
        sign_in @user
        controller.send(:find_cart)

        expect(assigns(:cart).id).to eq(@cart_with_items.id)
      end
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

    it "should delete guest from session" do
      @user = FactoryGirl.create(:user)
      @cart = FactoryGirl.create(:cart, :user_id => @user.id)
      session[:guest] = @user.id
      controller.send(:clean_up_guest)

      session[:guest].should be_nil
    end
  end
end